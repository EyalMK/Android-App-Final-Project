import 'package:android_dev_final_project/models/book.dart';
import 'package:flutter/material.dart';
import 'package:android_dev_final_project/screens/books/books_list_screen.dart';
import 'package:android_dev_final_project/services/book_service.dart';
import 'package:android_dev_final_project/utils/theme.dart';
import 'package:android_dev_final_project/widgets/age_category_card.dart';

class AgeSelectionScreen extends StatelessWidget {
  const AgeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Peekabook'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose your child\'s age:',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Select an age group to find appropriate books for your child',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: Row(
                  children: [
                    // PDF Column
                    Expanded(
                      child: Column(
                        children: [
                          // PDF Icon Header
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Column(
                              children: [
                                Icon(
                                  Icons.picture_as_pdf,
                                  size: 40,
                                  color: Colors.red,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'PDF Books',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Age Category Cards
                          Expanded(
                            child: ListView(
                              children: [
                                AgeCategoryCard(
                                  title: 'Ages 0-4',
                                  description: 'Picture books, board books',
                                  color: AppTheme.age04Color,
                                  icon: Icons.child_care,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => BooksListScreen(
                                          ageGroup: BookService.ageGroup04,
                                          title: 'Ages 0-4 (PDF)',
                                          extension: bookExtensionToString(BookExtension.pdf)
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 12),
                                AgeCategoryCard(
                                  title: 'Ages 4-8',
                                  description: 'Early readers',
                                  color: AppTheme.age48Color,
                                  icon: Icons.face,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => BooksListScreen(
                                          ageGroup: BookService.ageGroup48,
                                          title: 'Ages 4-8 (PDF)',
                                          extension: bookExtensionToString(BookExtension.pdf)
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 12),
                                AgeCategoryCard(
                                  title: 'Ages 8-12',
                                  description: 'Chapter books',
                                  color: AppTheme.age812Color,
                                  icon: Icons.school,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => BooksListScreen(
                                          ageGroup: BookService.ageGroup812,
                                          title: 'Ages 8-12 (PDF)',
                                          extension: bookExtensionToString(BookExtension.pdf)
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Word Column
                    Expanded(
                      child: Column(
                        children: [
                          // Word Icon Header
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Column(
                              children: [
                                Icon(
                                  Icons.description,
                                  size: 40,
                                  color: Colors.blue,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Word Books',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Age Category Cards
                          Expanded(
                            child: ListView(
                              children: [
                                AgeCategoryCard(
                                  title: 'Ages 0-4',
                                  description: 'Picture books, board books',
                                  color: AppTheme.age04Color,
                                  icon: Icons.child_care,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => BooksListScreen(
                                          ageGroup: BookService.ageGroup04,
                                          title: 'Ages 0-4 (Word)',
                                          extension: bookExtensionToString(BookExtension.doc)
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 12),
                                AgeCategoryCard(
                                  title: 'Ages 4-8',
                                  description: 'Early readers',
                                  color: AppTheme.age48Color,
                                  icon: Icons.face,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => BooksListScreen(
                                          ageGroup: BookService.ageGroup48,
                                          title: 'Ages 4-8 (Word)',
                                          extension: bookExtensionToString(BookExtension.doc)
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 12),
                                AgeCategoryCard(
                                  title: 'Ages 8-12',
                                  description: 'Chapter books',
                                  color: AppTheme.age812Color,
                                  icon: Icons.school,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => BooksListScreen(
                                          ageGroup: BookService.ageGroup812,
                                          title: 'Ages 8-12 (Word)',
                                          extension: bookExtensionToString(BookExtension.doc)
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
