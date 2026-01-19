class ResidenceModel {
  final String id;
  final String residence;
  final String residenceType;
  final String block;
  final String address;
  final bool isPrimary;
  final bool? isApprovedBySociety;
  final int? guestCount;
  final int? vehicleCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ResidenceModel({
    required this.id,
    required this.residence,
    required this.residenceType,
    required this.block,
    required this.address,
    required this.isPrimary,
    this.isApprovedBySociety,
    this.guestCount,
    this.vehicleCount,
    this.createdAt,
    this.updatedAt,
  });

  factory ResidenceModel.fromJson(Map<String, dynamic> json) {
    return ResidenceModel(
      id: json['id'] as String,
      residence: json['residence'] as String? ?? json['Residence1'] as String? ?? '',
      residenceType: json['residenceType'] as String? ?? json['ResidenceType'] as String? ?? '',
      block: json['block'] as String? ?? json['Block'] as String? ?? '',
      address: json['address'] as String? ?? json['AddressLine1'] as String? ?? '',
      isPrimary: json['isPrimary'] as bool? ?? json['IsPrimary'] as bool? ?? false,
      isApprovedBySociety: json['isApprovedBySociety'] as bool? ?? json['IsApprovedBySociety'] as bool?,
      guestCount: json['guestCount'] as int? ?? json['vehicleCount'] as int?,
      vehicleCount: json['vehicleCount'] as int?,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String) 
          : json['CreatedAt'] != null 
          ? DateTime.parse(json['CreatedAt'] as String) 
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String) 
          : json['UpdatedAt'] != null 
          ? DateTime.parse(json['UpdatedAt'] as String) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'residence': residence,
      'residenceType': residenceType,
      'block': block,
      'address': address,
      'isPrimary': isPrimary,
      if (isApprovedBySociety != null) 'isApprovedBySociety': isApprovedBySociety,
      if (guestCount != null) 'guestCount': guestCount,
      if (vehicleCount != null) 'vehicleCount': vehicleCount,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  String get displayName => '$residence - Block $block';
  
  bool get isApproved => isApprovedBySociety ?? false;
}

/// DTO for adding new residence
class AddResidenceDto {
  final String residence;
  final String residenceType;
  final String block;
  final String address;

  AddResidenceDto({
    required this.residence,
    required this.residenceType,
    required this.block,
    required this.address,
  });

  Map<String, dynamic> toJson() {
    return {
      'residence': residence,
      'residenceType': residenceType,
      'block': block,
      'address': address,
    };
  }
}

/// DTO for adding secondary residence
class AddSecondaryResidenceDto {
  final String? addressLine1;
  final String? addressLine2;
  final String residenceType;
  final String residence1;
  final bool? isPrimary;
  final bool isApprovedBySociety;
  final String? approvedBy;
  final String? flatNumber;
  final String? block;
  final String? userid;
  final DateTime? approvedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  AddSecondaryResidenceDto({
    this.addressLine1,
    this.addressLine2,
    required this.residenceType,
    required this.residence1,
    this.isPrimary,
    required this.isApprovedBySociety,
    this.approvedBy,
    this.flatNumber,
    this.block,
    this.userid,
    this.approvedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'AddressLine1': addressLine1,
      'AddressLine2': addressLine2,
      'ResidenceType': residenceType,
      'Residence1': residence1,
      'IsPrimary': isPrimary,
      'IsApprovedBySociety': isApprovedBySociety,
      'ApprovedBy': approvedBy,
      'FlatNumber': flatNumber,
      'Block': block,
      'Userid': userid,
      'ApprovedAt': approvedAt?.toIso8601String(),
      'CreatedAt': createdAt.toIso8601String(),
      'UpdatedAt': updatedAt.toIso8601String(),
    };
  }
}