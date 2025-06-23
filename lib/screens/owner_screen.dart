import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:pos_inventory_app/services/auth_service.dart';
import 'package:pos_inventory_app/screens/sales_report_screen.dart';
import 'package:pos_inventory_app/screens/financial_report_screen.dart';

class OwnerScreen extends StatelessWidget {
  const OwnerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(user),
            const SizedBox(height: 16),
            _buildOwnerLabel(),
            const SizedBox(height: 16),
            _buildWelcomeCard(user),
            const SizedBox(height: 16),
            Expanded(child: _buildFeatureGrid(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(dynamic user) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "POS",
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            Text(
              "Inventory",
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.teal.shade300,
              ),
            ),
          ],
        ),
        Row(
          children: [
            const Icon(Icons.notifications_none, size: 28),
            const SizedBox(width: 12),
            CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(
                user?['photoUrl'] ?? "https://i.pravatar.cc/150?img=4",
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOwnerLabel() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.teal.shade800,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          "Owner",
          style: GoogleFonts.poppins(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(dynamic user) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            const Icon(Icons.business, size: 50, color: Colors.teal),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'Halo, Owner ${user?['name'] ?? ''}',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      childAspectRatio: 1.1,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildFeatureCard(
          context,
          icon: Icons.bar_chart,
          title: 'Laporan\nPenjualan',
          color: Colors.deepPurpleAccent,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SalesReportScreen()),
            );
          },
        ),
        _buildFeatureCard(
          context,
          icon: Icons.attach_money,
          title: 'Laporan\nKeuangan',
          color: Colors.green,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FinancialReportScreen()),
            );
          },
        ),
        _buildFeatureCard(
          context,
          icon: Icons.people,
          title: 'Performance\nStaff',
          color: Colors.orangeAccent,
          onTap: () {
            // Implementasi lanjut
          },
        ),
        _buildFeatureCard(
          context,
          icon: Icons.settings,
          title: 'Pengaturan\nBisnis',
          color: Colors.indigo,
          onTap: () {
            // Implementasi lanjut
          },
        ),
      ],
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required Function() onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
