import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/ai_service.dart';
import '../services/pantry_service.dart';
import '../models/user_preferences.dart';
import '../widgets/animated_gradient_background.dart';
import '../widgets/glass_container.dart';

/// AI Assistant Chat Screen
/// Provides conversational AI interface for pantry management
class AIAssistantScreen extends StatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> {
  final AIService _aiService = AIService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _currentMood;
  String? _currentFoodPreference;
  bool _inMoodConversation = false;
  UserPreferences? _userPreferences;

  @override
  void initState() {
    super.initState();
    _initializeAI();
    _loadUserPreferences();
    _addWelcomeMessage();
  }

  Future<void> _initializeAI() async {
    await _aiService.initialize();
  }

  Future<void> _loadUserPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final prefsJson = prefs.getString('user_preferences');
      if (prefsJson != null) {
        setState(() {
          _userPreferences = UserPreferences.fromJson(jsonDecode(prefsJson));
        });
      }
    } catch (e) {
      // Preferences not set yet, that's okay
    }
  }

  void _addWelcomeMessage() {
    String welcomeText = '👋 Hi! I\'m your AI pantry assistant and friend. I can help with recipes, pantry management, or just chat about how you\'re feeling today! How can I help?';
    
    if (_userPreferences != null && _userPreferences!.hasRestrictions()) {
      welcomeText += '\n\n✨ I see you have dietary preferences set. I\'ll make sure all recipe suggestions respect your needs!';
    }

    setState(() {
      _messages.add(ChatMessage(
        text: welcomeText,
        isUser: false,
        timestamp: DateTime.now(),
        suggestions: [
          '😊 Let\'s talk about my mood',
          '🍳 Show recipes',
          '📦 Check expiring items',
          '💡 Storage tips',
        ],
      ));
    });
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Add user message
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isLoading = true;
    });

    _messageController.clear();
    _scrollToBottom();

    // Get AI response
    try {
      final pantryService = Provider.of<PantryService>(context, listen: false);
      final items = pantryService.items;

      // Check if user wants to start mood conversation
      if (text.toLowerCase().contains('mood') || 
          text.toLowerCase().contains('feeling') ||
          text.toLowerCase().contains('how am i') ||
          text.toLowerCase().contains('talk about')) {
        final response = await _aiService.startMoodConversation();
        setState(() {
          _inMoodConversation = true;
          _messages.add(ChatMessage(
            text: response.message,
            isUser: false,
            timestamp: DateTime.now(),
            suggestions: response.suggestions,
            action: response.action,
          ));
          _isLoading = false;
        });
        _scrollToBottom();
        return;
      }

      // Handle mood response
      if (_inMoodConversation && _currentMood == null) {
        final response = await _aiService.respondToMood(text, items);
        setState(() {
          _currentMood = text;
          _messages.add(ChatMessage(
            text: response.message,
            isUser: false,
            timestamp: DateTime.now(),
            suggestions: response.suggestions,
            action: response.action,
          ));
          _isLoading = false;
        });
        _scrollToBottom();
        return;
      }

      // Handle food preference and show recipes
      if (_inMoodConversation && _currentMood != null && _currentFoodPreference == null) {
        setState(() {
          _currentFoodPreference = text;
          _isLoading = true;
        });

        final recipeResponse = await _aiService.getMoodBasedRecipes(
          _currentMood!,
          text,
          items,
          userPreferences: _userPreferences,
        );

        setState(() {
          // Add the message
          _messages.add(ChatMessage(
            text: '${recipeResponse.message}\n\n${recipeResponse.moodMessage}',
            isUser: false,
            timestamp: DateTime.now(),
            suggestions: [],
          ));

          // Add each recipe as a separate message
          for (final recipe in recipeResponse.recipes) {
            _messages.add(ChatMessage(
              text: '${recipe.emoji} **${recipe.name}**\n\n'
                  '${recipe.description}\n\n'
                  '💡 *${recipe.moodBoost}*\n\n'
                  '⏱️ Prep time: ${recipe.prepTime} mins | Difficulty: ${recipe.difficulty}\n\n'
                  '**Ingredients:**\n${recipe.ingredients.map((i) => '• $i').join('\n')}\n\n'
                  '**Instructions:**\n${recipe.instructions}',
              isUser: false,
              timestamp: DateTime.now(),
              suggestions: [],
            ));
          }

          // Add continuation message
          if (recipeResponse.conversationContinuation != null) {
            _messages.add(ChatMessage(
              text: recipeResponse.conversationContinuation!,
              isUser: false,
              timestamp: DateTime.now(),
              suggestions: [
                'Tell me more about one',
                'Start over with new mood',
                'Thanks, that helps!',
                'Just keep chatting'
              ],
            ));
          }

          // Reset conversation state
          _inMoodConversation = false;
          _currentMood = null;
          _currentFoodPreference = null;
          _isLoading = false;
        });
        _scrollToBottom();
        return;
      }

      // Regular chat
      final response = await _aiService.chat(text, items);

      setState(() {
        _messages.add(ChatMessage(
          text: response.message,
          isUser: false,
          timestamp: DateTime.now(),
          suggestions: response.suggestions,
          action: response.action,
        ));
        _isLoading = false;
      });

      _scrollToBottom();
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          text: 'Sorry, I encountered an error. Please try again.',
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated gradient background
          const AnimatedGradientBackground(theme: GradientTheme.green),

          // Content
          SafeArea(
            child: Column(
              children: [
                // Custom app bar
                _buildAppBar(),

                // Chat messages
                Expanded(
                  child: _buildMessageList(),
                ),

                // Input field
                _buildInputField(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: GlassContainer(
              blur: 10,
              opacity: 0.2,
              borderRadius: 12,
              child: const Padding(
                padding: EdgeInsets.all(12.0),
                child: Icon(Icons.arrow_back, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI Assistant',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _aiService.isAIEnabled ? 'Online' : 'Offline',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          GlassContainer(
            blur: 10,
            opacity: 0.2,
            borderRadius: 12,
            child: IconButton(
              onPressed: () {
                // Show AI settings
                _showAISettings();
              },
              icon: const Icon(Icons.settings, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _messages.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _messages.length && _isLoading) {
          return _buildLoadingIndicator();
        }

        final message = _messages[index];
        return _buildMessageBubble(message);
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment:
            message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: message.isUser
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: [
              if (!message.isUser)
                Container(
                  width: 40,
                  height: 40,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Colors.green.shade400, Colors.blue.shade400],
                    ),
                  ),
                  child: const Icon(Icons.smart_toy, color: Colors.white),
                ),
              Flexible(
                child: GlassContainer(
                  blur: 10,
                  opacity: message.isUser ? 0.3 : 0.2,
                  borderRadius: 16,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      message.text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
              if (message.isUser)
                Container(
                  width: 40,
                  height: 40,
                  margin: const EdgeInsets.only(left: 12),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white24,
                  ),
                  child: const Icon(Icons.person, color: Colors.white),
                ),
            ],
          ),

          // Suggestions
          if (message.suggestions != null && message.suggestions!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: message.suggestions!.map((suggestion) {
                  return GestureDetector(
                    onTap: () => _sendMessage(suggestion),
                    child: GlassContainer(
                      blur: 10,
                      opacity: 0.2,
                      borderRadius: 20,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Text(
                          suggestion,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Colors.green.shade400, Colors.blue.shade400],
              ),
            ),
            child: const Icon(Icons.smart_toy, color: Colors.white),
          ),
          GlassContainer(
            blur: 10,
            opacity: 0.2,
            borderRadius: 16,
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Thinking...',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField() {
    return GlassContainer(
      blur: 15,
      opacity: 0.2,
      borderRadius: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: TextField(
                  controller: _messageController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Ask me anything about your pantry...',
                    hintStyle: TextStyle(color: Colors.white60),
                    border: InputBorder.none,
                  ),
                  textInputAction: TextInputAction.send,
                  onSubmitted: _sendMessage,
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () => _sendMessage(_messageController.text),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Colors.green.shade400, Colors.blue.shade400],
                  ),
                ),
                child: const Icon(Icons.send, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAISettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return GlassContainer(
          blur: 20,
          opacity: 0.3,
          borderRadius: 24,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI Settings',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                SwitchListTile(
                  title: const Text(
                    'Enable AI Features',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    'Turn on/off AI assistance',
                    style: TextStyle(color: Colors.white.withOpacity(0.7)),
                  ),
                  value: _aiService.isAIEnabled,
                  onChanged: (value) async {
                    await _aiService.setAIEnabled(value);
                    setState(() {});
                    Navigator.pop(context);
                  },
                  activeColor: Colors.green,
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.info_outline, color: Colors.white),
                  title: const Text(
                    'About AI Assistant',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    'Powered by advanced AI to help manage your pantry',
                    style: TextStyle(color: Colors.white.withOpacity(0.7)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<String>? suggestions;
  final String? action;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.suggestions,
    this.action,
  });
}
