import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/providers/profile_provider.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/like_provider.dart';
import '../../../../core/providers/user_photos_provider.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/models/photo_model.dart';

class ProfilePage extends ConsumerWidget {
  final String uid;

  const ProfilePage({
    super.key,
    required this.uid,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileProvider);
    final currentUser = ref.watch(currentUserProvider);
    final isProfileCompleted = ref.watch(isProfileCompletedProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          if (currentUser.value?.uid == uid)
            IconButton(
              onPressed: () => context.go('/me'),
              icon: const Icon(Icons.edit),
            ),
        ],
      ),
      body: profileState == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _buildProfileContent(context, ref, profileState, isProfileCompleted),
    );
  }

  Widget _buildProfileContent(
    BuildContext context,
    WidgetRef ref,
    UserModel profile,
    bool isProfileCompleted,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Header
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Profile Picture
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    child: Text(
                      profile.nickname.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 32,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Basic Info
                  Text(
                    profile.nickname,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  if (profile.age != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${profile.age} years old',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                  
                  if (profile.job != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      profile.job!,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                  
                  if (profile.regionCity != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${profile.regionCity}${profile.regionDistrict != null ? ', ${profile.regionDistrict}' : ''}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Photos Section
          Text(
            'Photos',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          
          Consumer(
            builder: (context, ref, child) {
              final photosState = ref.watch(userPhotosProvider(uid));
              return photosState.when(
                data: (photos) => _buildPhotosGrid(context, photos, isProfileCompleted),
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (_, __) => const Center(
                  child: Text('Error loading photos'),
                ),
              );
            },
          ),
          
          const SizedBox(height: 16),
          
          // Bio Section
          if (profile.bio != null && profile.bio!.isNotEmpty) ...[
            Text(
              'About',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  profile.bio!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isProfileCompleted
                      ? () => _sendLike(context, ref, profile.uid)
                      : () => _showProfileRequiredDialog(context),
                  icon: const Icon(Icons.favorite),
                  label: const Text('Send Like'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhotosGrid(BuildContext context, List<PhotoModel> photos, bool isProfileCompleted) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: photos.length,
      itemBuilder: (context, index) {
        final photo = photos[index];
        final isLocked = index >= 2 && !isProfileCompleted;
        
        return _buildPhotoCard(context, photo, isLocked);
      },
    );
  }

  Widget _buildPhotoCard(BuildContext context, PhotoModel photo, bool isLocked) {
    return Card(
      elevation: 2,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: photo.url,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              placeholder: (context, url) => Container(
                color: Colors.grey[200],
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[200],
                child: const Icon(Icons.error),
              ),
            ),
          ),
          
          if (isLocked)
            Container(
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lock,
                      color: Colors.white,
                      size: 32,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Complete your profile\nto view more photos',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _sendLike(BuildContext context, WidgetRef ref, String targetUserId) {
    ref.read(likeServiceProvider).sendLike(
      ref.read(currentUserProvider).value?.uid ?? '',
      targetUserId,
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Like sent!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showProfileRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Profile Required'),
        content: const Text(
          'To send likes, please complete your profile first.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/profile-setup');
            },
            child: const Text('Complete Profile'),
          ),
        ],
      ),
    );
  }
}
