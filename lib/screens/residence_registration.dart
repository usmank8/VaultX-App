import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:vaultx_solution/loading/loading.dart';
import 'package:vaultx_solution/models/residence_model.dart';
import 'package:vaultx_solution/services/api_service.dart';
import 'package:vaultx_solution/widgets/custom_app_bar.dart';

class ResidenceRegistrationPage extends StatefulWidget {
  const ResidenceRegistrationPage({super.key});

  @override
  _ResidenceRegistrationPageState createState() => _ResidenceRegistrationPageState();
}

class _ResidenceRegistrationPageState extends State<ResidenceRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _addressLine1Controller = TextEditingController();
  final _addressLine2Controller = TextEditingController();
  final _flatNumberController = TextEditingController();
  final _blockController = TextEditingController();
  String _residence = 'House'; // Default value
  String _residenceType = 'Owned'; // Default value
  
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  String? _errorMessage;
  
  final List<String> _residenceOptions = ['House', 'Apartment', 'Flat', 'Villa', 'Other'];
  final List<String> _residenceTypes = ['Owned', 'Rented'];

  @override
  void dispose() {
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _flatNumberController.dispose();
    _blockController.dispose();
    super.dispose();
  }

  Future<void> _submitResidence() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get current user ID
      final profile = await _apiService.getProfile();
      if (profile == null || profile.userid == null) {
        throw Exception('Unable to get user information. Please login again.');
      }

      // Generate unique ID
      const uuid = Uuid();
      final residenceId = uuid.v4();

      final dto = AddSecondaryResidenceDto(
        addressLine1: _addressLine1Controller.text.trim(),
        addressLine2: _addressLine2Controller.text.trim().isEmpty ? null : _addressLine2Controller.text.trim(),
        residenceType: _residenceType,
        residence1: _residence,
        isPrimary: false,
        isApprovedBySociety: false,
        flatNumber: _flatNumberController.text.trim().isEmpty ? null : _flatNumberController.text.trim(),
        block: _blockController.text.trim(),
        userid: profile.userid,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _apiService.addSecondaryResidence(dto);
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 10),
                Text('Secondary residence added successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        
        // Navigate back
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
                'Add Secondary Residence',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF600f0f),
                ),
              ),
              SizedBox(height: 24),
              
              _buildDropdown(
                label: "Residence",
                value: _residence,
                items: _residenceOptions,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _residence = value;
                    });
                  }
                },
              ),
              
              _buildDropdown(
                label: "Residence Type",
                value: _residenceType,
                items: _residenceTypes,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _residenceType = value;
                    });
                  }
                },
              ),
              
              _buildInputField(
                controller: _blockController,
                label: "Block",
                hint: "Enter block (e.g., A, B, C)",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter block';
                  }
                  return null;
                },
              ),
              
              _buildInputField(
                controller: _addressLine1Controller,
                label: "Address Line 1",
                hint: "Enter address line 1",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter address line 1';
                  }
                  return null;
                },
              ),
              
              _buildInputField(
                controller: _addressLine2Controller,
                label: "Address Line 2 (Optional)",
                hint: "Enter address line 2",
                validator: (value) => null, // Optional
              ),
              
              _buildInputField(
                controller: _flatNumberController,
                label: "Flat Number (Optional)",
                hint: "Enter flat number",
                validator: (value) => null, // Optional
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
                  onPressed: _isLoading ? null : _submitResidence,
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