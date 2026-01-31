import 'dart:developer';
import 'package:baby_binder/providers/app_state.dart';
import 'package:baby_binder/providers/hive_provider.dart';
import 'package:baby_binder/screens/child_selection_page.dart';
import 'package:baby_binder/screens/child_settings_page.dart';
import 'package:baby_binder/screens/child_story_page.dart';
import 'package:baby_binder/screens/labor_tracker_page.dart';
import 'package:baby_binder/screens/login_screen.dart';
import 'package:baby_binder/screens/splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  log('Starting app initialization...');

  // Initialize Firebase - but don't crash if it fails
  bool firebaseInitialized = false;
  try {
    log('Initializing Firebase...');
    await Firebase.initializeApp();
    log('Firebase initialized successfully');
    log('Firebase default app: ${Firebase.app().name}');
    firebaseInitialized = true;
  } catch (e, st) {
    log('Firebase initialization error: $e', error: st);
    log('App will run without Firebase');
  }

  try {
    log('Initializing Hive...');
    await Hive.initFlutter();
    log('Hive initialized successfully');
  } catch (e, st) {
    log('Hive initialization error: $e', error: st);
  }

  log('All initialization complete, running app');
  runApp(
    ProviderScope(
      child: BabyBinder(firebaseAvailable: firebaseInitialized),
    ),
  );
}

class BabyBinder extends ConsumerWidget {
  const BabyBinder({super.key, this.firebaseAvailable = false});
  final bool firebaseAvailable;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Only try to watch appStateProvider if Firebase is available
    // Otherwise, return a simple error screen
    if (!firebaseAvailable) {
      return MaterialApp(
        title: 'Baby Binder',
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Firebase Configuration Error'),
                const SizedBox(height: 16),
                const Text(
                    'Unable to initialize Firebase. Please check your configuration.'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Retry or exit
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final appState = ref.watch(appStateProvider);
    appState.context = context;
    return MaterialApp(
      title: 'Baby Binder',
      theme: ThemeData(
        colorScheme: const ColorScheme.light().copyWith(
          primary: Colors.teal,
        ),
      ),
      home: const LandingFlow(),
    );
  }
}

class LandingFlow extends StatefulWidget {
  const LandingFlow({super.key});

  @override
  _LandingFlowState createState() => _LandingFlowState();
}

class _LandingFlowState extends State<LandingFlow> {
  bool isSplashOver = false;
  late final Future<HiveDB> _hiveDbFuture;

  @override
  void initState() {
    super.initState();
    _hiveDbFuture = HiveDB.create();
  }

  /// Restore the last visited page or default to ChildSelectionPage
  Widget _buildAuthPage() {
    return FutureBuilder<HiveDB>(
      future: _hiveDbFuture,
      builder: (context, hiveSnapshot) {
        if (hiveSnapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        final hiveBox = hiveSnapshot.data;
        final lastRoute = hiveBox?.getLastPage() ?? '';

        // Map last route to widget
        Widget getPageForRoute(String route) {
          switch (route) {
            case ChildStoryPage.routeName:
              return const ChildStoryPage();
            case ChildSettingsPage.routeName:
              return const ChildSettingsPage();
            case LaborTrackerPage.routeName:
              return LaborTrackerPage();
            case ChildSelectionPage.routeName:
            default:
              return const ChildSelectionPage();
          }
        }

        // Return the last page if set, otherwise default to ChildSelectionPage
        if (lastRoute.isNotEmpty) {
          return getPageForRoute(lastRoute);
        }
        return const ChildSelectionPage();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isSplashOver) {
      return StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }

          if (snapshot.hasData) {
            return _buildAuthPage();
          } else {
            return const LoginScreen();
          }
        },
      );
    }

    return SplashScreen(
      splashMaxDurationInSec: 3,
      onFinished: () => setState(() {
        isSplashOver = true;
      }),
    );
  }
}
