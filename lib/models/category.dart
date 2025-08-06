class Category {
  final int id;
  final String name;
  final String description;
  final String icon;
  final int orderIndex;

  Category({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.orderIndex,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      icon: json['icon'],
      orderIndex: json['order_index'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'order_index': orderIndex,
    };
  }
}