import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';

import '../services/rental_office_service.dart';
import '../theme/app_theme.dart';
import '../theme/theme_controller.dart';
import '../widgets/app_islamic_background.dart';

class BuildingsManagementPage extends StatefulWidget {
  const BuildingsManagementPage({super.key});

  @override
  State<BuildingsManagementPage> createState() =>
      _BuildingsManagementPageState();
}

class _BuildingsManagementPageState extends State<BuildingsManagementPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _floatingButtonController;
  String _searchQuery = '';
  String _filterStatus = 'all'; // all, occupied, vacant

  @override
  void initState() {
    super.initState();
    _floatingButtonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatingButtonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: _buildGradientAppBar(isDark),
      ),
      floatingActionButton: _buildFloatingActionButton(),
      body: Stack(
        children: [
          const Positioned.fill(child: AppIslamicBackground()),
          Consumer<RentalOfficeService>(
            builder: (context, office, child) {
              final items = office.getBuildingsWithUnitsOverview();
              final filteredItems = _filterBuildings(items);

              return Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    _buildSearchAndFilterBar(isDark),
                    const SizedBox(height: 8),
                    Expanded(
                      child: filteredItems.isEmpty
                          ? _buildEmptyState(isDark)
                          : LayoutBuilder(
                              builder: (context, constraints) {
                                final crossAxisCount =
                                    constraints.maxWidth >= 1320
                                    ? 3
                                    : constraints.maxWidth >= 820
                                    ? 2
                                    : 1;

                                return GridView.builder(
                                  padding: EdgeInsets.zero,
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: crossAxisCount,
                                        mainAxisSpacing: 12,
                                        crossAxisSpacing: 12,
                                        childAspectRatio: crossAxisCount == 1
                                            ? 2.5
                                            : 1.38,
                                      ),
                                  itemCount: filteredItems.length,
                                  itemBuilder: (context, index) {
                                    return FadeInUp(
                                      duration: Duration(
                                        milliseconds: 300 + (index * 50),
                                      ),
                                      child: _AnimatedBuildingCard(
                                        item: filteredItems[index],
                                        onTap: () => _showBuildingDetails(
                                          context,
                                          filteredItems[index],
                                        ),
                                        onDelete: () => _confirmDeleteBuilding(
                                          context,
                                          filteredItems[index],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
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
                        Icons.location_city_rounded,
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
                            'إدارة العمارات',
                            style: GoogleFonts.cairo(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'إدارة وتنظيم جميع العمارات والعقارات',
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
                          '/units',
                          Icons.apartment_rounded,
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

  Widget _buildSearchAndFilterBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.grey.shade900.withValues(alpha: 0.8)
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'ابحث عن عمارة...',
                hintStyle: GoogleFonts.poppins(fontSize: 14),
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                border: InputBorder.none,
              ),
            ),
          ),
          Container(
            width: 1,
            height: 30,
            color: Colors.grey.withValues(alpha: 0.3),
          ),
          PopupMenuButton<String>(
            icon: Icon(
              _filterStatus == 'all'
                  ? Icons.filter_list_rounded
                  : Icons.filter_alt_rounded,
              color: _filterStatus != 'all' ? AppColors.primary : null,
            ),
            onSelected: (value) => setState(() => _filterStatus = value),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('جميع العمارات')),
              const PopupMenuItem(
                value: 'occupied',
                child: Text('عمارات بها وحدات مؤجرة'),
              ),
              const PopupMenuItem(
                value: 'vacant',
                child: Text('عمارات بها وحدات فارغة'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_city_outlined,
            size: 80,
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد عمارات بعد',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ابدئي بإضافة أول عمارة',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => _openAddBuildingDialog(context),
            icon: const Icon(Icons.add_business_rounded),
            label: const Text('إضافة عمارة'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return ScaleTransition(
      scale: Tween(begin: 1.0, end: 1.1).animate(
        CurvedAnimation(
          parent: _floatingButtonController,
          curve: Curves.easeInOut,
        ),
      ),
      child: FloatingActionButton.extended(
        onPressed: () => _openAddBuildingDialog(context),
        icon: const Icon(Icons.add_business_rounded),
        label: const Text('إضافة عمارة'),
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
    );
  }

  List<BuildingUnitsOverview> _filterBuildings(
    List<BuildingUnitsOverview> items,
  ) {
    return items.where((item) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          item.building.name.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          item.building.area.toLowerCase().contains(_searchQuery.toLowerCase());

      if (!matchesSearch) return false;

      if (_filterStatus == 'occupied') {
        return item.units.any((u) => u.isOccupied);
      }
      if (_filterStatus == 'vacant') {
        return item.units.any((u) => !u.isOccupied);
      }
      return true;
    }).toList();
  }

  void _showBuildingDetails(BuildContext context, BuildingUnitsOverview item) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return _BuildingDetailsSheet(item: item);
      },
    );
  }

  Future<void> _openAddBuildingDialog(BuildContext context) async {
    final service = context.read<RentalOfficeService>();
    final formKey = GlobalKey<FormState>();

    final nameController = TextEditingController();
    final cityController = TextEditingController();
    final areaController = TextEditingController();
    final streetController = TextEditingController();
    final floorsController = TextEditingController(text: '1');

    String? landlordId = service.landlords.isNotEmpty
        ? service.landlords.first.id
        : null;

    final added = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            constraints: const BoxConstraints(maxWidth: 500),
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isCompact = constraints.maxWidth < 560;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF6F4A2F),
                                    Color(0xFFA6784E),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.add_business_rounded,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'إضافة عمارة جديدة',
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _buildAnimatedTextField(
                          controller: nameController,
                          label: 'اسم العمارة',
                          icon: Icons.location_city_rounded,
                          validator: (v) =>
                              v?.isEmpty ?? true ? 'ادخلي اسم العمارة' : null,
                        ),
                        const SizedBox(height: 16),
                        isCompact
                            ? Column(
                                children: [
                                  _buildAnimatedTextField(
                                    controller: cityController,
                                    label: 'المدينة',
                                    icon: Icons.location_on_rounded,
                                    validator: (v) => v?.isEmpty ?? true
                                        ? 'ادخلي المدينة'
                                        : null,
                                  ),
                                  const SizedBox(height: 12),
                                  _buildAnimatedTextField(
                                    controller: areaController,
                                    label: 'المنطقة',
                                    icon: Icons.map_rounded,
                                    validator: (v) => v?.isEmpty ?? true
                                        ? 'ادخلي المنطقة'
                                        : null,
                                  ),
                                ],
                              )
                            : Row(
                                children: [
                                  Expanded(
                                    child: _buildAnimatedTextField(
                                      controller: cityController,
                                      label: 'المدينة',
                                      icon: Icons.location_on_rounded,
                                      validator: (v) => v?.isEmpty ?? true
                                          ? 'ادخلي المدينة'
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildAnimatedTextField(
                                      controller: areaController,
                                      label: 'المنطقة',
                                      icon: Icons.map_rounded,
                                      validator: (v) => v?.isEmpty ?? true
                                          ? 'ادخلي المنطقة'
                                          : null,
                                    ),
                                  ),
                                ],
                              ),
                        const SizedBox(height: 16),
                        _buildAnimatedTextField(
                          controller: streetController,
                          label: 'العنوان',
                          icon: Icons.streetview_rounded,
                          validator: (v) =>
                              v?.isEmpty ?? true ? 'ادخلي العنوان' : null,
                        ),
                        const SizedBox(height: 16),
                        isCompact
                            ? Column(
                                children: [
                                  _buildAnimatedTextField(
                                    controller: floorsController,
                                    label: 'عدد الأدوار',
                                    icon: Icons.height_rounded,
                                    keyboardType: TextInputType.number,
                                    validator: (v) {
                                      final parsed = int.tryParse(v ?? '');
                                      if (parsed == null || parsed <= 0) {
                                        return 'رقم صحيح';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 12),
                                  DropdownButtonFormField<String>(
                                    value: landlordId,
                                    isExpanded: true,
                                    decoration: InputDecoration(
                                      labelText: 'المالك',
                                      prefixIcon: const Icon(
                                        Icons.person_rounded,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    selectedItemBuilder: (context) {
                                      return service.landlords.map((landlord) {
                                        return Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            landlord.fullName,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        );
                                      }).toList();
                                    },
                                    items: service.landlords.map((landlord) {
                                      return DropdownMenuItem(
                                        value: landlord.id,
                                        child: Text(
                                          landlord.fullName,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) => landlordId = value,
                                    validator: (v) =>
                                        v == null ? 'اختاري المالك' : null,
                                  ),
                                ],
                              )
                            : Row(
                                children: [
                                  Expanded(
                                    child: _buildAnimatedTextField(
                                      controller: floorsController,
                                      label: 'عدد الأدوار',
                                      icon: Icons.height_rounded,
                                      keyboardType: TextInputType.number,
                                      validator: (v) {
                                        final parsed = int.tryParse(v ?? '');
                                        if (parsed == null || parsed <= 0) {
                                          return 'رقم صحيح';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      value: landlordId,
                                      isExpanded: true,
                                      decoration: InputDecoration(
                                        labelText: 'المالك',
                                        prefixIcon: const Icon(
                                          Icons.person_rounded,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                      ),
                                      selectedItemBuilder: (context) {
                                        return service.landlords.map((
                                          landlord,
                                        ) {
                                          return Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              landlord.fullName,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          );
                                        }).toList();
                                      },
                                      items: service.landlords.map((landlord) {
                                        return DropdownMenuItem(
                                          value: landlord.id,
                                          child: Text(
                                            landlord.fullName,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (value) => landlordId = value,
                                      validator: (v) =>
                                          v == null ? 'اختاري المالك' : null,
                                    ),
                                  ),
                                ],
                              ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () =>
                                    Navigator.pop(dialogContext, false),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: const Text('إلغاء'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: FilledButton(
                                onPressed: () async {
                                  if (!(formKey.currentState?.validate() ??
                                      false)) {
                                    return;
                                  }
                                  final ok = await service.addBuilding(
                                    name: nameController.text,
                                    city: cityController.text,
                                    area: areaController.text,
                                    streetAddress: streetController.text,
                                    landlordId: landlordId ?? '',
                                    floorsCount: int.parse(
                                      floorsController.text,
                                    ),
                                  );
                                  if (!dialogContext.mounted) return;
                                  Navigator.pop(dialogContext, ok);
                                },
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: const Text('حفظ'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          added == true
              ? '✨ تمت إضافة العمارة بنجاح'
              : '⚠️ تعذر الإضافة، تأكدي من البيانات',
        ),
        backgroundColor: added == true
            ? Colors.green.shade700
            : Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _confirmDeleteBuilding(
    BuildContext context,
    BuildingUnitsOverview overview,
  ) async {
    final service = context.read<RentalOfficeService>();

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('حذف العمارة'),
        content: Text(
          'هل تريدين حذف عمارة ${overview.building.name}؟ سيتم حذف كل الشقق والعقود والمدفوعات المرتبطة بها.',
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

    final deleted = await service.deleteBuilding(
      buildingId: overview.building.id,
    );
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(deleted ? 'تم حذف العمارة' : 'تعذر حذف العمارة'),
        backgroundColor: deleted ? Colors.green : Colors.red,
      ),
    );
  }

  Widget _buildAnimatedTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      validator: validator,
    );
  }
}

class _AnimatedBuildingCard extends StatefulWidget {
  final BuildingUnitsOverview item;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _AnimatedBuildingCard({
    required this.item,
    required this.onTap,
    required this.onDelete,
  });

  @override
  State<_AnimatedBuildingCard> createState() => _AnimatedBuildingCardState();
}

class _AnimatedBuildingCardState extends State<_AnimatedBuildingCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final occupiedUnits = widget.item.units.where((u) => u.isOccupied).length;
    final vacantUnits = widget.item.units.length - occupiedUnits;
    final occupancyRate = widget.item.units.isEmpty
        ? 0
        : (occupiedUnits / widget.item.units.length) * 100;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        transform: Matrix4.identity()..translate(0, _isHovered ? -4 : 0),
        child: Material(
          elevation: _isHovered ? 8 : 2,
          borderRadius: BorderRadius.circular(24),
          color: isDark ? Colors.grey.shade900 : Colors.white,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(24),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary,
                              AppColors.primary.withValues(alpha: 0.7),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.location_city_rounded,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.item.building.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${widget.item.building.city} - ${widget.item.building.area}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: occupancyRate > 50
                              ? Colors.green.shade50
                              : Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${occupancyRate.toStringAsFixed(0)}% مشغولة',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: occupancyRate > 50
                                ? Colors.green.shade700
                                : Colors.orange.shade700,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'حذف العمارة',
                        onPressed: widget.onDelete,
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildStatChip(
                        Icons.meeting_room_rounded,
                        '${widget.item.units.length}',
                        'وحدة',
                        const Color(0xFF8B5E3C),
                      ),
                      const SizedBox(width: 12),
                      _buildStatChip(
                        Icons.key_rounded,
                        '$occupiedUnits',
                        'مؤجرة',
                        Colors.green,
                      ),
                      const SizedBox(width: 12),
                      _buildStatChip(
                        Icons.meeting_room_outlined,
                        '$vacantUnits',
                        'فارغة',
                        Colors.orange,
                      ),
                    ],
                  ),
                  if (widget.item.units.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: occupancyRate / 100,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        occupancyRate > 70
                            ? Colors.green
                            : occupancyRate > 30
                            ? Colors.orange
                            : Colors.red,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      minHeight: 8,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              '$value $label',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BuildingDetailsSheet extends StatelessWidget {
  final BuildingUnitsOverview item;

  const _BuildingDetailsSheet({required this.item});

  @override
  Widget build(BuildContext context) {
    final maxDialogHeight = (MediaQuery.of(context).size.height * 0.72)
        .clamp(420.0, 640.0)
        .toDouble();

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Container(
        constraints: BoxConstraints(maxWidth: 500, maxHeight: maxDialogHeight),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey.shade900
              : Colors.white,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6F4A2F), Color(0xFFA6784E)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.location_city_rounded,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.building.name,
                              style: GoogleFonts.poppins(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${item.building.city}، ${item.building.area}، ${item.building.streetAddress}',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: item.units.length,
                itemBuilder: (context, index) {
                  final unit = item.units[index];
                  return FadeInLeft(
                    duration: Duration(milliseconds: 200 + (index * 50)),
                    child: Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: unit.isOccupied
                              ? Colors.green.withValues(alpha: 0.2)
                              : Colors.orange.withValues(alpha: 0.2),
                          child: Icon(
                            unit.isOccupied
                                ? Icons.key_rounded
                                : Icons.meeting_room_rounded,
                            color: unit.isOccupied
                                ? Colors.green
                                : Colors.orange,
                          ),
                        ),
                        title: Text(
                          'شقة ${unit.unit.unitNumber} - الدور ${unit.unit.floorNumber}',
                        ),
                        subtitle: Text(
                          unit.isOccupied
                              ? 'المستأجر: ${unit.currentTenant?.fullName ?? '-'}'
                              : 'شاغرة - متاحة للإيجار',
                        ),
                        trailing: Text(
                          '${unit.unit.monthlyRent.toStringAsFixed(0)} ج.م',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
