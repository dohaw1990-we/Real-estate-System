import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';

import '../theme/app_theme.dart';
import '../theme/theme_controller.dart';
import '../widgets/app_islamic_background.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: const AppBarIslamicOrnament(),
        title: FadeInDown(
          duration: const Duration(milliseconds: 600),
          child: Text(
            'Real Estate Office',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              foreground: Paint()
                ..shader = const LinearGradient(
                  colors: [Color(0xFF8B5E3C), Color(0xFF6F4A2F)],
                ).createShader(const Rect.fromLTWH(0, 0, 200, 50)),
            ),
          ),
        ),
        actions: [
          FadeInDown(
            duration: const Duration(milliseconds: 600),
            delay: const Duration(milliseconds: 100),
            child: IconButton(
              onPressed: () {
                context.read<ThemeController>().toggleTheme();
              },
              icon: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                color: isDark ? Colors.amber : const Color(0xFF7A5233),
              ),
              tooltip: 'Toggle Theme',
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: AppIslamicBackground()),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? const [
                        Color(0xFF1C140F),
                        Color(0xFF251A13),
                        Color(0xFF2E2017),
                      ]
                    : const [
                        Color(0xFFF4E9DB),
                        Color(0xFFF8EEE1),
                        Color(0xFFFFFBF5),
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1300),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FadeInUp(
                          duration: const Duration(milliseconds: 700),
                          from: 30,
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 400),
                              transform: Matrix4.identity(),
                              curve: Curves.easeOutCubic,
                              width: double.infinity,
                              padding: const EdgeInsets.all(28),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(32),
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFF6F4A2F),
                                    const Color(0xFF8B5E3C),
                                    const Color(0xFFB2875D),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.4,
                                    ),
                                    blurRadius: 30,
                                    offset: const Offset(0, 15),
                                    spreadRadius: -5,
                                  ),
                                ],
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'نظام إدارة مكتب العقارات',
                                          style: GoogleFonts.cairo(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 32,
                                            shadows: [
                                              Shadow(
                                                color: Colors.black.withValues(
                                                  alpha: 0.2,
                                                ),
                                                blurRadius: 10,
                                                offset: const Offset(2, 2),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  TweenAnimationBuilder(
                                    tween: Tween<double>(begin: 0, end: 1),
                                    duration: const Duration(milliseconds: 800),
                                    builder: (context, value, child) {
                                      return Transform.scale(
                                        scale: value,
                                        child: FilledButton.icon(
                                          onPressed: () {
                                            Navigator.pushNamed(
                                              context,
                                              '/dashboard',
                                            );
                                          },
                                          icon: const Icon(
                                            Icons.dashboard_customize_rounded,
                                          ),
                                          label: const Text('فتح الداشبورد'),
                                          style: FilledButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            foregroundColor: const Color(
                                              0xFF6F4A2F,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 24,
                                              vertical: 14,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(40),
                                            ),
                                            elevation: 0,
                                            textStyle: GoogleFonts.cairo(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final crossAxisCount =
                                  constraints.maxWidth >= 1100
                                  ? 3
                                  : constraints.maxWidth >= 700
                                  ? 2
                                  : 1;
                              return GridView.builder(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: crossAxisCount,
                                      childAspectRatio: 1.3,
                                      crossAxisSpacing: 20,
                                      mainAxisSpacing: 20,
                                    ),
                                itemCount: 3,
                                itemBuilder: (context, index) {
                                  final items = const [
                                    {
                                      'title': 'الداشبورد',
                                      'subtitle':
                                          'مؤشرات لحظية، تنبيهات، متابعة الإيجارات والعقود',
                                      'icon': Icons.insights_rounded,
                                      'color': Color(0xFF8B5E3C),
                                      'route': '/dashboard',
                                    },
                                    {
                                      'title': 'إدارة العمارات',
                                      'subtitle':
                                          'إضافة عمارة جديدة ومراجعة بيانات كل عمارة',
                                      'icon': Icons.location_city_rounded,
                                      'color': Color(0xFF8C6A44),
                                      'route': '/buildings',
                                    },
                                    {
                                      'title': 'إدارة الشقق',
                                      'subtitle':
                                          'إضافة شقق للعمارات الموجودة ومتابعة حالتها',
                                      'icon': Icons.apartment_rounded,
                                      'color': Color(0xFFB2875D),
                                      'route': '/units',
                                    },
                                  ];
                                  return FadeInUp(
                                    duration: Duration(
                                      milliseconds: 500 + (index * 100),
                                    ),
                                    from: 40,
                                    child: _AnimatedNavCard(
                                      routeName:
                                          items[index]['route'] as String,
                                      title: items[index]['title'] as String,
                                      subtitle:
                                          items[index]['subtitle'] as String,
                                      icon: items[index]['icon'] as IconData,
                                      tone: items[index]['color'] as Color,
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== _AnimatedNavCard Widget ====================
class _AnimatedNavCard extends StatefulWidget {
  final String routeName;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color tone;

  const _AnimatedNavCard({
    required this.routeName,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.tone,
  });

  @override
  State<_AnimatedNavCard> createState() => _AnimatedNavCardState();
}

class _AnimatedNavCardState extends State<_AnimatedNavCard>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _animationController.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _animationController.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Material(
              elevation: _isHovered ? 12 : 4,
              shadowColor: widget.tone.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(28),
              color: isDark
                  ? const Color(0xFF2A1E16).withValues(alpha: 0.9)
                  : Colors.white.withValues(alpha: 0.95),
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(context, widget.routeName);
                },
                borderRadius: BorderRadius.circular(28),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: _isHovered
                          ? widget.tone.withValues(alpha: 0.5)
                          : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              widget.tone.withValues(alpha: 0.2),
                              widget.tone.withValues(alpha: 0.1),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(widget.icon, size: 32, color: widget.tone),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        widget.title,
                        style: GoogleFonts.cairo(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF3B2A1F),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.subtitle,
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          height: 1.4,
                          color: isDark
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
