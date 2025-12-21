class GuestModel {
  final String guestId;
  final String guestName;
  final String guestPhoneNumber;
  final DateTime eta;
  final DateTime? checkoutTime;
  final String? status;
  final bool? visitCompleted;
  final bool? isVerified;
  final String? qrCode;
  final String? vehicleId;
  final String? vehicleModel;
  final String? vehicleLicensePlateNumber;
  final String? vehicleColor;
  final bool? isGuest;

  GuestModel({
    required this.guestId,
    required this.guestName,
    required this.guestPhoneNumber,
    required this.eta,
    this.checkoutTime,
    this.status,
    this.visitCompleted,
    this.isVerified,
    this.qrCode,
    this.vehicleId,
    this.vehicleModel,
    this.vehicleLicensePlateNumber,
    this.vehicleColor,
    this.isGuest,
  });

  // Computed property - check if guest is expired based on checkoutTime
  bool get isExpired {
    if (checkoutTime == null) return false;
    return DateTime.now().isAfter(checkoutTime!);
  }

  factory GuestModel.fromJson(Map<String, dynamic> json) {
    return GuestModel(
      guestId: json['guestId'] ?? '',
      guestName: json['guestName'] ?? '',
      guestPhoneNumber: json['guestPhoneNumber'] ?? '',
      eta: json['eta'] != null ? DateTime.parse(json['eta']) : DateTime.now(),
      checkoutTime: json['checkoutTime'] != null ? DateTime.parse(json['checkoutTime']) : null,
      status: json['status'],
      visitCompleted: json['visitCompleted'],
      isVerified: json['isVerified'],
      qrCode: json['qrCode'],
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
