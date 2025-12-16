// lib/models/create_profile_model.dart
class CreateProfileModel {
  final String? userid;
  final String firstname;
  final String lastname;
  final String phone;
  final String cnic;
  final String email;
  
  // Residence fields
  final String address;
  final String block;
  final String residence;
  final String residenceType;
  
  // ✅ Add this field
  final bool isApprovedBySociety;

  CreateProfileModel({
    this.userid,
    required this.firstname,
    required this.lastname,
    required this.phone,
    required this.cnic,
    required this.email,
    required this.address,
    required this.block,
    required this.residence,
    required this.residenceType,
    this.isApprovedBySociety = false,  // ✅ Default to false
  });

  factory CreateProfileModel.fromJson(Map<String, dynamic> json) {
    // Handle nested residence object
    final residenceData = json['residence'] as Map<String, dynamic>?;
    
    return CreateProfileModel(
      userid: json['userid'] as String?,
      firstname: json['firstname'] as String? ?? '',
      lastname: json['lastname'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      cnic: json['cnic'] as String? ?? '',
      email: json['email'] as String? ?? '',
      address: residenceData?['addressLine1'] as String? ?? '',
      block: residenceData?['block'] as String? ?? '',
      residence: residenceData?['residence'] as String? ?? '',
      residenceType: residenceData?['residenceType'] as String? ?? '',
      // ✅ Extract approval status
      isApprovedBySociety: json['isApprovedBySociety'] as bool? ?? 
                          residenceData?['isApprovedBySociety'] as bool? ?? 
                          false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (userid != null) 'userid': userid,
      'firstname': firstname,
      'lastname': lastname,
      'phone': phone,
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
}
