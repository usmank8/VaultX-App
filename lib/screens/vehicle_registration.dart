import 'package:flutter/material.dart';
import 'package:vaultx_solution/loading/loading.dart';
import 'package:vaultx_solution/models/vehicle_model.dart';
import 'package:vaultx_solution/services/api_service.dart';
import 'package:vaultx_solution/widgets/custom_app_bar.dart';

class VehicleRegistrationPage extends StatefulWidget {
  const VehicleRegistrationPage({super.key});

  @override
  _VehicleRegistrationPageState createState() => _VehicleRegistrationPageState();
}

class _VehicleRegistrationPageState extends State<VehicleRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _vehicleNameController = TextEditingController();
  final _vehicleModelController = TextEditingController();
  final _licensePlateController = TextEditingController();
  final _rfidTagController = TextEditingController();
  final _vehicleColorController = TextEditingController();
  String _vehicleType = 'Sedan'; // Default value
  
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  String? _errorMessage;
  
  final List<String> _vehicleTypes = ['Sedan', 'SUV', 'Hatchback', 'Truck', 'Motorcycle', 'Other'];

  @override
  void dispose() {
    _vehicleNameController.dispose();
    _vehicleModelController.dispose();
    _licensePlateController.dispose();
    _rfidTagController.dispose();
    _vehicleColorController.dispose();
    super.dispose();
  }

  Future<void> _submitVehicle() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final vehicleModel = VehicleModel(
        vehicleName: _vehicleNameController.text.trim(),
        vehicleModel: _vehicleModelController.text.trim(),
        vehicleLicensePlateNumber: _licensePlateController.text.trim(),
        vehicleType: _vehicleType,
        RFIDTagID: _rfidTagController.text.trim(),
        vehicleColor: _vehicleColorController.text.trim(),
      );

      await _apiService.addVehicle(vehicleModel);
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 10),
                Text('Vehicle added successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        
        // Navigate back to refresh the vehicle list
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Vehicle Registration',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF600f0f),
                ),
              ),
              SizedBox(height: 24),
              
              _buildInputField(
                controller: _vehicleNameController,
                label: "Vehicle Name",
                hint: "Enter vehicle name (e.g., Toyota Corolla)",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter vehicle name';
                  }
                  return null;
                },
              ),
              
              _buildInputField(
                controller: _vehicleModelController,
                label: "Vehicle Model",
                hint: "Enter model year (e.g., 2022)",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter vehicle model';
                  }
                  return null;
                },
              ),
              
              _buildInputField(
                controller: _licensePlateController,
                label: "License Plate Number",
                hint: "Enter license plate number",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter license plate number';
                  }
                  return null;
                },
              ),
              
              _buildDropdown(
                label: "Vehicle Type",
                value: _vehicleType,
                items: _vehicleTypes,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _vehicleType = value;
                    });
                  }
                },
              ),
              
              _buildInputField(
                controller: _rfidTagController,
                label: "RFID Tag ID",
                hint: "Enter RFID tag ID",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter RFID tag ID';
                  }
                  return null;
                },
              ),
              
              _buildInputField(
                controller: _vehicleColorController,
                label: "Vehicle Color",
                hint: "Enter vehicle color",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter vehicle color';
                  }
                  return null;
                },
              ),
              
              SizedBox(height: 24),
              
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitVehicle,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD6A19F),
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: _isLoading
                      ? UnderReviewScreen()
                      : Text(
                          "Submit",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String? Function(String?) validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          TextFormField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: const Color(0xFFFFF1ED),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            validator: validator,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1ED),
              borderRadius: BorderRadius.circular(24),
            ),
            child: DropdownButtonFormField<String>(
              value: value,
              decoration: InputDecoration(
                border: InputBorder.none,
              ),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
