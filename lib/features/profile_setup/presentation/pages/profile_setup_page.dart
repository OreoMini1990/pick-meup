import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';
import '../../../../core/providers/profile_setup_provider.dart';
import '../widgets/photo_upload_step.dart';
import '../widgets/basics_step.dart';
import '../widgets/contact_step.dart';

class ProfileSetupPage extends ConsumerStatefulWidget {
  const ProfileSetupPage({super.key});

  @override
  ConsumerState<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends ConsumerState<ProfileSetupPage> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 3;

  final List<File> _photos = [];
  int? _age;
  String _job = '';
  String _regionCity = '';
  String _regionDistrict = '';
  String _bio = '';
  String _contactPhone = '';

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeProfile();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeProfile() async {
    try {
      await ref.read(profileSetupProvider.notifier).completeProfile(
        photos: _photos,
        age: _age!,
        job: _job,
        regionCity: _regionCity,
        regionDistrict: _regionDistrict,
        bio: _bio,
        contactPhone: _contactPhone,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile completed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/pick-you');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to complete profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Profile'),
        leading: _currentStep > 0
            ? IconButton(
                onPressed: _previousStep,
                icon: const Icon(Icons.arrow_back),
              )
            : null,
      ),
      body: Column(
        children: [
          // Progress Indicator
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: List.generate(_totalSteps, (index) {
                    return Expanded(
                      child: Container(
                        height: 4,
                        margin: EdgeInsets.only(
                          right: index < _totalSteps - 1 ? 8 : 0,
                        ),
                        decoration: BoxDecoration(
                          color: index <= _currentStep
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 8),
                Text(
                  'Step ${_currentStep + 1} of $_totalSteps',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          
          // Page Content
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentStep = index;
                });
              },
              children: [
                // Step 1: Photos
                PhotoUploadStep(
                  photos: _photos,
                  onPhotosChanged: (photos) {
                    setState(() {
                      _photos.clear();
                      _photos.addAll(photos);
                    });
                  },
                ),
                
                // Step 2: Basics
                BasicsStep(
                  age: _age,
                  job: _job,
                  regionCity: _regionCity,
                  regionDistrict: _regionDistrict,
                  bio: _bio,
                  onAgeChanged: (age) => setState(() => _age = age),
                  onJobChanged: (job) => setState(() => _job = job),
                  onRegionChanged: (city, district) {
                    setState(() {
                      _regionCity = city;
                      _regionDistrict = district;
                    });
                  },
                  onBioChanged: (bio) => setState(() => _bio = bio),
                ),
                
                // Step 3: Contact
                ContactStep(
                  contactPhone: _contactPhone,
                  onContactPhoneChanged: (phone) {
                    setState(() => _contactPhone = phone);
                  },
                ),
              ],
            ),
          ),
          
          // Navigation Buttons
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousStep,
                      child: const Text('Previous'),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _canProceed() ? _nextStep : null,
                    child: Text(_currentStep == _totalSteps - 1 ? 'Complete' : 'Next'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0: // Photos
        return _photos.length >= 2;
      case 1: // Basics
        return _age != null && _job.isNotEmpty && _regionCity.isNotEmpty;
      case 2: // Contact
        return true; // Contact phone is optional
      default:
        return false;
    }
  }
}
