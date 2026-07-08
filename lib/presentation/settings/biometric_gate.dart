import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

import '../../application/settings/app_settings.dart';
import '../../core/theme.dart';

String _hashValue(String input) {
  final bytes = utf8.encode('mm_${input}_slt');
  var h = 0;
  for (final b in bytes) {
    h = ((h << 5) - h) + b;
    h = h & 0x7FFFFFFF;
  }
  return base64.encode(utf8.encode(h.toString()));
}

bool _checkValue(String input, String hash) => _hashValue(input) == hash;

final pinHashProvider = Provider<String?>((ref) {
  final box = ref.watch(settingsBoxProvider);
  return box.get('app_pin') as String?;
});

final patternHashProvider = Provider<String?>((ref) {
  final box = ref.watch(settingsBoxProvider);
  return box.get('app_pattern') as String?;
});

final pinFailCountProvider = Provider<int>((ref) {
  final box = ref.watch(settingsBoxProvider);
  return box.get('pin_fail_count', defaultValue: 0) as int;
});

final lockoutEndProvider = Provider<DateTime?>((ref) {
  final box = ref.watch(settingsBoxProvider);
  final ts = box.get('lockout_end') as int?;
  return ts != null ? DateTime.fromMillisecondsSinceEpoch(ts) : null;
});

final lastUnlockTimeProvider = Provider<DateTime?>((ref) {
  final box = ref.watch(settingsBoxProvider);
  final ts = box.get('last_unlock_time') as int?;
  return ts != null ? DateTime.fromMillisecondsSinceEpoch(ts) : null;
});

final securityQuestionsProvider = Provider<Map<String, String>>((ref) {
  final box = ref.watch(settingsBoxProvider);
  final raw = box.get('security_questions') as String?;
  if (raw == null) return {};
  try {
    return Map<String, String>.from(json.decode(raw) as Map);
  } catch (_) {
    return {};
  }
});

final setupCompletedProvider = Provider<bool>((ref) {
  final box = ref.watch(settingsBoxProvider);
  return box.get('lock_setup_completed', defaultValue: false) as bool;
});

enum _GateMode {
  locked,
  authenticating,
  pinEntry,
  patternEntry,
  forgotPin,
  setupWizard,
  securityDashboard,
  unlocked,
}

class BiometricGate extends ConsumerStatefulWidget {
  final Widget child;
  const BiometricGate({super.key, required this.child});

  @override
  ConsumerState<BiometricGate> createState() => _BiometricGateState();
}

class _BiometricGateState extends ConsumerState<BiometricGate>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  _GateMode _mode = _GateMode.authenticating;
  bool _initialized = false;

  Timer? _lockoutTimer;
  int _lockoutSeconds = 0;

  String _pinBuffer = '';
  bool _pinError = false;
  String _pinErrorMsg = '';

  final Set<int> _patternBuffer = {};
  bool _patternError = false;

  int _wizardStep = 0;
  String _wizardLockType = 'pin';
  String _newPin = '';
  String _confirmPin = '';
  final Set<int> _newPattern = {};
  final Set<int> _confirmPattern = {};
  int _selectedQ1 = 0;
  int _selectedQ2 = 1;
  final _ansCtl1 = TextEditingController();
  final _ansCtl2 = TextEditingController();

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  static const _questions = [
    "What is your mother's maiden name?",
    'What was the name of your first pet?',
    'What city were you born in?',
    'What is your favorite book?',
    'What is your favorite color?',
    'What was your childhood nickname?',
    'What is your dream job?',
  ];
  static const _maxFailures = 5;
  static const _lockoutDuration = Duration(seconds: 30);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut),
    );
    _scaleAnim = Tween<double>(begin: 0.9, end: 1).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutBack),
    );
    _initStateAsync();
  }

  Future<void> _initStateAsync() async {
    setState(() => _initialized = true);
    _startAuth();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _animCtrl.dispose();
    _ansCtl1.dispose();
    _ansCtl2.dispose();
    _lockoutTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _mode == _GateMode.unlocked) {
      final enabled = ref.read(biometricLockProvider);
      if (enabled) _startAuth();
    }
  }

  Future<void> _startAuth() async {
    final bio = ref.read(biometricLockProvider);
    final pinHash = ref.read(pinHashProvider);
    final patternHash = ref.read(patternHashProvider);
    final setupDone = ref.read(setupCompletedProvider);

    if (!bio && pinHash == null && patternHash == null) {
      _unlock();
      return;
    }

    setState(() => _mode = _GateMode.authenticating);

    final box = ref.read(settingsBoxProvider);
    final lockEnd = box.get('lockout_end') as int?;
    if (lockEnd != null) {
      final end = DateTime.fromMillisecondsSinceEpoch(lockEnd);
      if (DateTime.now().isBefore(end)) {
        _beginLockout(end);
        return;
      }
      box.delete('lockout_end');
      box.put('pin_fail_count', 0);
    }

    if (bio && !setupDone && pinHash == null && patternHash == null) {
      _resetWizard();
      setState(() => _mode = _GateMode.setupWizard);
      return;
    }

    if (bio) {
      final ok = await _tryBiometric();
      if (ok) return;
    }

    if (pinHash != null) {
      setState(() => _mode = _GateMode.pinEntry);
    } else if (patternHash != null) {
      setState(() => _mode = _GateMode.patternEntry);
    } else {
      _unlock();
    }
  }

  Future<bool> _tryBiometric() async {
    try {
      final auth = LocalAuthentication();
      final can = await auth.canCheckBiometrics;
      final supported = await auth.isDeviceSupported();
      if (!can || !supported) return false;
      final ok = await auth.authenticate(
        localizedReason: 'Unlock MoneyMate to continue',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
      if (ok) _unlock();
      return ok;
    } catch (_) {
      return false;
    }
  }

  void _unlock() {
    final box = ref.read(settingsBoxProvider);
    box.put('last_unlock_time', DateTime.now().millisecondsSinceEpoch);
    box.put('pin_fail_count', 0);
    setState(() {
      _mode = _GateMode.unlocked;
      _pinBuffer = '';
      _pinError = false;
      _patternBuffer.clear();
      _patternError = false;
    });
    _animCtrl.forward();
  }

  void _showPinEntry() => setState(() => _mode = _GateMode.pinEntry);
  void _showPatternEntry() => setState(() => _mode = _GateMode.patternEntry);
  void _showForgotPin() => setState(() => _mode = _GateMode.forgotPin);
  void _showDashboard() => setState(() => _mode = _GateMode.securityDashboard);

  void _resetWizard() {
    _wizardStep = 0;
    _wizardLockType = 'pin';
    _newPin = '';
    _confirmPin = '';
    _newPattern.clear();
    _confirmPattern.clear();
  }

  void _beginLockout(DateTime end) {
    _lockoutTimer?.cancel();
    _lockoutSeconds = end.difference(DateTime.now()).inSeconds.clamp(0, 30).ceil();
    setState(() => _mode = _GateMode.locked);
    _lockoutTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      final remaining = end.difference(DateTime.now()).inSeconds.ceil();
      if (remaining <= 0) {
        t.cancel();
        final box = ref.read(settingsBoxProvider);
        box.delete('lockout_end');
        box.put('pin_fail_count', 0);
        _startAuth();
        return;
      }
      setState(() => _lockoutSeconds = remaining);
    });
  }

  void _onPinDigit(String d) {
    if (_pinBuffer.length >= 6) return;
    setState(() { _pinBuffer += d; _pinError = false; });
    if (_pinBuffer.length == 6) _verifyPin();
  }

  void _onPinDelete() {
    if (_pinBuffer.isEmpty) return;
    setState(() => _pinBuffer = _pinBuffer.substring(0, _pinBuffer.length - 1));
  }

  void _verifyPin() {
    final hash = ref.read(pinHashProvider);
    if (hash == null) return;
    if (_checkValue(_pinBuffer, hash)) {
      _unlock();
    } else {
      _pinFail();
    }
  }

  void _pinFail() {
    final box = ref.read(settingsBoxProvider);
    final count = (box.get('pin_fail_count', defaultValue: 0) as int) + 1;
    box.put('pin_fail_count', count);
    if (count >= _maxFailures) {
      final end = DateTime.now().add(_lockoutDuration);
      box.put('lockout_end', end.millisecondsSinceEpoch);
      setState(() {
        _pinError = true;
        _pinErrorMsg = 'Too many attempts. Locked for 30s.';
        _pinBuffer = '';
      });
      _beginLockout(end);
    } else {
      setState(() {
        _pinError = true;
        _pinErrorMsg = 'Wrong PIN. ${_maxFailures - count} attempt${_maxFailures - count == 1 ? '' : 's'} left.';
        _pinBuffer = '';
      });
    }
  }

  void _onPatternDot(int i) {
    if (_patternBuffer.contains(i)) return;
    HapticFeedback.lightImpact();
    setState(() { _patternBuffer.add(i); _patternError = false; });
    if (_patternBuffer.length >= 4) _verifyPattern();
  }

  void _verifyPattern() {
    final hash = ref.read(patternHashProvider);
    if (hash == null) return;
    final str = _patternBuffer.join(',');
    if (_checkValue(str, hash)) {
      _unlock();
    } else {
      _pinFail();
      setState(() { _patternError = true; _patternBuffer.clear(); });
    }
  }

  void _wizardNext() {
    if (_wizardStep == 0) {
      setState(() => _wizardStep = 1);
    } else if (_wizardStep == 1) {
      if (_wizardLockType == 'pin' && _newPin.length == 6) {
        setState(() => _wizardStep = 2);
      } else if (_wizardLockType == 'pattern' && _newPattern.length >= 4) {
        setState(() => _wizardStep = 2);
      }
    } else if (_wizardStep == 2) {
      if (_wizardLockType == 'pin' && _confirmPin == _newPin) {
        setState(() => _wizardStep = 3);
      } else if (_wizardLockType == 'pattern' && _confirmPattern.join(',') == _newPattern.join(',')) {
        setState(() => _wizardStep = 3);
      }
    } else if (_wizardStep == 3) {
      setState(() => _wizardStep = 4);
    } else if (_wizardStep == 4) {
      _finishSetup();
    }
  }

  void _finishSetup() {
    final box = ref.read(settingsBoxProvider);
    if (_newPin.isNotEmpty) {
      box.put('app_pin', _hashValue(_newPin));
    }
    if (_newPattern.isNotEmpty) {
      box.put('app_pattern', _hashValue(_newPattern.join(',')));
    }
    final qs = {
      _questions[_selectedQ1]: _hashValue(_ansCtl1.text.trim().toLowerCase()),
      _questions[_selectedQ2]: _hashValue(_ansCtl2.text.trim().toLowerCase()),
    };
    box.put('security_questions', json.encode(qs));
    box.put('lock_setup_completed', true);
    final bio = ref.read(biometricLockProvider);
    if (!bio) {
      ref.read(biometricLockProvider.notifier).state = true;
    }
    _resetWizard();
    setState(() => _mode = _GateMode.authenticating);
    _startAuth();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
      );
    }
    if (_mode == _GateMode.unlocked) {
      return AnimatedBuilder(
        animation: _animCtrl,
        builder: (_, child) => FadeTransition(
          opacity: _fadeAnim,
          child: ScaleTransition(scale: _scaleAnim, child: child),
        ),
        child: widget.child,
      );
    }
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0B1220), Color(0xFF060D18)],
          ),
        ),
        child: SafeArea(child: _buildBody()),
      ),
    );
  }

  Widget _buildBody() {
    switch (_mode) {
      case _GateMode.locked:
        return _LockoutView();
      case _GateMode.authenticating:
        return const Center(
          child: CircularProgressIndicator(color: AppTheme.primary),
        );
      case _GateMode.pinEntry:
        return _PinEntryView();
      case _GateMode.patternEntry:
        return _PatternEntryView();
      case _GateMode.forgotPin:
        return _ForgotPinView();
      case _GateMode.setupWizard:
        return _SetupWizardView();
      case _GateMode.securityDashboard:
        return _SecurityDashboardView();
      default:
        return const SizedBox();
    }
  }

  Widget _headerIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primary.withAlpha(25),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 48, color: AppTheme.primary),
    );
  }

  Widget _LockoutView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _headerIcon(Icons.lock_outline),
            const SizedBox(height: 24),
            const Text(
              'Too Many Attempts',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Locked out temporarily',
              style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 24),
            Text(
              '$_lockoutSeconds s',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w300,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _lockoutSeconds / 30,
                backgroundColor: AppTheme.cardSurface,
                color: AppTheme.primary,
                minHeight: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _PinEntryView() {
    final hasBio = ref.read(biometricLockProvider);
    final hasPattern = ref.read(patternHashProvider) != null;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _headerIcon(Icons.lock_outline),
            const SizedBox(height: 20),
            const Text(
              'Enter PIN',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _pinError ? _pinErrorMsg : 'Enter your 6-digit PIN',
              style: TextStyle(
                fontSize: 13,
                color: _pinError ? AppTheme.expense : AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            _PinDots(length: _pinBuffer.length, error: _pinError),
            const SizedBox(height: 32),
            _PinPad(onDigit: _onPinDigit, onDelete: _onPinDelete),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (hasBio)
                  TextButton.icon(
                    icon: const Icon(Icons.fingerprint, size: 18),
                    label: const Text('Bio'),
                    onPressed: () { _tryBiometric(); },
                  ),
                if (hasPattern)
                  TextButton.icon(
                    icon: const Icon(Icons.grid_view, size: 18),
                    label: const Text('Pattern'),
                    onPressed: _showPatternEntry,
                  ),
              ],
            ),
            TextButton(
              onPressed: _showForgotPin,
              child: const Text(
                'Forgot PIN?',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            ),
            TextButton(
              onPressed: _showDashboard,
              child: const Text(
                'Security Dashboard',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _PatternEntryView() {
    final hasBio = ref.read(biometricLockProvider);
    final hasPin = ref.read(pinHashProvider) != null;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _headerIcon(Icons.grid_view_outlined),
            const SizedBox(height: 20),
            const Text(
              'Draw Pattern',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _patternError
                  ? 'Wrong pattern. Try again.'
                  : 'Connect at least 4 dots',
              style: TextStyle(
                fontSize: 13,
                color: _patternError ? AppTheme.expense : AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            _PatternGrid(
              selected: _patternBuffer,
              error: _patternError,
              onDot: _onPatternDot,
              onCancel: () => setState(() => _patternBuffer.clear()),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (hasBio)
                  TextButton.icon(
                    icon: const Icon(Icons.fingerprint, size: 18),
                    label: const Text('Bio'),
                    onPressed: () { _tryBiometric(); },
                  ),
                if (hasPin)
                  TextButton.icon(
                    icon: const Icon(Icons.pin, size: 18),
                    label: const Text('PIN'),
                    onPressed: _showPinEntry,
                  ),
              ],
            ),
            TextButton(
              onPressed: _showDashboard,
              child: const Text(
                'Security Dashboard',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _ForgotPinView() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _headerIcon(Icons.help_outline),
            const SizedBox(height: 20),
            const Text(
              'Verify Your Identity',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Answer your security questions',
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 24),
            _buildQuestionField(
              0, _selectedQ1, _ansCtl1,
              (v) => setState(() => _selectedQ1 = v!),
            ),
            const SizedBox(height: 16),
            _buildQuestionField(
              1, _selectedQ2, _ansCtl2,
              (v) => setState(() => _selectedQ2 = v!),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _verifySecurityAnswers,
              child: const Text('Verify & Reset'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _showPinEntry,
              child: const Text(
                'Back',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionField(
    int idx,
    int selected,
    TextEditingController ctl,
    ValueChanged<int?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<int>(
          value: selected,
          dropdownColor: AppTheme.cardSurface,
          items: List.generate(
            _questions.length,
            (i) => DropdownMenuItem(
              value: i,
              child: Text(
                _questions[i],
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          onChanged: onChanged,
          decoration: const InputDecoration(
            labelText: 'Question',
            labelStyle: TextStyle(color: AppTheme.textSecondary),
            contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: ctl,
          style: const TextStyle(color: AppTheme.textPrimary),
          decoration: const InputDecoration(
            hintText: 'Your answer',
            hintStyle: TextStyle(color: AppTheme.textSecondary),
          ),
        ),
      ],
    );
  }

  void _verifySecurityAnswers() {
    final saved = ref.read(securityQuestionsProvider);
    if (saved.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No security questions configured.'),
          backgroundColor: AppTheme.warning,
        ),
      );
      return;
    }
    final a1 = _ansCtl1.text.trim().toLowerCase();
    final a2 = _ansCtl2.text.trim().toLowerCase();
    final q1 = _questions[_selectedQ1];
    final q2 = _questions[_selectedQ2];
    if (_checkValue(a1, saved[q1] ?? '') &&
        _checkValue(a2, saved[q2] ?? '')) {
      final box = ref.read(settingsBoxProvider);
      box.delete('app_pin');
      box.put('pin_fail_count', 0);
      box.delete('lockout_end');
      _ansCtl1.clear();
      _ansCtl2.clear();
      _resetWizard();
      setState(() => _mode = _GateMode.setupWizard);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Identity verified. Set a new PIN.'),
          backgroundColor: AppTheme.primary,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Answers incorrect.'),
          backgroundColor: AppTheme.expense,
        ),
      );
    }
  }

  Widget _SetupWizardView() {
    final steps = [
      'Choose',
      _wizardLockType == 'pin' ? 'Set PIN' : 'Draw',
      'Confirm',
      'Questions',
      'Done',
    ];
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 16),
          const Text(
            'Lock Setup',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Step ${_wizardStep + 1} of ${steps.length}: ${steps[_wizardStep]}',
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          _StepIndicator(current: _wizardStep, total: steps.length),
          const SizedBox(height: 24),
          Expanded(child: _buildWizardStep()),
        ],
      ),
    );
  }

  Widget _buildWizardStep() {
    switch (_wizardStep) {
      case 0:
        return _WizardChooseType();
      case 1:
        return _WizardSet();
      case 2:
        return _WizardConfirm();
      case 3:
        return _WizardQuestions();
      case 4:
        return _WizardDone();
      default:
        return const SizedBox();
    }
  }

  Widget _WizardChooseType() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Choose a fallback lock method',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
        ),
        const SizedBox(height: 24),
        _WizardOption(
          icon: Icons.pin,
          title: 'PIN Code',
          subtitle: '6-digit numeric PIN',
          selected: _wizardLockType == 'pin',
          onTap: () => setState(() => _wizardLockType = 'pin'),
        ),
        const SizedBox(height: 12),
        _WizardOption(
          icon: Icons.grid_view,
          title: 'Pattern Lock',
          subtitle: 'Draw a pattern on 3x3 grid',
          selected: _wizardLockType == 'pattern',
          onTap: () => setState(() => _wizardLockType = 'pattern'),
        ),
        const SizedBox(height: 32),
        FilledButton(onPressed: _wizardNext, child: const Text('Continue')),
      ],
    );
  }

  Widget _WizardSet() {
    if (_wizardLockType == 'pin') {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Set your 6-digit PIN',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 24),
          _PinDots(length: _newPin.length, error: false),
          const SizedBox(height: 24),
          _PinPad(
            onDigit: (d) {
              if (_newPin.length < 6) setState(() => _newPin += d);
              if (_newPin.length == 6) _wizardNext();
            },
            onDelete: () {
              if (_newPin.isNotEmpty) {
                setState(
                  () => _newPin = _newPin.substring(0, _newPin.length - 1),
                );
              }
            },
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => setState(() { _newPin = ''; _wizardStep = 0; }),
            child: const Text(
              'Back',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
        ],
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Draw your pattern',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 8),
        const Text(
          'Connect at least 4 dots',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 16),
        _PatternGrid(
          selected: _newPattern,
          error: false,
          onDot: (i) {
            if (_newPattern.contains(i)) return;
            HapticFeedback.lightImpact();
            setState(() => _newPattern.add(i));
            if (_newPattern.length >= 4) _wizardNext();
          },
          onCancel: () => setState(() => _newPattern.clear()),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () {
            setState(() { _newPattern.clear(); _wizardStep = 0; });
          },
          child: const Text(
            'Back',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
        ),
      ],
    );
  }

  Widget _WizardConfirm() {
    if (_wizardLockType == 'pin') {
      final mismatch = _confirmPin.length == 6 && _confirmPin != _newPin;
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Confirm your PIN',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 24),
          _PinDots(length: _confirmPin.length, error: mismatch),
          if (mismatch)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'PINs do not match',
                style: TextStyle(color: AppTheme.expense, fontSize: 13),
              ),
            ),
          const SizedBox(height: 24),
          _PinPad(
            onDigit: (d) {
              if (_confirmPin.length < 6) setState(() => _confirmPin += d);
              if (_confirmPin.length == 6 && _confirmPin == _newPin) {
                _wizardNext();
              }
            },
            onDelete: () {
              if (_confirmPin.isNotEmpty) {
                setState(
                  () => _confirmPin = _confirmPin.substring(
                    0, _confirmPin.length - 1,
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              setState(() { _confirmPin = ''; _wizardStep = 1; });
            },
            child: const Text(
              'Back',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
        ],
      );
    }
    final mismatch = _confirmPattern.length >= 4 &&
        _confirmPattern.join(',') != _newPattern.join(',');
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Confirm your pattern',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 8),
        if (mismatch)
          const Text(
            'Patterns do not match',
            style: TextStyle(color: AppTheme.expense, fontSize: 13),
          ),
        const SizedBox(height: 16),
        _PatternGrid(
          selected: _confirmPattern,
          error: mismatch,
          onDot: (i) {
            if (_confirmPattern.contains(i)) return;
            HapticFeedback.lightImpact();
            setState(() => _confirmPattern.add(i));
            if (_confirmPattern.length >= 4 &&
                _confirmPattern.join(',') == _newPattern.join(',')) {
              _wizardNext();
            }
          },
          onCancel: () => setState(() => _confirmPattern.clear()),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () {
            setState(() { _confirmPattern.clear(); _wizardStep = 1; });
          },
          child: const Text(
            'Back',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
        ),
      ],
    );
  }

  Widget _WizardQuestions() {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Set security questions (for PIN recovery)',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _buildQuestionField(
            0, _selectedQ1, _ansCtl1,
            (v) => setState(() => _selectedQ1 = v!),
          ),
          const SizedBox(height: 16),
          _buildQuestionField(
            1, _selectedQ2, _ansCtl2,
            (v) => setState(() => _selectedQ2 = v!),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () {
              if (_ansCtl1.text.trim().isEmpty ||
                  _ansCtl2.text.trim().isEmpty) return;
              _wizardNext();
            },
            child: const Text('Continue'),
          ),
          TextButton(
            onPressed: _wizardNext,
            child: const Text(
              'Skip',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _WizardDone() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.primary.withAlpha(25),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle,
            size: 64,
            color: AppTheme.primary,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Setup Complete!',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Your lock settings have been configured.',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 32),
        FilledButton(
          onPressed: _finishSetup,
          child: const Text('Continue'),
        ),
      ],
    );
  }

  Widget _SecurityDashboardView() {
    final box = ref.read(settingsBoxProvider);
    final failCount = box.get('pin_fail_count', defaultValue: 0) as int;
    final lastTs = box.get('last_unlock_time') as int?;
    final lockEndTs = box.get('lockout_end') as int?;
    final hasPin = (box.get('app_pin') as String?) != null;
    final hasPattern = (box.get('app_pattern') as String?) != null;
    final hasQuestions = (box.get('security_questions') as String?) != null;
    final bio = ref.read(biometricLockProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 16),
          _headerIcon(Icons.security),
          const SizedBox(height: 16),
          const Text(
            'Security Dashboard',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          _DashboardTile(
            icon: Icons.lock_outline,
            title: 'Lock Method',
            value: [
              if (bio) 'Biometric',
              if (hasPin) 'PIN',
              if (hasPattern) 'Pattern',
            ].join(' + '),
          ),
          _DashboardTile(
            icon: Icons.schedule,
            title: 'Last Unlock',
            value: lastTs != null
                ? _formatTime(DateTime.fromMillisecondsSinceEpoch(lastTs))
                : 'N/A',
          ),
          _DashboardTile(
            icon: Icons.error_outline,
            title: 'Failed Attempts',
            value: '$failCount / $_maxFailures',
            valueColor: failCount >= _maxFailures ? AppTheme.expense : null,
          ),
          _DashboardTile(
            icon: Icons.timer_outlined,
            title: 'Lockout Status',
            value: lockEndTs != null &&
                    DateTime.now()
                        .isBefore(DateTime.fromMillisecondsSinceEpoch(lockEndTs))
                ? 'Locked'
                : 'Normal',
            valueColor: lockEndTs != null &&
                    DateTime.now()
                        .isBefore(DateTime.fromMillisecondsSinceEpoch(lockEndTs))
                ? AppTheme.expense
                : AppTheme.income,
          ),
          _DashboardTile(
            icon: Icons.help_outline,
            title: 'Recovery Questions',
            value: hasQuestions ? 'Configured' : 'Not set',
            valueColor: hasQuestions ? AppTheme.income : AppTheme.warning,
          ),
          const SizedBox(height: 24),
          if (hasPin)
            OutlinedButton.icon(
              onPressed: () {
                box.delete('app_pin');
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('PIN removed'),
                    backgroundColor: AppTheme.primary,
                  ),
                );
              },
              icon: const Icon(Icons.delete_outline),
              label: const Text('Remove PIN'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.expense,
                side: const BorderSide(color: AppTheme.expense),
              ),
            ),
          if (hasPattern)
            OutlinedButton.icon(
              onPressed: () {
                box.delete('app_pattern');
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Pattern removed'),
                    backgroundColor: AppTheme.primary,
                  ),
                );
              },
              icon: const Icon(Icons.delete_outline),
              label: const Text('Remove Pattern'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.expense,
                side: const BorderSide(color: AppTheme.expense),
              ),
            ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => setState(() => _mode = _GateMode.pinEntry),
            child: const Text(
              'Back',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${dt.month}/${dt.day} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _PinDots extends StatelessWidget {
  final int length;
  final bool error;
  const _PinDots({required this.length, this.error = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(6, (i) {
        final filled = i < length;
        return Container(
          width: 14,
          height: 14,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled
                ? (error ? AppTheme.expense : AppTheme.primary)
                : AppTheme.cardSurface,
            border: filled
                ? null
                : Border.all(color: AppTheme.border, width: 1),
          ),
        );
      }),
    );
  }
}

class _PinPad extends StatelessWidget {
  final void Function(String) onDigit;
  final VoidCallback onDelete;
  const _PinPad({required this.onDigit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _pinRow(['1', '2', '3']),
        _pinRow(['4', '5', '6']),
        _pinRow(['7', '8', '9']),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 76),
            _pinBtn('0'),
            SizedBox(
              width: 76,
              height: 64,
              child: IconButton(
                onPressed: onDelete,
                icon: const Icon(
                  Icons.backspace_outlined,
                  color: AppTheme.textPrimary,
                ),
                iconSize: 24,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _pinRow(List<String> digits) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: digits.map((d) => _pinBtn(d)).toList(),
    );
  }

  Widget _pinBtn(String digit) {
    return SizedBox(
      width: 76,
      height: 64,
      child: TextButton(
        onPressed: () => onDigit(digit),
        style: TextButton.styleFrom(
          foregroundColor: AppTheme.textPrimary,
          textStyle: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w500,
          ),
          shape: const CircleBorder(),
        ),
        child: Text(digit),
      ),
    );
  }
}

class _PatternGrid extends StatelessWidget {
  final Set<int> selected;
  final bool error;
  final void Function(int) onDot;
  final VoidCallback onCancel;
  const _PatternGrid({
    required this.selected,
    required this.error,
    required this.onDot,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int row = 0; row < 3; row++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int col = 0; col < 3; col++)
                  _buildDot(row * 3 + col),
              ],
            ),
          ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: onCancel,
          icon: const Icon(Icons.refresh, size: 18),
          label: const Text('Clear'),
          style: TextButton.styleFrom(
            foregroundColor: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildDot(int index) {
    final isSelected = selected.contains(index);
    return GestureDetector(
      onTap: () => onDot(index),
      child: Container(
        width: 64,
        height: 64,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected
              ? (error ? AppTheme.expense : AppTheme.primary)
              : Colors.transparent,
          border: Border.all(
            color: isSelected
                ? (error ? AppTheme.expense : AppTheme.primary)
                : AppTheme.border,
            width: isSelected ? 3 : 2,
          ),
        ),
        alignment: Alignment.center,
        child: isSelected
            ? Text(
                '${index + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              )
            : Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.textSecondary,
                ),
              ),
      ),
    );
  }
}

class _DashboardTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color? valueColor;
  const _DashboardTile({
    required this.icon,
    required this.title,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, size: 22, color: AppTheme.primary),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 14,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? AppTheme.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int current;
  final int total;
  const _StepIndicator({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(total, (i) {
        final active = i <= current;
        return Container(
          width: i == current ? 24 : 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: active ? AppTheme.primary : AppTheme.cardSurface,
          ),
        );
      }),
    );
  }
}

class _WizardOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;
  const _WizardOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.selected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.primary.withAlpha(20)
              : AppTheme.cardSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppTheme.primary : AppTheme.border,
            width: selected ? 1.5 : 0.5,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.primary, size: 32),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

