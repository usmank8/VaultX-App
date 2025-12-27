class VehicleModel {
  final String? vehicleId;
  final String? vehicleName;
  final String? vehicleModel;
  final String? vehicleType;
  final String? vehicleLicensePlateNumber;
  final String? vehicleRfidTagId;
  final String? vehicleColor;
  final String? residenceId;
  final String? residenceName;
  final String? residenceBlock;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  VehicleModel({
    this.vehicleId,
    this.vehicleName,
    this.vehicleModel,
    this.vehicleType,
    this.vehicleLicensePlateNumber,
    this.vehicleRfidTagId,
    this.vehicleColor,
    this.residenceId,
    this.residenceName,
    this.residenceBlock,
    this.createdAt,
    this.updatedAt,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      vehicleId: json['vehicleId'] as String?,
      vehicleName: json['vehicleName'] as String?,
      vehicleModel: json['vehicleModel'] as String?,
      vehicleType: json['vehicleType'] as String?,
      vehicleLicensePlateNumber: json['vehicleLicensePlateNumber'] as String?,
      vehicleRfidTagId: json['vehicleRfidtagId'] as String? ??
                        json['vehicleRfidTagId'] as String? ??
                        json['vehicleRFIDTagId'] as String?,
      vehicleColor: json['vehicleColor'] as String?,
      residenceId: json['residenceId']?.toString(),
      residenceName: json['residenceName'] as String?,
      residenceBlock: json['residenceBlock'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (vehicleId != null) 'vehicleId': vehicleId,
      'vehicleName': vehicleName,
      if (vehicleModel != null) 'vehicleModel': vehicleModel,
      'vehicleType': vehicleType,
      'vehicleLicensePlateNumber': vehicleLicensePlateNumber,
      if (vehicleRfidTagId != null) 'vehicleRfidTagId': vehicleRfidTagId,
      if (vehicleColor != null) 'vehicleColor': vehicleColor,
      if (residenceId != null) 'residenceId': residenceId,
    };
  }
}
