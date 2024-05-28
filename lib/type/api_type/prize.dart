class Prize {
  final int id;
  String name;
  String description;
  String createdAt;
  double price;
  String image;
  int stock;
  double cost;

  Prize({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
    required this.price,
    required this.image,
    required this.stock,
    required this.cost
  });

  factory Prize.fromJson(Map<String, dynamic> json) {
    return Prize(
      id: int.parse(json['pri_id']),
      name: json['pri_name'] as String,
      description: json['pri_description'] as String,
      createdAt: json['pri_created_at'] as String,
      price: double.parse(json['pri_price']),
      image: json['pri_image'] ?? "",
      stock: int.parse(json['pri_stock']),
      cost: double.parse(json["pri_cost"])
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pri_id': id.toString(),
      'pri_name': name.toString(),
      'pri_description': description.toString(),
      'pri_created_at': createdAt.toString(),
      'pri_price': price.toString(),
      'pri_image': image.toString(),
      'pri_stock': stock.toString(),
      'pri_cost': cost.toString(),
    };
  }
}