import 'package:flutter/material.dart';
import 'package:vaultx_solution/auth/screens/loginscreen.dart';
import 'package:vaultx_solution/loading/loading.dart';
import 'package:vaultx_solution/models/create_profile_model.dart';
import 'package:vaultx_solution/models/update_profile_model.dart';
import 'package:vaultx_solution/services/api_service.dart';
import 'package:vaultx_solution/screens/home_page.dart'; 
import 'package:vaultx_solution/screens/pending_approval_screen.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';

class ProfileRegistrationPage extends StatefulWidget {
  const ProfileRegistrationPage({super.key});

  @override
  _ProfileRegistrationPageState createState() =>
      _ProfileRegistrationPageState();
}

class _ProfileRegistrationPageState extends State<ProfileRegistrationPage> {
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _cnicCtrl = TextEditingController();
  final _blockCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  String? _residenceChoice;
  String? _residenceTypeChoice;

  final _api = ApiService();
  bool _loading = false;
  String? _error;
  double _completionPercentage = 0.0;

  CreateProfileModel? _existingProfile;

  final List<String> _residenceOptions = ['House', 'Apartment', 'Flat'];
  final List<String> _residenceTypeOptions = ['Owned', 'Rented'];

  @override
  void initState() {
    super.initState();

    // Check if profile already exists, if so redirect to dashboard
    _checkExistingProfile();

    // Set default values for dropdowns
    setState(() {
      _residenceChoice = 'house';
      _residenceTypeChoice = 'owned';
    });

    // Add listeners to all text controllers to update completion percentage
    _firstNameCtrl.addListener(_updateCompletionPercentage);
    _lastNameCtrl.addListener(_updateCompletionPercentage);
    _phoneCtrl.addListener(_updateCompletionPercentage);
    _cnicCtrl.addListener(_updateCompletionPercentage);
    _blockCtrl.addListener(_updateCompletionPercentage);
    _addressCtrl.addListener(_updateCompletionPercentage);
  }

  // Add this new method to check for existing profile
  Future<void> _checkExistingProfile() async {
    try {
      final profile = await _api.getProfile();
      if (profile != null && mounted) {
        // If only email is present and all other fields are empty, treat as no profile
        final onlyEmailPresent = profile.email.isNotEmpty &&
            profile.firstname.isEmpty &&
            profile.lastname.isEmpty &&
            profile.phonenumber.isEmpty &&
            profile.cnic.isEmpty &&
            profile.address.isEmpty &&
            profile.block.isEmpty &&
            profile.residence.isEmpty &&
            profile.residenceType.isEmpty;
        if (onlyEmailPresent) {
          // Do not prefill or set _existingProfile, treat as new profile
          return;
        }
        _existingProfile = profile;
        // Prefill fields with existing data
        _firstNameCtrl.text = profile.firstname;
        _lastNameCtrl.text = profile.lastname;
        _phoneCtrl.text = profile.phonenumber;
        _cnicCtrl.text = profile.cnic;
        _blockCtrl.text = profile.block;
        _addressCtrl.text = profile.address;
        _residenceChoice = profile.residence;
        _residenceTypeChoice = profile.residenceType;

        // Check if all required fields are filled
        final allFieldsFilled = profile.firstname.isNotEmpty &&
            profile.lastname.isNotEmpty &&
            profile.phonenumber.isNotEmpty &&
            profile.cnic.isNotEmpty &&
            profile.address.isNotEmpty &&
            profile.block.isNotEmpty &&
            profile.residence.isNotEmpty &&
            profile.residenceType.isNotEmpty &&
            profile.email.isNotEmpty;

        if (allFieldsFilled) {
          // Profile exists and is complete, navigate to dashboard
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Profile already exists. Redirecting to dashboard.'),
              backgroundColor: Colors.green,
            ),
          );

          // Short delay to show the message
          Future.delayed(Duration(seconds: 1), () {
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const DashboardPage()),
              );
            }
          });
        }
        // else: stay on profile registration with prefilled fields
      }
    } catch (e) {
      debugPrint('Error checking existing profile: $e');
    }
  }

  @override
  void dispose() {
    // Remove listeners before disposing controllers
    _firstNameCtrl.removeListener(_updateCompletionPercentage);
    _lastNameCtrl.removeListener(_updateCompletionPercentage);
    _phoneCtrl.removeListener(_updateCompletionPercentage);
    _cnicCtrl.removeListener(_updateCompletionPercentage);
    _blockCtrl.removeListener(_updateCompletionPercentage);
    _addressCtrl.removeListener(_updateCompletionPercentage);

    // Dispose controllers
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCtrl.dispose();
    _cnicCtrl.dispose();
    _blockCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  void _updateCompletionPercentage() {
    // Total number of fields to complete
    const int totalFields = 8;
    int completedFields = 0;

    // Check each field
    if (_firstNameCtrl.text.trim().isNotEmpty) completedFields++;
    if (_lastNameCtrl.text.trim().isNotEmpty) completedFields++;

    // Phone validation (Pakistani format)
    final RegExp phoneRegex = RegExp(r'^\+?92[0-9]{10}$|^0[0-9]{10}$');
    if (phoneRegex.hasMatch(_phoneCtrl.text.trim())) completedFields++;

    // CNIC validation (13 digits)
    final RegExp cnicRegex = RegExp(r'^\d{13}$');
    if (cnicRegex.hasMatch(_cnicCtrl.text.trim())) completedFields++;

    if (_blockCtrl.text.trim().isNotEmpty) completedFields++;
    if (_addressCtrl.text.trim().isNotEmpty) completedFields++;
    if (_residenceChoice != null) completedFields++;
    if (_residenceTypeChoice != null) completedFields++;

    // Calculate percentage
    final newPercentage = completedFields / totalFields;

    // Update state if percentage changed
    if (newPercentage != _completionPercentage) {
      setState(() {
        _completionPercentage = newPercentage;
      });
    }
  }

  Future<void> _onSubmit() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    // Debug the token before submission
    _api.debugToken();

    // Validate required fields
    if (_firstNameCtrl.text.isEmpty || _lastNameCtrl.text.isEmpty) {
      setState(() {
        _error = 'First name and last name are required.';
        _loading = false;
      });
      return;
    }

    // Validate CNIC (13 digits)
    final RegExp cnicRegex = RegExp(r'^\d{13}$');
    if (!cnicRegex.hasMatch(_cnicCtrl.text.trim())) {
      setState(() {
        _error = 'CNIC must be 13 digits.';
        _loading = false;
      });
      return;
    }

    // Validate phone number (Pakistani format)
    final RegExp phoneRegex = RegExp(r'^\+?92[0-9]{10}$|^0[0-9]{10}$');
    if (!phoneRegex.hasMatch(_phoneCtrl.text.trim())) {
      setState(() {
        _error = 'Please enter a valid Pakistani phone number.';
        _loading = false;
      });
      return;
    }

    if (_residenceChoice == null || _residenceTypeChoice == null) {
      setState(() {
        _error = 'Please select residence and residence type.';
        _loading = false;
      });
      return;
    }

    final dto = CreateProfileModel(
      firstname: _firstNameCtrl.text.trim(),
      lastname: _lastNameCtrl.text.trim(),
      phonenumber: _phoneCtrl.text.trim(),
      email: _existingProfile?.email ?? '',
      cnic: _cnicCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      block: _blockCtrl.text.trim(),
      residence: _residenceChoice ?? '',
      residenceType: _residenceTypeChoice ?? '',
    );

    try {
      if (_existingProfile != null) {
        // Convert CreateProfileModel to UpdateProfileModel
        final updateDto = UpdateProfileModel(
          firstname: dto.firstname,
          lastname: dto.lastname,
          phonenumber: dto.phonenumber,
          cnic: dto.cnic,
          address: dto.address,
          block: dto.block,
          residence: dto.residence,
          residenceType: dto.residenceType,
        );
        await _api.updateProfile(updateDto);
      } else {
        // Call createProfile if no profile exists
        await _api.createProfile(dto);
      }

      if (!mounted) return;

      // Check if all required fields are filled before navigating
      final allFieldsFilled = dto.firstname.isNotEmpty &&
          dto.lastname.isNotEmpty &&
          dto.phonenumber.isNotEmpty &&
          dto.cnic.isNotEmpty &&
          dto.address.isNotEmpty &&
          dto.block.isNotEmpty &&
          dto.residence.isNotEmpty &&
          dto.residenceType.isNotEmpty &&
          dto.email.isNotEmpty;

      if (allFieldsFilled) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 10),
                Text('Profile saved successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        // Redirect to PendingApprovalScreen with no back arrow
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const PendingApprovalScreen()),
          (route) => false,
        );
      } else {
        setState(() {
          _error = 'Please fill all required fields.';
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // Helper to get a valid dropdown value from options (case-insensitive)
  String? _getDropdownValue(String? value, List<String> options) {
    if (value == null || value.isEmpty) return null;
    final match = options.firstWhere(
      (opt) => opt.toLowerCase() == value.toLowerCase(),
      orElse: () => '',
    );
    return match.isNotEmpty ? match : null;
  }

  @override
  Widget build(BuildContext context) {
    // Format completion percentage for display
    final completionText = "${(_completionPercentage * 100).toInt()}%";

    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginPage()),
            );
          },
        ),
        centerTitle: true,
        title: const Text(
          'Profile registration',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Profile completion: $completionText"),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: LinearProgressIndicator(
                value: _completionPercentage,
                minHeight: 10,
                backgroundColor: const Color(0xFFF8DADA),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Color(0xFF5C0D0D)),
              ),
            ),
            const SizedBox(height: 24),

            // First & Last Name
            Row(
              children: [
                Expanded(
                  child: _buildInput(_firstNameCtrl, label: "First Name"),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInput(_lastNameCtrl, label: "Last Name"),
                ),
              ],
            ),

            _buildInput(_phoneCtrl,
                label: "Phone Number",
                helperText: "Format: +92XXXXXXXXXX or 03XXXXXXXXX"),
            _buildInput(_cnicCtrl,
                label: "CNIC Number", helperText: "13 digits without dashes"),
            _buildInput(_blockCtrl, label: "Block"),
            _buildInput(_addressCtrl, label: "Street Number / Address"),

            _buildDropdown(
              label: "Residence",
              value: _getDropdownValue(_residenceChoice, _residenceOptions),
              options: _residenceOptions,
              onChanged: (v) {
                setState(() => _residenceChoice = v);
                _updateCompletionPercentage();
              },
            ),

            _buildDropdown(
              label: "Residence Type",
              value: _getDropdownValue(
                  _residenceTypeChoice, _residenceTypeOptions),
              options: _residenceTypeOptions,
              onChanged: (v) {
                setState(() => _residenceTypeChoice = v);
                _updateCompletionPercentage();
              },
            ),

            const SizedBox(height: 24),

            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _completionPercentage == 1.0 && !_loading
                    ? _onSubmit
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD6A19F),
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _loading
                    ? const UnderReviewScreen()
                    : Text(
                        _completionPercentage == 1.0
                            ? "Submit"
                            : "Complete all fields to continue",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _completionPercentage == 1.0
                              ? Colors.white
                              : Colors.grey.shade700,
                        ),
                      ),
              ),
            ),
          ],
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
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            TextFormField(
              controller: ctrl,
              decoration: InputDecoration(
                hintText: label,
                helperText: helperText,
                helperStyle:
                    TextStyle(color: Colors.grey.shade700, fontSize: 12),
                filled: true,
                fillColor: const Color(0xFFFFF1ED),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ]));

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) =>
      Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1ED),
                borderRadius: BorderRadius.circular(24),
              ),
              child: DropdownButtonFormField<String>(
                value: value != null && options.contains(value) ? value : null,
                decoration: const InputDecoration(border: InputBorder.none),
                hint: Text(label),
                items: options
                    .map(
                        (opt) => DropdownMenuItem(value: opt, child: Text(opt)))
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
          ]));
}
