import '../models/friend_model.dart';

class HomeController {
  // Simulated list of friends
  List<Friend> fetchFriends() {
    return [
      Friend(
        id: '1',
        name: 'John Doe',
        profilePicture: 'assets/images/john_doe.png',
        upcomingEvents: 2,
      ),
      Friend(
        id: '2',
        name: 'Jane Smith',
        profilePicture: 'assets/images/jane_smith.png',
        upcomingEvents: 0,
      ),
    ];
  }

  // Simulated search functionality
  List<Friend> searchFriends(String query, List<Friend> friends) {
    return friends
        .where((friend) => friend.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}
