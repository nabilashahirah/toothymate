import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../services/profile_service.dart';
import '../services/sound_manager.dart';
import 'home_screen.dart';
import 'welcome_screens.dart';

class ProfileSelectionScreen extends StatefulWidget {
  const ProfileSelectionScreen({super.key});

  @override
  State<ProfileSelectionScreen> createState() => _ProfileSelectionScreenState();
}

class _ProfileSelectionScreenState extends State<ProfileSelectionScreen> {
  List<ChildProfile> _profiles = [];

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  void _loadProfiles() {
    setState(() {
      _profiles = ProfileService.getAllProfiles();
    });
  }

  void _selectProfile(ChildProfile profile) async {
    SoundManager.playPop();
    await ProfileService.setActiveProfile(profile);

    // Set the user_name from the profile name for HomeScreen
    await ProfileService.setString('user_name', profile.name);

    // Mark onboarding as complete for this profile
    await ProfileService.setBool('onboarding_complete', true);

    // Init stats if not exist
    if (ProfileService.getInt('user_xp') == null) {
      await ProfileService.setInt('user_xp', 0);
    }
    if (ProfileService.getInt('streak_count') == null) {
      await ProfileService.setInt('streak_count', 0);
    }

    if (!mounted) return;

    // Go to Home
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  void _showAddProfileDialog() {
    // Check if this is the first profile (user just came from onboarding)
    // or additional profile (user came from home screen)
    final isFirstProfile = _profiles.isEmpty;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddProfileSheet(
        onProfileCreated: (profile) async {
          _loadProfiles();
          if (isFirstProfile) {
            // First profile - they just saw onboarding, go directly to home
            _selectProfile(profile);
          } else {
            // Additional profile from home - show onboarding first
            await _selectNewProfile(profile);
          }
        },
      ),
    );
  }

  // For NEW profiles (created from home screen) - show onboarding first
  Future<void> _selectNewProfile(ChildProfile profile) async {
    SoundManager.playPop();
    await ProfileService.setActiveProfile(profile);

    // Set the user_name from the profile name
    await ProfileService.setString('user_name', profile.name);

    // Init stats for new profile
    await ProfileService.setInt('user_xp', 0);
    await ProfileService.setInt('streak_count', 0);

    // Don't mark onboarding complete - they need to see it
    await ProfileService.setBool('onboarding_complete', false);

    if (!mounted) return;

    // Go to Onboarding for new profiles
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const OnboardingScreen()),
    );
  }

  void _showDeleteConfirmation(ChildProfile profile) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('deleteProfile'.tr()),
          content: Text('deleteProfileConfirm'.tr(args: [profile.name])),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('cancel'.tr()),
            ),
            TextButton(
              onPressed: () {
                final nav = Navigator.of(dialogContext);
                ProfileService.deleteProfile(profile.id).then((_) {
                  nav.pop();
                  if (mounted) _loadProfiles();
                });
              },
              child: Text(
                'delete'.tr(),
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4FC3F7), Color(0xFF0288D1)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40),

              // Header
              Text(
                'whoIsPlaying'.tr(),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'selectYourProfile'.tr(),
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),

              const SizedBox(height: 40),

              // Profiles Grid
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.9,
                    ),
                    itemCount: _profiles.length + 1, // +1 for Add button
                    itemBuilder: (context, index) {
                      if (index == _profiles.length) {
                        // Add Profile Card
                        return _AddProfileCard(onTap: _showAddProfileDialog);
                      }

                      final profile = _profiles[index];
                      return _ProfileCard(
                        profile: profile,
                        onTap: () => _selectProfile(profile),
                        onLongPress: () => _showDeleteConfirmation(profile),
                      );
                    },
                  ),
                ),
              ),

              // Hint text
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'longPressToDelete'.tr(),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white60,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// PROFILE CARD WIDGET
// ==========================================
class _ProfileCard extends StatelessWidget {
  final ChildProfile profile;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _ProfileCard({
    required this.profile,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 15,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Avatar
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: profile.avatarColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: profile.avatarColor.withAlpha(100),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  profile.initials,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Name
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                profile.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// ADD PROFILE CARD
// ==========================================
class _AddProfileCard extends StatelessWidget {
  final VoidCallback onTap;

  const _AddProfileCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white24,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white54,
            width: 2,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Colors.white30,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_rounded,
                size: 40,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'addChild'.tr(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// ADD PROFILE BOTTOM SHEET
// ==========================================
class _AddProfileSheet extends StatefulWidget {
  final Function(ChildProfile) onProfileCreated;

  const _AddProfileSheet({required this.onProfileCreated});

  @override
  State<_AddProfileSheet> createState() => _AddProfileSheetState();
}

class _AddProfileSheetState extends State<_AddProfileSheet> {
  final TextEditingController _nameController = TextEditingController();
  Color _selectedColor = ChildProfile.avatarColors[0];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _createProfile() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('pleaseEnterName'.tr()),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    SoundManager.playPop();
    final profile = await ProfileService.createProfile(name, _selectedColor);

    if (!mounted) return;
    Navigator.pop(context);
    widget.onProfileCreated(profile);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              'addNewChild'.tr(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 24),

            // Name Input
            TextField(
              controller: _nameController,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: 'childName'.tr(),
                hintText: 'enterChildName'.tr(),
                prefixIcon: const Icon(Icons.person_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
            const SizedBox(height: 24),

            // Color Selection
            Text(
              'chooseColor'.tr(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: ChildProfile.avatarColors.map((color) {
                final isSelected = _selectedColor == color;
                return GestureDetector(
                  onTap: () {
                    SoundManager.playPop();
                    setState(() => _selectedColor = color);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: Colors.white, width: 3)
                          : null,
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: color.withAlpha(128),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 24)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            // Create Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _createProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'createProfile'.tr(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
