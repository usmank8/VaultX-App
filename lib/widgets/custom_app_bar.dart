import 'package:flutter/material.dart';
import 'package:vaultx_solution/auth/screens/loginscreen.dart';
import 'package:vaultx_solution/screens/change_password_page.dart';
import 'package:vaultx_solution/screens/notifications.dart';
import 'dart:math' as math;
import 'package:vaultx_solution/services/api_service.dart';
import 'package:vaultx_solution/models/create_profile_model.dart';
import 'profile_dropdown.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final bool showBackButton;
  final List<Widget>? actions;
  final CreateProfileModel? userProfile;
  final VoidCallback? onRefresh;
  final int unreadNotifications;

  const CustomAppBar({
    Key? key,
    this.showBackButton = false,
    this.actions,
    this.userProfile,
    this.onRefresh,
    this.unreadNotifications = 0,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _refreshController;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _refreshController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _refreshController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _refreshController.reset();
        setState(() {
          _isRefreshing = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  void _handleRefresh() {
    setState(() {
      _isRefreshing = true;
    });
    _refreshController.forward();

    if (widget.onRefresh != null) {
      widget.onRefresh!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 1,
      backgroundColor: Colors.white,
      titleSpacing: 16,
      leading: widget.showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          : null,
      title: Row(
        children: [
          Image.asset(
            'assets/vx_logo.png',
            height: 40,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: Color(0xFFD6A19F),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    'V',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              );
            },
          ),
          const Spacer(),

          // Refresh Button
          GestureDetector(
            onTap: _isRefreshing ? null : _handleRefresh,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFD6A19F), Color(0xFF7D2828)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: AnimatedBuilder(
                animation: _refreshController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _refreshController.value * 2 * math.pi,
                    child: Icon(
                      Icons.refresh,
                      color: Colors.white,
                      size: 20,
                    ),
                  );
                },
              ),
            ),
          ),
          SizedBox(width: 12),

          // Notifications Button
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsPage()),
              );
            },
            child: Stack(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 3,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.notifications_outlined,
                    color: Color(0xFF600f0f),
                    size: 22,
                  ),
                ),
                if (widget.unreadNotifications > 0)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Center(
                        child: Text(
                          widget.unreadNotifications > 9
                              ? '9+'
                              : widget.unreadNotifications.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(width: 12),

          // Profile Avatar
          GestureDetector(
            onTap: () {
              _showProfileDropdown(context);
            },
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    backgroundColor: Color(0xFFD6A19F),
                    radius: 18,
                    child: Text(
                      (widget.userProfile != null &&
                              widget.userProfile!.firstname.isNotEmpty)
                          ? widget.userProfile!.firstname[0].toUpperCase()
                          : 'U',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 5,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 4,
                      backgroundColor: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8),
        ],
      ),
      actions: widget.actions,
    );
  }

  void _showProfileDropdown(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;

    // Calculate position based on screen size for better reliability
    final Size screenSize = MediaQuery.of(context).size;
    final double rightOffset = screenSize.width > 400 ? 250 : 200;

    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(
            Offset(button.size.width - rightOffset, button.size.height + 10),
            ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero),
            ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    showMenu<String>(
      context: context,
      position: position,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.transparent,
      items: [
        PopupMenuItem<String>(
          padding: EdgeInsets.zero,
          child: ProfileDropdown(
            userName: widget.userProfile != null
                ? "${widget.userProfile!.firstname} ${widget.userProfile!.lastname}"
                : "User",
            userImage: "assets/profile.png",
            onClose: () => Navigator.pop(context),
            onLogout: () async {
              Navigator.pop(context);
              await _handleLogout(context);
            },
            onEditProfile: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/edit-profile');
            },
            onChangePassword: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    // Show loading dialog with elegant spinner
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: Color(0xFFD6A19F),
                strokeWidth: 3,
              ),
              SizedBox(height: 15),
              Text(
                "Logging out...",
                style: TextStyle(
                  color: Color(0xFF600f0f),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      final apiService = ApiService();
      await apiService.logout();

      // Close loading dialog
      Navigator.pop(context);

      // Navigate to login page
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    } catch (e) {
      // Close loading dialog
      Navigator.pop(context);

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 10),
              Expanded(child: Text('Error logging out: ${e.toString()}')),
            ],
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: EdgeInsets.all(10),
        ),
      );
    }
  }
}
