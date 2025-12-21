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
      residence: json['residence'] as String? ?? '',
      residenceType: json['residenceType'] as String? ?? '',
      block: json['block'] as String? ?? '',
      address: json['address'] as String? ?? json['addressLine1'] as String? ?? '',
      isPrimary: json['isPrimary'] as bool? ?? false,
      isApprovedBySociety: json['isApprovedBySociety'] as bool?,
      guestCount: json['guestCount'] as int? ?? json['vehicleCount'] as int?,
      vehicleCount: json['vehicleCount'] as int?,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String) 
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String) 
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