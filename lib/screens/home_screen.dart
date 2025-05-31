// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pos_inventory_app/services/auth_service.dart';
import 'package:pos_inventory_app/screens/products_screen.dart';
import 'package:pos_inventory_app/screens/admin_screen.dart';
import 'package:pos_inventory_app/screens/cashier_screen.dart';
import 'package:pos_inventory_app/screens/stock_counter_screen.dart';
import 'package:pos_inventory_app/screens/owner_screen.dart';
import 'package:pos_inventory_app/screens/cart_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Widget _getRoleScreen(Map<String, dynamic>? user) {
    switch (user?['role']) {
      case 'admin':
        return const AdminScreen();
      case 'cashier':
        return const CashierScreen();
      case 'stock_counter':
        return const StockCounterScreen();
      case 'owner':
        return const OwnerScreen();
      case 'buyer':
      default:
        return const ProductsScreen();
    }
  }

  List<Widget> _getAppBarActions(
    BuildContext context,
    AuthService authService,
    Map<String, dynamic>? user,
  ) {
    if (user?['role'] == 'buyer') {
      return [
        IconButton(
          icon: const Icon(Icons.shopping_cart),
          onPressed: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const CartScreen()));
          },
        ),
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () async {
            await authService.logout();
            Navigator.of(context).pushReplacementNamed('/');
          },
        ),
      ];
    }
    return [
      IconButton(
        icon: const Icon(Icons.logout),
        onPressed: () async {
          await authService.logout();
          Navigator.of(context).pushReplacementNamed('/');
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('POS Inventory'),
        actions: _getAppBarActions(context, authService, user),
      ),
      body: _getRoleScreen(user),
      floatingActionButton:
          user?['role'] == 'buyer'
              ? FloatingActionButton(
                onPressed: () {
                  Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (_) => const CartScreen()));
                },
                child: const Icon(Icons.shopping_cart),
              )
              : null,
    );
  }
}
