class VehicleModel {
  final String vehicleName;
  final String vehicleModel;
  final String vehicleLicensePlateNumber;
  final String vehicleType;
  final String RFIDTagID;
  final String vehicleColor;
  final bool isGuest;

  VehicleModel({
    required this.vehicleName,
    required this.vehicleModel,
    required this.vehicleLicensePlateNumber,
    required this.vehicleType,
    required this.RFIDTagID,
    required this.vehicleColor,
    this.isGuest = false,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      vehicleName: json['vehicleName'] ?? '',
      vehicleModel: json['vehicleModel'] ?? '',
      vehicleLicensePlateNumber: json['vehicleLicensePlateNumber'] ?? '',
      vehicleType: json['vehicleType'] ?? '',
      RFIDTagID: json['vehicleRFIDTagId'] ?? '',
      vehicleColor: json['vehicleColor'] ?? '',
      isGuest: json['isGuest'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vehicleName': vehicleName,
      'vehicleModel': vehicleModel,
      'vehicleLicensePlateNumber': vehicleLicensePlateNumber,
      'vehicleType': vehicleType,
      'RFIDTagID': RFIDTagID,
      'vehicleColor': vehicleColor,
    };
  }
}
