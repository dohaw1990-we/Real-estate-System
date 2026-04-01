enum PropertyType { apartment, villa, office, house }

class Property {
  final String id;
  final String title;
  final double price;
  final String location;
  final PropertyType type;
  final String description;
  final String contactPhone;
  List<String> images;
  bool isFavorite;

  Property({
    required this.id,
    required this.title,
    required this.price,
    required this.location,
    required this.type,
    required this.description,
    required this.contactPhone,
    required this.images,
    this.isFavorite = false,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['id'] as String,
      title: json['title'] as String,
      price: (json['price'] as num).toDouble(),
      location: json['location'] as String,
      type: PropertyType.values.firstWhere(
        (e) => e.toString() == 'PropertyType.${json['type']}',
        orElse: () => PropertyType.apartment,
      ),
      description: json['description'] as String,
      contactPhone: json['contactPhone'] as String,
      images: List<String>.from(json['images'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'location': location,
      'type': type.toString().split('.').last,
      'description': description,
      'contactPhone': contactPhone,
      'images': images,
      'isFavorite': isFavorite,
    };
  }
}
