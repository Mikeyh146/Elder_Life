class Commander {
  final String id;
  final String name;
  final String imageUrl;

  Commander({
    required this.id,
    required this.name,
    required this.imageUrl,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'imageUrl': imageUrl,
      };

  factory Commander.fromJson(Map<String, dynamic> json) {
    return Commander(
      id: json['id'],
      name: json['name'],
      imageUrl: json['imageUrl'] ?? '',
    );
  }
}
