// lib/models/create_profile_model.dart
class CreateProfileModel {
  final String firstname;
  final String lastname;
  final String phonenumber;
  final String cnic;
  final String address;
  final String block;
  final String residence;
  final String residenceType;
  final String email;

  CreateProfileModel({
    required this.firstname,
    required this.lastname,
    required this.phonenumber,
    required this.cnic,
    required this.address,
    required this.block,
    required this.residence,
    required this.residenceType,
    required this.email,
  });

  // Add validation methods to match backend requirements
  bool isValid() {
    return firstname.isNotEmpty &&
        lastname.isNotEmpty &&
        isValidPhoneNumber() &&
        isValidCNIC() &&
        isValidResidence() &&
        isValidResidenceType() &&
        block.isNotEmpty &&
        address.isNotEmpty;
  }

  bool isValidPhoneNumber() {
    // Pakistani phone number validation
    final RegExp phoneRegex = RegExp(r'^\+?92[0-9]{10}$|^0[0-9]{10}$');
    return phoneRegex.hasMatch(phonenumber);
  }

  bool isValidCNIC() {
    // CNIC must be 13 digits
    final RegExp cnicRegex = RegExp(r'^\d{13}$');
    return cnicRegex.hasMatch(cnic);
  }

  bool isValidResidence() {
    // Must be one of the enum values from backend
    return ['apartment', 'flat', 'house'].contains(residence.toLowerCase());
  }

  bool isValidResidenceType() {
    // Must be one of the enum values from backend
    return ['rented', 'owned'].contains(residenceType.toLowerCase());
  }

  factory CreateProfileModel.fromJson(Map<String, dynamic> json) {
    // Handle the nested structure from backend
    final residence = json['residence'] ?? {};
    return CreateProfileModel(
      firstname: json['firstname'] ?? '',
      lastname: json['lastname'] ?? '',
      phonenumber: json['phone'] ?? '',
      cnic: json['cnic'] ?? '',
      address: residence['addressLine1'] ?? '',
      block: residence['block'] ?? '',
      residence: residence['residence'] ?? '',
      residenceType: residence['residenceType'] ?? '',
      email: json['email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'firstname': firstname,
        'lastname': lastname,
        'phone': phonenumber,
        'cnic': cnic,
        'email': email,
        'residence': {
          'addressLine1': address,
          'block': block,
          'residence': residence,
          'residenceType': residenceType,
        },
      };
}
