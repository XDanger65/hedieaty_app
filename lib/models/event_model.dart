class Event {
  final String id;
  final String name;
  final String associatedGift;

  Event({
    required this.id,
    required this.name,
    required this.associatedGift,
  });

  factory Event.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Event(
      id: documentId,
      name: data['name'] ?? 'Unnamed Event',
      associatedGift: data['associatedGift'] ?? 'No Gift',
    );
  }
}
