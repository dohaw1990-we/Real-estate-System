import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/property.dart';
import '../theme/app_theme.dart';

class ModernPropertyCard extends StatefulWidget {
  final Property property;
  final VoidCallback? onViewDetails;
  final VoidCallback? onToggleFavorite;

  const ModernPropertyCard({
    required this.property,
    this.onViewDetails,
    this.onToggleFavorite,
    super.key,
  });

  @override
  State<ModernPropertyCard> createState() => _ModernPropertyCardState();
}

class _ModernPropertyCardState extends State<ModernPropertyCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _hoverAnimation;
  bool _isFavorited = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _hoverAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) => _hoverController.forward(),
      onExit: (_) => _hoverController.reverse(),
      child: AnimatedBuilder(
        animation: _hoverAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: 1 + (_hoverAnimation.value * 0.03),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(
                      0.1 + (_hoverAnimation.value * 0.15),
                    ),
                    blurRadius: 20 + (_hoverAnimation.value * 20),
                    offset: Offset(0, 4 + (_hoverAnimation.value * 6)),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image with Overlay
                    Expanded(
                      child: Stack(
                        children: [
                          // Image
                          Container(
                            color: Colors.grey[300],
                            child: widget.property.images.isNotEmpty
                                ? Image.network(
                                    widget.property.images[0],
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey[300],
                                        child: Icon(
                                          Icons.image_not_supported,
                                          color: Colors.grey[600],
                                        ),
                                      );
                                    },
                                  )
                                : Container(
                                    color: Colors.grey[300],
                                    child: Icon(
                                      Icons.image,
                                      color: Colors.grey[600],
                                      size: 48,
                                    ),
                                  ),
                          ),

                          // Dark Overlay on Hover
                          Container(
                            color: Colors.black.withOpacity(
                              0.1 + (_hoverAnimation.value * 0.25),
                            ),
                          ),

                          // Favorite Button
                          Positioned(
                            top: 12,
                            right: 12,
                            child: GestureDetector(
                              onTap: () {
                                setState(() => _isFavorited = !_isFavorited);
                                widget.onToggleFavorite?.call();
                              },
                              child: AnimatedScale(
                                scale: _isFavorited ? 1.1 : 1.0,
                                duration: const Duration(milliseconds: 200),
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withOpacity(0.95),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.all(8),
                                  child: Icon(
                                    _isFavorited
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: _isFavorited
                                        ? Colors.red
                                        : Colors.grey[700],
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Price Badge
                          Positioned(
                            bottom: 12,
                            left: 12,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.3),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              child: Text(
                                '\$${(widget.property.price / 1000).toStringAsFixed(0)}K',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),

                          // View Details Button (appears on hover)
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Transform.translate(
                              offset: Offset(
                                0,
                                20 - (_hoverAnimation.value * 20),
                              ),
                              child: Opacity(
                                opacity: _hoverAnimation.value,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withOpacity(0.6),
                                      ],
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(12),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: widget.onViewDetails,
                                      child: Text(
                                        'View Details',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Property Info
                    Container(
                      color: isDark
                          ? Colors.grey[900]
                          : Colors.white,
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Text(
                            widget.property.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),

                          const SizedBox(height: 4),

                          // Location
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 14,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  widget.property.location,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: isDark
                                        ? Colors.grey[400]
                                        : Colors.grey[600],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          // Room Count (dummy)
                          Row(
                            children: [
                              Icon(
                                Icons.bed_outlined,
                                size: 14,
                                color: AppColors.secondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '3 Bedrooms',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: isDark
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Icon(
                                Icons.bathtub_outlined,
                                size: 14,
                                color: AppColors.secondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '2 Baths',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: isDark
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
