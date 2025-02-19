import 'package:flutter/material.dart';
import 'package:project/models/leader_board_model.dart';
import 'package:project/screens/leader_board.dart';
import 'package:project/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LeaderboardProvider with ChangeNotifier {
  List<UserData> _allUsers = [];
  List<UserData> _displayedUsers = [];
  UserData? _currentUser;
  bool _isLoading = false;
  String _errorMessage = '';

  List<UserData> get displayedUsers => _displayedUsers;
  UserData? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // Method to fetch data from API
// Future<void> fetchLeaderboardData() async {
//   _isLoading = true;
//   _errorMessage = '';
//   notifyListeners();

//   try {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? currentUserId = prefs.getString('userId');
//     Map<String, dynamic> response = await ApiService.fetchLeaderBoard();
//     print('jjjjjjjjjjjjjjjjjjjj,${response}');

//     if (201 == 201) {
//       final List<dynamic> usersData = response['users'];

//       _allUsers = usersData.map((userData) {
//         final quizProgress = userData['quizProgress'] ?? {};

//         return UserData(
//           rank: int.tryParse(quizProgress['rank'].toString()) ?? 0,
//           name: userData['userName'] ?? 'Unknown',
//           photoUrl: userData['profilePhoto'] ?? 'https://via.placeholder.com/150', // Update to real image field if available
//           score: quizProgress['score'] ?? 0,
//           progress: double.tryParse(quizProgress['progress'].toString().replaceAll('+', '')) ?? 0.0,
//           isCurrentUser: quizProgress['userId'] == currentUserId, // You may need to check against the logged-in user's ID
//         );
//       }).toList();

//       // Sort users by rank
//       _allUsers.sort((a, b) => a.rank.compareTo(b.rank));

//       _displayedUsers = List.from(_allUsers);
//     } else {
//       _errorMessage = response['message'] ?? 'Failed to load leaderboard';
//     }
//   } catch (e) {
//     _errorMessage = 'Error: $e';
//   } finally {
//     _isLoading = false;
//     notifyListeners();
//   }
// }

  Future<void> fetchLeaderboardData() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      // Fetch the current user ID from SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? currentUserId = prefs.getString('userId');
      print('Logged-in User ID: $currentUserId');

      // Fetch leaderboard data from API
      Map<String, dynamic> response = await ApiService.fetchLeaderBoard();
      print('API Response: $response');

      if (200 == 200) {
        // Ensure correct status check
        final List<dynamic> usersData = response['users'];

        _allUsers = usersData.map((userData) {
          final quizProgress = userData['quizProgress'] ?? {};
          String userId =
              userData['_id'] ?? ''; // Ensure correct key for user ID
          return UserData(
            rank: int.tryParse(quizProgress['rank'].toString()) ?? 0,
            name: userData['userName'] ?? 'Unknown',
            photoUrl:
                userData['profilePhoto'] ?? 'https://via.placeholder.com/150',
            score: quizProgress['score'] ?? 0,
            progress: double.tryParse(
                    quizProgress['progress'].toString().replaceAll('+', '')) ??
                0.0,
            isCurrentUser: userId ==
                currentUserId, // Compare API user ID with logged-in user ID
          );
        }).toList();

        // Sort users by rank
        _allUsers.sort((a, b) => a.rank.compareTo(b.rank));

        // Set `_currentUser` explicitly
        try {
          _currentUser = _allUsers.firstWhere((user) => user.isCurrentUser);
        } catch (e) {
          _currentUser = null; // If no match, set to null
        }

        _displayedUsers = List.from(_allUsers);
      } else {
        _errorMessage = response['message'] ?? 'Failed to load leaderboard';
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Method to search users
  void searchUsers(String query) {
    if (query.isEmpty) {
      _displayedUsers = List.from(_allUsers);
    } else {
      _displayedUsers = _allUsers
          .where(
              (user) => user.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }
}
