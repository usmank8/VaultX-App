// lib/models/update_profile_model.dart
class UpdateProfileModel {
  final String? firstname;
  final String? lastname;
  final String? phonenumber;
  final String? cnic;
  final String? address;
  final String? block;
  final String? residence;
  final String? residenceType;

  UpdateProfileModel({
    this.firstname,
    this.lastname,
    this.phonenumber,
    this.cnic,
    this.address,
    this.block,
    this.residence,
    this.residenceType,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    
    if (firstname != null) data['firstname'] = firstname;
    if (lastname != null) data['lastname'] = lastname;
    if (phonenumber != null) data['phonenumber'] = phonenumber;
    if (cnic != null) data['cnic'] = cnic;
    if (address != null) data['address'] = address;
    if (block != null) data['block'] = block;
    if (residence != null) data['residence'] = residence!.toLowerCase();
    if (residenceType != null) data['residenceType'] = residenceType!.toLowerCase();
    
    return data;
  }
}
