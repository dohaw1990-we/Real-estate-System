import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../services/firebase_service.dart';
import '../models/property.dart';
import '../widgets/app_islamic_background.dart';

class AddPropertyPage extends StatefulWidget {
  const AddPropertyPage({super.key});

  @override
  State<AddPropertyPage> createState() => _AddPropertyPageState();
}

class _AddPropertyPageState extends State<AddPropertyPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _phoneController = TextEditingController();
  final _priceController = TextEditingController();
  PropertyType _type = PropertyType.apartment;
  List<XFile> _images = [];
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Property'),
        surfaceTintColor: Colors.transparent,
        flexibleSpace: const AppBarIslamicOrnament(),
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: AppIslamicBackground()),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<PropertyType>(
                value: _type,
                decoration: const InputDecoration(
                  labelText: 'Type',
                  border: OutlineInputBorder(),
                ),
                items: PropertyType.values
                    .map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Text(
                          type.toString().split('.').last.toUpperCase(),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _type = value!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Price',
                  border: OutlineInputBorder(),
                  prefixText: '\$ ',
                ),
                validator: (value) => double.tryParse(value ?? '') == null
                    ? 'Enter valid price'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Contact Phone',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _pickImages,
                icon: const Icon(Icons.photo_camera),
                label: Text('Pick Images (${_images.length})'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
              const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _submitProperty,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                        : const Icon(Icons.add),
                    label: Text(_isLoading ? 'Adding...' : 'Add Property'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImages() async {
    final picked = await Provider.of<FirebaseService>(
      context,
      listen: false,
    ).pickImages();
    if (picked != null) {
      setState(() => _images = picked);
    }
  }

  Future<void> _submitProperty() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final price = double.parse(_priceController.text);

    final property = Property(
      id: '',
      title: _titleController.text,
      price: price,
      location: _locationController.text,
      type: _type,
      description: _descriptionController.text,
      contactPhone: _phoneController.text,
      images: [],
    );

    await Provider.of<FirebaseService>(
      context,
      listen: false,
    ).addProperty(property, _images);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Property added successfully!')),
      );
      Navigator.pop(context);
    }

    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _phoneController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}
