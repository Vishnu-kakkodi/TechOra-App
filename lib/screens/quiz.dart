import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project/models/quiz_model.dart';
import 'package:project/providers/quiz_provider.dart';
import 'package:project/screens/quiz_display.dart';
import 'package:provider/provider.dart';

class QuizListingScreen extends StatefulWidget {
  const QuizListingScreen({Key? key}) : super(key: key);

  @override
  State<QuizListingScreen> createState() => _QuizListingScreenState();
}

class _QuizListingScreenState extends State<QuizListingScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedSort = 'newest';
  String _selectedFilter = '';

  @override
  void initState() {
    super.initState();
    // Fetch quiz data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<QuizListProvider>(context, listen: false).fetchQuizData(
          _searchController.text, _selectedSort, _selectedFilter);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
final quizProvider = Provider.of<QuizListProvider>(context);
    final departments =
        quizProvider.departments.map((item) => item.toString()).toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Quizzes'),
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildFilterSection(departments),
          Expanded(
            child: Consumer<QuizListProvider>(
              builder: (context, quizProvider, child) {
                if (quizProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (quizProvider.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Error: ${quizProvider.errorMessage}',
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            quizProvider.fetchQuizData(_searchController.text,
                                _selectedSort, _selectedFilter);
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (quizProvider.quizzes.isEmpty) {
                  return const Center(
                    child: Text(
                      'No quizzes available',
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: quizProvider.quizzes.length,
                  itemBuilder: (context, index) {
                    final quiz = quizProvider.quizzes[index];
                    return _buildQuizCard(quiz);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(List<String> departments) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search quizzes...',
              prefixIcon: const Icon(Icons.search),
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.blue.shade400),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            onChanged: (value) {
              Provider.of<QuizListProvider>(context, listen: false)
                  .fetchQuizData(
                      _searchController.text, _selectedSort, _selectedFilter);
            },
          ),
          const SizedBox(height: 12),

          // Filter and Sort
          Row(
            children: [
              // Filter Dropdown
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Department',
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  value: departments.contains(_selectedFilter)
                      ? _selectedFilter
                      : 'all', // Fallback to 'all' if the value is invalid
                  items: [
                    const DropdownMenuItem(
                        value: 'all', child: Text('All Departments')),
                    ...departments.map((dept) => DropdownMenuItem(
                          value: dept, // Use the department string directly
                          child: Text(dept), // Display department name
                        )),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedFilter = value!;
                    });
                    Provider.of<QuizListProvider>(context, listen: false)
                        .fetchQuizData(_searchController.text, _selectedSort,
                            _selectedFilter);
                  },
                ),
              ),
              const SizedBox(width: 12),

              // Sort Dropdown
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Sort By',
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  value:
                      _selectedSort, // Ensure this matches one of the DropdownMenuItem values
                  items: const [
                    DropdownMenuItem(
                        value: 'newest',
                        child: Text('Latest')), // ✅ Match this exactly
                    DropdownMenuItem(
                        value: 'oldest',
                        child: Text('Oldest')), // ✅ Match this exactly
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedSort = value!;
                    });
                    Provider.of<QuizListProvider>(context, listen: false)
                        .fetchQuizData(_searchController.text, _selectedSort,
                            _selectedFilter);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuizCard(Quiz quiz) {
    // Mock data for fields not in your API response
    final DateTime endDate = DateTime.now().add(const Duration(days: 5));
    final int durationMinutes = 60;

    // Format the date
    final dateFormat = DateFormat('MMM dd, yyyy');
    final String formattedEndDate = dateFormat.format(endDate);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quiz icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child:
                      Icon(Icons.quiz, color: Colors.blue.shade700, size: 28),
                ),
                const SizedBox(width: 16),

                // Quiz details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        quiz.title ?? 'Unknown Quiz',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(Icons.school,
                          quiz.department ?? 'Unknown Department'),
                      const SizedBox(height: 4),
                      _buildInfoRow(Icons.location_on,
                          quiz.collegeName ?? 'Unknown Institution'),
                    ],
                  ),
                ),
              ],
            ),

            const Divider(height: 24),

            // Additional quiz info
            Row(
              children: [
                Expanded(
                  child: _buildInfoRow(
                    Icons.timer,
                    'Duration: $durationMinutes mins',
                    iconColor: Colors.orange.shade700,
                  ),
                ),
                Expanded(
                  child: _buildInfoRow(
                    Icons.event_available,
                    'Ends: $formattedEndDate',
                    iconColor: Colors.red.shade700,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Start quiz button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuizParticipationScreen(
                        quizData: quiz,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Start Quiz',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, {Color? iconColor}) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: iconColor ?? Colors.grey.shade700,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.grey.shade800,
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
