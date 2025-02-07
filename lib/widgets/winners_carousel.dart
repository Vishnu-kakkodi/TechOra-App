import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class WinnersCarousel extends StatefulWidget {
  final List<Map<String, dynamic>> winners;

  const WinnersCarousel({Key? key, required this.winners}) : super(key: key);

  @override
  State<WinnersCarousel> createState() => _WinnersCarouselState();
}

class _WinnersCarouselState extends State<WinnersCarousel> {
  int _currentIndex = 0;

  Widget _getRankTrophy(String rank) {
    switch (rank) {
      case '1':
        return Icon(Icons.grade, color: Colors.amber, size: 40); // Gold
      case '2':
        return Icon(Icons.grade, color: Colors.grey, size: 40); // Silver
      case '3':
        return Icon(Icons.grade, color: Colors.brown, size: 40); // Bronze
      default:
        return Icon(Icons.star_border, size: 40); // Default if no rank
    }
  }

  Widget _getRankText(String rank) {
    switch (rank) {
      case '1':
        return Text(
          "Gold Winner",
          style: TextStyle(
            color: Colors.amber,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        );
      case '2':
        return Text(
          "Silver Winner",
          style: TextStyle(
            color: Colors.grey,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        );
      case '3':
        return Text(
          "Bronze Winner",
          style: TextStyle(
            color: Colors.brown,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        );
      default:
        return Text(
          "No Rank",
          style: TextStyle(fontSize: 14),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CarouselSlider.builder(
          itemCount: widget.winners.length,
          options: CarouselOptions(
            height: 170.0,
            enlargeCenterPage: true,
            autoPlay: true,
            viewportFraction: 0.85,
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
          itemBuilder: (context, index, _) {
            final winner = widget.winners[index];
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 5.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.purple[100],
                borderRadius: BorderRadius.circular(20.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 3,
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top section: Profile photo, Username, Rank, Trophy, Score
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Left side: Profile photo and Username
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundImage:
                                NetworkImage(winner['profilePhoto']),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                winner['userName'],
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "Rank: ${winner['rank']}",
                                style: TextStyle(
                                    color: Colors.blue.shade700, fontSize: 14),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // Right side: Trophy and Score
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _getRankTrophy(winner['rank']),
                          const SizedBox(height: 5),
                          Text(
                            "Score: ${winner['score']}",
                            style: TextStyle(color: Colors.blue.shade700),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Bottom section: Winner Text
                  _getRankText(winner['rank']),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
