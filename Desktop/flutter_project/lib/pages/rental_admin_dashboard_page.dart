import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import '../models/building.dart';
import '../models/lease_contract.dart';
import '../models/rental_unit.dart';
import '../services/rental_office_service.dart';
import '../theme/theme_controller.dart';

class _DashboardPalette {
  static const Color primary = Color(0xFF7A5233);
}

class RentalAdminDashboardPage extends StatefulWidget {
  const RentalAdminDashboardPage({super.key});

  @override
  State<RentalAdminDashboardPage> createState() =>
      _RentalAdminDashboardPageState();
}

class _RentalAdminDashboardPageState extends State<RentalAdminDashboardPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late final AnimationController _entryController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  String _searchQuery = '';
  int _activeSection = 0;
  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;

  final List<String> _months = [
    'يناير',
    'فبراير',
    'مارس',
    'أبريل',
    'مايو',
    'يونيو',
    'يوليو',
    'أغسطس',
    'سبتمبر',
    'أكتوبر',
    'نوفمبر',
    'ديسمبر',
  ];

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOutCubic,
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.045), end: Offset.zero).animate(
          CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic),
        );
    _entryController.forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RentalOfficeService>(
      builder: (context, office, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final stats = office.getDashboardStats();
        final expiringContracts = office.getContractsExpiringWithinDays(30);
        final renewals = office.getRenewalsDueWithinDays(45);
        final overduePayments = office.getOverduePayments();
        final upcomingRent = office.getUpcomingRentDueWithinDays(7);
        final monthlyUnpaid = office.getUnpaidForCurrentMonth();
        final arrears = office.getTenantArrears(minMonths: 2);
        final buildings = office.getBuildingsWithUnitsOverview();
        final searchResult = office.searchContracts(_searchQuery);
        final activeContracts = office
            .searchContracts('')
            .where((item) => item.contract.status == ContractStatus.active)
            .toList();

        return Scaffold(
          backgroundColor: isDark
              ? const Color(0xFF1C140F)
              : const Color(0xFFF4E9DB),
          appBar: _buildAppBar(office),
          body: Stack(
            children: [
              const _AmbientBackground(),
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isDesktop = constraints.maxWidth >= 1200;
                      final statColumns = constraints.maxWidth >= 900
                          ? 4
                          : constraints.maxWidth >= 620
                          ? 2
                          : 1;

                      return Align(
                        alignment: Alignment.topCenter,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1600),
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _welcomeHeader(stats),
                                const SizedBox(height: 24),
                                _quickActionsBar(
                                  expiringContracts: expiringContracts,
                                  arrears: arrears,
                                ),
                                const SizedBox(height: 28),
                                _sectionSwitcher(),
                                const SizedBox(height: 24),
                                _searchBar(),
                                const SizedBox(height: 24),
                                _statsGrid(
                                  stats: stats,
                                  activeContracts: activeContracts,
                                  expiringContracts: expiringContracts,
                                  overduePayments: overduePayments,
                                  monthlyUnpaid: monthlyUnpaid,
                                  buildings: buildings,
                                  columns: statColumns,
                                ),
                                const SizedBox(height: 24),
                                _activeSectionBody(
                                  isDesktop: isDesktop,
                                  office: office,
                                  searchResult: searchResult,
                                  expiringContracts: expiringContracts,
                                  renewals: renewals,
                                  monthlyUnpaid: monthlyUnpaid,
                                  arrears: arrears,
                                  overduePayments: overduePayments,
                                  upcomingRent: upcomingRent,
                                  buildings: buildings,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  AppBar _buildAppBar(RentalOfficeService office) {
    return AppBar(
      backgroundColor: const Color(0xFF6F4A2F),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      foregroundColor: Colors.white,
      flexibleSpace: const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6F4A2F), Color(0xFF8B5E3C)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
      ),
      centerTitle: false,
      titleSpacing: 20,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6F4A2F), Color(0xFFA6784E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.business_center_rounded,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Rental Command Center',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  letterSpacing: 0.2,
                  color: Colors.white,
                ),
              ),
              Text(
                'إدارة العقارات الذكية',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.82),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () => context.read<ThemeController>().toggleTheme(),
          icon: Icon(
            Theme.of(context).brightness == Brightness.dark
                ? Icons.light_mode_rounded
                : Icons.dark_mode_rounded,
          ),
          tooltip: 'تبديل الوضع',
        ),
        _buildNavButton('Home', Icons.home_rounded, '/'),
        _buildNavButton('العمارات', Icons.apartment_rounded, '/buildings'),
        _buildNavButton('الشقق', Icons.home_work_rounded, '/units'),
        _buildSyncButton(office),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildNavButton(String label, IconData icon, String route) {
    return TextButton.icon(
      onPressed: () => Navigator.pushNamed(context, route),
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: TextButton.styleFrom(
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildSyncButton(RentalOfficeService office) {
    return FilledButton.icon(
      onPressed: () async {
        final success = await office.seedFirestoreFromLocalData();
        if (!mounted) return;
        _showResult(
          context,
          success,
          'تمت مزامنة بيانات المكتب مع قاعدة البيانات',
          'فشل رفع البيانات',
        );
      },
      icon: const Icon(Icons.cloud_sync_rounded, size: 18),
      label: const Text('مزامنة'),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _welcomeHeader(RentalDashboardStats stats) {
    const greetingIcon = Icons.business_center_rounded;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _DashboardPalette.primary.withValues(alpha: 0.1),
            _DashboardPalette.primary.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _DashboardPalette.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6F4A2F), Color(0xFFA6784E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(greetingIcon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تفاصيل مكتب العقارات',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'لديك ${stats.activeContracts} عقد نشط و ${stats.occupiedUnits} وحدة مؤجرة',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _DashboardPalette.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 14,
                  color: _DashboardPalette.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  _formatDate(DateTime.now()),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: _DashboardPalette.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchBar() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        style: GoogleFonts.poppins(),
        decoration: InputDecoration(
          hintText: 'ابحث باسم المستأجر، المالك، العمارة أو رقم الوحدة...',
          hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: _DashboardPalette.primary,
          ),
          suffixIcon: _searchQuery.isEmpty
              ? null
              : IconButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                  icon: Icon(Icons.close_rounded, color: Colors.grey.shade500),
                ),
          filled: true,
          fillColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: _DashboardPalette.primary, width: 2),
          ),
        ),
        onChanged: (value) => setState(() => _searchQuery = value),
      ),
    );
  }

  Widget _quickActionsBar({
    required List<ContractOverview> expiringContracts,
    required List<TenantArrearsOverview> arrears,
  }) {
    return _GlassPanel(
      padding: const EdgeInsets.all(14),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        alignment: WrapAlignment.spaceBetween,
        children: [
          FilledButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/buildings'),
            icon: const Icon(Icons.add_business_rounded),
            label: const Text('إضافة عمارة'),
          ),
          FilledButton.tonalIcon(
            onPressed: () => Navigator.pushNamed(context, '/units'),
            icon: const Icon(Icons.add_home_work_rounded),
            label: const Text('إضافة شقة'),
          ),
          OutlinedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/buildings'),
            icon: const Icon(Icons.location_city_rounded),
            label: const Text('عرض العمارات'),
          ),
          OutlinedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/units'),
            icon: const Icon(Icons.apartment_rounded),
            label: const Text('عرض الشقق'),
          ),
          FilledButton.tonalIcon(
            onPressed: () => _exportFollowUpReportPdf(
              expiringContracts: expiringContracts,
              arrears: arrears,
            ),
            icon: const Icon(Icons.picture_as_pdf_rounded),
            label: const Text('تقرير PDF'),
          ),
          OutlinedButton.icon(
            onPressed: () => _exportFollowUpReportWord(
              expiringContracts: expiringContracts,
              arrears: arrears,
            ),
            icon: const Icon(Icons.description_rounded),
            label: const Text('تقرير Word'),
          ),
        ],
      ),
    );
  }

  Widget _statsGrid({
    required RentalDashboardStats stats,
    required List<ContractOverview> activeContracts,
    required List<ContractOverview> expiringContracts,
    required List<RentPaymentOverview> overduePayments,
    required List<RentPaymentOverview> monthlyUnpaid,
    required List<BuildingUnitsOverview> buildings,
    required int columns,
  }) {
    final totalUnits = stats.totalUnits;
    final occupancyPercent = totalUnits == 0
        ? 0
        : ((stats.occupiedUnits / totalUnits) * 100).toInt();
    final monthlyDue = stats.monthlyDue;
    final collectionPercent = monthlyDue == 0
        ? 0
        : ((stats.monthlyCollected / monthlyDue) * 100).toInt();

    final statsItems = [
      _StatItem(
        title: 'العقود النشطة',
        value: stats.activeContracts,
        icon: Icons.description_rounded,
        color: const Color(0xFF6F4A2F),
        trend: '${stats.expiringContractsIn30Days} تنتهي قريبًا',
        onTap: () {
          _showHeroDetailsDialog(
            title: 'العقود النشطة',
            rows: [
              'إجمالي العقود النشطة: ${stats.activeContracts}',
              if (activeContracts.isNotEmpty)
                ...activeContracts
                    .take(20)
                    .map(
                      (item) =>
                          '${item.tenant.fullName} • شقة ${item.unit.unitNumber} • تنتهي ${_formatDate(item.contract.endDate)}',
                    ),
            ],
            emptyText: 'لا توجد عقود نشطة',
          );
        },
      ),
      _StatItem(
        title: 'الإشغال',
        value: occupancyPercent,
        icon: Icons.analytics_rounded,
        color: const Color(0xFF8C6A44),
        suffix: '%',
        trend: '${stats.occupiedUnits}/${stats.totalUnits} وحدة',
        onTap: () {
          _showHeroDetailsDialog(
            title: 'نسبة الإشغال',
            rows: [
              'الوحدات المؤجرة: ${stats.occupiedUnits}',
              'الوحدات الفارغة: ${stats.vacantUnits}',
              'نسبة الإشغال: ${totalUnits == 0 ? '0.0' : ((stats.occupiedUnits / totalUnits) * 100).toStringAsFixed(1)}%',
              if (buildings.isNotEmpty) ...[
                '---',
                ...buildings
                    .take(10)
                    .map(
                      (b) =>
                          '${b.building.name}: ${b.occupiedCount}/${b.units.length} مؤجر',
                    ),
              ],
            ],
            emptyText: 'لا توجد بيانات',
          );
        },
      ),
      _StatItem(
        title: 'الدفعات المتأخرة',
        value: stats.overduePayments,
        icon: Icons.warning_amber_rounded,
        color: const Color(0xFF9B5D4A),
        trend: 'تحتاج متابعة',
        onTap: () {
          _showHeroDetailsDialog(
            title: 'الدفعات المتأخرة',
            rows: overduePayments
                .map(
                  (item) =>
                      '${item.tenant.fullName} • ${item.building.name} / ${item.unit.unitNumber} • متبقي ${_money(item.payment.amount - item.payment.paidAmount)} ج.م',
                )
                .toList(),
            emptyText: 'لا توجد دفعات متأخرة',
          );
        },
      ),
      _StatItem(
        title: 'تحصيل الشهر',
        value: collectionPercent,
        icon: Icons.payments_rounded,
        color: const Color(0xFF8B5E3C),
        suffix: '%',
        trend:
            '${_money(stats.monthlyCollected)} / ${_money(stats.monthlyDue)} ج.م',
        onTap: () {
          _showHeroDetailsDialog(
            title: 'تفاصيل تحصيل الشهر',
            rows: [
              'تم تحصيل: ${_money(stats.monthlyCollected)} ج.م',
              'المطلوب: ${_money(stats.monthlyDue)} ج.م',
              'نسبة التحصيل: ${monthlyDue == 0 ? '0.0' : ((stats.monthlyCollected / monthlyDue) * 100).toStringAsFixed(1)}%',
              if (monthlyUnpaid.isNotEmpty) ...[
                '---',
                ...monthlyUnpaid
                    .take(15)
                    .map(
                      (item) =>
                          '${item.tenant.fullName} • ${item.unit.unitNumber} • متبقي ${_money(item.payment.amount - item.payment.paidAmount)} ج.م',
                    ),
              ],
            ],
            emptyText: 'لا توجد بيانات تحصيل',
          );
        },
      ),
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: columns,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.3,
      children: statsItems.asMap().entries.map((entry) {
        if (kIsWeb) {
          return _StatCard(
            title: entry.value.title,
            value: entry.value.suffix != null
                ? '${entry.value.value}${entry.value.suffix}'
                : entry.value.value.toString(),
            icon: entry.value.icon,
            tone: entry.value.color,
            trend: entry.value.trend,
            onTapCard: entry.value.onTap,
          );
        }

        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: entry.value.value.toDouble()),
          duration: Duration(milliseconds: 600 + (entry.key * 80)),
          curve: Curves.easeOutCubic,
          builder: (context, animatedValue, child) {
            return _StatCard(
              title: entry.value.title,
              value: entry.value.suffix != null
                  ? '${animatedValue.toInt()}${entry.value.suffix}'
                  : animatedValue.toInt().toString(),
              icon: entry.value.icon,
              tone: entry.value.color,
              trend: entry.value.trend,
              onTapCard: entry.value.onTap,
            );
          },
        );
      }).toList(),
    );
  }

  Widget _sectionSwitcher() {
    final sections = <({String label, IconData icon, String description})>[
      (
        label: 'نظرة عامة',
        icon: Icons.dashboard_rounded,
        description: 'ملخص الأداء',
      ),
      (
        label: 'العقود',
        icon: Icons.description_rounded,
        description: 'إدارة العقود',
      ),
      (
        label: 'المالية',
        icon: Icons.account_balance_wallet_rounded,
        description: 'المدفوعات',
      ),
      (
        label: 'العمارات',
        icon: Icons.location_city_rounded,
        description: 'الممتلكات',
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: List.generate(sections.length, (index) {
          final section = sections[index];
          final selected = index == _activeSection;
          return Expanded(
            child: _SectionChip(
              icon: section.icon,
              label: section.label,
              description: section.description,
              selected: selected,
              onTap: () => setState(() => _activeSection = index),
            ),
          );
        }),
      ),
    );
  }

  Widget _activeSectionBody({
    required bool isDesktop,
    required RentalOfficeService office,
    required List<ContractOverview> searchResult,
    required List<ContractOverview> expiringContracts,
    required List<ContractOverview> renewals,
    required List<RentPaymentOverview> monthlyUnpaid,
    required List<TenantArrearsOverview> arrears,
    required List<RentPaymentOverview> overduePayments,
    required List<RentPaymentOverview> upcomingRent,
    required List<BuildingUnitsOverview> buildings,
  }) {
    switch (_activeSection) {
      case 0:
        return _overviewSection(
          isDesktop: isDesktop,
          office: office,
          expiringContracts: expiringContracts,
          monthlyUnpaid: monthlyUnpaid,
          buildings: buildings,
          arrears: arrears,
        );
      case 1:
        return _contractsSection(
          searchResult: searchResult,
          expiringContracts: expiringContracts,
          renewals: renewals,
          office: office,
        );
      case 2:
        return _financeSection(
          monthlyUnpaid: monthlyUnpaid,
          arrears: arrears,
          overduePayments: overduePayments,
          upcomingRent: upcomingRent,
          office: office,
        );
      case 3:
        return _buildingsSection(buildings);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _overviewSection({
    required bool isDesktop,
    required RentalOfficeService office,
    required List<ContractOverview> expiringContracts,
    required List<RentPaymentOverview> monthlyUnpaid,
    required List<BuildingUnitsOverview> buildings,
    required List<TenantArrearsOverview> arrears,
  }) {
    if (!isDesktop) {
      return Column(
        children: [
          _priorityAlertCards(expiringContracts, arrears, monthlyUnpaid),
          const SizedBox(height: 16),
          _performanceChart(office),
          const SizedBox(height: 16),
          _recentActivityList(expiringContracts, monthlyUnpaid),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 7,
          child: Column(
            children: [
              _priorityAlertCards(expiringContracts, arrears, monthlyUnpaid),
              const SizedBox(height: 16),
              _recentActivityList(expiringContracts, monthlyUnpaid),
            ],
          ),
        ),
        const SizedBox(width: 20),
        Expanded(flex: 5, child: _performanceChart(office)),
      ],
    );
  }

  Widget _priorityAlertCards(
    List<ContractOverview> expiringContracts,
    List<TenantArrearsOverview> arrears,
    List<RentPaymentOverview> monthlyUnpaid,
  ) {
    return Row(
      children: [
        Expanded(
          child: _AlertCard(
            title: 'عقود منتهية قريبًا',
            count: expiringContracts.length,
            icon: Icons.event_busy_rounded,
            color: const Color(0xFFA66A42),
            message: expiringContracts.isEmpty
                ? 'لا توجد عقود منتهية'
                : '${expiringContracts.first.tenant.fullName} - ينتهي ${_formatDate(expiringContracts.first.contract.endDate)}',
            onTap: () {
              _showHeroDetailsDialog(
                title: 'العقود المنتهية قريبًا',
                rows: expiringContracts
                    .map(
                      (item) =>
                          '${item.tenant.fullName} • ${item.building.name} / ${item.unit.unitNumber} • ${_formatDate(item.contract.endDate)}',
                    )
                    .toList(),
                emptyText: 'لا توجد عقود منتهية قريبًا',
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _AlertCard(
            title: 'متأخرات',
            count: arrears.length,
            icon: Icons.money_off_rounded,
            color: const Color(0xFF8A4F3F),
            message: arrears.isEmpty
                ? 'لا توجد متأخرات'
                : 'إجمالي ${_money(arrears.fold<double>(0, (sum, item) => sum + item.totalUnpaid))} ج.م',
            onTap: () {
              _showHeroDetailsDialog(
                title: 'المتأخرات',
                rows: arrears
                    .map(
                      (item) =>
                          '${item.tenant.fullName} • ${item.unpaidMonths} شهر • ${_money(item.totalUnpaid)} ج.م',
                    )
                    .toList(),
                emptyText: 'لا توجد متأخرات',
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _AlertCard(
            title: 'مدفوعات شهرية',
            count: monthlyUnpaid.length,
            icon: Icons.payment_rounded,
            color: const Color(0xFFB07B4D),
            message: monthlyUnpaid.isEmpty
                ? 'جميع المدفوعات مسددة'
                : 'متبقي ${_money(monthlyUnpaid.fold<double>(0, (sum, item) => sum + (item.payment.amount - item.payment.paidAmount)))} ج.م',
            onTap: () {
              _showHeroDetailsDialog(
                title: 'الدفعات غير المسددة',
                rows: monthlyUnpaid
                    .map(
                      (item) =>
                          '${item.tenant.fullName} • ${_money(item.payment.amount - item.payment.paidAmount)} ج.م',
                    )
                    .toList(),
                emptyText: 'جميع المدفوعات مسددة',
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _performanceChart(RentalOfficeService office) {
    return _GlassPanel(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up_rounded, color: _DashboardPalette.primary),
              const SizedBox(width: 8),
              Text(
                'أداء التحصيل',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              _buildMonthSelector(),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(height: 200, child: _buildPerformanceBars(office)),
          const SizedBox(height: 16),
          _buildPerformanceStats(office),
        ],
      ),
    );
  }

  Widget _buildMonthSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () {
              setState(() {
                if (_selectedMonth > 1) {
                  _selectedMonth--;
                } else {
                  _selectedMonth = 12;
                  _selectedYear--;
                }
              });
            },
            icon: const Icon(Icons.chevron_left, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 8),
          Text(
            '${_months[_selectedMonth - 1]} $_selectedYear',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () {
              setState(() {
                if (_selectedMonth < 12) {
                  _selectedMonth++;
                } else {
                  _selectedMonth = 1;
                  _selectedYear++;
                }
              });
            },
            icon: const Icon(Icons.chevron_right, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceBars(RentalOfficeService office) {
    // Mock data for demonstration - replace with actual data
    final List<double> collectionRates = [65, 72, 78, 85, 82, 88];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(6, (index) {
        final rate = collectionRates[index];
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              '$rate%',
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 35,
              height: (rate / 100) * 160,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: const [Color(0xFF6F4A2F), Color(0xFFA6784E)],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              ['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو'][index],
              style: GoogleFonts.poppins(fontSize: 10),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildPerformanceStats(RentalOfficeService office) {
    final stats = office.getDashboardStats();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _DashboardPalette.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Text(
                  _money(stats.monthlyCollected),
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: _DashboardPalette.primary,
                  ),
                ),
                Text('محصل', style: GoogleFonts.poppins(fontSize: 11)),
              ],
            ),
          ),
          Container(width: 1, height: 40, color: Colors.grey.shade300),
          Expanded(
            child: Column(
              children: [
                Text(
                  _money(stats.monthlyDue),
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
                Text('مستحق', style: GoogleFonts.poppins(fontSize: 11)),
              ],
            ),
          ),
          Container(width: 1, height: 40, color: Colors.grey.shade300),
          Expanded(
            child: Column(
              children: [
                Text(
                  '${((stats.monthlyCollected / stats.monthlyDue) * 100).toInt()}%',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: const Color(0xFF8C6A44),
                  ),
                ),
                Text('نسبة التحصيل', style: GoogleFonts.poppins(fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _recentActivityList(
    List<ContractOverview> expiringContracts,
    List<RentPaymentOverview> monthlyUnpaid,
  ) {
    return _GlassPanel(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.notifications_active_rounded,
                color: _DashboardPalette.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'آخر الأنشطة',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  _showHeroDetailsDialog(
                    title: 'كل الأنشطة',
                    rows: _buildAllActivitiesRows(
                      expiringContracts: expiringContracts,
                      monthlyUnpaid: monthlyUnpaid,
                    ),
                    emptyText: 'لا توجد أنشطة حديثة',
                  );
                },
                child: const Text('عرض الكل'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (expiringContracts.isNotEmpty)
            ...expiringContracts
                .take(3)
                .map(
                  (item) => _ActivityTile(
                    icon: Icons.event_busy_rounded,
                    title: 'عقد على وشك الانتهاء',
                    description:
                        '${item.tenant.fullName} - شقة ${item.unit.unitNumber}',
                    time: 'ينتهي ${_formatDate(item.contract.endDate)}',
                    color: const Color(0xFFA66A42),
                  ),
                ),
          if (monthlyUnpaid.isNotEmpty)
            ...monthlyUnpaid
                .take(3)
                .map(
                  (item) => _ActivityTile(
                    icon: Icons.payment_rounded,
                    title: 'دفعة غير مسددة',
                    description:
                        '${item.tenant.fullName} - ${_money(item.payment.amount - item.payment.paidAmount)} ج.م',
                    time: 'استحقاق ${_formatDate(item.payment.dueDate)}',
                    color: const Color(0xFFB07B4D),
                  ),
                ),
          if (expiringContracts.isEmpty && monthlyUnpaid.isEmpty)
            const _Empty(text: 'لا توجد أنشطة حديثة'),
        ],
      ),
    );
  }

  List<String> _buildAllActivitiesRows({
    required List<ContractOverview> expiringContracts,
    required List<RentPaymentOverview> monthlyUnpaid,
  }) {
    final rows = <String>[];

    for (final item in expiringContracts) {
      rows.add(
        'عقد على وشك الانتهاء • ${item.tenant.fullName} • شقة ${item.unit.unitNumber} • ينتهي ${_formatDate(item.contract.endDate)}',
      );
    }

    for (final item in monthlyUnpaid) {
      rows.add(
        'دفعة غير مسددة • ${item.tenant.fullName} • ${_money(item.payment.amount - item.payment.paidAmount)} ج.م • استحقاق ${_formatDate(item.payment.dueDate)}',
      );
    }

    return rows;
  }

  Widget _contractsSection({
    required List<ContractOverview> searchResult,
    required List<ContractOverview> expiringContracts,
    required List<ContractOverview> renewals,
    required RentalOfficeService office,
  }) {
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: _GlassPanel(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'بحث العقود',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                if (searchResult.isEmpty)
                  const _Empty(text: 'لا توجد نتائج بحث')
                else
                  ...searchResult
                      .take(8)
                      .map(
                        (item) => _ContractTile(
                          tenant: item.tenant.fullName,
                          unit:
                              '${item.building.name} / شقة ${item.unit.unitNumber}',
                          landlord: item.landlord.fullName,
                          period:
                              '${_formatDate(item.contract.startDate)} - ${_formatDate(item.contract.endDate)}',
                          status: _getContractStatus(item.contract.endDate),
                          onTap: () => _showRenewalDialog(
                            context,
                            item.contract,
                            office,
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 3,
          child: Column(
            children: [
              _GlassPanel(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تنتهي قريبًا',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    if (expiringContracts.isEmpty)
                      const _Empty(text: 'لا توجد عقود تنتهي قريبًا')
                    else
                      ...expiringContracts
                          .take(5)
                          .map(
                            (item) => _CompactTile(
                              title: item.tenant.fullName,
                              subtitle: 'شقة ${item.unit.unitNumber}',
                              date: _formatDate(item.contract.endDate),
                              dateColor: _urgency(item.contract.endDate),
                            ),
                          ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _GlassPanel(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'مواعيد التجديد',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    if (renewals.isEmpty)
                      const _Empty(text: 'لا توجد مواعيد تجديد')
                    else
                      ...renewals
                          .take(5)
                          .map(
                            (item) => _CompactTile(
                              title: item.tenant.fullName,
                              subtitle: 'شقة ${item.unit.unitNumber}',
                              date: _formatDate(item.contract.nextRenewalDate),
                              dateColor: _urgency(
                                item.contract.nextRenewalDate,
                              ),
                              onTap: () => _showRenewalDialog(
                                context,
                                item.contract,
                                office,
                              ),
                              actionLabel: 'تجديد',
                              onAction: () => _showRenewalDialog(
                                context,
                                item.contract,
                                office,
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _financeSection({
    required List<RentPaymentOverview> monthlyUnpaid,
    required List<TenantArrearsOverview> arrears,
    required List<RentPaymentOverview> overduePayments,
    required List<RentPaymentOverview> upcomingRent,
    required RentalOfficeService office,
  }) {
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: Column(
            children: [
              _GlassPanel(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: const Color(0xFF9B5D4A),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'المتأخرات',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (arrears.isEmpty)
                      const _Empty(text: 'لا توجد متأخرات')
                    else
                      ...arrears
                          .take(6)
                          .map(
                            (item) => _ArrearsTile(
                              tenant: item.tenant.fullName,
                              unit:
                                  '${item.building.name} / ${item.unit.unitNumber}',
                              months: item.unpaidMonths,
                              amount: item.totalUnpaid,
                              onPay: () async {
                                final firstUnpaid =
                                    item.unpaidPayments.isNotEmpty
                                    ? item.unpaidPayments.first
                                    : null;
                                if (firstUnpaid == null) {
                                  if (!mounted) return;
                                  _showResult(
                                    context,
                                    false,
                                    'تم تسجيل السداد',
                                    'لا توجد دفعات متأخرة مسجلة لهذا المستأجر',
                                  );
                                  return;
                                }

                                final ok = await office.markPaymentAsPaid(
                                  paymentId: firstUnpaid.id,
                                  paymentMethod: 'cash',
                                );
                                if (!mounted) return;
                                _showResult(
                                  context,
                                  ok,
                                  'تم تسجيل السداد',
                                  'تعذر تسجيل السداد',
                                );
                              },
                            ),
                          ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _GlassPanel(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.upcoming_rounded,
                          color: const Color(0xFF8B5E3C),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'الاستحقاقات القادمة',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (upcomingRent.isEmpty)
                      const _Empty(text: 'لا توجد استحقاقات خلال 7 أيام')
                    else
                      ...upcomingRent
                          .take(6)
                          .map(
                            (item) => _UpcomingPaymentTile(
                              tenant: item.tenant.fullName,
                              unit:
                                  '${item.building.name} / ${item.unit.unitNumber}',
                              amount: item.payment.amount,
                              dueDate: item.payment.dueDate,
                            ),
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 3,
          child: _GlassPanel(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ملخص مالي سريع',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 20),
                _QuickFinanceCard(
                  title: 'إجمالي الإيرادات الشهرية',
                  amount: monthlyUnpaid.fold<double>(
                    0,
                    (sum, item) => sum + item.payment.amount,
                  ),
                  color: const Color(0xFF8C6A44),
                ),
                const SizedBox(height: 12),
                _QuickFinanceCard(
                  title: 'المتأخرات الكلية',
                  amount: arrears.fold<double>(
                    0,
                    (sum, item) => sum + item.totalUnpaid,
                  ),
                  color: const Color(0xFF9B5D4A),
                ),
                const SizedBox(height: 12),
                _QuickFinanceCard(
                  title: 'المتوقع تحصيله',
                  amount: upcomingRent.fold<double>(
                    0,
                    (sum, item) => sum + item.payment.amount,
                  ),
                  color: const Color(0xFF8B5E3C),
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 12),
                _FinanceSummaryRow(
                  label: 'نسبة التحصيل',
                  value: '78%',
                  color: const Color(0xFF8C6A44),
                ),
                const SizedBox(height: 8),
                _FinanceSummaryRow(
                  label: 'متوسط الإيجار',
                  value: '4,250 ج.م',
                  color: const Color(0xFF6F4A2F),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildingsSection(List<BuildingUnitsOverview> buildings) {
    return _GlassPanel(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'محفظة العقارات',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.25,
            ),
            itemCount: buildings.length,
            itemBuilder: (context, index) {
              final building = buildings[index];
              return _BuildingCard(
                building: building.building,
                occupiedCount: building.occupiedCount,
                vacantCount: building.vacantCount,
                units: building.units,
              );
            },
          ),
        ],
      ),
    );
  }

  // Helper methods remain the same...
  String _getContractStatus(DateTime endDate) {
    final now = DateTime.now();
    final daysLeft = endDate.difference(now).inDays;
    if (daysLeft < 0) return 'منتهي';
    if (daysLeft <= 30) return 'ينتهي قريبًا';
    return 'نشط';
  }

  String _formatDate(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '$d/$m/${date.year}';
  }

  String _money(double value) {
    final text = value.toStringAsFixed(0);
    return text.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );
  }

  Color _urgency(DateTime date) {
    final now = DateTime.now();
    final diff = DateTime(
      date.year,
      date.month,
      date.day,
    ).difference(DateTime(now.year, now.month, now.day)).inDays;
    if (diff < 0) return const Color(0xFF8D5546);
    if (diff <= 7) return const Color(0xFFE1732A);
    if (diff <= 30) return const Color(0xFFB2875D);
    return const Color(0xFF8C6A44);
  }

  void _showHeroDetailsDialog({
    required String title,
    required List<String> rows,
    String emptyText = 'لا توجد بيانات',
  }) {
    final screenSize = MediaQuery.sizeOf(context);
    final dialogWidth = screenSize.width < 500
        ? screenSize.width * 0.72
        : 320.0;
    final dialogMaxHeight = screenSize.height < 700
        ? screenSize.height * 0.30
        : 210.0;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 20,
          ),
          title: Text(title),
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: dialogWidth,
              maxHeight: dialogMaxHeight,
            ),
            child: rows.isEmpty
                ? Text(emptyText, style: GoogleFonts.poppins())
                : SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(rows.length, (index) {
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: index == rows.length - 1 ? 0 : 8,
                          ),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest
                                  .withValues(alpha: 0.4),
                            ),
                            child: Text(
                              rows[index],
                              style: GoogleFonts.poppins(),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('إغلاق'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showRenewalDialog(
    BuildContext context,
    LeaseContract contract,
    RentalOfficeService office,
  ) async {
    final monthsController = TextEditingController(text: '12');
    final rentController = TextEditingController(
      text: contract.monthlyRent.toStringAsFixed(0),
    );
    final increaseController = TextEditingController(
      text: contract.annualIncreasePercent.toStringAsFixed(1),
    );
    DateTime? selectedRenewalDate;

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('تجديد العقد'),
        content: SizedBox(
          width: 560,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: monthsController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'عدد أشهر التجديد',
                    hintText: '12',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: rentController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: 'الإيجار الشهري الجديد (ج.م)',
                    hintText: contract.monthlyRent.toStringAsFixed(0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: increaseController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: 'نسبة الزيادة السنوية (%)',
                    hintText: contract.annualIncreasePercent.toStringAsFixed(1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: contract.endDate.add(
                        const Duration(days: 1),
                      ),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(
                        const Duration(days: 365 * 5),
                      ),
                    );
                    if (pickedDate != null) {
                      selectedRenewalDate = pickedDate;
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          selectedRenewalDate == null
                              ? 'تاريخ البداية: بعد نهاية العقد'
                              : 'تاريخ البداية: ${_formatDate(selectedRenewalDate!)}',
                          style: GoogleFonts.poppins(),
                        ),
                        const Icon(Icons.calendar_today),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () async {
              final months = int.tryParse(monthsController.text) ?? 12;
              final newRent =
                  double.tryParse(rentController.text) ?? contract.monthlyRent;
              final newIncrease =
                  double.tryParse(increaseController.text) ??
                  contract.annualIncreasePercent;

              Navigator.pop(ctx);

              if (!mounted) return;

              final ok = await office.renewContract(
                contractId: contract.id,
                extensionMonths: months,
                newMonthlyRent: newRent,
                annualIncreasePercent: newIncrease,
                renewalDate: selectedRenewalDate,
              );

              if (!mounted) return;
              _showResult(
                context,
                ok,
                'تم تجديد العقد بنجاح • $months شهر بإيجار ${_money(newRent)} ج.م',
                'تعذر تجديد العقد',
              );
            },
            child: const Text('تجديد العقد'),
          ),
        ],
      ),
    );
  }

  void _showResult(BuildContext context, bool success, String ok, String fail) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? ok : fail),
        backgroundColor: success
            ? const Color(0xFF8C6A44)
            : const Color(0xFF8D5546),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _exportFollowUpReportPdf({
    required List<ContractOverview> expiringContracts,
    required List<TenantArrearsOverview> arrears,
  }) async {
    final stamp = _reportStamp();
    final now = DateTime.now();

    try {
      final arabicRegular = await PdfGoogleFonts.cairoRegular();
      final arabicBold = await PdfGoogleFonts.cairoBold();
      final doc = pw.Document();
      doc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(24),
          theme: pw.ThemeData.withFont(base: arabicRegular, bold: arabicBold),
          build: (context) => [
            pw.Directionality(
              textDirection: pw.TextDirection.rtl,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  pw.Text(
                    'تقرير متابعة العقارات',
                    textAlign: pw.TextAlign.right,
                    style: const pw.TextStyle(fontSize: 24),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'تاريخ التقرير: ${_formatDateTime(now)}',
                    textAlign: pw.TextAlign.right,
                  ),
                  pw.SizedBox(height: 20),
                  pw.Text(
                    '1) العقود المنتهية قريبًا (${expiringContracts.length})',
                    textAlign: pw.TextAlign.right,
                    style: const pw.TextStyle(fontSize: 16),
                  ),
                  pw.SizedBox(height: 12),
                  if (expiringContracts.isEmpty)
                    pw.Text(
                      'لا توجد عقود منتهية في الفترة المحددة.',
                      textAlign: pw.TextAlign.right,
                    )
                  else
                    pw.Table.fromTextArray(
                      headers: const [
                        'المستأجر',
                        'العمارة/الشقة',
                        'تاريخ الانتهاء',
                      ],
                      data: expiringContracts
                          .map(
                            (item) => [
                              item.tenant.fullName,
                              '${item.building.name} / ${item.unit.unitNumber}',
                              _formatDate(item.contract.endDate),
                            ],
                          )
                          .toList(),
                      headerStyle: const pw.TextStyle(),
                      headerAlignment: pw.Alignment.centerRight,
                      cellAlignment: pw.Alignment.centerRight,
                      cellAlignments: {
                        0: pw.Alignment.centerRight,
                        1: pw.Alignment.centerRight,
                        2: pw.Alignment.centerRight,
                      },
                      cellPadding: const pw.EdgeInsets.all(8),
                    ),
                  pw.SizedBox(height: 20),
                  pw.Text(
                    '2) المستأجرون المتأخرون (${arrears.length})',
                    textAlign: pw.TextAlign.right,
                    style: const pw.TextStyle(fontSize: 16),
                  ),
                  pw.SizedBox(height: 12),
                  if (arrears.isEmpty)
                    pw.Text(
                      'لا توجد متأخرات مسجلة.',
                      textAlign: pw.TextAlign.right,
                    )
                  else
                    pw.Table.fromTextArray(
                      headers: const [
                        'المستأجر',
                        'العمارة/الشقة',
                        'شهور متأخرة',
                        'إجمالي المتأخرات',
                      ],
                      data: arrears
                          .map(
                            (item) => [
                              item.tenant.fullName,
                              '${item.building.name} / ${item.unit.unitNumber}',
                              item.unpaidMonths.toString(),
                              '${_money(item.totalUnpaid)} ج.م',
                            ],
                          )
                          .toList(),
                      headerStyle: const pw.TextStyle(),
                      headerAlignment: pw.Alignment.centerRight,
                      cellAlignment: pw.Alignment.centerRight,
                      cellAlignments: {
                        0: pw.Alignment.centerRight,
                        1: pw.Alignment.centerRight,
                        2: pw.Alignment.centerRight,
                        3: pw.Alignment.centerRight,
                      },
                      cellPadding: const pw.EdgeInsets.all(8),
                    ),
                ],
              ),
            ),
          ],
        ),
      );

      final bytes = await doc.save();
      await FileSaver.instance.saveFile(
        name: 'تقرير_المتابعة_$stamp',
        bytes: bytes,
        fileExtension: 'pdf',
        mimeType: MimeType.pdf,
      );

      if (!mounted) return;
      _showResult(
        context,
        true,
        'تم إنشاء تقرير PDF بنجاح',
        'تعذر إنشاء تقرير PDF',
      );
    } catch (e) {
      if (!mounted) return;
      _showResult(
        context,
        false,
        'تم إنشاء تقرير PDF بنجاح',
        'تعذر إنشاء تقرير PDF: $e',
      );
    }
  }

  Future<void> _exportFollowUpReportWord({
    required List<ContractOverview> expiringContracts,
    required List<TenantArrearsOverview> arrears,
  }) async {
    final stamp = _reportStamp();

    try {
      final html = StringBuffer()
        ..writeln('<!DOCTYPE html>')
        ..writeln('<html lang="ar" dir="rtl">')
        ..writeln('<head><meta charset="utf-8">')
        ..writeln(
          '<meta http-equiv="Content-Type" content="text/html; charset=utf-8">',
        )
        ..writeln('<style>')
        ..writeln(
          'body { font-family: "Tahoma", "Segoe UI", Arial, sans-serif; direction: rtl; unicode-bidi: embed; text-align: right; margin: 40px; }',
        )
        ..writeln(
          'h2 { color: #2c3e50; border-bottom: 2px solid #3498db; padding-bottom: 10px; }',
        )
        ..writeln('h3 { color: #34495e; margin-top: 20px; }')
        ..writeln(
          'table { border-collapse: collapse; width: 100%; margin: 15px 0; }',
        )
        ..writeln(
          'th { background-color: #3498db; color: white; padding: 10px; text-align: right; }',
        )
        ..writeln('td { border: 1px solid #ddd; padding: 8px; }')
        ..writeln('tr:nth-child(even) { background-color: #f2f2f2; }')
        ..writeln('</style>')
        ..writeln('</head><body>')
        ..writeln('<h2>تقرير متابعة العقارات</h2>')
        ..writeln('<p>تاريخ الإصدار: ${_formatDateTime(DateTime.now())}</p>')
        ..writeln(
          '<h3>العقود المنتهية قريبًا (${expiringContracts.length})</h3>',
        );

      if (expiringContracts.isEmpty) {
        html.writeln('<p>لا توجد عقود تنتهي قريبًا.</p>');
      } else {
        html
          ..writeln('<table>')
          ..writeln(
            '<tr><th>المستأجر</th><th>العمارة/الشقة</th><th>تاريخ الانتهاء</th></tr>',
          );

        for (final item in expiringContracts) {
          html.writeln(
            '<tr><td>${_escapeHtml(item.tenant.fullName)}</td><td>${_escapeHtml(item.building.name)} / ${_escapeHtml(item.unit.unitNumber)}</td><td>${_formatDate(item.contract.endDate)}</td></tr>',
          );
        }
        html.writeln('</table>');
      }

      html.writeln('<h3>المستأجرون المتأخرون (${arrears.length})</h3>');

      if (arrears.isEmpty) {
        html.writeln('<p>لا توجد متأخرات حالياً.</p>');
      } else {
        html
          ..writeln('<table>')
          ..writeln(
            '<tr><th>المستأجر</th><th>العمارة/الشقة</th><th>عدد الشهور</th><th>إجمالي المتأخرات</th></tr>',
          );

        for (final item in arrears) {
          html.writeln(
            '<tr><td>${_escapeHtml(item.tenant.fullName)}</td><td>${_escapeHtml(item.building.name)} / ${_escapeHtml(item.unit.unitNumber)}</td><td>${item.unpaidMonths}</td><td>${_money(item.totalUnpaid)} ج.م</td></tr>',
          );
        }
        html.writeln('</table>');
      }

      html.writeln('</body></html>');

      final wordBytes = Uint8List.fromList([
        0xEF,
        0xBB,
        0xBF,
        ...utf8.encode(html.toString()),
      ]);

      await FileSaver.instance.saveFile(
        name: 'تقرير_المتابعة_$stamp',
        bytes: wordBytes,
        fileExtension: 'doc',
        mimeType: MimeType.custom,
        customMimeType: 'application/msword',
      );

      if (!mounted) return;
      _showResult(
        context,
        true,
        'تم إنشاء تقرير Word بنجاح',
        'تعذر إنشاء تقرير Word',
      );
    } catch (e) {
      if (!mounted) return;
      _showResult(
        context,
        false,
        'تم إنشاء تقرير Word بنجاح',
        'تعذر إنشاء تقرير Word: $e',
      );
    }
  }

  String _reportStamp() {
    final now = DateTime.now();
    return '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';
  }

  String _formatDateTime(DateTime dateTime) {
    final d = dateTime.day.toString().padLeft(2, '0');
    final m = dateTime.month.toString().padLeft(2, '0');
    final h = dateTime.hour.toString().padLeft(2, '0');
    final min = dateTime.minute.toString().padLeft(2, '0');
    return '$d/$m/${dateTime.year} $h:$min';
  }

  String _escapeHtml(String value) {
    return value
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#39;');
  }
}

// New custom widgets for the enhanced design
class _StatItem {
  final String title;
  final int value;
  final IconData icon;
  final Color color;
  final String? trend;
  final String? suffix;
  final VoidCallback? onTap;

  const _StatItem({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.trend,
    this.suffix,
    this.onTap,
  });
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color tone;
  final String? trend;
  final VoidCallback? onTapCard;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.tone,
    this.trend,
    this.onTapCard,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTapCard,
      child: _GlassPanel(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: tone.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: tone, size: 20),
                ),
                const Spacer(),
                if (trend != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: tone.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      trend!,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: tone,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionChip extends StatelessWidget {
  final String label;
  final String description;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _SectionChip({
    required this.label,
    required this.description,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: selected
                ? _DashboardPalette.primary.withValues(alpha: 0.1)
                : Colors.transparent,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: selected
                    ? _DashboardPalette.primary
                    : Colors.grey.shade500,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: selected
                      ? _DashboardPalette.primary
                      : Colors.grey.shade700,
                ),
              ),
              Text(
                description,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const _GlassPanel({required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final panelBody = Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: dark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.white.withValues(alpha: 0.85),
        border: Border.all(
          color: dark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.white.withValues(alpha: 0.9),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: dark ? 0.2 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );

    if (kIsWeb) {
      return panelBody;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: panelBody,
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color color;
  final String message;
  final VoidCallback? onTap;

  const _AlertCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
    required this.message,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: _GlassPanel(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    count.toString(),
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String time;
  final Color color;

  const _ActivityTile({
    required this.icon,
    required this.title,
    required this.description,
    required this.time,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                Text(description, style: GoogleFonts.poppins(fontSize: 11)),
              ],
            ),
          ),
          Text(
            time,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ContractTile extends StatelessWidget {
  final String tenant;
  final String unit;
  final String landlord;
  final String period;
  final String status;
  final VoidCallback? onTap;

  const _ContractTile({
    required this.tenant,
    required this.unit,
    required this.landlord,
    required this.period,
    required this.status,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    switch (status) {
      case 'ينتهي قريبًا':
        statusColor = const Color(0xFFA66A42);
        break;
      case 'منتهي':
        statusColor = const Color(0xFF9B5D4A);
        break;
      default:
        statusColor = const Color(0xFF8C6A44);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  tenant,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(unit, style: GoogleFonts.poppins(fontSize: 12)),
          const SizedBox(height: 4),
          Text(
            'المالك: $landlord',
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(period, style: GoogleFonts.poppins(fontSize: 11)),
          const SizedBox(height: 8),
          if (onTap != null)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: onTap,
                child: const Text('تجديد العقد'),
              ),
            ),
        ],
      ),
    );
  }
}

class _CompactTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String date;
  final Color dateColor;
  final VoidCallback? onTap;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _CompactTile({
    required this.title,
    required this.subtitle,
    required this.date,
    required this.dateColor,
    this.onTap,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Theme.of(
            context,
          ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  Text(subtitle, style: GoogleFonts.poppins(fontSize: 11)),
                ],
              ),
            ),
            Text(
              date,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: dateColor,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(width: 8),
              FilledButton.tonal(
                onPressed: onAction,
                style: FilledButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                ),
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ArrearsTile extends StatelessWidget {
  final String tenant;
  final String unit;
  final int months;
  final double amount;
  final VoidCallback onPay;

  const _ArrearsTile({
    required this.tenant,
    required this.unit,
    required this.months,
    required this.amount,
    required this.onPay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  tenant,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF9B5D4A).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$months شهر',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF9B5D4A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(unit, style: GoogleFonts.poppins(fontSize: 12)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  'المتأخرات: ${_money(amount)} ج.م',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF9B5D4A),
                  ),
                ),
              ),
              FilledButton.tonal(
                onPressed: onPay,
                child: const Text('تسجيل سداد'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _money(double value) {
    final text = value.toStringAsFixed(0);
    return text.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );
  }
}

class _UpcomingPaymentTile extends StatelessWidget {
  final String tenant;
  final String unit;
  final double amount;
  final DateTime dueDate;

  const _UpcomingPaymentTile({
    required this.tenant,
    required this.unit,
    required this.amount,
    required this.dueDate,
  });

  @override
  Widget build(BuildContext context) {
    final daysLeft = dueDate.difference(DateTime.now()).inDays;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tenant,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                Text(unit, style: GoogleFonts.poppins(fontSize: 12)),
                Text(
                  '${_money(amount)} ج.م',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: daysLeft <= 3
                      ? const Color(0xFFA66A42).withValues(alpha: 0.15)
                      : const Color(0xFF8C6A44).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'باقي $daysLeft يوم',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: daysLeft <= 3
                        ? const Color(0xFFA66A42)
                        : const Color(0xFF8C6A44),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatDate(dueDate),
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _money(double value) {
    final text = value.toStringAsFixed(0);
    return text.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );
  }
}

class _QuickFinanceCard extends StatelessWidget {
  final String title;
  final double amount;
  final Color color;

  const _QuickFinanceCard({
    required this.title,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: color.withValues(alpha: 0.1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: GoogleFonts.poppins(fontSize: 13)),
          ),
          Text(
            '${_money(amount)} ج.م',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _money(double value) {
    final text = value.toStringAsFixed(0);
    return text.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );
  }
}

class _FinanceSummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _FinanceSummaryRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade600),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _BuildingCard extends StatelessWidget {
  final Building building;
  final int occupiedCount;
  final int vacantCount;
  final List<UnitOccupancyOverview> units;

  const _BuildingCard({
    required this.building,
    required this.occupiedCount,
    required this.vacantCount,
    required this.units,
  });

  @override
  Widget build(BuildContext context) {
    final occupancyRate = (occupiedCount / (occupiedCount + vacantCount)) * 100;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            _DashboardPalette.primary.withValues(alpha: 0.05),
            Colors.white.withValues(alpha: 0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: _DashboardPalette.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.apartment_rounded,
                  color: _DashboardPalette.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  building.name,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            building.area,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _BuildingStat(
                  label: 'مؤجر',
                  value: occupiedCount.toString(),
                  color: const Color(0xFF8C6A44),
                ),
              ),
              Expanded(
                child: _BuildingStat(
                  label: 'فارغ',
                  value: vacantCount.toString(),
                  color: const Color(0xFFC3925E),
                ),
              ),
              Expanded(
                child: _BuildingStat(
                  label: 'الإشغال',
                  value: '${occupancyRate.toInt()}%',
                  color: _DashboardPalette.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'الشقق:',
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 4),
          if (units.isNotEmpty)
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: units.map((unit) {
                final unitColor = unit.isOccupied
                    ? const Color(0xFF8C6A44)
                    : const Color(0xFFC3925E);

                return InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => _showUnitDetailsDialog(context, unit),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: unitColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'شقة ${unit.unit.unitNumber} • ${unit.isOccupied ? 'مؤجرة' : 'فارغة'}',
                      style: GoogleFonts.poppins(fontSize: 9, color: unitColor),
                    ),
                  ),
                );
              }).toList(),
            )
          else
            Text(
              'لا توجد شقق',
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: Colors.grey.shade500,
              ),
            ),
        ],
      ),
    );
  }

  void _showUnitDetailsDialog(
    BuildContext context,
    UnitOccupancyOverview unitOverview,
  ) {
    final unit = unitOverview.unit;
    final isOccupied = unitOverview.isOccupied;

    String statusLabel;
    switch (unit.status) {
      case UnitStatus.occupied:
        statusLabel = 'مؤجرة';
        break;
      case UnitStatus.maintenance:
        statusLabel = 'صيانة';
        break;
      case UnitStatus.vacant:
        statusLabel = 'فارغة';
        break;
    }

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'بيانات الشقة ${unit.unitNumber}',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        content: SizedBox(
          width: 560,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _detailRow('العمارة', building.name),
                const SizedBox(height: 10),
                _detailRow('المنطقة', building.area),
                const SizedBox(height: 10),
                _detailRow('الدور', unit.floorNumber.toString()),
                const SizedBox(height: 10),
                _detailRow('عدد الغرف', unit.bedrooms.toString()),
                const SizedBox(height: 10),
                _detailRow('عدد الحمامات', unit.bathrooms.toString()),
                const SizedBox(height: 10),
                _detailRow('المساحة', '${unit.areaSqm.toStringAsFixed(0)} م²'),
                const SizedBox(height: 10),
                _detailRow(
                  'الإيجار الشهري',
                  '${unit.monthlyRent.toStringAsFixed(0)} ج.م',
                ),
                const SizedBox(height: 10),
                _detailRow('الحالة', statusLabel),
                const SizedBox(height: 10),
                _detailRow(
                  'المستأجر',
                  isOccupied
                      ? (unitOverview.currentTenant?.fullName ?? 'غير متاح')
                      : 'غير مؤجرة',
                ),
                const SizedBox(height: 10),
                _detailRow(
                  'المالك',
                  unitOverview.landlord?.fullName ?? 'غير متاح',
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: _DashboardPalette.primary.withValues(alpha: 0.06),
        border: Border.all(
          color: _DashboardPalette.primary.withValues(alpha: 0.18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: _DashboardPalette.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _BuildingStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _BuildingStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: color,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}

class _AmbientBackground extends StatelessWidget {
  const _AmbientBackground();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned.fill(child: _IslamicPatternLayer(isDark: isDark)),
          Positioned(
            top: -150,
            left: -100,
            child: _BlurBall(
              size: 350,
              color: isDark ? const Color(0xFF5E4530) : const Color(0xFFD8C1A4),
            ),
          ),
          Positioned(
            top: 200,
            right: -120,
            child: _BlurBall(
              size: 300,
              color: isDark ? const Color(0xFF6A4B33) : const Color(0xFFE1CDB3),
            ),
          ),
          Positioned(
            bottom: -150,
            left: 120,
            child: _BlurBall(
              size: 320,
              color: isDark ? const Color(0xFF7A5A3D) : const Color(0xFFE6D8C5),
            ),
          ),
        ],
      ),
    );
  }
}

class _IslamicPatternLayer extends StatelessWidget {
  final bool isDark;

  const _IslamicPatternLayer({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _IslamicPatternPainter(isDark: isDark),
      size: Size.infinite,
    );
  }
}

class _IslamicPatternPainter extends CustomPainter {
  final bool isDark;

  const _IslamicPatternPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final starPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.15
      ..color = (isDark ? const Color(0xFFB58E64) : const Color(0xFFA67D56))
          .withValues(alpha: isDark ? 0.12 : 0.2);

    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9
      ..color = (isDark ? const Color(0xFFCFB28F) : const Color(0xFFB99466))
          .withValues(alpha: isDark ? 0.1 : 0.16);

    final dotPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = (isDark ? const Color(0xFFD8BE9D) : const Color(0xFF9E734D))
          .withValues(alpha: isDark ? 0.12 : 0.2);

    final spacing = size.width < 700 ? 120.0 : 155.0;

    for (double y = 48; y < size.height + spacing; y += spacing) {
      final rowOffset = ((y / spacing).floor().isEven) ? 0.0 : spacing / 2;
      for (double x = 32 + rowOffset; x < size.width + spacing; x += spacing) {
        final center = Offset(x, y);
        _drawEightPointStar(canvas, center, 22, 10, starPaint);
        canvas.drawCircle(center, 30, ringPaint);
        canvas.drawCircle(center, 2.2, dotPaint);
      }
    }
  }

  void _drawEightPointStar(
    Canvas canvas,
    Offset center,
    double outerRadius,
    double innerRadius,
    Paint paint,
  ) {
    final path = Path();
    for (int i = 0; i < 16; i++) {
      final angle = -math.pi / 2 + (i * math.pi / 8);
      final radius = i.isEven ? outerRadius : innerRadius;
      final point = Offset(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius,
      );

      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _IslamicPatternPainter oldDelegate) {
    return oldDelegate.isDark != isDark;
  }
}

class _BlurBall extends StatelessWidget {
  final double size;
  final Color color;

  const _BlurBall({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.12),
        ),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.15),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  final String text;

  const _Empty({required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(Icons.inbox_rounded, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 8),
            Text(
              text,
              style: GoogleFonts.poppins(
                color: Colors.grey.shade500,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
