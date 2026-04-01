import 'package:cloud_firestore/cloud_firestore.dart';

import '../data/egypt_rental_office_data.dart';

class RentalOfficeSeedService {
  final FirebaseFirestore firestore;

  const RentalOfficeSeedService({required this.firestore});

  Future<void> seedAllData() async {
    final batch = firestore.batch();

    for (final landlord in EgyptRentalOfficeData.landlords()) {
      final ref = firestore.collection('landlords').doc(landlord.id);
      batch.set(ref, landlord.toJson());
    }

    for (final tenant in EgyptRentalOfficeData.tenants()) {
      final ref = firestore.collection('tenants').doc(tenant.id);
      batch.set(ref, tenant.toJson());
    }

    for (final building in EgyptRentalOfficeData.buildings()) {
      final ref = firestore.collection('buildings').doc(building.id);
      batch.set(ref, building.toJson());
    }

    for (final unit in EgyptRentalOfficeData.units()) {
      final ref = firestore.collection('units').doc(unit.id);
      batch.set(ref, unit.toJson());
    }

    for (final contract in EgyptRentalOfficeData.contracts()) {
      final ref = firestore.collection('contracts').doc(contract.id);
      batch.set(ref, contract.toJson());
    }

    for (final payment in EgyptRentalOfficeData.payments()) {
      final ref = firestore.collection('rentPayments').doc(payment.id);
      batch.set(ref, payment.toJson());
    }

    await batch.commit();
  }
}
