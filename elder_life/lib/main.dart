import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core
import 'screens/home_screen.dart';
import 'screens/manage_players_screen.dart';
import 'screens/new_game_start_screen.dart';
import 'screens/end_game_screen.dart';
import 'models/player.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase before running the app.
  //await Firebase.initializeApp();

  // Force landscape orientation
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
      // This builder ensures the app uses the full screen dimensions.
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
        }
        return null;
      },
    );
  }
}
