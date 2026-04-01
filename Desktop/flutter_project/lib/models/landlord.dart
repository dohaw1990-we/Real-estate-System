class Landlord {
  final String id;
  final String fullName;
  final String phone;
  final String email;
  final String address;
  final String nationalId;

  const Landlord({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.email,
    required this.address,
    required this.nationalId,
  });

  factory Landlord.fromJson(Map<String, dynamic> json) {
    return Landlord(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String,
      address: json['address'] as String,
      nationalId: json['nationalId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'phone': phone,
      'email': email,
      'address': address,
      'nationalId': nationalId,
    };
  }
}
