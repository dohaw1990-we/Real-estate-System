class Tenant {
  final String id;
  final String fullName;
  final String phone;
  final String email;
  final String currentAddress;
  final String nationalId;
  final String emergencyContactName;
  final String emergencyContactPhone;

  const Tenant({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.email,
    required this.currentAddress,
    required this.nationalId,
    required this.emergencyContactName,
    required this.emergencyContactPhone,
  });

  factory Tenant.fromJson(Map<String, dynamic> json) {
    return Tenant(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String,
      currentAddress: json['currentAddress'] as String,
      nationalId: json['nationalId'] as String,
      emergencyContactName: json['emergencyContactName'] as String,
      emergencyContactPhone: json['emergencyContactPhone'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'phone': phone,
      'email': email,
      'currentAddress': currentAddress,
      'nationalId': nationalId,
      'emergencyContactName': emergencyContactName,
      'emergencyContactPhone': emergencyContactPhone,
    };
  }
}
