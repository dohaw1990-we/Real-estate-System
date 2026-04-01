enum UnitStatus { vacant, occupied, maintenance }

enum UnitPurpose { residential, commercial }

class RentalUnit {
  final String id;
  final String buildingId;
  final String unitNumber;
  final int floorNumber;
  final UnitPurpose purpose;
  final UnitStatus status;
  final int bedrooms;
  final int bathrooms;
  final double areaSqm;
  final double monthlyRent;
  final double securityDeposit;

  const RentalUnit({
    required this.id,
    required this.buildingId,
    required this.unitNumber,
    required this.floorNumber,
    required this.purpose,
    required this.status,
    required this.bedrooms,
    required this.bathrooms,
    required this.areaSqm,
    required this.monthlyRent,
    required this.securityDeposit,
  });

  factory RentalUnit.fromJson(Map<String, dynamic> json) {
    return RentalUnit(
      id: json['id'] as String,
      buildingId: json['buildingId'] as String,
      unitNumber: json['unitNumber'] as String,
      floorNumber: json['floorNumber'] as int,
      purpose: UnitPurpose.values.firstWhere(
        (value) => value.name == json['purpose'],
        orElse: () => UnitPurpose.residential,
      ),
      status: UnitStatus.values.firstWhere(
        (value) => value.name == json['status'],
        orElse: () => UnitStatus.vacant,
      ),
      bedrooms: json['bedrooms'] as int,
      bathrooms: json['bathrooms'] as int,
      areaSqm: (json['areaSqm'] as num).toDouble(),
      monthlyRent: (json['monthlyRent'] as num).toDouble(),
      securityDeposit: (json['securityDeposit'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'buildingId': buildingId,
      'unitNumber': unitNumber,
      'floorNumber': floorNumber,
      'purpose': purpose.name,
      'status': status.name,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'areaSqm': areaSqm,
      'monthlyRent': monthlyRent,
      'securityDeposit': securityDeposit,
    };
  }
}
