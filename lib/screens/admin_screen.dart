import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:pos_inventory_app/services/auth_service.dart';
import 'package:pos_inventory_app/screens/user_management_screen.dart';
import 'package:pos_inventory_app/screens/system_activities_screen.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(user),
              const SizedBox(height: 20),
              _buildAdminLabel(),
              const SizedBox(height: 16),
              _buildSummaryCards(),
              const SizedBox(height: 24),
              _buildMenuTitle("Kelola User"),
              const SizedBox(height: 12),
              _buildTabButtons(),
              const SizedBox(height: 16),
              _buildFeatureButtons(context),
            ],
          ),
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
            Text("POS",
                style: GoogleFonts.poppins(
                    fontSize: 28, fontWeight: FontWeight.bold, color: Colors.teal)),
            Text("Inventory",
                style: GoogleFonts.poppins(
                    fontSize: 16, color: Colors.teal.shade300)),
          ],
        ),
        Row(
          children: [
            const Icon(Icons.notifications_none, size: 28),
            const SizedBox(width: 12),
            CircleAvatar(
              backgroundImage: NetworkImage(
                user?['photoUrl'] ??
                    "https://i.pravatar.cc/150?img=3", // fallback
              ),
              radius: 20,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAdminLabel() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF004D40),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          "Admin",
          style: GoogleFonts.poppins(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildSummaryCard(Icons.people, "Total User", "05"),
        _buildSummaryCard(Icons.receipt_long, "Transaksi Hari Ini", "99"),
      ],
    );
  }

  Widget _buildSummaryCard(IconData icon, String label, String value) {
    return Expanded(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            children: [
              Icon(icon, size: 40, color: Colors.teal),
              const SizedBox(height: 8),
              Text(
                value,
                style: GoogleFonts.poppins(
                    fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 4),
              Text(label,
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700])),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuTitle(String title) {
    return Center(
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.teal.shade800,
        ),
      ),
    );
  }

  Widget _buildTabButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTab("Cashier", isSelected: true),
        const SizedBox(width: 12),
        _buildTab("Buyer"),
      ],
    );
  }

  Widget _buildTab(String label, {bool isSelected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? Colors.teal : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.teal),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          color: isSelected ? Colors.white : Colors.teal,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildFeatureButtons(BuildContext context) {
    return Column(
      children: [
        _buildFeatureCard(
          context,
          icon: Icons.people,
          title: 'Kelola User',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const UserManagementScreen()),
          ),
        ),
        const SizedBox(height: 16),
        _buildFeatureCard(
          context,
          icon: Icons.history,
          title: 'Aktivitas Sistem',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SystemActivitiesScreen()),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required Function() onTap,
      }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Icon(icon, color: Colors.teal, size: 32),
        title: Text(
          title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
