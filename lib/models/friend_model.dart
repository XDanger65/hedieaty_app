class Friend {
  final String id;
  final String name;
  final String profilePicture;
  final int upcomingEvents;

  Friend({
    required this.id,
    required this.name,
    required this.profilePicture,
    this.upcomingEvents = 0,
  });
}
