import 'package:flutter/material.dart';
import 'package:vaultx_solution/loading/loading.dart';
import 'package:vaultx_solution/models/create_profile_model.dart';
import 'package:vaultx_solution/models/update_profile_model.dart';
import 'package:vaultx_solution/services/api_service.dart';
import 'package:vaultx_solution/widgets/custom_app_bar.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _cnicCtrl = TextEditingController();
  final _blockCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  String? _residenceChoice;
  String? _residenceTypeChoice;

  final _api = ApiService();
  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;
  CreateProfileModel? _profile;

  // Define required fields for validation
  final List<String> _residenceOptions = ['House', 'Apartment', 'Flat'];
  final List<String> _residenceTypeOptions = ['Owned', 'Rented'];

  // Helper to get the matching dropdown value from options (case-insensitive)
  String _getDropdownValue(String? value, List<String> options) {
    if (value == null) return options.first;
    final match = options.firstWhere(
      (opt) => opt.toLowerCase() == value.toLowerCase(),
      orElse: () => options.first,
    );
    return match;
  }

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCtrl.dispose();
    _cnicCtrl.dispose();
    _blockCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final profile = await _api.getProfile();
      if (profile != null) {
        setState(() {
          _profile = profile;
          _firstNameCtrl.text = profile.firstname;
          _lastNameCtrl.text = profile.lastname;
          _phoneCtrl.text = profile.phonenumber;
          _cnicCtrl.text = profile.cnic;
          _addressCtrl.text = profile.address;
          _blockCtrl.text = profile.block;
          _residenceChoice =
              _getDropdownValue(profile.residence, _residenceOptions);
          _residenceTypeChoice =
              _getDropdownValue(profile.residenceType, _residenceTypeOptions);
        });
      } else {
        setState(() {
          _error = 'Profile not found';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading profile: \\${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
      _error = null;
    });

    try {
      // Create an update model with the changed fields
      final updatedProfile = UpdateProfileModel(
        firstname: _firstNameCtrl.text.trim(),
        lastname: _lastNameCtrl.text.trim(),
        phonenumber: _phoneCtrl.text.trim(),
        cnic: _cnicCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
        block: _blockCtrl.text.trim(),
        residence: _residenceChoice,
        residenceType: _residenceTypeChoice,
      );

      // Use the new updateProfile method instead of createProfile
      await _api.updateProfile(updatedProfile);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 10),
              Text('Profile updated successfully!'),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );

      // Navigate back
      Navigator.pop(
          context, true); // Return true to indicate profile was updated
    } catch (e) {
      setState(() {
        _error = 'Error updating profile: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: CustomAppBar(
          showBackButton: true,
          userProfile: _profile,
          actions: [],
        ),
      ),
      body: _isLoading
          ? Center(child: UnderReviewScreen())
          : _error != null && _profile == null
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
                        onPressed: _loadProfile,
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Edit Profile',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF600f0f),
                          ),
                        ),
                        SizedBox(height: 24),

                        // Profile picture
                        Center(
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundColor: Color(0xFFE6E9F5),
                                child: Text(
                                  _firstNameCtrl.text.isNotEmpty
                                      ? _firstNameCtrl.text[0].toUpperCase()
                                      : 'U',
                                  style: TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF6D213C),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Color(0xFFD6A19F),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 24),

                        // First & Last Name
                        Row(
                          children: [
                            Expanded(
                              child: _buildInput(_firstNameCtrl,
                                  label: "First Name"),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: _buildInput(_lastNameCtrl,
                                  label: "Last Name"),
                            ),
                          ],
                        ),

                        _buildInput(_phoneCtrl,
                            label: "Phone Number",
                            helperText: "Format: +92XXXXXXXXXX or 03XXXXXXXXX"),
                        _buildInput(_cnicCtrl,
                            label: "CNIC Number",
                            helperText: "13 digits without dashes"),
                        _buildInput(_blockCtrl, label: "Block"),
                        _buildInput(_addressCtrl,
                            label: "Street Number / Address"),

                        _buildDropdown(
                          label: "Residence",
                          value: _residenceChoice,
                          options: _residenceOptions,
                          onChanged: (v) {
                            setState(() => _residenceChoice =
                                _getDropdownValue(v, _residenceOptions));
                          },
                        ),

                        _buildDropdown(
                          label: "Residence Type",
                          value: _residenceTypeChoice,
                          options: _residenceTypeOptions,
                          onChanged: (v) {
                            setState(() => _residenceTypeChoice =
                                _getDropdownValue(v, _residenceTypeOptions));
                          },
                        ),

                        SizedBox(height: 24),

                        if (_error != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Text(_error!,
                                style: const TextStyle(color: Colors.red)),
                          ),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isSaving ? null : _saveProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD6A19F),
                              disabledBackgroundColor: Colors.grey.shade300,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: _isSaving
                                ? UnderReviewScreen()
                                : Text(
                                    "Save Changes",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildInput(
    TextEditingController ctrl, {
    required String label,
    String? helperText,
  }) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          TextFormField(
            controller: ctrl,
            decoration: InputDecoration(
              hintText: label,
              helperText: helperText,
              helperStyle: TextStyle(color: Colors.grey.shade700, fontSize: 12),
              filled: true,
              fillColor: const Color(0xFFFFF1ED),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'This field is required';
              }

              if (label == "CNIC Number") {
                final RegExp cnicRegex = RegExp(r'^\d{13}$');
                if (!cnicRegex.hasMatch(value.trim())) {
                  return 'CNIC must be 13 digits';
                }
              }

              if (label == "Phone Number") {
                final RegExp phoneRegex =
                    RegExp(r'^\+?92[0-9]{10}$|^0[0-9]{10}$');
                if (!phoneRegex.hasMatch(value.trim())) {
                  return 'Please enter a valid Pakistani phone number';
                }
              }

              return null;
            },
          ),
        ]),
      );

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1ED),
              borderRadius: BorderRadius.circular(24),
            ),
            child: DropdownButtonFormField<String>(
              value: value != null && options.contains(value)
                  ? value
                  : options.first,
              decoration: const InputDecoration(border: InputBorder.none),
              hint: Text(label),
              items: options
                  .map((opt) => DropdownMenuItem(value: opt, child: Text(opt)))
                  .toList(),
              onChanged: onChanged,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a $label';
                }
                return null;
              },
            ),
          ),
        ]),
      );
}
