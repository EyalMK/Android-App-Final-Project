import 'package:flutter/material.dart';
import 'package:android_dev_final_project/screens/auth/login_screen.dart';
import 'package:android_dev_final_project/services/theme_service.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _appVersion = '';
  bool _isDarkMode = false;
  bool _isSigningOut = false;

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _isDarkMode = Theme.of(context).brightness == Brightness.dark;
  }

  Future<void> _loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = '${packageInfo.version} (${packageInfo.buildNumber})';
    });
  }

  Future<void> _signOut() async {
    setState(() {
      _isSigningOut = true;
    });

    try {
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error signing out: $e')),
        );
      }
    } finally {
      setState(() {
        _isSigningOut = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeService>(context);
    final isDarkMode = themeProvider.isDarkMode;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // User profile section
          ...[
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: const Icon(Icons.person, color: Colors.white),
              ),
              title: Text('User'),
              subtitle: const Text('Account'),
            ),
            const Divider(),
          ],
          
          // App settings
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: const Text('Dark Mode'),
            trailing: Switch(
              value: isDarkMode,
              onChanged: (value) {
                themeProvider.toggleTheme(value);
              },
            )
          ),
          
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications settings not implemented in this demo')),
              );
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.storage),
            title: const Text('Storage'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Storage settings not implemented in this demo')),
              );
            },
          ),
          
          const Divider(),
          
          // About section
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Peekabook - Children\'s Books App',
                applicationVersion: _appVersion,
                applicationIcon: Icon(
                  Icons.menu_book_rounded,
                  size: 48,
                  color: Theme.of(context).colorScheme.primary,
                ),
                children: [
                  const Text(
                    'A Flutter application for uploading and downloading children\'s books, categorized by age groups.',
                  ),
                ],
              );
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Help & Support'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Help & Support not implemented in this demo')),
              );
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Privacy Policy'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Privacy Policy not implemented in this demo')),
              );
            },
          ),
          
          const Divider(),
          
          // Sign out
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: Text(
              'Sign Out',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: _isSigningOut ? null : _signOut,
          ),
          
          if (_isSigningOut)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
