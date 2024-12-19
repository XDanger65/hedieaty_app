class Gift {
  final String id;
  final String name;
  final bool isPledged;

  Gift({required this.id, required this.name, this.isPledged = false});

  Map<String, dynamic> toMap() {
    return {'name': name, 'isPledged': isPledged};
  }

  static Gift fromMap(String id, Map<String, dynamic> map) {
    return Gift(
      id: id,
      name: map['name'],
      isPledged: map['isPledged'] ?? false,
    );
  }
}
