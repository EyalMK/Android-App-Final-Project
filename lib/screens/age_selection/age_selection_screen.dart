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
                child: GridView.count(
                  crossAxisCount: 1,
                  childAspectRatio: 2.5,
                  mainAxisSpacing: 16,
                  children: [
                    AgeCategoryCard(
                      title: 'Ages 0-4',
                      description: 'Picture books, board books, and simple stories',
                      color: AppTheme.age04Color,
                      icon: Icons.child_care,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BooksListScreen(
                              ageGroup: BookService.ageGroup04,
                              title: 'Ages 0-4',
                            ),
                          ),
                        );
                      },
                    ),
                    AgeCategoryCard(
                      title: 'Ages 4-8',
                      description: 'Early readers and chapter books',
                      color: AppTheme.age48Color,
                      icon: Icons.face,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BooksListScreen(
                              ageGroup: BookService.ageGroup48,
                              title: 'Ages 4-8',
                            ),
                          ),
                        );
                      },
                    ),
                    AgeCategoryCard(
                      title: 'Ages 8-12',
                      description: 'Chapter books and middle-grade novels',
                      color: AppTheme.age812Color,
                      icon: Icons.school,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BooksListScreen(
                              ageGroup: BookService.ageGroup812,
                              title: 'Ages 8-12',
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
      ),
    );
  }
}
