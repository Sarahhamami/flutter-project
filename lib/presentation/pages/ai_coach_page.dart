import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../presentation/providers/ai_coach_provider.dart';
import '../../presentation/widgets/chat_message_widget.dart';
import '../../presentation/widgets/voice_input_button.dart';
import '../../presentation/widgets/meal_plan_card.dart';
import '../../presentation/widgets/error_message_widget.dart';
import '../../core/models/ai_response.dart';
import '../../core/config/api_config.dart';
import '../pages/api_config_page.dart';
import '../../themes/app_theme.dart';
import '../../widgets/modern_button.dart';
import '../../widgets/modern_card.dart';

class AICoachPage extends StatefulWidget {
  const AICoachPage({super.key});

  @override
  State<AICoachPage> createState() => _AICoachPageState();
}

class _AICoachPageState extends State<AICoachPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    // Initialiser le provider AI Coach
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AICoachProvider>()..clearConversation();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Coach IA Nutritionnel'),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.darkGrey,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _showOptionsMenu,
            icon: Icon(
              Icons.more_vert,
              color: AppColors.darkGrey,
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.secondaryGradient,
        ),
        child: Consumer<AICoachProvider>(
          builder: (context, aiProvider, child) {
            return Column(
              children: [
                // Zone de chat
                Expanded(
                  child: _buildChatArea(aiProvider),
                ),

                // Suggestions rapides
                if (aiProvider.suggestedQuestions.isNotEmpty)
                  _buildQuickSuggestions(aiProvider),

                // Zone de saisie
                _buildInputArea(aiProvider),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildChatArea(AICoachProvider aiProvider) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 100, 16, 16),
      child: aiProvider.messages.isEmpty
          ? _buildWelcomeMessage()
          : _buildMessagesList(aiProvider),
    );
  }

  Widget _buildWelcomeMessage() {
    return FutureBuilder<bool>(
      future: _checkApiKeyConfigured(),
      builder: (context, snapshot) {
        final hasApiKey = snapshot.data ?? false;

        if (!hasApiKey) {
          return _buildApiKeyRequiredMessage();
        }

        return AnimationLimiter(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: AnimationConfiguration.toStaggeredList(
              duration: const Duration(milliseconds: 800),
              childAnimationBuilder: (widget) => SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(child: widget),
              ),
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.smart_toy,
                    color: Colors.white,
                    size: 64,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Bienvenue dans votre Coach IA !',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkGrey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Je suis là pour vous aider à atteindre vos objectifs nutritionnels.\nPosez-moi vos questions ou demandez-moi de générer un plan alimentaire personnalisé.',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.grey,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Text(
                  '💡 Essayez de dire :',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildExampleChip('Génère un plan pour la semaine'),
                    _buildExampleChip('Comment augmenter mes protéines ?'),
                    _buildExampleChip('Analyse mes habitudes'),
                    _buildExampleChip('Quels sont les meilleurs snacks ?'),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildApiKeyRequiredMessage() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: ErrorMessageWidget(
        errorType: ErrorType.missingApiKey,
        customMessage: 'Pour utiliser le coach IA, vous devez d\'abord configurer votre clé API Gemini. C\'est gratuit et prend moins de 2 minutes !',
      ),
    );
  }

  Future<bool> _checkApiKeyConfigured() async {
    try {
      final key = await ApiConfig.getGeminiApiKey();
      return key != null && key.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Widget _buildExampleChip(String text) {
    return InkWell(
      onTap: () => _sendMessage(text),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildMessagesList(AICoachProvider aiProvider) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: aiProvider.messages.length,
      itemBuilder: (context, index) {
        final message = aiProvider.messages[index];
        return AnimationConfiguration.staggeredList(
          position: index,
          duration: const Duration(milliseconds: 400),
          child: SlideAnimation(
            verticalOffset: 50.0,
            child: FadeInAnimation(
              child: message.type == 'meal_plan'
                  ? MealPlanCard(message: message)
                  : ChatMessageWidget(
                      message: message,
                      showTimestamp: true,
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickSuggestions(AICoachProvider aiProvider) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: aiProvider.suggestedQuestions.length,
        itemBuilder: (context, index) {
          final question = aiProvider.suggestedQuestions[index];
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 300),
            child: SlideAnimation(
              horizontalOffset: 50.0,
              child: FadeInAnimation(
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: QuickQuestionCard(
                    question: question,
                    onTap: () => _sendMessage(question),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputArea(AICoachProvider aiProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.95),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          if (aiProvider.isLoading)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Le coach IA réfléchit...',
                    style: TextStyle(
                      color: AppColors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

          if (aiProvider.error != null)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.error.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: AppColors.error,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      aiProvider.error!,
                      style: TextStyle(
                        color: AppColors.error,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => aiProvider.clearError(),
                    icon: Icon(
                      Icons.close,
                      color: AppColors.error,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),

          if (aiProvider.isRateLimited)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.accent.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.timer,
                    color: AppColors.accent,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Trop de requêtes. Veuillez patienter avant de continuer.',
                      style: TextStyle(
                        color: AppColors.accent,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.lightGrey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: AppColors.white.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Posez votre question au coach IA...',
                      hintStyle: TextStyle(
                        color: AppColors.grey,
                        fontSize: 16,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    style: TextStyle(
                      color: AppColors.darkGrey,
                      fontSize: 16,
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (text) {
                      if (text.trim().isNotEmpty) {
                        _sendMessage(text);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              VoiceInputButton(
                onTextRecognized: _sendMessage,
                isEnabled: !aiProvider.isLoading,
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: aiProvider.isLoading || _messageController.text.trim().isEmpty
                      ? null
                      : () => _sendMessage(_messageController.text),
                  icon: Icon(
                    Icons.send,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    _messageController.clear();
    await context.read<AICoachProvider>().sendMessage(text.trim());
  }

  void _showOptionsMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ModernCard(
        borderRadius: 20,
        margin: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                Icons.restaurant_menu,
                color: AppColors.primary,
              ),
              title: const Text('Générer un plan alimentaire'),
              onTap: () {
                Navigator.pop(context);
                context.read<AICoachProvider>().generateMealPlan();
              },
            ),
            ListTile(
              leading: Icon(
                Icons.analytics,
                color: AppColors.secondary,
              ),
              title: const Text('Analyser mes habitudes'),
              onTap: () {
                Navigator.pop(context);
                context.read<AICoachProvider>().analyzeHabits();
              },
            ),
            ListTile(
              leading: Icon(
                Icons.settings,
                color: AppColors.accent,
              ),
              title: const Text('Configuration API'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ApiConfigPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(
                Icons.clear_all,
                color: AppColors.grey,
              ),
              title: const Text('Effacer la conversation'),
              onTap: () {
                Navigator.pop(context);
                context.read<AICoachProvider>().clearConversation();
              },
            ),
          ],
        ),
      ),
    );
  }
}