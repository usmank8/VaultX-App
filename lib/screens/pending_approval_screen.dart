import 'package:flutter/material.dart';
import 'package:vaultx_solution/services/api_service.dart';

class PendingApprovalScreen extends StatelessWidget {
  const PendingApprovalScreen({Key? key}) : super(key: key);

  Future<void> _handleLogout(BuildContext context) async {
    try {
      await ApiService().logout();
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Fullscreen, no gaps
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.hourglass_empty,
                size: 64, color: Colors.redAccent),
            const SizedBox(height: 32),
            const Text(
              'Pending account approval by admin society',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: 200,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => _handleLogout(context),
              ),
            ),
          ],
        ),
      ),
     
    );
  }
}
