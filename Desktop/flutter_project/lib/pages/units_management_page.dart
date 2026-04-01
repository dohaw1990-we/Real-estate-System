import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/building.dart';
import '../models/rental_unit.dart';
import '../services/rental_office_service.dart';
import '../theme/app_theme.dart';
import '../theme/theme_controller.dart';
import '../widgets/app_islamic_background.dart';

class UnitsManagementPage extends StatefulWidget {
  const UnitsManagementPage({super.key, this.preselectedBuildingId});

  final String? preselectedBuildingId;

  @override
  State<UnitsManagementPage> createState() => _UnitsManagementPageState();
}

class _UnitsManagementPageState extends State<UnitsManagementPage> {
  String? _selectedBuildingId;

  @override
  void initState() {
    super.initState();
    _selectedBuildingId = widget.preselectedBuildingId;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RentalOfficeService>(
      builder: (context, office, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final buildings = office.buildings;

        if (_selectedBuildingId == null && buildings.isNotEmpty) {
          _selectedBuildingId = buildings.first.id;
        }

        final selectedBuilding = buildings.cast<Building?>().firstWhere(
          (item) => item?.id == _selectedBuildingId,
          orElse: () => null,
        );

        final units = _selectedBuildingId == null
            ? const <RentalUnit>[]
            : office.getUnitsForBuilding(_selectedBuildingId!);

        return Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(120),
            child: _buildGradientAppBar(isDark),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _selectedBuildingId == null
                ? null
                : () => _openAddUnitDialog(context, _selectedBuildingId!),
            icon: const Icon(Icons.add_home_work_rounded),
            label: const Text('إضافة شقة'),
          ),
          body: Stack(
            children: [
              const Positioned.fill(child: AppIslamicBackground()),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.business_rounded,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                initialValue: _selectedBuildingId,
                                decoration: const InputDecoration(
                                  labelText: 'اختاري العمارة',
                                ),
                                items: buildings
                                    .map(
                                      (building) => DropdownMenuItem(
                                        value: building.id,
                                        child: Text(
                                          '${building.name} - ${building.area}',
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedBuildingId = value;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (selectedBuilding != null)
                      Text(
                        'شقق ${selectedBuilding.name} (${units.length})',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: units.isEmpty
                          ? Center(
                              child: Text(
                                'لا توجد شقق حالياً لهذه العمارة',
                                style: GoogleFonts.poppins(),
                              ),
                            )
                          : ListView.separated(
                              itemCount: units.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                final unit = units[index];
                                final statusColor =
                                    unit.status == UnitStatus.occupied
                                    ? Colors.green
                                    : unit.status == UnitStatus.vacant
                                    ? Colors.orange
                                    : const Color(0xFF7A6552);
                                return Card(
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: statusColor.withValues(
                                        alpha: 0.14,
                                      ),
                                      child: Icon(
                                        Icons.apartment_rounded,
                                        color: statusColor,
                                      ),
                                    ),
                                    title: Text(
                                      'شقة ${unit.unitNumber} - الدور ${unit.floorNumber}',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    subtitle: Text(
                                      'غرف: ${unit.bedrooms} | حمام: ${unit.bathrooms} | مساحة: ${unit.areaSqm.toStringAsFixed(0)} م²',
                                      style: GoogleFonts.poppins(fontSize: 12),
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              '${unit.monthlyRent.toStringAsFixed(0)} ج.م',
                                              style: GoogleFonts.poppins(
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            Text(
                                              unit.status.name,
                                              style: GoogleFonts.poppins(
                                                color: statusColor,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                        IconButton(
                                          tooltip: 'حذف الشقة',
                                          onPressed: () =>
                                              _confirmDeleteUnit(context, unit),
                                          icon: const Icon(
                                            Icons.delete_outline_rounded,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  PreferredSize _buildGradientAppBar(bool isDark) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(120),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? const [Color(0xFF2A1E16), Color(0xFF3A2A1F)]
                : const [Color(0xFF6F4A2F), Color(0xFFA6784E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            const AppBarIslamicOrnament(),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(
                        Icons.apartment_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'إدارة الشقق',
                            style: GoogleFonts.cairo(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'إدارة وتنظيم جميع الشقق والوحدات',
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        _buildThemeToggleButton(context, isDark),
                        const SizedBox(width: 8),
                        _buildNavButton(
                          context,
                          '/dashboard',
                          Icons.dashboard_rounded,
                        ),
                        const SizedBox(width: 8),
                        _buildNavButton(
                          context,
                          '/buildings',
                          Icons.location_city_rounded,
                        ),
                        const SizedBox(width: 8),
                        _buildNavButton(context, '/', Icons.home_rounded),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeToggleButton(BuildContext context, bool isDark) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.read<ThemeController>().toggleTheme(),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildNavButton(BuildContext context, String route, IconData icon) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, route),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }

  Future<void> _openAddUnitDialog(
    BuildContext context,
    String buildingId,
  ) async {
    final service = context.read<RentalOfficeService>();
    final formKey = GlobalKey<FormState>();

    final unitNumberController = TextEditingController();
    final floorController = TextEditingController(text: '1');
    final bedroomsController = TextEditingController(text: '2');
    final bathroomsController = TextEditingController(text: '1');
    final areaController = TextEditingController(text: '120');
    final rentController = TextEditingController(text: '8000');
    final depositController = TextEditingController(text: '16000');

    UnitPurpose purpose = UnitPurpose.residential;
    UnitStatus status = UnitStatus.vacant;

    final added = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('إضافة شقة جديدة'),
          content: SizedBox(
            width: 560,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: unitNumberController,
                      decoration: const InputDecoration(labelText: 'رقم الشقة'),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                          ? 'ادخلي رقم الشقة'
                          : null,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: floorController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'الدور',
                            ),
                            validator: _requiredInt,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonFormField<UnitPurpose>(
                            initialValue: purpose,
                            decoration: const InputDecoration(
                              labelText: 'الغرض',
                            ),
                            items: UnitPurpose.values
                                .map(
                                  (value) => DropdownMenuItem(
                                    value: value,
                                    child: Text(value.name),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value != null) purpose = value;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: bedroomsController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'غرف النوم',
                            ),
                            validator: _requiredInt,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: bathroomsController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'الحمامات',
                            ),
                            validator: _requiredInt,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: areaController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'المساحة م²',
                            ),
                            validator: _requiredDouble,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonFormField<UnitStatus>(
                            initialValue: status,
                            decoration: const InputDecoration(
                              labelText: 'الحالة',
                            ),
                            items: UnitStatus.values
                                .map(
                                  (value) => DropdownMenuItem(
                                    value: value,
                                    child: Text(value.name),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value != null) status = value;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: rentController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'الإيجار الشهري',
                      ),
                      validator: _requiredDouble,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: depositController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'التأمين'),
                      validator: _requiredDouble,
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () async {
                if (!(formKey.currentState?.validate() ?? false)) return;
                final ok = await service.addUnit(
                  buildingId: buildingId,
                  unitNumber: unitNumberController.text,
                  floorNumber: int.parse(floorController.text),
                  purpose: purpose,
                  status: status,
                  bedrooms: int.parse(bedroomsController.text),
                  bathrooms: int.parse(bathroomsController.text),
                  areaSqm: double.parse(areaController.text),
                  monthlyRent: double.parse(rentController.text),
                  securityDeposit: double.parse(depositController.text),
                );
                if (!dialogContext.mounted) return;
                Navigator.pop(dialogContext, ok);
              },
              child: const Text('إضافة'),
            ),
          ],
        );
      },
    );

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          added == true
              ? 'تمت إضافة الشقة وربطها بقاعدة البيانات'
              : 'تعذر إضافة الشقة (قد تكون موجودة بنفس الرقم)',
        ),
        backgroundColor: added == true ? Colors.green : Colors.red,
      ),
    );
  }

  Future<void> _confirmDeleteUnit(BuildContext context, RentalUnit unit) async {
    final service = context.read<RentalOfficeService>();

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('حذف الشقة'),
        content: Text(
          'هل تريدين حذف شقة ${unit.unitNumber}؟ سيتم حذف البيانات المرتبطة بها.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;

    final deleted = await service.deleteUnit(unitId: unit.id);
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(deleted ? 'تم حذف الشقة' : 'تعذر حذف الشقة'),
        backgroundColor: deleted ? Colors.green : Colors.red,
      ),
    );
  }

  String? _requiredInt(String? value) {
    final parsed = int.tryParse(value ?? '');
    if (parsed == null) return 'رقم غير صحيح';
    return null;
  }

  String? _requiredDouble(String? value) {
    final parsed = double.tryParse(value ?? '');
    if (parsed == null) return 'رقم غير صحيح';
    return null;
  }
}
