class UserData {
  final int rank;
  final String name;
  final String photoUrl;
  final int score;
  final double progress; // From 0.0 to 1.0
  final bool isCurrentUser;

  UserData({
    required this.rank,
    required this.name,
    required this.photoUrl,
    required this.score,
    required this.progress,
    this.isCurrentUser = false,
  });

  factory UserData.fromJson(Map<String, dynamic> json, int currentUserRank) {
    return UserData(
      rank: json['rank'] ?? 0,
      name: json['name'] ?? 'Unknown',
      photoUrl: json['profilePhoto'] ?? 'https://via.placeholder.com/150',
      score: json['score'] ?? 0,
      progress: json['progress'] ?? 0.0,
      isCurrentUser: json['userId'] == currentUserRank, // Assuming current user is identified by rank
    );
  }
}