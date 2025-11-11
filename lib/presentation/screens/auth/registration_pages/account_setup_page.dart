import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/registration_provider.dart';
import '../../../widgets/registration/registration_step_indicator.dart';
import '../../../../core/models/psgc_models.dart';
import '../../../widgets/common/address_selector.dart';

class AccountSetupPage extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const AccountSetupPage({
    super.key,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<AccountSetupPage> createState() => _AccountSetupPageState();
}

class _AccountSetupPageState extends State<AccountSetupPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _streetAddressController = TextEditingController();
  
  // Address selections
  Region? _selectedRegion;
  Province? _selectedProvince;
  City? _selectedCity;
  Barangay? _selectedBarangay;

  @override
  void initState() {
    super.initState();
    // Load existing data from provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<RegistrationProvider>();
      _usernameController.text = provider.username;
      _streetAddressController.text = provider.streetAddress;
      setState(() {});
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _streetAddressController.dispose();
    super.dispose();
  }

  String _getAvatarUrl(String username) {
    if (username.isEmpty) {
      return 'https://api.dicebear.com/9.x/bottts-neutral/svg?seed=default';
    }
    return 'https://api.dicebear.com/9.x/bottts-neutral/svg?seed=$username';
  }

  void _showAddressPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final streetController = TextEditingController(text: _streetAddressController.text);
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Select Address',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2D5F4C),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    AddressSelector(
                      selectedRegion: _selectedRegion,
                      selectedProvince: _selectedProvince,
                      selectedCity: _selectedCity,
                      selectedBarangay: _selectedBarangay,
                      onRegionChanged: (region) {
                        setModalState(() {
                          _selectedRegion = region;
                          _selectedProvince = null;
                          _selectedCity = null;
                          _selectedBarangay = null;
                        });
                      },
                      onProvinceChanged: (province) {
                        setModalState(() {
                          _selectedProvince = province;
                          _selectedCity = null;
                          _selectedBarangay = null;
                        });
                      },
                      onCityChanged: (city) {
                        setModalState(() {
                          _selectedCity = city;
                          _selectedBarangay = null;
                        });
                      },
                      onBarangayChanged: (barangay) {
                        setModalState(() {
                          _selectedBarangay = barangay;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _selectedRegion != null
                            ? () {
                                final provider = context.read<RegistrationProvider>();
                                // For NCR, use region name as province
                                final provinceName = _selectedProvince?.name ?? _selectedRegion!.name;
                                provider.setProvince(provinceName);
                                provider.setCity(_selectedCity?.name ?? '');
                                provider.setBarangay(_selectedBarangay?.name ?? '');
                                setState(() {});
                                Navigator.pop(context);
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2D5F4C),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Confirm Address',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _handleNext() {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<RegistrationProvider>();
    provider.setUsername(_usernameController.text.trim());
    provider.setStreetAddress(_streetAddressController.text.trim());

    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              // Step Indicator
              const RegistrationStepIndicatorWithLabels(
                currentStep: 2,
                stepLabels: ['Email', 'Profile', 'Account', 'Password', 'Review'],
              ),

              const SizedBox(height: 32),

              // Title
              Text(
                'Create New Account',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2D5F4C),
                    ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              Text(
                'Fill in your details to register your account',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // // Auto-generated Avatar Preview
              // Center(
              //   child: Column(
              //     children: [
              //       Container(
              //         width: 100,
              //         height: 100,
              //         decoration: BoxDecoration(
              //           shape: BoxShape.circle,
              //           color: Colors.grey.shade200,
              //           border: Border.all(
              //             color: const Color(0xFF2D5F4C),
              //             width: 2,
              //           ),
              //         ),
              //         child: ClipOval(
              //           child: Image.network(
              //             _getAvatarUrl(_usernameController.text),
              //             width: 100,
              //             height: 100,
              //             fit: BoxFit.cover,
              //             loadingBuilder: (context, child, loadingProgress) {
              //               if (loadingProgress == null) return child;
              //               return Center(
              //                 child: CircularProgressIndicator(
              //                   value: loadingProgress.expectedTotalBytes != null
              //                       ? loadingProgress.cumulativeBytesLoaded /
              //                           loadingProgress.expectedTotalBytes!
              //                       : null,
              //                   strokeWidth: 2,
              //                   valueColor: const AlwaysStoppedAnimation<Color>(
              //                     Color(0xFF2D5F4C),
              //                   ),
              //                 ),
              //               );
              //             },
              //             errorBuilder: (context, error, stackTrace) {
              //               return Icon(
              //                 Icons.person,
              //                 size: 50,
              //                 color: Colors.grey.shade600,
              //               );
              //             },
              //           ),
              //         ),
              //       ),
              //     ],
              //   ),
              // ),

              // const SizedBox(height: 32),

              // Username
              Text(
                'Username',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade800,
                    ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _usernameController,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  hintText: 'Enter username',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF2D5F4C), width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                onChanged: (value) {
                  // Update avatar preview when username changes
                  setState(() {});
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Username is required';
                  }
                  if (value.length < 3) {
                    return 'Username must be at least 3 characters';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Address
              Text(
                'Address',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade800,
                    ),
              ),
              const SizedBox(height: 8),

              // Region, Province, City, Barangay Selector
              Consumer<RegistrationProvider>(
                builder: (context, provider, child) {
                  final hasRegion = provider.province.isNotEmpty;
                  String addressText = 'Select Region, Province, City, Barangay';
                  
                  if (hasRegion) {
                    addressText = provider.province;
                    if (provider.city.isNotEmpty) {
                      addressText = '${provider.city}, $addressText';
                    }
                    if (provider.barangay.isNotEmpty) {
                      addressText += ', ${provider.barangay}';
                    }
                  }
                  
                  return GestureDetector(
                    onTap: _showAddressPicker,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              addressText,
                              style: TextStyle(
                                color: hasRegion ? Colors.black87 : Colors.grey.shade400,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Icon(Icons.chevron_right, color: Colors.grey.shade600),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              // Street Address
              TextFormField(
                controller: _streetAddressController,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  hintText: 'Street Name, Building, House No.',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF2D5F4C), width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Street address is required';
                  }
                  return null;
                },
              ),

              SizedBox(height: MediaQuery.of(context).size.height * 0.1),

              // Navigation Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: widget.onBack,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 56),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Colors.white,
                      ),
                      child: const Text(
                        'Back',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _handleNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2D5F4C),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(0, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Next',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
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
    );
  }
}
