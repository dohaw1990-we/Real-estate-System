import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../data/egypt_rental_office_data.dart';
import '../models/building.dart';
import '../models/landlord.dart';
import '../models/lease_contract.dart';
import '../models/rent_payment.dart';
import '../models/rental_unit.dart';
import '../models/tenant.dart';

class ContractOverview {
  final LeaseContract contract;
  final Tenant tenant;
  final Landlord landlord;
  final Building building;
  final RentalUnit unit;

  const ContractOverview({
    required this.contract,
    required this.tenant,
    required this.landlord,
    required this.building,
    required this.unit,
  });
}

class RentPaymentOverview {
  final RentPayment payment;
  final LeaseContract contract;
  final Tenant tenant;
  final RentalUnit unit;
  final Building building;

  const RentPaymentOverview({
    required this.payment,
    required this.contract,
    required this.tenant,
    required this.unit,
    required this.building,
  });
}

class UnitOccupancyOverview {
  final RentalUnit unit;
  final LeaseContract? activeContract;
  final Tenant? currentTenant;
  final Landlord? landlord;

  const UnitOccupancyOverview({
    required this.unit,
    required this.activeContract,
    required this.currentTenant,
    required this.landlord,
  });

  bool get isOccupied => activeContract != null && currentTenant != null;
}

class BuildingUnitsOverview {
  final Building building;
  final Landlord? landlord;
  final List<UnitOccupancyOverview> units;

  const BuildingUnitsOverview({
    required this.building,
    required this.landlord,
    required this.units,
  });

  int get occupiedCount => units.where((item) => item.isOccupied).length;
  int get vacantCount => units.where((item) => !item.isOccupied).length;
}

class TenantArrearsOverview {
  final Tenant tenant;
  final LeaseContract contract;
  final RentalUnit unit;
  final Building building;
  final List<RentPayment> unpaidPayments;

  const TenantArrearsOverview({
    required this.tenant,
    required this.contract,
    required this.unit,
    required this.building,
    required this.unpaidPayments,
  });

  int get unpaidMonths => unpaidPayments.length;

  double get totalUnpaid => unpaidPayments.fold<double>(
    0,
    (sum, payment) => sum + (payment.amount - payment.paidAmount),
  );

  DateTime get oldestDueDate => unpaidPayments
      .map((payment) => payment.dueDate)
      .reduce((a, b) => a.isBefore(b) ? a : b);
}

class RentalDashboardStats {
  final int totalBuildings;
  final int totalUnits;
  final int occupiedUnits;
  final int vacantUnits;
  final int activeContracts;
  final int expiringContractsIn30Days;
  final int overduePayments;
  final double monthlyCollected;
  final double monthlyDue;

  const RentalDashboardStats({
    required this.totalBuildings,
    required this.totalUnits,
    required this.occupiedUnits,
    required this.vacantUnits,
    required this.activeContracts,
    required this.expiringContractsIn30Days,
    required this.overduePayments,
    required this.monthlyCollected,
    required this.monthlyDue,
  });
}

class RentalOfficeService extends ChangeNotifier {
  final FirebaseFirestore? _firestore;
  final List<StreamSubscription> _subscriptions = [];
  bool _isUsingFirestoreLiveData = false;
  final List<Landlord> _landlords = EgyptRentalOfficeData.landlords();
  final List<Tenant> _tenants = EgyptRentalOfficeData.tenants();
  final List<Building> _buildings = EgyptRentalOfficeData.buildings();
  final List<RentalUnit> _units = EgyptRentalOfficeData.units();
  final List<LeaseContract> _contracts = EgyptRentalOfficeData.contracts();
  final List<RentPayment> _payments = EgyptRentalOfficeData.payments();

  RentalOfficeService()
    : _firestore = Firebase.apps.isNotEmpty
          ? FirebaseFirestore.instance
          : null {
    _attachRealtimeListeners();
  }

  @override
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    super.dispose();
  }

  List<Landlord> get landlords => List.unmodifiable(_landlords);
  List<Tenant> get tenants => List.unmodifiable(_tenants);
  List<Building> get buildings => List.unmodifiable(_buildings);
  List<RentalUnit> get units => List.unmodifiable(_units);
  List<LeaseContract> get contracts => List.unmodifiable(_contracts);
  List<RentPayment> get payments => List.unmodifiable(_payments);
  bool get isUsingFirestoreLiveData => _isUsingFirestoreLiveData;

  void _attachRealtimeListeners() {
    final firestore = _firestore;
    if (firestore == null) return;

    _subscriptions.add(
      firestore
          .collection('landlords')
          .snapshots()
          .listen(
            (snapshot) {
              if (snapshot.docs.isEmpty) return;
              final items = snapshot.docs
                  .map((doc) => Landlord.fromJson(doc.data()..['id'] = doc.id))
                  .toList();
              _replaceWithRealtimeData(_landlords, items);
            },
            onError: (error) {
              debugPrint('landlords realtime listener error: $error');
            },
          ),
    );

    _subscriptions.add(
      firestore
          .collection('tenants')
          .snapshots()
          .listen(
            (snapshot) {
              if (snapshot.docs.isEmpty) return;
              final items = snapshot.docs
                  .map((doc) => Tenant.fromJson(doc.data()..['id'] = doc.id))
                  .toList();
              _replaceWithRealtimeData(_tenants, items);
            },
            onError: (error) {
              debugPrint('tenants realtime listener error: $error');
            },
          ),
    );

    _subscriptions.add(
      firestore
          .collection('buildings')
          .snapshots()
          .listen(
            (snapshot) {
              if (snapshot.docs.isEmpty) return;
              final items = snapshot.docs
                  .map((doc) => Building.fromJson(doc.data()..['id'] = doc.id))
                  .toList();
              _replaceWithRealtimeData(_buildings, items);
            },
            onError: (error) {
              debugPrint('buildings realtime listener error: $error');
            },
          ),
    );

    _subscriptions.add(
      firestore
          .collection('units')
          .snapshots()
          .listen(
            (snapshot) {
              if (snapshot.docs.isEmpty) return;
              final items = snapshot.docs
                  .map(
                    (doc) => RentalUnit.fromJson(doc.data()..['id'] = doc.id),
                  )
                  .toList();
              _replaceWithRealtimeData(_units, items);
            },
            onError: (error) {
              debugPrint('units realtime listener error: $error');
            },
          ),
    );

    _subscriptions.add(
      firestore
          .collection('contracts')
          .snapshots()
          .listen(
            (snapshot) {
              if (snapshot.docs.isEmpty) return;
              final items = snapshot.docs
                  .map(
                    (doc) =>
                        LeaseContract.fromJson(doc.data()..['id'] = doc.id),
                  )
                  .toList();
              _replaceWithRealtimeData(_contracts, items);
            },
            onError: (error) {
              debugPrint('contracts realtime listener error: $error');
            },
          ),
    );

    _subscriptions.add(
      firestore
          .collection('rentPayments')
          .snapshots()
          .listen(
            (snapshot) {
              if (snapshot.docs.isEmpty) return;
              final items = snapshot.docs
                  .map(
                    (doc) => RentPayment.fromJson(doc.data()..['id'] = doc.id),
                  )
                  .toList();
              _replaceWithRealtimeData(_payments, items);
            },
            onError: (error) {
              debugPrint('rentPayments realtime listener error: $error');
            },
          ),
    );
  }

  void _replaceWithRealtimeData<T>(List<T> target, List<T> incoming) {
    target
      ..clear()
      ..addAll(incoming);
    _isUsingFirestoreLiveData = true;
    notifyListeners();
  }

  Future<bool> seedFirestoreFromLocalData() async {
    final firestore = _firestore;
    if (firestore == null) return false;

    try {
      final batch = firestore.batch();

      for (final landlord in _landlords) {
        batch.set(
          firestore.collection('landlords').doc(landlord.id),
          landlord.toJson(),
          SetOptions(merge: true),
        );
      }
      for (final tenant in _tenants) {
        batch.set(
          firestore.collection('tenants').doc(tenant.id),
          tenant.toJson(),
          SetOptions(merge: true),
        );
      }
      for (final building in _buildings) {
        batch.set(
          firestore.collection('buildings').doc(building.id),
          building.toJson(),
          SetOptions(merge: true),
        );
      }
      for (final unit in _units) {
        batch.set(
          firestore.collection('units').doc(unit.id),
          unit.toJson(),
          SetOptions(merge: true),
        );
      }
      for (final contract in _contracts) {
        batch.set(
          firestore.collection('contracts').doc(contract.id),
          contract.toJson(),
          SetOptions(merge: true),
        );
      }
      for (final payment in _payments) {
        batch.set(
          firestore.collection('rentPayments').doc(payment.id),
          payment.toJson(),
          SetOptions(merge: true),
        );
      }

      await batch.commit();
      return true;
    } catch (e) {
      debugPrint('seedFirestoreFromLocalData failed: $e');
      return false;
    }
  }

  List<RentalUnit> getUnitsForBuilding(String buildingId) {
    final result =
        _units.where((unit) => unit.buildingId == buildingId).toList()
          ..sort((a, b) => a.unitNumber.compareTo(b.unitNumber));
    return result;
  }

  Future<bool> addBuilding({
    required String name,
    required String city,
    required String area,
    required String streetAddress,
    required String landlordId,
    required int floorsCount,
  }) async {
    final trimmedName = name.trim();
    final trimmedCity = city.trim();
    final trimmedArea = area.trim();
    final trimmedStreet = streetAddress.trim();

    if (trimmedName.isEmpty ||
        trimmedCity.isEmpty ||
        trimmedArea.isEmpty ||
        trimmedStreet.isEmpty ||
        landlordId.trim().isEmpty ||
        floorsCount <= 0) {
      return false;
    }

    final id = 'building-${DateTime.now().microsecondsSinceEpoch}';
    final building = Building(
      id: id,
      name: trimmedName,
      city: trimmedCity,
      area: trimmedArea,
      streetAddress: trimmedStreet,
      landlordId: landlordId,
      floorsCount: floorsCount,
      unitsCount: 0,
    );

    _buildings.add(building);

    try {
      final firestore = _firestore;
      if (firestore != null) {
        await firestore
            .collection('buildings')
            .doc(building.id)
            .set(building.toJson(), SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint('addBuilding firestore sync failed: $e');
      _buildings.removeWhere((item) => item.id == building.id);
      notifyListeners();
      return false;
    }

    notifyListeners();
    return true;
  }

  Future<bool> addUnit({
    required String buildingId,
    required String unitNumber,
    required int floorNumber,
    required UnitPurpose purpose,
    required int bedrooms,
    required int bathrooms,
    required double areaSqm,
    required double monthlyRent,
    required double securityDeposit,
    UnitStatus status = UnitStatus.vacant,
  }) async {
    final buildingIndex = _buildings.indexWhere(
      (building) => building.id == buildingId,
    );
    if (buildingIndex == -1) return false;

    final trimmedUnitNumber = unitNumber.trim();
    if (trimmedUnitNumber.isEmpty ||
        floorNumber < 0 ||
        bedrooms < 0 ||
        bathrooms < 0 ||
        areaSqm <= 0 ||
        monthlyRent < 0 ||
        securityDeposit < 0) {
      return false;
    }

    final alreadyExists = _units.any(
      (unit) =>
          unit.buildingId == buildingId &&
          unit.unitNumber.toLowerCase() == trimmedUnitNumber.toLowerCase(),
    );
    if (alreadyExists) return false;

    final unitId = 'unit-${DateTime.now().microsecondsSinceEpoch}';
    final newUnit = RentalUnit(
      id: unitId,
      buildingId: buildingId,
      unitNumber: trimmedUnitNumber,
      floorNumber: floorNumber,
      purpose: purpose,
      status: status,
      bedrooms: bedrooms,
      bathrooms: bathrooms,
      areaSqm: areaSqm,
      monthlyRent: monthlyRent,
      securityDeposit: securityDeposit,
    );

    _units.add(newUnit);

    final building = _buildings[buildingIndex];
    final updatedBuilding = Building(
      id: building.id,
      name: building.name,
      city: building.city,
      area: building.area,
      streetAddress: building.streetAddress,
      landlordId: building.landlordId,
      floorsCount: building.floorsCount,
      unitsCount: building.unitsCount + 1,
    );
    _buildings[buildingIndex] = updatedBuilding;

    try {
      final firestore = _firestore;
      if (firestore != null) {
        await firestore
            .collection('units')
            .doc(newUnit.id)
            .set(newUnit.toJson(), SetOptions(merge: true));
        await firestore
            .collection('buildings')
            .doc(updatedBuilding.id)
            .set(updatedBuilding.toJson(), SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint('addUnit firestore sync failed: $e');
      _units.removeWhere((item) => item.id == newUnit.id);
      _buildings[buildingIndex] = building;
      notifyListeners();
      return false;
    }

    notifyListeners();
    return true;
  }

  Future<bool> deleteUnit({required String unitId}) async {
    final unitIndex = _units.indexWhere((unit) => unit.id == unitId);
    if (unitIndex == -1) return false;

    final unit = _units[unitIndex];
    final buildingIndex = _buildings.indexWhere(
      (building) => building.id == unit.buildingId,
    );

    final contractIds = _contracts
        .where((contract) => contract.unitId == unit.id)
        .map((contract) => contract.id)
        .toSet();

    final paymentIds = _payments
        .where((payment) => contractIds.contains(payment.contractId))
        .map((payment) => payment.id)
        .toList();

    _payments.removeWhere(
      (payment) => contractIds.contains(payment.contractId),
    );
    _contracts.removeWhere((contract) => contract.unitId == unit.id);
    _units.removeAt(unitIndex);

    Building? updatedBuilding;
    if (buildingIndex != -1) {
      final building = _buildings[buildingIndex];
      updatedBuilding = Building(
        id: building.id,
        name: building.name,
        city: building.city,
        area: building.area,
        streetAddress: building.streetAddress,
        landlordId: building.landlordId,
        floorsCount: building.floorsCount,
        unitsCount: building.unitsCount > 0 ? building.unitsCount - 1 : 0,
      );
      _buildings[buildingIndex] = updatedBuilding;
    }

    try {
      final firestore = _firestore;
      if (firestore != null) {
        final batch = firestore.batch();
        batch.delete(firestore.collection('units').doc(unit.id));

        for (final contractId in contractIds) {
          batch.delete(firestore.collection('contracts').doc(contractId));
        }
        for (final paymentId in paymentIds) {
          batch.delete(firestore.collection('rentPayments').doc(paymentId));
        }

        if (updatedBuilding != null) {
          batch.set(
            firestore.collection('buildings').doc(updatedBuilding.id),
            updatedBuilding.toJson(),
            SetOptions(merge: true),
          );
        }

        await batch.commit();
      }
    } catch (e) {
      debugPrint('deleteUnit firestore sync failed: $e');
    }

    notifyListeners();
    return true;
  }

  Future<bool> deleteBuilding({required String buildingId}) async {
    final buildingIndex = _buildings.indexWhere(
      (building) => building.id == buildingId,
    );
    if (buildingIndex == -1) return false;

    final unitIds = _units
        .where((unit) => unit.buildingId == buildingId)
        .map((unit) => unit.id)
        .toSet();

    final contractIds = _contracts
        .where((contract) => unitIds.contains(contract.unitId))
        .map((contract) => contract.id)
        .toSet();

    final paymentIds = _payments
        .where((payment) => contractIds.contains(payment.contractId))
        .map((payment) => payment.id)
        .toList();

    _payments.removeWhere(
      (payment) => contractIds.contains(payment.contractId),
    );
    _contracts.removeWhere((contract) => unitIds.contains(contract.unitId));
    _units.removeWhere((unit) => unit.buildingId == buildingId);
    final building = _buildings.removeAt(buildingIndex);

    try {
      final firestore = _firestore;
      if (firestore != null) {
        final batch = firestore.batch();
        batch.delete(firestore.collection('buildings').doc(building.id));

        for (final unitId in unitIds) {
          batch.delete(firestore.collection('units').doc(unitId));
        }
        for (final contractId in contractIds) {
          batch.delete(firestore.collection('contracts').doc(contractId));
        }
        for (final paymentId in paymentIds) {
          batch.delete(firestore.collection('rentPayments').doc(paymentId));
        }

        await batch.commit();
      }
    } catch (e) {
      debugPrint('deleteBuilding firestore sync failed: $e');
    }

    notifyListeners();
    return true;
  }

  RentalDashboardStats getDashboardStats({DateTime? now}) {
    final currentDate = now ?? DateTime.now();
    final occupied = _units
        .where((unit) => unit.status == UnitStatus.occupied)
        .length;
    final vacant = _units
        .where((unit) => unit.status == UnitStatus.vacant)
        .length;

    final activeContracts = _contracts
        .where((contract) => contract.status == ContractStatus.active)
        .length;

    final expiringContracts = getContractsExpiringWithinDays(
      30,
      now: currentDate,
    );
    final overdue = getOverduePayments(now: currentDate);

    final dueThisMonth = _payments.where(
      (payment) =>
          payment.year == currentDate.year &&
          payment.month == currentDate.month,
    );

    final monthlyCollected = dueThisMonth.fold<double>(
      0,
      (sum, payment) => sum + payment.paidAmount,
    );
    final monthlyDue = dueThisMonth.fold<double>(
      0,
      (sum, payment) => sum + payment.amount,
    );

    return RentalDashboardStats(
      totalBuildings: _buildings.length,
      totalUnits: _units.length,
      occupiedUnits: occupied,
      vacantUnits: vacant,
      activeContracts: activeContracts,
      expiringContractsIn30Days: expiringContracts.length,
      overduePayments: overdue.length,
      monthlyCollected: monthlyCollected,
      monthlyDue: monthlyDue,
    );
  }

  List<ContractOverview> getContractsExpiringWithinDays(
    int days, {
    DateTime? now,
  }) {
    final baseDate = now ?? DateTime.now();
    final deadline = baseDate.add(Duration(days: days));

    return _contracts
        .where(
          (contract) =>
              contract.status != ContractStatus.expired &&
              !contract.endDate.isBefore(baseDate) &&
              !contract.endDate.isAfter(deadline),
        )
        .map(_toContractOverview)
        .whereType<ContractOverview>()
        .toList()
      ..sort((a, b) => a.contract.endDate.compareTo(b.contract.endDate));
  }

  List<ContractOverview> getRenewalsDueWithinDays(int days, {DateTime? now}) {
    final baseDate = now ?? DateTime.now();
    final deadline = baseDate.add(Duration(days: days));

    return _contracts
        .where(
          (contract) =>
              contract.status != ContractStatus.expired &&
              !contract.nextRenewalDate.isBefore(baseDate) &&
              !contract.nextRenewalDate.isAfter(deadline),
        )
        .map(_toContractOverview)
        .whereType<ContractOverview>()
        .toList()
      ..sort(
        (a, b) =>
            a.contract.nextRenewalDate.compareTo(b.contract.nextRenewalDate),
      );
  }

  List<RentPaymentOverview> getOverduePayments({DateTime? now}) {
    final currentDate = now ?? DateTime.now();

    return _payments
        .where(
          (payment) =>
              payment.status == PaymentStatus.overdue ||
              (payment.status != PaymentStatus.paid &&
                  payment.dueDate.isBefore(currentDate)),
        )
        .map(_toPaymentOverview)
        .whereType<RentPaymentOverview>()
        .toList()
      ..sort((a, b) => a.payment.dueDate.compareTo(b.payment.dueDate));
  }

  List<RentPaymentOverview> getUpcomingRentDueWithinDays(
    int days, {
    DateTime? now,
  }) {
    final currentDate = now ?? DateTime.now();
    final deadline = currentDate.add(Duration(days: days));

    return _payments
        .where(
          (payment) =>
              payment.status != PaymentStatus.paid &&
              !payment.dueDate.isBefore(currentDate) &&
              !payment.dueDate.isAfter(deadline),
        )
        .map(_toPaymentOverview)
        .whereType<RentPaymentOverview>()
        .toList()
      ..sort((a, b) => a.payment.dueDate.compareTo(b.payment.dueDate));
  }

  List<RentPaymentOverview> getUnpaidForCurrentMonth({DateTime? now}) {
    final currentDate = now ?? DateTime.now();

    return _payments
        .where(
          (payment) =>
              payment.year == currentDate.year &&
              payment.month == currentDate.month &&
              payment.status != PaymentStatus.paid,
        )
        .map(_toPaymentOverview)
        .whereType<RentPaymentOverview>()
        .toList()
      ..sort((a, b) => a.payment.dueDate.compareTo(b.payment.dueDate));
  }

  List<TenantArrearsOverview> getTenantArrears({
    int minMonths = 2,
    DateTime? now,
  }) {
    final currentDate = now ?? DateTime.now();

    final grouped = <String, List<RentPayment>>{};
    for (final payment in _payments) {
      if (payment.status == PaymentStatus.paid) continue;
      if (payment.dueDate.isAfter(currentDate)) continue;
      grouped.putIfAbsent(payment.contractId, () => []).add(payment);
    }

    final result = <TenantArrearsOverview>[];
    for (final entry in grouped.entries) {
      if (entry.value.length < minMonths) continue;
      final contract = _contracts.cast<LeaseContract?>().firstWhere(
        (item) => item?.id == entry.key,
        orElse: () => null,
      );
      if (contract == null) continue;

      final tenant = _tenants.cast<Tenant?>().firstWhere(
        (item) => item?.id == contract.tenantId,
        orElse: () => null,
      );
      final unit = _units.cast<RentalUnit?>().firstWhere(
        (item) => item?.id == contract.unitId,
        orElse: () => null,
      );
      final building = _buildings.cast<Building?>().firstWhere(
        (item) => item?.id == unit?.buildingId,
        orElse: () => null,
      );

      if (tenant == null || unit == null || building == null) continue;

      final sortedUnpaid = List<RentPayment>.from(entry.value)
        ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

      result.add(
        TenantArrearsOverview(
          tenant: tenant,
          contract: contract,
          unit: unit,
          building: building,
          unpaidPayments: sortedUnpaid,
        ),
      );
    }

    result.sort((a, b) {
      final unpaidCompare = b.unpaidMonths.compareTo(a.unpaidMonths);
      if (unpaidCompare != 0) return unpaidCompare;
      return b.totalUnpaid.compareTo(a.totalUnpaid);
    });

    return result;
  }

  List<BuildingUnitsOverview> getBuildingsWithUnitsOverview({DateTime? now}) {
    final currentDate = now ?? DateTime.now();

    final result = _buildings.map((building) {
      final buildingUnits =
          _units.where((unit) => unit.buildingId == building.id).toList()
            ..sort((a, b) => a.unitNumber.compareTo(b.unitNumber));

      final landlord = _landlords.cast<Landlord?>().firstWhere(
        (item) => item?.id == building.landlordId,
        orElse: () => null,
      );

      final unitOverview = buildingUnits.map((unit) {
        final activeContract =
            _contracts
                .where((contract) => contract.unitId == unit.id)
                .where((contract) => contract.status != ContractStatus.expired)
                .where(
                  (contract) =>
                      !contract.startDate.isAfter(currentDate) &&
                      !contract.endDate.isBefore(currentDate),
                )
                .toList()
              ..sort((a, b) => b.startDate.compareTo(a.startDate));

        final contract = activeContract.isEmpty ? null : activeContract.first;
        final tenant = contract == null
            ? null
            : _tenants.cast<Tenant?>().firstWhere(
                (item) => item?.id == contract.tenantId,
                orElse: () => null,
              );

        return UnitOccupancyOverview(
          unit: unit,
          activeContract: contract,
          currentTenant: tenant,
          landlord: landlord,
        );
      }).toList();

      return BuildingUnitsOverview(
        building: building,
        landlord: landlord,
        units: unitOverview,
      );
    }).toList();

    result.sort((a, b) => a.building.name.compareTo(b.building.name));
    return result;
  }

  List<ContractOverview> searchContracts(String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) {
      return _contracts
          .map(_toContractOverview)
          .whereType<ContractOverview>()
          .toList();
    }

    return _contracts
        .map(_toContractOverview)
        .whereType<ContractOverview>()
        .where((item) {
          final tenant = item.tenant.fullName.toLowerCase();
          final landlord = item.landlord.fullName.toLowerCase();
          final building = item.building.name.toLowerCase();
          final area = item.building.area.toLowerCase();
          final city = item.building.city.toLowerCase();
          final unitNumber = item.unit.unitNumber.toLowerCase();

          return tenant.contains(normalized) ||
              landlord.contains(normalized) ||
              building.contains(normalized) ||
              area.contains(normalized) ||
              city.contains(normalized) ||
              unitNumber.contains(normalized);
        })
        .toList();
  }

  Future<bool> renewContract({
    required String contractId,
    int extensionMonths = 12,
    double? newMonthlyRent,
    double? annualIncreasePercent,
    DateTime? renewalDate,
  }) async {
    final contractIndex = _contracts.indexWhere(
      (item) => item.id == contractId,
    );
    if (contractIndex == -1) return false;

    final current = _contracts[contractIndex];
    final nextStart =
        renewalDate ?? current.endDate.add(const Duration(days: 1));
    final nextEnd = DateTime(
      nextStart.year,
      nextStart.month + extensionMonths,
      nextStart.day,
    ).subtract(const Duration(days: 1));

    final updatedContract = LeaseContract(
      id: current.id,
      unitId: current.unitId,
      tenantId: current.tenantId,
      landlordId: current.landlordId,
      startDate: nextStart,
      endDate: nextEnd,
      rentDueDay: current.rentDueDay,
      monthlyRent: newMonthlyRent ?? current.monthlyRent,
      securityDeposit: current.securityDeposit,
      annualIncreasePercent:
          annualIncreasePercent ?? current.annualIncreasePercent,
      status: ContractStatus.active,
      nextRenewalDate: nextEnd.subtract(const Duration(days: 30)),
      notes:
          '${current.notes} | renewed on ${DateTime.now().toIso8601String()}',
    );

    _contracts[contractIndex] = updatedContract;

    final unitIndex = _units.indexWhere((item) => item.id == current.unitId);
    if (unitIndex != -1) {
      final unit = _units[unitIndex];
      final updatedUnit = RentalUnit(
        id: unit.id,
        buildingId: unit.buildingId,
        unitNumber: unit.unitNumber,
        floorNumber: unit.floorNumber,
        purpose: unit.purpose,
        status: UnitStatus.occupied,
        bedrooms: unit.bedrooms,
        bathrooms: unit.bathrooms,
        areaSqm: unit.areaSqm,
        monthlyRent: newMonthlyRent ?? unit.monthlyRent,
        securityDeposit: unit.securityDeposit,
      );
      _units[unitIndex] = updatedUnit;

      try {
        final firestore = _firestore;
        if (firestore != null) {
          await firestore
              .collection('contracts')
              .doc(updatedContract.id)
              .set(updatedContract.toJson(), SetOptions(merge: true));
          await firestore
              .collection('units')
              .doc(updatedUnit.id)
              .set(updatedUnit.toJson(), SetOptions(merge: true));
        }
      } catch (e) {
        debugPrint('renewContract firestore sync failed: $e');
      }
    }

    notifyListeners();
    return true;
  }

  Future<bool> markPaymentAsPaid({
    required String paymentId,
    String paymentMethod = 'cash',
    String receiptNumber = '',
    DateTime? paidAt,
  }) async {
    final paymentIndex = _payments.indexWhere((item) => item.id == paymentId);
    if (paymentIndex == -1) return false;

    final current = _payments[paymentIndex];
    final effectivePaidAt = paidAt ?? DateTime.now();
    final effectiveReceipt = receiptNumber.isEmpty
        ? 'RCPT-${effectivePaidAt.year}-${current.id}'
        : receiptNumber;

    final updatedPayment = RentPayment(
      id: current.id,
      contractId: current.contractId,
      year: current.year,
      month: current.month,
      dueDate: current.dueDate,
      paidAt: effectivePaidAt,
      amount: current.amount,
      paidAmount: current.amount,
      status: PaymentStatus.paid,
      paymentMethod: paymentMethod,
      receiptNumber: effectiveReceipt,
    );
    _payments[paymentIndex] = updatedPayment;

    try {
      final firestore = _firestore;
      if (firestore != null) {
        await firestore
            .collection('rentPayments')
            .doc(updatedPayment.id)
            .set(updatedPayment.toJson(), SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint('markPaymentAsPaid firestore sync failed: $e');
    }

    notifyListeners();
    return true;
  }

  ContractOverview? _toContractOverview(LeaseContract contract) {
    final tenant = _tenants.cast<Tenant?>().firstWhere(
      (item) => item?.id == contract.tenantId,
      orElse: () => null,
    );
    final landlord = _landlords.cast<Landlord?>().firstWhere(
      (item) => item?.id == contract.landlordId,
      orElse: () => null,
    );
    final unit = _units.cast<RentalUnit?>().firstWhere(
      (item) => item?.id == contract.unitId,
      orElse: () => null,
    );
    final building = _buildings.cast<Building?>().firstWhere(
      (item) => item?.id == unit?.buildingId,
      orElse: () => null,
    );

    if (tenant == null ||
        landlord == null ||
        unit == null ||
        building == null) {
      return null;
    }

    return ContractOverview(
      contract: contract,
      tenant: tenant,
      landlord: landlord,
      unit: unit,
      building: building,
    );
  }

  RentPaymentOverview? _toPaymentOverview(RentPayment payment) {
    final contract = _contracts.cast<LeaseContract?>().firstWhere(
      (item) => item?.id == payment.contractId,
      orElse: () => null,
    );
    if (contract == null) return null;

    final tenant = _tenants.cast<Tenant?>().firstWhere(
      (item) => item?.id == contract.tenantId,
      orElse: () => null,
    );
    final unit = _units.cast<RentalUnit?>().firstWhere(
      (item) => item?.id == contract.unitId,
      orElse: () => null,
    );
    final building = _buildings.cast<Building?>().firstWhere(
      (item) => item?.id == unit?.buildingId,
      orElse: () => null,
    );

    if (tenant == null || unit == null || building == null) {
      return null;
    }

    return RentPaymentOverview(
      payment: payment,
      contract: contract,
      tenant: tenant,
      unit: unit,
      building: building,
    );
  }
}
