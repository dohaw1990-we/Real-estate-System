import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/property.dart';
import '../theme/app_theme.dart';
import 'modern_property_card.dart';

class FeaturedPropertiesSection extends StatefulWidget {
  final List<Property> properties;

  const FeaturedPropertiesSection({
    required this.properties,
    super.key,
  });

  @override
  State<FeaturedPropertiesSection> createState() =>
      _FeaturedPropertiesSectionState();
}

class _FeaturedPropertiesSectionState extends State<FeaturedPropertiesSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late List<Animation<double>> _itemAnimations;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _itemAnimations = List.generate(
      (widget.properties.length > 6 ? 6 : widget.properties.length),
      (index) => Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            index * 0.1,
            0.5 + (index * 0.1),
            curve: Curves.easeOutCubic,
          ),
        ),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive grid columns
    int crossAxisCount = 3;
    if (screenWidth < 1200) crossAxisCount = 2;
    if (screenWidth < 768) crossAxisCount = 1;

    final displayProperties =
        widget.properties.length > 6 ? widget.properties.sublist(0, 6) : widget.properties;

    return Container(
      color: isDark ? Colors.black : Colors.grey[50],
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Featured Properties',
                style: GoogleFonts.poppins(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 60,
                height: 4,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Discover our handpicked selection of premium properties',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),

          const SizedBox(height: 40),

          // Grid Layout
          displayProperties.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40.0),
                    child: Text(
                      'No properties available',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ),
                )
              : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 24,
                    mainAxisSpacing: 24,
                  ),
                  itemCount: displayProperties.length,
                  itemBuilder: (context, index) {
                    return AnimatedBuilder(
                      animation: _itemAnimations[index],
                      builder: (context, child) {
                        return Opacity(
                          opacity: _itemAnimations[index].value,
                          child: Transform.translate(
                            offset: Offset(
                              0,
                              (1 - _itemAnimations[index].value) * 30,
                            ),
                            child: ModernPropertyCard(
                              property: displayProperties[index],
                              onViewDetails: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'View details for ${displayProperties[index].title}',
                                    ),
                                  ),
                                );
                              },
                              onToggleFavorite: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Added ${displayProperties[index].title} to favorites',
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),

          const SizedBox(height: 40),

          // View All Button
          Center(
            child: Container(
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('View All Properties'),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 14,
                    ),
                    child: Text(
                      'View All Properties',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
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
