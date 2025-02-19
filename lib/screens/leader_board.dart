import 'package:flutter/material.dart';
import 'package:project/models/leader_board_model.dart';
import 'package:project/providers/leader_board_provider.dart';
import 'package:provider/provider.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({Key? key}) : super(key: key);

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<LeaderboardProvider>(context, listen: false).fetchLeaderboardData());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        centerTitle: true,
        backgroundColor: Colors.indigo,
      ),
      body: Consumer<LeaderboardProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.errorMessage.isNotEmpty) {
            return Center(child: Text(provider.errorMessage));
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search players...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  onChanged: provider.searchUsers,
                ),
              ),

              if (provider.currentUser != null)
                _buildCurrentUserCard(provider.currentUser!),

              Expanded(
                child: ListView.builder(
                  itemCount: provider.displayedUsers.length,
                  itemBuilder: (context, index) {
                    return _buildLeaderboardTile(provider.displayedUsers[index]);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCurrentUserCard(UserData user) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.indigo.shade50,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(radius: 25.0, backgroundImage: NetworkImage(user.photoUrl)),
              const SizedBox(width: 12.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Rank #${user.rank}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)),
                  Text('Score: ${user.score}', style: const TextStyle(fontSize: 14.0)),
                ],
              ),
            ],
          ),
          Column(
            children: [
              const Text('Progress', style: TextStyle(fontSize: 14.0)),
              SizedBox(
                width: 100.0,
                child: LinearProgressIndicator(
                  value: user.progress,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.indigo),
                ),
              ),
              Text('${(user.progress * 100).toInt()}%', style: const TextStyle(fontSize: 12.0)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardTile(UserData user) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: user.isCurrentUser ? Colors.amber.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: user.isCurrentUser ? Colors.amber : Colors.grey.shade200, width: 1.5),
      ),
      child: ListTile(
        leading: CircleAvatar(radius: 20.0, backgroundImage: NetworkImage(user.photoUrl)),
        title: Text(user.name, style: TextStyle(fontWeight: user.isCurrentUser ? FontWeight.bold : FontWeight.normal)),
        subtitle: Text('Rank: #${user.rank}  |  Score: ${user.score}'),
        trailing: SizedBox(
          width: 100.0,
          child: LinearProgressIndicator(
            value: user.progress,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(user.rank == 1 ? Colors.amber.shade700 : Colors.indigo),
          ),
        ),
      ),
    );
  }
}
