// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pos_inventory_app/screens/auth_screen.dart';
import 'package:pos_inventory_app/screens/home_screen.dart';
import 'package:pos_inventory_app/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthService())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'POS Inventory',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: FutureBuilder(
        future: Provider.of<AuthService>(context, listen: false).loadUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Consumer<AuthService>(
              builder: (context, authService, _) {
                return authService.currentUser != null
                    ? const HomeScreen()
                    : const AuthScreen();
              },
            );
          }
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        },
      ),
      // HAPUS routes: { '/' : ... }
      // Karena sudah pakai home, ga perlu lagi daftar '/' di routes.
      routes: {
        '/home': (context) => const HomeScreen(), // Ini boleh tetap ada
      },
    );
  }
}
