class Market {
  String id;
  String name;

  Market({required this.id, required this.name});

  Market.fromMap(Map<String, dynamic> map)
      : id = map["id"],
        name = map["name"];

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
    };
  }
}
