import 'package:flutter/material.dart';

import '../models/session.dart';
import '../theme/app_theme.dart';
import 'app_widgets.dart';

class SessionFormSheet extends StatefulWidget {
  const SessionFormSheet({required this.formState, super.key});

  final SessionFormState formState;

  @override
  State<SessionFormSheet> createState() => _SessionFormSheetState();
}

class _SessionFormSheetState extends State<SessionFormSheet> {
  late SessionType _selectedType = widget.formState.initial.type;
  late DateTime _selectedDate = widget.formState.initial.date;
  late TimeOfDay _selectedTime = widget.formState.initial.time;
  late final TextEditingController _studioController = TextEditingController(
    text: widget.formState.initial.studio,
  );
  late final TextEditingController _capacityController = TextEditingController(
    text: widget.formState.initial.capacity > 0
        ? '${widget.formState.initial.capacity}'
        : '',
  );
  bool _submitAttempted = false;
  bool _studioFocused = false;
  bool _capacityFocused = false;

  bool get _hasValidStudio => _studioController.text.trim().isNotEmpty;
  int? get _capacityValue => int.tryParse(_capacityController.text);

  bool get _canSubmit =>
      _hasValidStudio &&
      (_capacityValue ?? 0) >= 1 &&
      (widget.formState.mode != SessionFormMode.edit ||
          widget.formState.sessionId != null);

  @override
  void dispose() {
    _studioController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      locale: const Locale('fr'),
      helpText: 'Sélectionner une date',
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.lime,
            onPrimary: AppColors.background,
            surface: AppColors.sheet,
            onSurface: AppColors.text,
          ),
        ),
        child: child!,
      ),
    );
    if (selected != null && mounted) {
      setState(() => _selectedDate = selected);
    }
  }

  Future<void> _selectTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      helpText: 'Sélectionner une heure',
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.lime,
              onPrimary: AppColors.background,
              surface: AppColors.sheet,
              onSurface: AppColors.text,
            ),
            timePickerTheme: const TimePickerThemeData(
              backgroundColor: AppColors.sheet,
              dialBackgroundColor: AppColors.sheetField,
              dialHandColor: AppColors.lime,
              hourMinuteColor: AppColors.sheetField,
              hourMinuteTextColor: AppColors.text,
              dayPeriodColor: AppColors.sheetField,
              dayPeriodTextColor: AppColors.text,
              entryModeIconColor: AppColors.muted,
            ),
          ),
          child: child!,
        ),
      ),
    );
    if (selected != null && mounted) {
      setState(() => _selectedTime = selected);
    }
  }

  void _submit() {
    if (!_canSubmit) {
      setState(() => _submitAttempted = true);
      return;
    }
    Navigator.of(context).pop(
      SessionInput(
        type: _selectedType,
        date: _selectedDate,
        time: _selectedTime,
        studio: _studioController.text.trim(),
        capacity: _capacityValue!,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCreate = widget.formState.mode == SessionFormMode.create;
    final keyboardHeight = MediaQuery.viewInsetsOf(context).bottom;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(24, 8, 24, 24 + keyboardHeight),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: AppColors.muted,
              borderRadius: BorderRadius.circular(100),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  isCreate ? 'Nouvelle séance' : 'Modifier la séance',
                  style: AppText.screenTitle.copyWith(
                    fontSize: 32,
                    letterSpacing: 0,
                  ),
                ),
              ),
              SizedBox(
                width: 40,
                height: 40,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.closeButton,
                    foregroundColor: AppColors.muted,
                    padding: EdgeInsets.zero,
                  ),
                  icon: const Icon(Icons.close, size: 20),
                  tooltip: 'Fermer',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Eyebrow('TYPE DE SÉANCE'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final type in SessionType.values)
                _SessionTypeChip(
                  type: type,
                  selected: type == _selectedType,
                  onTap: () => setState(() => _selectedType = type),
                ),
            ],
          ),
          const SizedBox(height: 24),
          const Eyebrow('DATE ET HEURE'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ReadOnlyFieldButton(
                  icon: Icons.calendar_month_outlined,
                  text: formatFrenchDate(_selectedDate),
                  onTap: _selectDate,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ReadOnlyFieldButton(
                  icon: Icons.schedule,
                  text: formatTime(_selectedTime),
                  onTap: _selectTime,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Eyebrow('DÉTAILS'),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FormTextField(
                      controller: _studioController,
                      placeholder: 'Studio A',
                      focusChanged: (value) =>
                          setState(() => _studioFocused = value),
                      focused: _studioFocused,
                      onChanged: (_) => setState(() {}),
                      textInputAction: TextInputAction.next,
                    ),
                    if (_submitAttempted && !_hasValidStudio)
                      const _FieldError('Le studio est obligatoire'),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FormTextField(
                      controller: _capacityController,
                      placeholder: '12',
                      focusChanged: (value) =>
                          setState(() => _capacityFocused = value),
                      focused: _capacityFocused,
                      onChanged: (_) => setState(() {}),
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      trailingLabel: ' places',
                    ),
                    if (_submitAttempted && (_capacityValue ?? 0) < 1)
                      const _FieldError('Au moins 1 place'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Opacity(
            opacity: _canSubmit ? 1 : 0.4,
            child: PrimaryButton(
              text: isCreate ? 'Créer la séance' : 'Enregistrer',
              onPressed: _submit,
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionTypeChip extends StatelessWidget {
  const _SessionTypeChip({
    required this.type,
    required this.selected,
    required this.onTap,
  });

  final SessionType type;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: selected ? AppColors.selectedChip : AppColors.sheetField,
    shape: StadiumBorder(
      side: BorderSide(
        width: selected ? 1.5 : 1,
        color: selected ? AppColors.lime : AppColors.border,
      ),
    ),
    child: InkWell(
      onTap: onTap,
      customBorder: const StadiumBorder(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Text(
          type.label,
          style: AppText.trailingLabel.copyWith(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? AppColors.lime : AppColors.text,
          ),
        ),
      ),
    ),
  );
}

class _ReadOnlyFieldButton extends StatelessWidget {
  const _ReadOnlyFieldButton({
    required this.icon,
    required this.text,
    required this.onTap,
  });

  final IconData icon;
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.sheetField,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(color: AppColors.border),
    ),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 52,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              Icon(icon, size: 18, color: AppColors.muted),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  text,
                  style: AppText.trailingLabel.copyWith(
                    fontSize: 12,
                    color: AppColors.text,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _FormTextField extends StatelessWidget {
  const _FormTextField({
    required this.controller,
    required this.placeholder,
    required this.focused,
    required this.focusChanged,
    required this.onChanged,
    required this.textInputAction,
    this.keyboardType,
    this.trailingLabel,
  });

  final TextEditingController controller;
  final String placeholder;
  final bool focused;
  final ValueChanged<bool> focusChanged;
  final ValueChanged<String> onChanged;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;
  final String? trailingLabel;

  @override
  Widget build(BuildContext context) => Container(
    height: 52,
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      color: AppColors.sheetField,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: focused ? AppColors.lime : AppColors.border),
    ),
    child: Row(
      children: [
        Expanded(
          child: Focus(
            onFocusChange: focusChanged,
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              keyboardType: keyboardType,
              textInputAction: textInputAction,
              maxLines: 1,
              style: AppText.trailingLabel.copyWith(
                fontSize: 13,
                color: AppColors.text,
              ),
              cursorColor: AppColors.lime,
              decoration: InputDecoration(
                hintText: placeholder,
                hintStyle: AppText.trailingLabel.copyWith(
                  fontSize: 13,
                  color: AppColors.muted,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ),
        if (trailingLabel != null)
          Text(
            trailingLabel!,
            style: AppText.trailingLabel.copyWith(
              fontSize: 11,
              color: AppColors.muted,
            ),
          ),
      ],
    ),
  );
}

class _FieldError extends StatelessWidget {
  const _FieldError(this.message);

  final String message;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 4, left: 2),
    child: Text(
      message,
      style: const TextStyle(fontSize: 11, color: Color(0xFFF4866A)),
    ),
  );
}
