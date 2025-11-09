import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ProfileDropdown extends StatelessWidget {
  final String userName;
  final String userImage;
  final VoidCallback onClose;
  final VoidCallback onLogout;
  final VoidCallback onEditProfile;
  final VoidCallback onChangePassword;
  
  const ProfileDropdown({
    Key? key,
    required this.userName,
    required this.userImage,
    required this.onClose,
    required this.onLogout,
    required this.onEditProfile,
    required this.onChangePassword,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(12),
      color: Colors.white,
      child: Container(
        width: 250,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Profile image
            CircleAvatar(
              radius: 40,
              backgroundColor: const Color(0xFFE6E9F5), // Light purple background
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6D213C),
                ),
              ),
            ),
            const SizedBox(height: 12),
            
            // User name
            Text(
              userName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6D213C), // Dark maroon color
              ),
            ),
            const SizedBox(height: 16),
            
            // Menu items
            _buildMenuItem(
              icon: Icons.edit,
              title: 'Edit Profile',
              iconColor: const Color(0xFFFBD3D2), // Light pink
              onTap: onEditProfile,
            ),
            
            const Divider(height: 1, thickness: 1, color: Color(0xFFF5F5F5)),
            
            _buildMenuItem(
              icon: Icons.lock,
              title: 'Change Password',
              iconColor: const Color(0xFFFBD3D2), // Light pink
              onTap: onChangePassword,
            ),
            
            const Divider(height: 1, thickness: 1, color: Color(0xFFF5F5F5)),
            
            // Log out button
            Padding(
              padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
              child: InkWell(
                onTap: onLogout,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout, size: 18, color: Colors.red.shade400),
                    SizedBox(width: 8),
                    Text(
                      'Log out',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.red.shade400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Icon container
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 20,
                  color: const Color(0xFFE57373), // Darker pink for the icon
                ),
              ),
            ),
            const SizedBox(width: 12),
            
            // Title
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            
            // Arrow icon
            const Icon(
              Icons.chevron_right,
              size: 20,
              color: Colors.black54,
            ),
          ],
        ),
      ),
    );
  }
}
