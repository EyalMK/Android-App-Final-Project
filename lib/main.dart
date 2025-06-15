import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/material.dart';
import 'package:android_dev_final_project/services/book_service.dart';
import 'package:android_dev_final_project/screens/age_selection/age_selection_screen.dart';
import 'package:android_dev_final_project/utils/theme.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
  );

  // Supabase for storage
  await Supabase.initialize(
    url: 'https://uqbkrmfekbeqbnowoapb.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVxYmtybWZla2JlcWJub3dvYXBiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDc1ODMzNzEsImV4cCI6MjA2MzE1OTM3MX0.yTZEy0wjc7GknfHpjvpX4bI9u_4MTzsqP-MweBA8qJM',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BookService(),
      child: MaterialApp(
        title: "Peekabook - Children's Books App",
        theme: AppTheme.theme,
        debugShowCheckedModeBanner: false,
        home: const AgeSelectionScreen(),
      ),
    );
  }
}
