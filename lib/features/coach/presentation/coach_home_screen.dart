import 'package:flutter/material.dart';

import 'package:salledesport/core/theme/app_colors.dart';
import 'package:salledesport/core/data/repositories/repositories.dart';
import 'package:salledesport/features/coach/viewmodels/screen_viewmodels.dart';

import 'home_screen.dart';
import 'members_screen.dart';
import 'profile_screen.dart';
import 'sessions_screen.dart';

class CoachHomeScreen extends StatefulWidget {
  const CoachHomeScreen({required this.repositories, super.key});

  final AppRepositories repositories;

  @override
  State<CoachHomeScreen> createState() => _CoachHomeScreenState();
}

class _CoachHomeScreenState extends State<CoachHomeScreen> {
  late final HomeViewModel _homeViewModel;
  late final SessionsViewModel _sessionsViewModel;
  late final MembersViewModel _membersViewModel;
  late final ProfileViewModel _profileViewModel;
  int _selectedIndex = 0;
  static const _coachId = 'mock-coach';

  @override
  void initState() {
    super.initState();
    final repositories = widget.repositories;
    _homeViewModel = HomeViewModel(
      profiles: repositories.profiles,
      sessions: repositories.sessions,
      uid: _coachId,
    );
    _sessionsViewModel = SessionsViewModel(repositories.sessions, _coachId);
    _membersViewModel = MembersViewModel(repositories.members, _coachId);
    _profileViewModel = ProfileViewModel(repositories.profiles, _coachId);
  }

  @override
  void dispose() {
    _homeViewModel.dispose();
    _sessionsViewModel.dispose();
    _membersViewModel.dispose();
    _profileViewModel.dispose();
    super.dispose();
  }

  void _selectTab(int index) {
    if (index >= 0 && index < 4) {
      setState(() => _selectedIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: _selectedIndex == 0,
    onPopInvokedWithResult: (didPop, result) {
      if (!didPop && _selectedIndex != 0) _selectTab(0);
    },
    child: Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: true,
        bottom: false,
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            HomeScreen(viewModel: _homeViewModel, onItemSelected: _selectTab),
            SessionsScreen(
              viewModel: _sessionsViewModel,
              onItemSelected: _selectTab,
            ),
            MembersScreen(
              viewModel: _membersViewModel,
              onItemSelected: _selectTab,
            ),
            ProfileScreen(
              viewModel: _profileViewModel,
              onItemSelected: _selectTab,
            ),
          ],
        ),
      ),
    ),
  );
}
