import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../themes/app_theme.dart';

class VoiceInputButton extends StatefulWidget {
  final Function(String) onTextRecognized;
  final VoidCallback? onListeningStarted;
  final VoidCallback? onListeningStopped;
  final bool isEnabled;

  const VoiceInputButton({
    super.key,
    required this.onTextRecognized,
    this.onListeningStarted,
    this.onListeningStopped,
    this.isEnabled = true,
  });

  @override
  State<VoiceInputButton> createState() => _VoiceInputButtonState();
}

class _VoiceInputButtonState extends State<VoiceInputButton>
    with SingleTickerProviderStateMixin {
  late stt.SpeechToText _speech;
  late FlutterTts _flutterTts;
  bool _isListening = false;
  bool _isAvailable = false;
  String _currentLocaleId = '';
  double _confidence = 1.0;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _flutterTts = FlutterTts();
    _initializeSpeech();
    _initializeTTS();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    _speech.stop();
    _flutterTts.stop();
    super.dispose();
  }

  Future<void> _initializeSpeech() async {
    try {
      _isAvailable = await _speech.initialize(
        onStatus: _onSpeechStatus,
        onError: _onSpeechError,
        debugLogging: false,
      );

      if (_isAvailable) {
        final locales = await _speech.locales();
        // Priorité aux locales françaises
        final frenchLocale = locales.firstWhere(
          (locale) => locale.localeId.startsWith('fr'),
          orElse: () => locales.first,
        );
        _currentLocaleId = frenchLocale.localeId;
      }
    } catch (e) {
      debugPrint('Erreur d\'initialisation de la reconnaissance vocale: $e');
    }

    setState(() {});
  }

  Future<void> _initializeTTS() async {
    await _flutterTts.setLanguage('fr-FR');
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  void _onSpeechStatus(String status) {
    debugPrint('Speech status: $status');
    if (status == 'listening') {
      setState(() => _isListening = true);
      _animationController.repeat(reverse: true);
      widget.onListeningStarted?.call();
    } else if (status == 'notListening' || status == 'done') {
      setState(() => _isListening = false);
      _animationController.stop();
      _animationController.reset();
      widget.onListeningStopped?.call();
    }
  }

  void _onSpeechError(dynamic error) {
    debugPrint('Speech error: $error');
    setState(() => _isListening = false);
    _animationController.stop();
    _animationController.reset();
    widget.onListeningStopped?.call();

    // Afficher un message d'erreur à l'utilisateur
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur de reconnaissance vocale: ${error.errorMsg ?? error}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permission microphone requise pour la reconnaissance vocale'),
            action: SnackBarAction(
              label: 'Paramètres',
              onPressed: openAppSettings,
            ),
          ),
        );
      }
    }
  }

  Future<void> _toggleListening() async {
    if (!widget.isEnabled || !_isAvailable) return;

    if (_isListening) {
      await _speech.stop();
      return;
    }

    // Demander la permission si nécessaire
    await _requestMicrophonePermission();

    await _speech.listen(
      onResult: (result) {
        setState(() {
          _confidence = result.confidence;
        });

        if (result.finalResult) {
          final recognizedText = result.recognizedWords;
          if (recognizedText.isNotEmpty) {
            widget.onTextRecognized(recognizedText);
          }
        }
      },
      localeId: _currentLocaleId,
      listenMode: stt.ListenMode.confirmation,
      partialResults: true,
      cancelOnError: true,
      listenFor: const Duration(seconds: 30),
    );
  }

  Future<void> _speakText(String text) async {
    await _flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAvailable) {
      return _buildDisabledButton();
    }

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _isListening ? _scaleAnimation.value : 1.0,
          child: Opacity(
            opacity: _isListening ? _pulseAnimation.value : 1.0,
            child: _buildVoiceButton(),
          ),
        );
      },
    );
  }

  Widget _buildVoiceButton() {
    return GestureDetector(
      onTap: widget.isEnabled ? _toggleListening : null,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: _isListening
              ? AppColors.errorGradient
              : AppColors.primaryGradient,
          boxShadow: [
            BoxShadow(
              color: (_isListening ? AppColors.error : AppColors.primary).withOpacity(0.3),
              blurRadius: _isListening ? 16 : 12,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 2,
          ),
        ),
        child: Icon(
          _isListening ? Icons.mic_off : Icons.mic,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildDisabledButton() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.textSecondary.withOpacity(0.3),
        border: Border.all(
          color: AppColors.textSecondary.withOpacity(0.2),
          width: 2,
        ),
      ),
      child: const Icon(
        Icons.mic_off,
        color: AppColors.textSecondary,
        size: 28,
      ),
    );
  }
}

// Widget pour lire les réponses de l'IA à voix haute
class TextToSpeechButton extends StatefulWidget {
  final String text;
  final bool isEnabled;

  const TextToSpeechButton({
    super.key,
    required this.text,
    this.isEnabled = true,
  });

  @override
  State<TextToSpeechButton> createState() => _TextToSpeechButtonState();
}

class _TextToSpeechButtonState extends State<TextToSpeechButton> {
  late FlutterTts _flutterTts;
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _flutterTts = FlutterTts();
    _initializeTTS();
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  Future<void> _initializeTTS() async {
    await _flutterTts.setLanguage('fr-FR');
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);

    _flutterTts.setStartHandler(() {
      setState(() => _isSpeaking = true);
    });

    _flutterTts.setCompletionHandler(() {
      setState(() => _isSpeaking = false);
    });

    _flutterTts.setErrorHandler((msg) {
      setState(() => _isSpeaking = false);
      debugPrint('TTS Error: $msg');
    });
  }

  Future<void> _toggleSpeech() async {
    if (!widget.isEnabled || widget.text.isEmpty) return;

    if (_isSpeaking) {
      await _flutterTts.stop();
      return;
    }

    await _flutterTts.speak(widget.text);
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: widget.isEnabled && widget.text.isNotEmpty ? _toggleSpeech : null,
      icon: Icon(
        _isSpeaking ? Icons.volume_off : Icons.volume_up,
        color: widget.isEnabled && widget.text.isNotEmpty
            ? AppColors.secondary
            : AppColors.textSecondary,
        size: 24,
      ),
      tooltip: _isSpeaking ? 'Arrêter la lecture' : 'Lire à voix haute',
    );
  }
}