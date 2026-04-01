import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firebase_service.dart';
import '../models/property.dart';
import '../widgets/app_islamic_background.dart';
import '../widgets/property_card.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        surfaceTintColor: Colors.transparent,
        flexibleSpace: const AppBarIslamicOrnament(),
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: AppIslamicBackground()),
          Consumer<FirebaseService>(
            builder: (context, service, child) {
              return StreamBuilder<List<Property>>(
                stream: service.getFavoritesStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final favorites = snapshot.data ?? [];
                  if (favorites.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.favorite_border,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No favorites yet',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: favorites.length,
                    itemBuilder: (context, index) {
                      final property = favorites[index];
                      return PropertyCard(property: property);
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
