import 'package:flutter/material.dart';
import 'package:vaultx_solution/models/vehicle_model.dart';
import 'package:vaultx_solution/screens/vehicle_registration.dart';
import 'package:vaultx_solution/widgets/custom_app_bar.dart';

class AllVehiclesScreen extends StatefulWidget {
  final List<VehicleModel> vehicles;
  
  const AllVehiclesScreen({
    Key? key,
    required this.vehicles,
  }) : super(key: key);

  @override
  _AllVehiclesScreenState createState() => _AllVehiclesScreenState();
}

class _AllVehiclesScreenState extends State<AllVehiclesScreen> {
  List<VehicleModel> _filteredVehicles = [];
  String _searchQuery = '';
  String _filterOption = 'All'; // 'All', 'Car', 'Motorcycle', etc.
  
  @override
  void initState() {
    super.initState();
    _filteredVehicles = widget.vehicles;
  }
  
  void _filterVehicles() {
    setState(() {
      _filteredVehicles = widget.vehicles.where((vehicle) {
        // Apply search filter
        final nameMatches = vehicle.vehicleName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                           vehicle.vehicleLicensePlateNumber.toLowerCase().contains(_searchQuery.toLowerCase());
        
        // Apply type filter
        bool typeMatches = true;
        if (_filterOption != 'All') {
          typeMatches = vehicle.vehicleType.toLowerCase() == _filterOption.toLowerCase();
        }
        
        return nameMatches && typeMatches;
      }).toList();
    });
  }

  // Get unique vehicle types from the list
  List<String> get _vehicleTypes {
    final types = widget.vehicles.map((v) => v.vehicleType).toSet().toList();
    types.sort(); // Sort alphabetically
    return ['All', ...types];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: CustomAppBar(
          showBackButton: true,
          actions: [],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: Text(
              'All Vehicles',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF600f0f),
              ),
            ),
          ),
          
          // Search and filter bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              children: [
                // Search field
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search vehicles...',
                      prefixIcon: Icon(Icons.search, color: Color(0xFFE57373)),
                      filled: true,
                      fillColor: Color(0xFFFFF1ED),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                        _filterVehicles();
                      });
                    },
                  ),
                ),
                
                // Filter dropdown
                PopupMenuButton<String>(
                  icon: Icon(Icons.filter_list, color: Color(0xFFE57373)),
                  onSelected: (value) {
                    setState(() {
                      _filterOption = value;
                      _filterVehicles();
                    });
                  },
                  itemBuilder: (context) => _vehicleTypes.map((type) => 
                    PopupMenuItem(
                      value: type,
                      child: Text(type),
                    )
                  ).toList(),
                ),
              ],
            ),
          ),
          
          // Filter chips
          if (_vehicleTypes.length > 1)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _vehicleTypes.map((type) => 
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(type),
                        selected: _filterOption == type,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _filterOption = type;
                              _filterVehicles();
                            });
                          }
                        },
                        backgroundColor: Color(0xFFFFF1ED),
                        selectedColor: Color(0xFFE57373).withOpacity(0.2),
                        checkmarkColor: Color(0xFFE57373),
                      ),
                    )
                  ).toList(),
                ),
              ),
            ),
          
          // Vehicle list
          Expanded(
            child: _filteredVehicles.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.directions_car,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No vehicles found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const VehicleRegistrationPage(),
                              ),
                            ).then((_) => Navigator.pop(context));
                          },
                          icon: Icon(Icons.add),
                          label: Text('Add Vehicle'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFD6A19F),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: _filteredVehicles.length,
                    itemBuilder: (context, index) {
                      final vehicle = _filteredVehicles[index];
                      return _buildVehicleCard(vehicle);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const VehicleRegistrationPage(),
            ),
          ).then((_) => Navigator.pop(context));
        },
        backgroundColor: Color(0xFFD6A19F),
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildVehicleCard(VehicleModel vehicle) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildVehicleIcon(vehicle.vehicleType),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vehicle.vehicleName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        vehicle.vehicleModel,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Color(0xFFFFF1ED),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Color(0xFFE57373).withOpacity(0.3)),
                  ),
                  child: Text(
                    vehicle.vehicleType,
                    style: TextStyle(
                      color: Color(0xFF600f0f),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Divider(),
            SizedBox(height: 8),
            
            // Vehicle details
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    icon: Icons.credit_card,
                    label: 'License Plate',
                    value: vehicle.vehicleLicensePlateNumber,
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    icon: Icons.palette,
                    label: 'Color',
                    value: vehicle.vehicleColor,
                    showColorDot: true,
                    color: _getColorFromName(vehicle.vehicleColor),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    icon: Icons.nfc,
                    label: 'RFID Tag',
                    value: vehicle.RFIDTagID.isEmpty ? 'Not assigned' : vehicle.RFIDTagID,
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    icon: Icons.person,
                    label: 'Status',
                    value: vehicle.isGuest ? 'Guest Vehicle' : 'Resident Vehicle',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleIcon(String vehicleType) {
    IconData iconData;
    Color backgroundColor;
    
    switch (vehicleType.toLowerCase()) {
      case 'sedan':
      case 'car':
        iconData = Icons.directions_car;
        backgroundColor = Colors.blue.shade100;
        break;
      case 'suv':
        iconData = Icons.directions_car;
        backgroundColor = Colors.green.shade100;
        break;
      case 'motorcycle':
        iconData = Icons.motorcycle;
        backgroundColor = Colors.red.shade100;
        break;
      case 'truck':
        iconData = Icons.local_shipping;
        backgroundColor = Colors.amber.shade100;
        break;
      default:
        iconData = Icons.directions_car;
        backgroundColor = Colors.purple.shade100;
    }
    
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      child: Icon(
        iconData,
        color: backgroundColor.withOpacity(1.0),
        size: 24,
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
    bool showColorDot = false,
    Color? color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey.shade600,
        ),
        SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              SizedBox(height: 2),
              Row(
                children: [
                  if (showColorDot && color != null) ...[
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                    ),
                    SizedBox(width: 4),
                  ],
                  Expanded(
                    child: Text(
                      value,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
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
