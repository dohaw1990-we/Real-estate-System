enum ContractStatus { active, pendingRenewal, expired, terminated }

class LeaseContract {
  final String id;
  final String unitId;
  final String tenantId;
  final String landlordId;
  final DateTime startDate;
  final DateTime endDate;
  final int rentDueDay;
  final double monthlyRent;
  final double securityDeposit;
  final double annualIncreasePercent;
  final ContractStatus status;
  final DateTime nextRenewalDate;
  final String notes;

  const LeaseContract({
    required this.id,
    required this.unitId,
    required this.tenantId,
    required this.landlordId,
    required this.startDate,
    required this.endDate,
    required this.rentDueDay,
    required this.monthlyRent,
    required this.securityDeposit,
    required this.annualIncreasePercent,
    required this.status,
    required this.nextRenewalDate,
    required this.notes,
  });

  factory LeaseContract.fromJson(Map<String, dynamic> json) {
    return LeaseContract(
      id: json['id'] as String,
      unitId: json['unitId'] as String,
      tenantId: json['tenantId'] as String,
      landlordId: json['landlordId'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      rentDueDay: json['rentDueDay'] as int,
      monthlyRent: (json['monthlyRent'] as num).toDouble(),
      securityDeposit: (json['securityDeposit'] as num).toDouble(),
      annualIncreasePercent: (json['annualIncreasePercent'] as num).toDouble(),
      status: ContractStatus.values.firstWhere(
        (value) => value.name == json['status'],
        orElse: () => ContractStatus.active,
      ),
      nextRenewalDate: DateTime.parse(json['nextRenewalDate'] as String),
      notes: json['notes'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'unitId': unitId,
      'tenantId': tenantId,
      'landlordId': landlordId,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'rentDueDay': rentDueDay,
      'monthlyRent': monthlyRent,
      'securityDeposit': securityDeposit,
      'annualIncreasePercent': annualIncreasePercent,
      'status': status.name,
      'nextRenewalDate': nextRenewalDate.toIso8601String(),
      'notes': notes,
    };
  }
}
