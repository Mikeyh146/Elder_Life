class Pod {
  final String id;
  final String name;

  Pod({required this.id, required this.name});

  factory Pod.fromJson(Map<String, dynamic> json) {
    return Pod(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
  };
}
