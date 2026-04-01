import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class HeroSection extends StatefulWidget {
  final Function(String, String?, double?) onSearch;

  const HeroSection({required this.onSearch, super.key});

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final _locationController = TextEditingController();
  String? _selectedType;
  double _selectedPrice = 1000000;

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

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _handleSearch() {
    widget.onSearch(_locationController.text, _selectedType, _selectedPrice);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 600,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(
            'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=1200&h=600&fit=crop',
          ),
          fit: BoxFit.cover,
          onError: (e, st) => null,
        ),
      ),
      child: Stack(
        children: [
          // Dark Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.5),
                ],
              ),
            ),
          ),

          // Content
          FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 24,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Headline
                    Text(
                      'Find Your Dream Home',
                      style: GoogleFonts.poppins(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 16),

                    // Subheading
                    Text(
                      'Discover the perfect property from our extensive collection',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w300,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 28),

                    // Search Card
                    Transform.translate(
                      offset: const Offset(0, -20),
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 800),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.black.withOpacity(0.4)
                              : Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              // First Row: Location and Type
                              Row(
                                children: [
                                  // Location Field
                                  Expanded(
                                    child: TextField(
                                      controller: _locationController,
                                      decoration: InputDecoration(
                                        hintText: 'Enter Location',
                                        hintStyle: TextStyle(
                                          color: isDark
                                              ? Colors.grey[400]
                                              : Colors.grey[600],
                                        ),
                                        prefixIcon: Icon(
                                          Icons.location_on_outlined,
                                          color: AppColors.primary,
                                        ),
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 1,
                                    height: 30,
                                    color: Colors.grey.withOpacity(0.3),
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                  ),
                                  // Type Dropdown
                                  Expanded(
                                    child: DropdownButton<String>(
                                      value: _selectedType,
                                      isExpanded: true,
                                      underline: const SizedBox(),
                                      hint: Text(
                                        'Property Type',
                                        style: TextStyle(
                                          color: isDark
                                              ? Colors.grey[400]
                                              : Colors.grey[600],
                                        ),
                                      ),
                                      items:
                                          [
                                                'Apartment',
                                                'Villa',
                                                'House',
                                                'Office',
                                              ]
                                              .map(
                                                (type) => DropdownMenuItem(
                                                  value: type,
                                                  child: Text(
                                                    type,
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                      onChanged: (value) {
                                        setState(() => _selectedType = value);
                                      },
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 20),

                              // Price Range and Search Button
                              Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Max Price: \$${(_selectedPrice / 1000).toStringAsFixed(0)}K',
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Slider(
                                          value: _selectedPrice,
                                          min: 0,
                                          max: 2000000,
                                          activeColor: AppColors.primary,
                                          inactiveColor: Colors.grey[300],
                                          onChanged: (value) {
                                            setState(() {
                                              _selectedPrice = value;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // Search Button
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: AppColors.primaryGradient,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primary.withOpacity(
                                            0.3,
                                          ),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: _handleSearch,
                                        borderRadius: BorderRadius.circular(12),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 24,
                                            vertical: 16,
                                          ),
                                          child: Icon(
                                            Icons.search,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
