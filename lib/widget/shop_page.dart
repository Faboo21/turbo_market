import 'dart:async';
import 'package:flutter/material.dart';
import 'package:turbo_market/api/api_request.dart';
import 'package:turbo_market/private/config.dart';
import 'package:turbo_market/type/prize.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({super.key, required this.scroll});

  final bool scroll;

  @override
  State<ShopPage> createState() => _ShopState();
}

class _ShopState extends State<ShopPage> {
  final ScrollController _scrollController = ScrollController();
  Timer? _timer;
  final double _scrollSpeed = 30;
  List<Prize> prizesList = [];
  bool _scrollingDown = true;

  @override
  void initState() {
    super.initState();
    loadPrizes();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      double maxScrollExtent = _scrollController.position.maxScrollExtent;
      double minScrollExtent = _scrollController.position.minScrollExtent;
      double currentScroll = _scrollController.position.pixels;
      double scrollIncrement = _scrollSpeed * 0.05;

      if (_scrollingDown) {
        if (currentScroll + scrollIncrement >= maxScrollExtent) {
          _scrollingDown = false;
        } else {
          _scrollController.animateTo(
            currentScroll + scrollIncrement,
            duration: const Duration(milliseconds: 50),
            curve: Curves.linear,
          );
        }
      } else {
        if (currentScroll - scrollIncrement <= minScrollExtent) {
          _scrollingDown = true;
        } else {
          _scrollController.animateTo(
            currentScroll - scrollIncrement,
            duration: const Duration(milliseconds: 50),
            curve: Curves.linear,
          );
        }
      }
    });
  }

  Future<void> loadPrizes() async {
    List<Prize> resList = await getAllPrizes();
    setState(() {
      prizesList = resList;
      if (widget.scroll) {
        _startAutoScroll();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: prizesList.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        controller: widget.scroll ? _scrollController : null,
        itemCount: prizesList.length,
        itemBuilder: (context, index) {
          Prize prize = prizesList[index];
          return ListTile(
            leading: AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Image.network(
                  prize.image,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    } else {
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
            title: Text(
              prize.name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: prize.stock == 0
                    ? Colors.red
                    : prize.stock <= 5
                    ? Colors.orangeAccent
                    : null,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 5),
                Text(
                  'Prix : ${prize.price * AppConfig.rate}ƒ',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Stock : ${prize.stock}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            trailing: prize.stock == 0
                ? const Icon(
              Icons.not_interested,
              color: Colors.red,
            )
                : prize.stock < 5
                ? const Icon(
              Icons.warning_amber,
              color: Colors.orangeAccent,
            )
                : null,
          );
        },
      ),
    );
  }
}
