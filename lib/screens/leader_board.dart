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
      bool isGrowing = (user.progress).toString().startsWith('+');

    return Container(
      padding: const EdgeInsets.all(22.0),
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.indigo.shade200,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        // crossAxisAlignment: CrossAxisAlignment.start,
        // mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'My progress',
            style: TextStyle(
              fontSize: 18,
            )
          ),
           const SizedBox(height: 12.0),
           Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(radius: 25.0, backgroundImage: NetworkImage(user.photoUrl)),
              const SizedBox(width: 12.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Rank ${user.rank}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)),
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              (user.progress),
              style: TextStyle(
                color: isGrowing ? Colors.green.shade900 : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            TweenAnimationBuilder<double>(
              duration: const Duration(seconds: 1),
              tween: Tween<double>(begin: 0, end: 1),
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, isGrowing ? -value * 4 : value * 4),
                  child: Icon(
                    isGrowing ? Icons.trending_up : Icons.trending_down,
                    color: isGrowing ? Colors.green.shade900 : Colors.red,
                    size: 24,
                  ),
                );
              },
            ),
          ],
        ),
              ),
            ],
          ),
        ],
      ),

        ],
      )
    );
  }



  Widget _buildLeaderboardTile(UserData user) {
      bool isGrowing = (user.progress).toString().startsWith('+');

    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    decoration: BoxDecoration(
      color: user.isCurrentUser ? const Color.fromARGB(223, 125, 254, 230) : Colors.white,
      borderRadius: BorderRadius.circular(8.0),
      border: Border.all(color: user.isCurrentUser ? Colors.amber.shade900 : Colors.black, width: 1),
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
                  Text('Rank ${user.rank}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)),
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              (user.progress),
              style: TextStyle(
                color: isGrowing ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            TweenAnimationBuilder<double>(
              duration: const Duration(seconds: 1),
              tween: Tween<double>(begin: 0, end: 1),
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, isGrowing ? -value * 4 : value * 4),
                  child: Icon(
                    isGrowing ? Icons.trending_up : Icons.trending_down,
                    color: isGrowing ? Colors.green : Colors.red,
                    size: 24,
                  ),
                );
              },
            ),
          ],
        ),
              ),
            ],
          ),
        ],
      ),
    );
  }

// Widget _buildLeaderboardTile(UserData user) {
//   // Extract direction from progress string
//   print('pppppppppppppppppppppppppppppppppppppp,${user.progress}');
//   bool isGrowing = (user.progress).toString().startsWith('+');
  
//   return Container(
//     margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
    // decoration: BoxDecoration(
    //   color: user.isCurrentUser ? Colors.amber.withOpacity(0.1) : Colors.white,
    //   borderRadius: BorderRadius.circular(8.0),
    //   border: Border.all(color: user.isCurrentUser ? Colors.amber : Colors.grey.shade200, width: 1.5),
    // ),
//     child: ListTile(
//       leading: CircleAvatar(radius: 20.0, backgroundImage: NetworkImage(user.photoUrl)),
//       title: Text(user.name, style: TextStyle(fontWeight: user.isCurrentUser ? FontWeight.bold : FontWeight.normal)),
//       subtitle: Text('Rank: ${user.rank}  |  Score: ${user.score}'),
//       trailing: SizedBox(
//         width: 100.0,
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.end,
//           children: [
//             Text(
//               (user.progress),
//               style: TextStyle(
//                 color: isGrowing ? Colors.green : Colors.red,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(width: 8),
//             TweenAnimationBuilder<double>(
//               duration: const Duration(seconds: 1),
//               tween: Tween<double>(begin: 0, end: 1),
//               builder: (context, value, child) {
//                 return Transform.translate(
//                   offset: Offset(0, isGrowing ? -value * 4 : value * 4),
//                   child: Icon(
//                     isGrowing ? Icons.trending_up : Icons.trending_down,
//                     color: isGrowing ? Colors.green : Colors.red,
//                     size: 24,
//                   ),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     ),
//   );
// }
}
