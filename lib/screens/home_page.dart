import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vaultx_solution/auth/screens/loginscreen.dart';
import 'package:vaultx_solution/loading/loading.dart';
import 'package:vaultx_solution/screens/guest_registration.dart';
import 'package:vaultx_solution/screens/guest_registration_confirmed.dart';
import 'package:vaultx_solution/screens/vehicle_registration.dart';
import 'package:vaultx_solution/screens/otp_screen.dart';
import 'package:vaultx_solution/screens/all_guests_screen.dart';
import 'package:vaultx_solution/screens/all_vehicles_screen.dart';
import 'package:vaultx_solution/models/vehicle_model.dart';
import 'package:vaultx_solution/models/guest_model.dart';
import 'package:vaultx_solution/models/residence_model.dart';
import 'package:vaultx_solution/models/create_profile_model.dart';
import 'package:vaultx_solution/services/api_service.dart';
import 'package:vaultx_solution/widgets/residence_selector_widget.dart';
import 'package:vaultx_solution/widgets/custom_app_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final ApiService _apiService = ApiService();

  bool _isLoading = true;
  String? _errorMessage;
  List<VehicleModel> _allVehicles = []; // All vehicles across residences
  List<VehicleModel> _residenceVehicles = []; // Vehicles for selected residence
  List<GuestModel> _allGuests = []; // All guests across residences
  List<GuestModel> _residenceGuests = []; // Guests for selected residence
  String? _selectedResidenceId;
  ResidenceModel? _selectedResidence;
  CreateProfileModel? _profile;

  @override
  void initState() {
    super.initState();
    _initializeAndLoadData();
  }

  Future<void> _initializeAndLoadData() async {
    // Get selected residence ID
    final prefs = await SharedPreferences.getInstance();
    _selectedResidenceId = prefs.getString('selected_residence_id');
    await _loadData();
    await _loadProfile();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Load all vehicles and guests
      final vehicles = await _apiService.getVehicles();
      final guests = await _apiService.getGuests();

      if (mounted) {
        setState(() {
          _allVehicles = vehicles;
          _allGuests = guests;
          
          // Filter by selected residence
          _filterByResidence();
          
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading data: $e');
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _apiService.getProfile();
      if (mounted) {
        setState(() {
          _profile = profile;
        });
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
    }
  }

  void _filterByResidence() {
    if (_selectedResidenceId != null && _selectedResidenceId!.isNotEmpty) {
      // Filter vehicles by residence ID
      _residenceVehicles = _allVehicles.where((v) {
        final vehicleResidenceId = v.residenceId?.toString().toLowerCase();
        final selectedId = _selectedResidenceId?.toLowerCase();
        return vehicleResidenceId == selectedId;
      }).toList();
      
      // Filter guests by residence ID
      _residenceGuests = _allGuests.where((g) {
        final guestResidenceId = g.residenceId?.toString().toLowerCase();
        final selectedId = _selectedResidenceId?.toLowerCase();
        return guestResidenceId == selectedId;
      }).toList();
      
      debugPrint('Selected Residence ID: $_selectedResidenceId');
      debugPrint('Total vehicles: ${_allVehicles.length}, Filtered: ${_residenceVehicles.length}');
      debugPrint('Total guests: ${_allGuests.length}, Filtered: ${_residenceGuests.length}');
    } else {
      // No residence selected, show all
      _residenceVehicles = _allVehicles;
      _residenceGuests = _allGuests;
    }
  }

  void _onResidenceChanged(dynamic residence) {
    debugPrint('Residence changed: ${residence.id}');
    setState(() {
      _selectedResidenceId = residence.id;
      _selectedResidence = residence;
      _filterByResidence();
    });
    
    // Also save to SharedPreferences
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('selected_residence_id', residence.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: CustomAppBar(
          showBackButton: false,
          actions: [],
          userProfile: _profile,
          onRefresh: _loadData,
          unreadNotifications: 0,
        ),
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Residence Selector
                ResidenceSelectorWidget(
                  onResidenceChanged: _onResidenceChanged,
                ),

                const SizedBox(height: 16),

                // Quick Actions
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Quick Actions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _QuickActionCard(
                              icon: Icons.person_add,
                              label: 'Add Guest',
                              color: Colors.blue,
                              onTap: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const GuestRegistrationForm(),
                                  ),
                                );
                                if (result == true) {
                                  _loadData();
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _QuickActionCard(
                              icon: Icons.directions_car,
                              label: 'Add Vehicle',
                              color: Colors.green,
                              onTap: () async {
                                // Check vehicle count for THIS residence
                                if (_residenceVehicles.length >= 4) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Maximum 4 vehicles allowed per residence'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const VehicleRegistrationPage(),
                                  ),
                                );
                                if (result == true) {
                                  _loadData();
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Vehicles Section - USE _residenceVehicles
                _buildSectionHeader(
                  title: 'My Vehicles',
                  count: _residenceVehicles.length, // ✅ Use filtered count
                  maxCount: 4,
                  onViewAll: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AllVehiclesScreen(vehicles: _residenceVehicles), // ✅ Pass filtered list
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                _buildVehiclesSection(),

                const SizedBox(height: 24),

                // Guests Section - USE _residenceGuests
                _buildSectionHeader(
                  title: 'Recent Guests',
                  count: _residenceGuests.length, // ✅ Use filtered count
                  onViewAll: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AllGuestsScreen(guests: _residenceGuests), // ✅ Pass filtered list
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                _buildGuestsSection(),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required int count,
    int? maxCount,
    required VoidCallback onViewAll,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF2D0A0A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  maxCount != null ? '$count/$maxCount' : '$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          TextButton(
            onPressed: onViewAll,
            child: const Text('View All'),
          ),
        ],
      ),
    );
  }

  Widget _buildVehiclesSection() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          color: Colors.red.shade50,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 8),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _loadData,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // ✅ Use _residenceVehicles instead of _vehicles
    if (_residenceVehicles.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Icon(
                  Icons.directions_car_outlined,
                  size: 48,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 12),
                const Text(
                  'No vehicles registered',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Add up to 4 vehicles per residence',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const VehicleRegistrationPage(),
                      ),
                    );
                    if (result == true) {
                      _loadData();
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Vehicle'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2D0A0A),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // ✅ Show vehicles for selected residence in horizontal scroll
    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _residenceVehicles.length, // ✅ Use filtered list
        itemBuilder: (context, index) {
          final vehicle = _residenceVehicles[index]; // ✅ Use filtered list
          return Container(
            width: 200,
            margin: EdgeInsets.only(right: index < _residenceVehicles.length - 1 ? 12 : 0),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2D0A0A).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            _getVehicleIcon(vehicle.vehicleType),
                            color: const Color(0xFF2D0A0A),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            vehicle.vehicleName ?? 'Unknown',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      vehicle.vehicleModel ?? 'No model',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        vehicle.vehicleLicensePlateNumber ?? 'No plate',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (vehicle.vehicleRfidTagId != null &&
                        vehicle.vehicleRfidTagId!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.nfc,
                            size: 12,
                            color: Colors.green.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'RFID Active',
                            style: TextStyle(
                              color: Colors.green.shade600,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGuestsSection() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      );
    }

    // ✅ Use _residenceGuests instead of _guests
    if (_residenceGuests.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Icon(
                  Icons.people_outline,
                  size: 48,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 12),
                const Text(
                  'No guests registered',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Register guests for easy entry',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const GuestRegistrationForm(),
                      ),
                    );
                    if (result == true) {
                      _loadData();
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Guest'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2D0A0A),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Show recent guests (max 3) - ✅ Use filtered list
    final recentGuests = _residenceGuests.take(3).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: recentGuests.map((guest) {
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GuestConfirmationPage(
                      qrCodeImage: guest.qrCode ?? '',
                      showQRInitially: true,
                    ),
                  ),
                );
              },
              leading: CircleAvatar(
                backgroundColor: const Color(0xFF2D0A0A),
                child: Text(
                  guest.guestName.isNotEmpty
                      ? guest.guestName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              title: Text(
                guest.guestName,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                guest.guestPhoneNumber,
                style: TextStyle(color: Colors.grey.shade600),
              ),
              trailing: _buildGuestStatusChip(guest),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGuestStatusChip(GuestModel guest) {
    Color color;
    String label;

    if (guest.visitCompleted == true) {
      color = Colors.grey;
      label = 'Completed';
    } else if (guest.isVerified == true) {
      color = Colors.green;
      label = 'Verified';
    } else if (guest.isExpired) {
      color = Colors.red;
      label = 'Expired';
    } else {
      color = Colors.orange;
      label = 'Pending';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  IconData _getVehicleIcon(String? type) {
    switch (type?.toLowerCase()) {
      case 'car':
        return Icons.directions_car;
      case 'motorcycle':
        return Icons.two_wheeler;
      case 'truck':
        return Icons.local_shipping;
      case 'suv':
        return Icons.directions_car_filled;
      case 'van':
        return Icons.airport_shuttle;
      default:
        return Icons.directions_car;
    }
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}
