import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vaultx_solution/auth/screens/loginscreen.dart';
import 'package:vaultx_solution/loading/loading.dart';
import 'package:vaultx_solution/screens/guest_registration.dart';
import 'package:vaultx_solution/screens/vehicle_registration.dart';
import 'package:vaultx_solution/screens/otp_screen.dart';
import 'package:vaultx_solution/screens/all_guests_screen.dart';
import 'package:vaultx_solution/screens/all_vehicles_screen.dart';
import 'package:vaultx_solution/widgets/custom_app_bar.dart';
import 'package:vaultx_solution/services/api_service.dart';
import 'package:vaultx_solution/models/create_profile_model.dart';
import 'package:vaultx_solution/models/vehicle_model.dart';
import 'package:vaultx_solution/models/guest_model.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  String _userName = "User";
  CreateProfileModel? _userProfile;
  List<VehicleModel> _vehicles = [];
  List<GuestModel> _guests = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Verify token is set
      _apiService.debugToken();

      // Get user profile
      final profile = await _apiService.getProfile();

      if (profile != null) {
        setState(() {
          _userProfile = profile;
          _userName = "${profile.firstname} ${profile.lastname}";
        });
      }

      // Get vehicles
      final vehicles = await _apiService.getVehicles();
      setState(() {
        _vehicles = vehicles;
      });

      // Get guests
      final guests = await _apiService.getGuests();
      setState(() {
        _guests = guests;
      });
    } catch (e) {
      setState(() {
        _error = "Failed to load data: ${e.toString()}";
      });

      // If there's an authentication error, redirect to login
      if (e.toString().contains("401") ||
          e.toString().contains("Unauthorized")) {
        _showSessionExpiredDialog();
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSessionExpiredDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text("Session Expired"),
        content: Text("Your session has expired. Please login again."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _logout();
            },
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    try {
      await _apiService.logout();
    } catch (e) {
      // Ignore errors during logout
    } finally {
      // Navigate to login screen
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: CustomAppBar(
          showBackButton: false,
          userProfile: _userProfile,
          onRefresh: _isLoading ? null : _loadData,
        ),
      ),
      backgroundColor: Colors.white,
      body: _isLoading
          ? Center(child: UnderReviewScreen())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _error!,
                        style: TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadData,
                        child: Text("Retry"),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  color: Color(0xFFD6A19F),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Welcome message with user name
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Text(
                            "Welcome, $_userName",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF600f0f),
                            ),
                          ),
                        ),

                        // Add Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildActionButton(
                                "Generate OTP", Icons.add, context),
                            _buildActionButton(
                                "Add a Guest", Icons.person_add_alt, context),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Text("Overview",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),

                        // Guests Section
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                _buildCard(
                                  context: context,
                                  title: "Guests",
                                  trailingText: "Add",
                                  viewAllText: "View All",
                                  onViewAllTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            AllGuestsScreen(guests: _guests),
                                      ),
                                    ).then((_) => _loadData());
                                  },
                                  onTrailingTap: () async {
                                    // Navigate to guest registration
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const GuestRegistrationForm(),
                                      ),
                                    );

                                    // Refresh data if guest was added
                                    if (result == true) {
                                      _loadData();
                                    }
                                  },
                                  content: _guests.isEmpty
                                      ? Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 16.0),
                                          child: Center(
                                            child: Text(
                                              "No guests added yet",
                                              style: TextStyle(
                                                color: Colors.grey.shade600,
                                                fontStyle: FontStyle.italic,
                                              ),
                                            ),
                                          ),
                                        )
                                      : Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: _guests
                                              .take(
                                                  3) // Show only first 3 guests
                                              .map((guest) => _buildGuestRow(
                                                    guest.guestName,
                                                    _formatDateTime(guest.eta),
                                                    _getGuestStatusColor(
                                                        guest.eta),
                                                  ))
                                              .toList(),
                                        ),
                                ),
                                const SizedBox(height: 16),

                                // Vehicles Section
                                _buildCard(
                                  context: context,
                                  title: "Vehicles",
                                  trailingText: "Add",
                                  viewAllText: "View All",
                                  onViewAllTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AllVehiclesScreen(
                                            vehicles: _vehicles),
                                      ),
                                    ).then((_) => _loadData());
                                  },
                                  onTrailingTap: () async {
                                    // Navigate to vehicle registration
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const VehicleRegistrationPage(),
                                      ),
                                    );

                                    // Refresh data if vehicle was added
                                    if (result == true) {
                                      _loadData();
                                    }
                                  },
                                  content: _vehicles.isEmpty
                                      ? Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 16.0),
                                          child: Center(
                                            child: Text(
                                              "No vehicles added yet",
                                              style: TextStyle(
                                                color: Colors.grey.shade600,
                                                fontStyle: FontStyle.italic,
                                              ),
                                            ),
                                          ),
                                        )
                                      : Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: _vehicles
                                              .take(
                                                  3) // Show only first 3 vehicles
                                              .map(
                                                  (vehicle) => _buildVehicleRow(
                                                        vehicle.vehicleName,
                                                        vehicle
                                                            .vehicleLicensePlateNumber,
                                                        vehicle.vehicleColor,
                                                      ))
                                              .toList(),
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        backgroundColor: const Color(0xFF600f0f),
        currentIndex: 0,
        onTap: (index) {
          // Handle navigation bar taps
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const GuestRegistrationForm()),
            ).then((_) => _loadData());
          }
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard), label: 'Overvieww'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_add), label: 'Add Guest'),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(Duration(days: 1));
    final date = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (date == today) {
      return "Today, ${DateFormat('h:mm a').format(dateTime)}";
    } else if (date == tomorrow) {
      return "Tomorrow, ${DateFormat('h:mm a').format(dateTime)}";
    } else {
      return DateFormat('MMM d, h:mm a').format(dateTime);
    }
  }

  Color _getGuestStatusColor(DateTime eta) {
    final now = DateTime.now();
    final difference = eta.difference(now);

    // If ETA is within 1 hour
    if (difference.inHours.abs() <= 1) {
      return Colors.green;
    }
    // If ETA is today but more than 1 hour away
    else if (eta.day == now.day &&
        eta.month == now.month &&
        eta.year == now.year) {
      return Colors.orange;
    }
    // If ETA is in the future
    else if (eta.isAfter(now)) {
      return Colors.blue;
    }
    // If ETA is in the past
    else {
      return Colors.grey;
    }
  }

  Widget _buildActionButton(String text, IconData icon, BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        child: OutlinedButton.icon(
          onPressed: () {
            // if (text == "Generate OTP") {
            //   // Navigate to OTP screen
            //   Navigator.push(
            //     context,
            //     MaterialPageRoute(builder: (context) => OtpScreen(email: _userProfile?.email ?? "")),
            //   );
            // } else
            if (text == "Add a Guest") {
              // Navigate to Register Guest screen
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const GuestRegistrationForm()),
              ).then((_) => _loadData());
            }
          },
          style: OutlinedButton.styleFrom(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            side: const BorderSide(color: Colors.redAccent),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          icon: Icon(icon, size: 18, color: Colors.redAccent),
          label: Text(text, style: const TextStyle(color: Colors.redAccent)),
        ),
      ),
    );
  }

  Widget _buildCard({
    required BuildContext context,
    required String title,
    required String trailingText,
    required VoidCallback onTrailingTap,
    required Widget content,
    String? viewAllText,
    VoidCallback? onViewAllTap,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFDECEC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w600)),
              Row(
                children: [
                  if (viewAllText != null)
                    TextButton(
                      onPressed: onViewAllTap,
                      child: Text(viewAllText),
                    ),
                  TextButton(
                    onPressed: onTrailingTap,
                    child: Text(trailingText),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          content,
        ],
      ),
    );
  }

  Widget _buildGuestRow(String name, String time, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
              Text(time, style: const TextStyle(color: Colors.black54)),
            ],
          )),
          CircleAvatar(radius: 8, backgroundColor: color),
          const SizedBox(width: 10),
          const Icon(Icons.remove_circle_outline, color: Colors.black54)
        ],
      ),
    );
  }

  Widget _buildVehicleRow(String model, String plate, String color) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(model, style: TextStyle(fontWeight: FontWeight.w500)),
                Text(plate, style: TextStyle(color: Colors.black54)),
              ],
            ),
          ),
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: _getColorFromName(color),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorFromName(String colorName) {
    // Simple mapping of color names to Color objects
    switch (colorName.toLowerCase()) {
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'black':
        return Colors.black;
      case 'white':
        return Colors.white;
      case 'silver':
      case 'grey':
      case 'gray':
        return Colors.grey;
      case 'yellow':
        return Colors.yellow;
      case 'orange':
        return Colors.orange;
      case 'purple':
        return Colors.purple;
      case 'brown':
        return Colors.brown;
      default:
        return Color(0xFF600f0f); // Default color
    }
  }
}
