import 'package:flutter/material.dart';

import 'package:salledesport/core/theme/app_colors.dart';
import 'package:salledesport/models/session.dart';
import 'package:salledesport/models/ui_state.dart';
import 'package:salledesport/core/theme/app_theme.dart';
import 'package:salledesport/features/coach/viewmodels/screen_viewmodels.dart';
import 'package:salledesport/core/widgets/app_widgets.dart';
import 'package:salledesport/core/widgets/session_form_sheet.dart';
import 'package:salledesport/core/widgets/ui_state_view.dart';

class SessionsScreen extends StatefulWidget {
  const SessionsScreen({
    required this.viewModel,
    required this.onItemSelected,
    super.key,
  });

  final SessionsViewModel viewModel;
  final ValueChanged<int> onItemSelected;

  @override
  State<SessionsScreen> createState() => _SessionsScreenState();
}

class _SessionsScreenState extends State<SessionsScreen> {
  static const _filters = ["Aujourd'hui", 'À venir', 'Passées'];
  static const _weekdayLabels = ['LUN', 'MAR', 'MER', 'JEU', 'VEN'];

  late final DateTime _today = DateTime.now();
  late final DateTime _monday = DateTime(
    _today.year,
    _today.month,
    _today.day,
  ).subtract(Duration(days: _today.weekday - 1));
  late DateTime _selectedDate = DateTime(_today.year, _today.month, _today.day);
  String _selectedFilter = _filters.first;
  bool _mutationInProgress = false;

  List<DateTime> get _weekdays =>
      List.generate(5, (index) => _monday.add(Duration(days: index)));

  List<TrainingSession> _filterSessions(List<TrainingSession> sessions) {
    final now = DateTime.now();
    return sessions.where((session) {
      final sessionDay = DateTime(
        session.date.year,
        session.date.month,
        session.date.day,
      );
      final sameDay = sessionDay == _selectedDate;
      final isToday = sessionDay == DateTime(now.year, now.month, now.day);
      return sameDay &&
          switch (_selectedFilter) {
            "Aujourd'hui" => isToday,
            'À venir' => session.date.isAfter(now),
            'Passées' => session.date.isBefore(now),
            _ => true,
          };
    }).toList()..sort((a, b) => a.date.compareTo(b.date));
  }

  Future<void> _openForm({
    required SessionFormMode mode,
    TrainingSession? session,
  }) async {
    final formState = SessionFormState(
      mode: mode,
      sessionId: session?.documentId,
      initial:
          session?.toInput() ??
          SessionInput(
            type: SessionType.hiit,
            date: _selectedDate,
            time: const TimeOfDay(hour: 18, minute: 30),
            studio: '',
            capacity: 0,
          ),
    );
    final input = await showModalBottomSheet<SessionInput>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.sheet,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => SessionFormSheet(formState: formState),
    );
    if (!mounted || input == null) return;
    await _runMutation(() async {
      if (mode == SessionFormMode.create) {
        await widget.viewModel.create(input);
      } else {
        final id = formState.sessionId;
        if (id == null) throw StateError('Session document ID is missing.');
        await widget.viewModel.update(id, input);
      }
    });
  }

  Future<void> _deleteSession(TrainingSession session) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.sheet,
        title: const Text('Supprimer la séance ?'),
        content: Text('Voulez-vous supprimer « ${session.title} » ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Supprimer',
              style: TextStyle(color: AppColors.destructive),
            ),
          ),
        ],
      ),
    );
    if (shouldDelete != true || !mounted) return;
    final id = session.documentId;
    if (id == null) return;
    await _runMutation(() => widget.viewModel.delete(id));
  }

  Future<void> _runMutation(Future<void> Function() operation) async {
    setState(() => _mutationInProgress = true);
    try {
      await operation();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible d’enregistrer la séance.')),
        );
      }
    } finally {
      if (mounted) setState(() => _mutationInProgress = false);
    }
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.viewModel,
    builder: (context, _) => Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
            children: [
              const _SessionsHeader(),
              const SizedBox(height: 16),
              Row(
                children: [
                  for (var index = 0; index < _filters.length; index++) ...[
                    if (index > 0) const SizedBox(width: 8),
                    Expanded(
                      child: _FilterChip(
                        label: _filters[index],
                        selected: _selectedFilter == _filters[index],
                        onTap: () =>
                            setState(() => _selectedFilter = _filters[index]),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  for (var index = 0; index < _weekdays.length; index++) ...[
                    if (index > 0) const SizedBox(width: 8),
                    Expanded(
                      child: _DayCard(
                        label: _weekdayLabels[index],
                        date: _weekdays[index],
                        selected: _selectedDate == _weekdays[index],
                        onTap: () =>
                            setState(() => _selectedDate = _weekdays[index]),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              _sessionList(widget.viewModel.state),
            ],
          ),
        ),
        BottomNavBar(selectedIndex: 1, onItemSelected: widget.onItemSelected),
      ],
    ),
  );

  Widget _sessionList(UiState<List<TrainingSession>> state) => switch (state) {
    UiLoading<List<TrainingSession>>() => const SizedBox(
      height: 240,
      child: Center(child: CircularProgressIndicator(color: AppColors.lime)),
    ),
    UiError<List<TrainingSession>>() => SizedBox(
      height: 240,
      child: UiStateView<List<TrainingSession>>(
        state: state,
        onRetry: widget.viewModel.retry,
        emptyMessage: 'Aucune séance.',
        onSuccess: (_) => const SizedBox.shrink(),
      ),
    ),
    UiEmpty<List<TrainingSession>>() => _sessionContents(const []),
    UiSuccess<List<TrainingSession>>(:final value) => _sessionContents(
      _filterSessions(value),
    ),
  };

  Widget _sessionContents(List<TrainingSession> sessions) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Expanded(
            child: Text(
              '${sessions.length} séances programmées',
              style: AppText.sectionTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 40,
            height: 40,
            child: FilledButton(
              onPressed: _mutationInProgress
                  ? null
                  : () => _openForm(mode: SessionFormMode.create),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.lime,
                foregroundColor: AppColors.background,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.zero,
              ),
              child: const Icon(Icons.add, size: 22),
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      if (sessions.isEmpty)
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: Center(
            child: Text(
              'Aucune séance pour cette sélection.',
              style: TextStyle(color: AppColors.muted),
            ),
          ),
        ),
      for (var index = 0; index < sessions.length; index++) ...[
        _SessionCard(
          session: sessions[index],
          onEdit: () =>
              _openForm(mode: SessionFormMode.edit, session: sessions[index]),
          onDelete: () => _deleteSession(sessions[index]),
        ),
        if (index < sessions.length - 1) const SizedBox(height: 12),
      ],
    ],
  );
}

class _SessionsHeader extends StatelessWidget {
  const _SessionsHeader();

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Eyebrow('TON PLANNING'),
            SizedBox(height: 3),
            Text('Mes séances', style: AppText.screenTitle),
            SizedBox(height: 3),
            Text(
              'Gère tes cours et suis les inscriptions.',
              style: TextStyle(fontSize: 13, color: AppColors.muted),
            ),
          ],
        ),
      ),
      NotificationButton(onPressed: () {}),
    ],
  );
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: selected ? AppColors.lime : Colors.transparent,
    shape: StadiumBorder(
      side: selected
          ? BorderSide.none
          : const BorderSide(color: AppColors.border),
    ),
    child: InkWell(
      customBorder: const StadiumBorder(),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          style: AppText.caption.copyWith(
            fontSize: 12,
            color: selected ? AppColors.background : AppColors.text,
          ),
        ),
      ),
    ),
  );
}

class _DayCard extends StatelessWidget {
  const _DayCard({
    required this.label,
    required this.date,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final DateTime date;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: selected ? AppColors.selectedDay : AppColors.card,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
      side: BorderSide(
        width: selected ? 1.5 : 1,
        color: selected ? AppColors.lime : AppColors.border,
      ),
    ),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        height: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: AppText.dateDay.copyWith(
                fontSize: 10,
                color: selected ? AppColors.lime : AppColors.muted,
              ),
            ),
            Text(
              '${date.day}',
              style: AppText.caption.copyWith(
                fontSize: 16,
                color: selected ? AppColors.lime : AppColors.text,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({
    required this.session,
    required this.onEdit,
    required this.onDelete,
  });

  final TrainingSession session;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) => OutlinedCard(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    child: Row(
      children: [
        Container(
          width: 3,
          height: 56,
          decoration: BoxDecoration(
            color: session.accentColor,
            borderRadius: BorderRadius.circular(100),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 52,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                formatTime(session.time),
                style: AppText.trailingLabel.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '${session.durationMinutes} min',
                style: AppText.caption.copyWith(color: AppColors.muted),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                session.title,
                style: AppText.sessionTitle.copyWith(fontSize: 17),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                session.studio,
                style: AppText.trailingLabel.copyWith(
                  fontSize: 14,
                  color: AppColors.muted,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  const Icon(
                    Icons.groups_outlined,
                    size: 14,
                    color: AppColors.lime,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${session.enrolledCount} inscrits',
                    style: AppText.caption.copyWith(color: AppColors.lime),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 40,
          height: 40,
          child: OutlinedButton(
            onPressed: onEdit,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.muted,
              side: const BorderSide(color: AppColors.border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.zero,
            ),
            child: const Icon(Icons.edit_outlined, size: 18),
          ),
        ),
        SizedBox(
          width: 34,
          height: 40,
          child: IconButton(
            onPressed: onDelete,
            padding: EdgeInsets.zero,
            color: AppColors.destructive,
            tooltip: 'Supprimer',
            icon: const Icon(Icons.delete_outline, size: 18),
          ),
        ),
      ],
    ),
  );
}
