class GuestModel {
  final String guestId;
  final String guestName;
  final String guestPhoneNumber;
  final String? gender;
  final DateTime? eta;
  final DateTime? checkoutTime;
  final DateTime? actualArrivalTime;
  final String? status;
  final String? qrCode;
  final bool? isVerified;
  final bool? visitCompleted;
  final String? residenceId;
  final String? residenceName;
  final DateTime? createdAt;
  final String? vehicleId;
  final String? vehicleModel;
  final String? vehicleLicensePlateNumber;
  final String? vehicleColor;

  GuestModel({
    required this.guestId,
    required this.guestName,
    required this.guestPhoneNumber,
    this.gender,
    this.eta,
    this.checkoutTime,
    this.actualArrivalTime,
    this.status,
    this.qrCode,
    this.isVerified,
    this.visitCompleted,
    this.residenceId,
    this.residenceName,
    this.createdAt,
    this.vehicleId,
    this.vehicleModel,
    this.vehicleLicensePlateNumber,
    this.vehicleColor,
  });

  factory GuestModel.fromJson(Map<String, dynamic> json) {
    return GuestModel(
      guestId: json['guestId'] as String? ?? '',
      guestName: json['guestName'] as String? ?? '',
      guestPhoneNumber: json['guestPhoneNumber'] as String? ?? '',
      gender: json['gender'] as String?,
      eta: json['eta'] != null ? DateTime.tryParse(json['eta'] as String) : null,
      checkoutTime: json['checkoutTime'] != null 
          ? DateTime.tryParse(json['checkoutTime'] as String) 
          : null,
      actualArrivalTime: json['actualArrivalTime'] != null 
          ? DateTime.tryParse(json['actualArrivalTime'] as String) 
          : null,
      status: json['status'] as String?,
      qrCode: json['qrCode'] as String?,
      isVerified: json['isVerified'] as bool?,
      visitCompleted: json['visitCompleted'] as bool?,
      residenceId: json['residenceId']?.toString(),
      residenceName: json['residenceName'] as String?,
      createdAt: json['createdAt'] != null 
          ? DateTime.tryParse(json['createdAt'] as String) 
          : null,
      vehicleId: json['vehicleId'] as String?,
      vehicleModel: json['vehicleModel'] as String?,
      vehicleLicensePlateNumber: json['vehicleLicensePlateNumber'] as String?,
      vehicleColor: json['vehicleColor'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'guestId': guestId,
      'guestName': guestName,
      'guestPhoneNumber': guestPhoneNumber,
      if (gender != null) 'gender': gender,
      if (eta != null) 'eta': eta!.toIso8601String(),
      if (checkoutTime != null) 'checkoutTime': checkoutTime!.toIso8601String(),
      if (residenceId != null) 'residenceId': residenceId,
    };
  }

  bool get isExpired {
    if (checkoutTime == null) return false;
    return checkoutTime!.isBefore(DateTime.now());
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
  final String? residenceId;
  final String? gender;

  AddGuestModel({
    required this.guestName,
    required this.guestPhoneNumber,
    required this.eta,
    this.visitCompleted,
    this.vehicle,
    this.residenceId,
    this.gender,
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

    if (residenceId != null) {
      data['residenceId'] = residenceId;
    }

    if (gender != null) {
      data['gender'] = gender;
    }

    return data;
  }
}
