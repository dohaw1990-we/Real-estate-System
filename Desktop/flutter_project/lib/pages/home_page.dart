import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/firebase_service.dart';
import '../models/property.dart';
import '../data/dummy_properties.dart';
import '../widgets/hero_section.dart';
import '../widgets/featured_properties_section.dart';
import '../widgets/app_islamic_background.dart';
import 'rental_admin_dashboard_page.dart';
import 'favorites_page.dart';
import 'add_property_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Property> _allProperties = [];
  List<Property> _filteredProperties = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProperties();
  }

  Future<void> _loadProperties() async {
    try {
      final service = Provider.of<FirebaseService>(context, listen: false);
      service.getPropertiesStream().listen((properties) {
        setState(() {
          // Combine Firebase properties with dummy data
          _allProperties = [
            ...DummyPropertyData.getSampleProperties(),
            ...properties,
          ];
          _filteredProperties = _allProperties;
          _isLoading = false;
        });
      });
    } catch (e) {
      // Fallback to dummy data if Firebase unavailable
      setState(() {
        _allProperties = DummyPropertyData.getSampleProperties();
        _filteredProperties = _allProperties;
        _isLoading = false;
      });
    }
  }

  void _handleSearch(String location, String? type, double? maxPrice) {
    setState(() {
      _filteredProperties = _allProperties.where((property) {
        final matchesLocation =
            location.isEmpty ||
            property.location.toLowerCase().contains(location.toLowerCase()) ||
            property.title.toLowerCase().contains(location.toLowerCase());

        final matchesType =
            type == null ||
            property.type.toString().split('.').last == type.toLowerCase();

        final matchesPrice = maxPrice == null || property.price <= maxPrice;

        return matchesLocation && matchesType && matchesPrice;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDark ? Colors.black : Colors.white,
        surfaceTintColor: Colors.transparent,
        flexibleSpace: const AppBarIslamicOrnament(),
        title: Text(
          'Premium Real Estate',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'لوحة إدارة المكتب',
            icon: const Icon(Icons.dashboard_customize_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const RentalAdminDashboardPage(),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.favorite_outline),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FavoritesPage()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddPropertyPage()),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: AppIslamicBackground()),
          SingleChildScrollView(
            child: Column(
              children: [
                // Hero Section
                HeroSection(onSearch: _handleSearch),

                // Featured Properties Section
                if (!_isLoading)
                  FeaturedPropertiesSection(properties: _filteredProperties),

                if (_isLoading)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 60),
                    child: const CircularProgressIndicator(),
                  ),

                // Footer Section
                Container(
                  color: isDark ? Colors.grey[900] : Colors.grey[100],
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 40,
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _FooterColumn(
                            title: 'About',
                            items: ['About Us', 'Blog', 'Careers'],
                            isDark: isDark,
                          ),
                          _FooterColumn(
                            title: 'Properties',
                            items: ['Buy', 'Rent', 'Sell'],
                            isDark: isDark,
                          ),
                          _FooterColumn(
                            title: 'Support',
                            items: ['Help Center', 'Contact', 'FAQ'],
                            isDark: isDark,
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      Divider(
                        color: isDark ? Colors.grey[800] : Colors.grey[300],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '© 2026 Premium Real Estate. All rights reserved.',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class _FooterColumn extends StatelessWidget {
  final String title;
  final List<String> items;
  final bool isDark;

  const _FooterColumn({
    required this.title,
    required this.items,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        ...items
            .map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(
                  item,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ),
            )
            .toList(),
      ],
    );
  }
}
