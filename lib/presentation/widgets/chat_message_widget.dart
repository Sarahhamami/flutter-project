import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../themes/app_theme.dart';
import '../providers/ai_coach_provider.dart';
import 'voice_input_button.dart';

class ChatMessageWidget extends StatelessWidget {
  final ChatMessage message;
  final bool showTimestamp;
  final VoidCallback? onCopy;
  final VoidCallback? onFeedback;

  const ChatMessageWidget({
    super.key,
    required this.message,
    this.showTimestamp = true,
    this.onCopy,
    this.onFeedback,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) _buildAvatar(),
          const SizedBox(width: 12),
          Flexible(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                _buildMessageBubble(context, theme),
                if (showTimestamp) _buildTimestamp(theme),
                if (!isUser && message.type != 'error') _buildActions(context),
              ],
            ),
          ),
          if (isUser) _buildAvatar(),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slide(begin: const Offset(0, 0.2), end: Offset.zero, duration: 300.ms);
  }

  Widget _buildAvatar() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: message.isUser
            ? AppColors.primaryGradient
            : AppColors.secondaryGradient,
        boxShadow: [
          BoxShadow(
            color: (message.isUser ? AppColors.primary : AppColors.secondary).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(
        message.isUser ? Icons.person : Icons.smart_toy,
        color: Colors.white,
        size: 20,
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context, ThemeData theme) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: message.isUser
            ? AppColors.primary
            : AppColors.glassBackground,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: message.isUser ? const Radius.circular(18) : const Radius.circular(4),
          bottomRight: message.isUser ? const Radius.circular(4) : const Radius.circular(18),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: message.isUser
              ? Colors.transparent
              : AppColors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: _buildMessageContent(theme),
    );
  }

  Widget _buildMessageContent(ThemeData theme) {
    final textColor = message.isUser ? Colors.white : AppColors.textPrimary;

    switch (message.type) {
      case 'meal_plan':
        return _buildMealPlanContent(textColor);
      case 'analysis':
        return _buildAnalysisContent(textColor);
      case 'error':
        return _buildErrorContent(textColor);
      default:
        return _buildTextContent(textColor);
    }
  }

  Widget _buildTextContent(Color textColor) {
    return SelectableText(
      message.content,
      style: TextStyle(
        color: textColor,
        fontSize: 16,
        height: 1.4,
      ),
      textAlign: TextAlign.left,
    );
  }

  Widget _buildMealPlanContent(Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.restaurant_menu,
              color: AppColors.secondary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Plan Alimentaire',
              style: TextStyle(
                color: AppColors.secondary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SelectableText(
          message.content,
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildAnalysisContent(Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.analytics,
              color: AppColors.accent,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Analyse Nutritionnelle',
              style: TextStyle(
                color: AppColors.accent,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SelectableText(
          message.content,
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorContent(Color textColor) {
    return Row(
      children: [
        Icon(
          Icons.error_outline,
          color: AppColors.error,
          size: 20,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            message.content,
            style: TextStyle(
              color: AppColors.error,
              fontSize: 16,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimestamp(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        _formatTimestamp(message.timestamp),
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextToSpeechButton(
            text: message.content,
            isEnabled: !message.isUser,
          ),
          const SizedBox(width: 8),
          _buildActionButton(
            context,
            icon: Icons.copy,
            label: 'Copier',
            onTap: () {
              Clipboard.setData(ClipboardData(text: message.content));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Message copié dans le presse-papiers'),
                  duration: Duration(seconds: 2),
                ),
              );
              onCopy?.call();
            },
          ),
          const SizedBox(width: 8),
          _buildActionButton(
            context,
            icon: Icons.thumb_up,
            label: 'Utile',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Merci pour votre retour !'),
                  duration: Duration(seconds: 2),
                ),
              );
              onFeedback?.call();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.glassBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${timestamp.day}/${timestamp.month} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else if (difference.inHours > 0) {
      return 'il y a ${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return 'il y a ${difference.inMinutes}min';
    } else {
      return 'à l\'instant';
    }
  }
}