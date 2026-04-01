class Building {
  final String id;
  final String name;
  final String city;
  final String area;
  final String streetAddress;
  final String landlordId;
  final int floorsCount;
  final int unitsCount;

  const Building({
    required this.id,
    required this.name,
    required this.city,
    required this.area,
    required this.streetAddress,
    required this.landlordId,
    required this.floorsCount,
    required this.unitsCount,
  });

  factory Building.fromJson(Map<String, dynamic> json) {
    return Building(
      id: json['id'] as String,
      name: json['name'] as String,
      city: json['city'] as String,
      area: json['area'] as String,
      streetAddress: json['streetAddress'] as String,
      landlordId: json['landlordId'] as String,
      floorsCount: json['floorsCount'] as int,
      unitsCount: json['unitsCount'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'city': city,
      'area': area,
      'streetAddress': streetAddress,
      'landlordId': landlordId,
      'floorsCount': floorsCount,
      'unitsCount': unitsCount,
    };
  }
}
