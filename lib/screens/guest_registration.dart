import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vaultx_solution/loading/loading.dart';
import 'package:vaultx_solution/models/guest_model.dart';
import 'package:vaultx_solution/screens/guest_registration_confirmed.dart';
import 'package:vaultx_solution/screens/guest_vehicle_registration.dart';
import 'package:vaultx_solution/services/api_service.dart';
import 'package:vaultx_solution/widgets/custom_app_bar.dart';

class GuestRegistrationForm extends StatefulWidget {
  const GuestRegistrationForm({super.key});

  @override
  State<GuestRegistrationForm> createState() => _GuestRegistrationFormState();
}

class _GuestRegistrationFormState extends State<GuestRegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController dateTimeController = TextEditingController();
  
  String _selectedGender = 'Male';
  bool _hasVehicle = false;
  bool _isLoading = false;
  String? _errorMessage;
  
  final ApiService _apiService = ApiService();
  
  final List<String> _genderOptions = ['Male', 'Female', 'Other'];
  
  DateTime _selectedDateTime = DateTime.now().add(Duration(hours: 1));
  
  // Vehicle information
  GuestVehicleModel? _guestVehicle;

  @override
  void initState() {
    super.initState();
    // Initialize the date time controller with formatted current date and time
    dateTimeController.text = DateFormat('MMM dd, yyyy - hh:mm a').format(_selectedDateTime);
  }

  @override
  void dispose() {
    nameController.dispose();
    contactController.dispose();
    dateTimeController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 30)),
    );
    
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );
      
      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          dateTimeController.text = DateFormat('MMM dd, yyyy - hh:mm a').format(_selectedDateTime);
        });
      }
    }
  }

  void _addVehicle() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GuestVehicleRegistrationPage(
          onVehicleAdded: (vehicle) {
            setState(() {
              _guestVehicle = vehicle;
            });
          },
        ),
      ),
    );
  }

  Future<void> _registerGuest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Create guest model
      final AddGuestModel guestModel = AddGuestModel(
        guestName: nameController.text.trim(),
        guestPhoneNumber: contactController.text.trim(),
        eta: _selectedDateTime.toIso8601String(),
        visitCompleted: false,
        vehicle: _hasVehicle ? _guestVehicle : null,
      );

      // Register guest and get QR code
      final String qrCodeImage = await _apiService.registerGuest(guestModel);
      
      if (mounted) {
        // Navigate to confirmation page with QR code
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GuestConfirmationPage(qrCodeImage: qrCodeImage),
          ),
        );
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
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                // Header
                const Center(
                  child: Text(
                    'Guest registration',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Divider
                Container(
                  height: 1,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 32),

                // Form fields
                _buildFormField(
                  'Name', 
                  nameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter guest name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                
                _buildFormField(
                  'Contact Number', 
                  contactController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter contact number';
                    }
                    // Simple phone validation
                    if (!RegExp(r'^\+?[0-9]{10,15}$').hasMatch(value)) {
                      return 'Please enter a valid phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                
                // Date and time picker
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Expected date and time',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF4A4A4A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _selectDateTime,
                      child: IgnorePointer(
                        child: TextField(
                          controller: dateTimeController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFFFEECEC),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            suffixIcon: Icon(Icons.calendar_today, color: Color(0xFFE57373)),
                          ),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFFE57373),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Gender dropdown
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gender',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF4A4A4A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEECEC),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: DropdownButtonFormField<String>(
                        value: _selectedGender,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                        ),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFFE57373),
                        ),
                        items: _genderOptions.map((String gender) {
                          return DropdownMenuItem<String>(
                            value: gender,
                            child: Text(gender),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedGender = newValue;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Vehicle checkbox
                Row(
                  children: [
                    Checkbox(
                      value: _hasVehicle,
                      onChanged: (value) {
                        setState(() {
                          _hasVehicle = value ?? false;
                          if (_hasVehicle && _guestVehicle == null) {
                            _addVehicle();
                          }
                        });
                      },
                      activeColor: Color(0xFFE57373),
                    ),
                    Text(
                      'Guest has a vehicle',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF4A4A4A),
                      ),
                    ),
                  ],
                ),
                
                // Vehicle details (conditional)
                if (_hasVehicle) ...[
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Vehicle Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4A4A4A),
                        ),
                      ),
                      TextButton(
                        onPressed: _addVehicle,
                        child: Text(
                          _guestVehicle == null ? 'Add Vehicle' : 'Edit Vehicle',
                          style: TextStyle(
                            color: Color(0xFFE57373),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  if (_guestVehicle != null) ...[
                    _buildVehicleInfoCard(),
                  ] else ...[
                    Center(
                      child: Text(
                        'No vehicle information added yet',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ],
                
                const SizedBox(height: 32),
                
                // Error message
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),

                // Submit Button
                Center(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _registerGuest,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD5A3A3), // Pink/rose color
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      minimumSize: const Size(120, 40),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,),
                          )
                        : const Text(
                            'Submit',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleInfoCard() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFFFF1ED),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFFE57373).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildVehicleInfoRow('Vehicle Name', _guestVehicle?.vehicleName ?? ''),
          _buildVehicleInfoRow('Model', _guestVehicle?.vehicleModel ?? ''),
          _buildVehicleInfoRow('Type', _guestVehicle?.vehicleType ?? ''),
          _buildVehicleInfoRow('License Plate', _guestVehicle?.vehicleLicensePlateNumber ?? ''),
          _buildVehicleInfoRow('Color', _guestVehicle?.vehicleColor ?? ''),
          if (_guestVehicle?.vehicleRFIDTagId != null)
            _buildVehicleInfoRow('RFID Tag', _guestVehicle?.vehicleRFIDTagId ?? ''),
        ],
      ),
    );
  }

  Widget _buildVehicleInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Color(0xFF4A4A4A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormField(
    String label, 
    TextEditingController controller, {
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF4A4A4A),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFFEECEC), // Light pink background
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFFE57373), // Pink text color to match the design
          ),
          validator: validator,
        ),
      ],
    );
  }
}
