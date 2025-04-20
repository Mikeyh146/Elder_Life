import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';  // Import Firebase Database
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'screens/manage_players_screen.dart';
import 'screens/new_game_start_screen.dart';
import 'screens/end_game_screen.dart';
import 'screens/pod_detail_screen.dart';  // Import the PodDetailScreen
import 'models/player.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ✅ Debug confirmation
  print("✅ Firebase is initialized and running!");

  // Test Firebase connectivity (writing test data to Firebase Realtime Database)
  try {
    final databaseRef = FirebaseDatabase.instance.ref();
    databaseRef.child('test').set({
      'message': 'Firebase is working!',
    }).then((_) {
      print('Successfully written to Firebase');
    }).catchError((error) {
      print('Failed to write to Firebase: $error');
    });
  } catch (error) {
    print('Error connecting to Firebase: $error');
  }

  // Force landscape mode
  await SystemChrome.setPreferredOrientations([ 
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runApp(const ElderLifeApp());
}

class ElderLifeApp extends StatelessWidget {
  const ElderLifeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Elder Life',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      builder: (context, child) {
        final size = MediaQuery.of(context).size;
        return SizedBox(
          width: size.width,
          height: size.height,
          child: child,
        );
      },
      home: const HomeScreen(),
      routes: {
        '/manage-players': (context) => const ManagePlayersScreen(),
        '/new-game': (context) => const NewGameStartScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/end-game') {
          final args = settings.arguments as List<Player>;
          return MaterialPageRoute(
            builder: (context) => EndGameScreen(players: args),
          );
        } else if (settings.name == '/pod_detail') {
  final podData = settings.arguments as Map<String, dynamic>;
  final podId = podData['podId'];
  final podName = podData['podName'];

  return MaterialPageRoute(
    builder: (context) => PodDetailScreen(
      podId: podId,
      podName: podName,
    ),
  );
}

        return null; // Return null for unhandled routes
      },
    );
  }
}
