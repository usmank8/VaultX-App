class GuestModel {
  final String guestId;
  final String guestName;
  final DateTime eta;
  final String? vehicleId;
  final String? vehicleModel;
  final String? vehicleLicensePlateNumber;
  final String? vehicleColor;
  final bool? isGuest;

  GuestModel({
    required this.guestId,
    required this.guestName,
    required this.eta,
    this.vehicleId,
    this.vehicleModel,
    this.vehicleLicensePlateNumber,
    this.vehicleColor,
    this.isGuest,
  });

  factory GuestModel.fromJson(Map<String, dynamic> json) {
    return GuestModel(
      guestId: json['guestId'] ?? '',
      guestName: json['guestName'] ?? '',
      eta: json['eta'] != null ? DateTime.parse(json['eta']) : DateTime.now(),
      vehicleId: json['vehicleId'],
      vehicleModel: json['vehicleModel'],
      vehicleLicensePlateNumber: json['vehicleLicensePlateNumber'],
      vehicleColor: json['vehicleColor'],
      isGuest: json['isGuest'],
    );
  }
}

class GuestVehicleModel {
  final String vehicleName;
  final String vehicleModel;
  final String vehicleType;
  final String vehicleLicensePlateNumber;
  final String? vehicleRFIDTagId;
  final String vehicleColor;

  GuestVehicleModel({
    required this.vehicleName,
    required this.vehicleModel,
    required this.vehicleType,
    required this.vehicleLicensePlateNumber,
    this.vehicleRFIDTagId,
    required this.vehicleColor,
  });

  Map<String, dynamic> toJson() {
    return {
      'vehicleName': vehicleName,
      'vehicleModel': vehicleModel,
      'vehicleType': vehicleType,
      'vehicleLicensePlateNumber': vehicleLicensePlateNumber,
      'vehicleRFIDTagId': vehicleRFIDTagId,
      'vehicleColor': vehicleColor,
    };
  }
}

class AddGuestModel {
  final String guestName;
  final String guestPhoneNumber;
  final String eta;
  final bool? visitCompleted;
  final GuestVehicleModel? vehicle;

  AddGuestModel({
    required this.guestName,
    required this.guestPhoneNumber,
    required this.eta,
    this.visitCompleted,
    this.vehicle,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'guestName': guestName,
      'guestPhoneNumber': guestPhoneNumber,
      'eta': eta,
    };

    if (visitCompleted != null) {
      data['visitCompleted'] = visitCompleted;
    }

    if (vehicle != null) {
      data['vehicle'] = vehicle!.toJson();
    }

    return data;
  }
}
