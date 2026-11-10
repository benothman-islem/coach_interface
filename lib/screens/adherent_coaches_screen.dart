import 'package:flutter/material.dart';

import '../data/repositories/repositories.dart';
import '../models/user_profile.dart';
import '../theme/app_theme.dart';
import '../widgets/coach_avatar.dart';
import 'coach_details_screen.dart';

class AdherentCoachesScreen extends StatefulWidget {
  const AdherentCoachesScreen({required this.coachesRepository, super.key});

  final CoachesRepository coachesRepository;

  @override
  State<AdherentCoachesScreen> createState() => _AdherentCoachesScreenState();
}

class _AdherentCoachesScreenState extends State<AdherentCoachesScreen> {
  final _searchController = TextEditingController();
  List<CoachProfile> _coaches = const [];
  String? _selectedSpecialty;
  Object? _error;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCoaches();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCoaches() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      // This repository query selects coaches by role, not by session bookings.
      final coaches = await widget.coachesRepository.getAllCoaches();
      if (!mounted) return;
      setState(() {
        _coaches = coaches;
        _isLoading = false;
      });
    } catch (error, stackTrace) {
      debugPrint('Could not load coach directory: $error\n$stackTrace');
      if (!mounted) return;
      setState(() {
        _error = error;
        _isLoading = false;
      });
    }
  }

  List<CoachProfile> get _filteredCoaches {
    final query = _searchController.text.trim().toLowerCase();
    return _coaches
        .where((coach) {
          final matchesSearch =
              query.isEmpty ||
              coach.name.toLowerCase().contains(query) ||
              coach.specialties.any(
                (specialty) => specialty.toLowerCase().contains(query),
              );
          final matchesSpecialty =
              _selectedSpecialty == null ||
              coach.specialties.contains(_selectedSpecialty);
          return matchesSearch && matchesSpecialty;
        })
        .toList(growable: false);
  }

  List<String> get _specialties =>
      _coaches.expand((coach) => coach.specialties).toSet().toList()..sort(
        (first, second) => first.toLowerCase().compareTo(second.toLowerCase()),
      );

  @override
  Widget build(BuildContext context) {
    final filteredCoaches = _filteredCoaches;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Nos coachs')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Rechercher un coach ou une spécialité',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Effacer la recherche',
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                          icon: const Icon(Icons.clear),
                        ),
                  filled: true,
                  fillColor: AppColors.card,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                ),
              ),
            ),
            if (!_isLoading && _error == null && _coaches.isNotEmpty)
              SizedBox(
                height: 48,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: const Text('Toutes'),
                        selected: _selectedSpecialty == null,
                        onSelected: (_) =>
                            setState(() => _selectedSpecialty = null),
                      ),
                    ),
                    for (final specialty in _specialties)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ChoiceChip(
                          label: Text(specialty),
                          selected: _selectedSpecialty == specialty,
                          onSelected: (_) => setState(
                            () => _selectedSpecialty =
                                _selectedSpecialty == specialty
                                ? null
                                : specialty,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            Expanded(child: _buildContent(filteredCoaches)),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(List<CoachProfile> coaches) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.lime),
      );
    }
    if (_error != null) {
      return _MessageState(
        icon: Icons.cloud_off_outlined,
        message: 'Impossible de charger la liste des coachs.',
        action: 'Réessayer',
        onPressed: _loadCoaches,
      );
    }
    if (_coaches.isEmpty) {
      return const _MessageState(
        icon: Icons.people_outline,
        message: 'Aucun coach disponible pour le moment.',
      );
    }
    if (coaches.isEmpty) {
      return const _MessageState(
        icon: Icons.search_off,
        message: 'Aucun coach ne correspond à ces critères.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      itemCount: coaches.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final coach = coaches[index];
        return _CoachCard(
          coach: coach,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => CoachDetailsScreen(coach: coach),
            ),
          ),
        );
      },
    );
  }
}

class _CoachCard extends StatelessWidget {
  const _CoachCard({required this.coach, required this.onTap});

  final CoachProfile coach;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    color: AppColors.card,
    shape: RoundedRectangleBorder(
      side: const BorderSide(color: AppColors.border),
      borderRadius: BorderRadius.circular(20),
    ),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CoachAvatar(coach: coach, size: 68),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(coach.name, style: AppText.sectionTitle),
                  const SizedBox(height: 5),
                  Text(
                    coach.specialties.isEmpty
                        ? 'Spécialité non renseignée'
                        : coach.specialties.join(' · '),
                    style: const TextStyle(color: AppColors.muted),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${coach.experienceYears ?? '—'} ans d’expérience  ·  ${coach.rating}',
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.muted),
          ],
        ),
      ),
    ),
  );
}

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.icon,
    required this.message,
    this.action,
    this.onPressed,
  });

  final IconData icon;
  final String message;
  final String? action;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 42, color: AppColors.muted),
          const SizedBox(height: 14),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.muted),
          ),
          if (action != null && onPressed != null) ...[
            const SizedBox(height: 18),
            OutlinedButton(onPressed: onPressed, child: Text(action!)),
          ],
        ],
      ),
    ),
  );
}
