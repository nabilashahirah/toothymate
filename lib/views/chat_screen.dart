// ignore_for_file: deprecated_member_use

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart'; // <--- 1. IMPORT CONFETTI
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';

// --- THEME COLORS ---
class AppColors {
  static const Color primaryBlue = Color(0xFF4FC3F7);
  static const Color primaryDarkBlue = Color(0xFF0288D1);
  static const Color background = Color(0xFFE1F5FE);
  static const Color myBubble = Color(0xFF2196F3);
  static const Color botBubble = Color(0xFFFFFFFF);
  static const Color accentOrange = Color(0xFFFF9800);
  static const Color darkText = Color(0xFF01579B); 
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late ConfettiController _confettiController; // <--- 2. CONFETTI CONTROLLER
  
  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChatProvider()..init(),
      child: Consumer<ChatProvider>(
        builder: (context, provider, child) {
          // Handle Confetti Trigger
          if (provider.shouldCelebrate) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _confettiController.play();
              provider.resetCelebrate();
            });
          }

          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              flexibleSpace: Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [AppColors.primaryBlue, AppColors.primaryDarkBlue]))),
              title: Row(
                children: [
                  // 🔥 ANIMATED ICON
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                    child: Icon(provider.botIcon, key: ValueKey(provider.botIcon), color: provider.botIconColor, size: 30),
                  ),
                  const SizedBox(width: 10),
                  const Text("Dr. Tooth Bot", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                ],
              ),
              actions: [
                // 🧹 CLEAR CHAT BUTTON
                IconButton(
                  icon: const Icon(Icons.delete_sweep_rounded, color: Colors.white),
                  onPressed: provider.clearChat,
                  tooltip: "Clear Chat",
                ),
              ],
              leading: const BackButton(color: Colors.white),
            ),
            body: Stack(
              children: [
                Column(
                  children: [
                    // MESSAGES LIST
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(15),
                        itemCount: provider.messages.length + (provider.isTyping ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == provider.messages.length) {
                            return _buildTypingIndicator();
                          }
                          final msg = provider.messages[index];
                          return _buildMessageBubble(msg['text']!, msg['sender'] == 'user');
                        },
                      ),
                    ),
                    
                    // --- 🔥 COLORFUL CHIPS ---
                    SizedBox(
                      height: 50,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        itemCount: provider.quickQuestions.length,
                        itemBuilder: (context, index) {
                          final q = provider.quickQuestions[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ActionChip(
                              label: Text(q['label'], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                              backgroundColor: q['color'], // <--- CANDY COLORS
                              elevation: 2,
                              side: BorderSide.none,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              onPressed: () {
                                provider.handleSubmitted(q['label']);
                                _scrollToBottom();
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),

                    // INPUT FIELD
                    Container(
                      padding: const EdgeInsets.all(10),
                      color: Colors.white,
                      child: SafeArea(
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _textController,
                                decoration: InputDecoration(
                                  hintText: "Ask me / Tanya saya...",
                                  filled: true, fillColor: AppColors.background,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                                ),
                                onSubmitted: (text) {
                                  provider.handleSubmitted(text);
                                  _textController.clear();
                                  _scrollToBottom();
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            FloatingActionButton(
                              mini: true, 
                              backgroundColor: AppColors.accentOrange, 
                              onPressed: () {
                                provider.handleSubmitted(_textController.text);
                                _textController.clear();
                                _scrollToBottom();
                              }, 
                              child: const Icon(Icons.send_rounded, color: Colors.white)
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                
                // 🔥 CONFETTI OVERLAY (Hidden until triggered)
                Align(
                  alignment: Alignment.topCenter,
                  child: ConfettiWidget(
                    confettiController: _confettiController,
                    blastDirectionality: BlastDirectionality.explosive,
                    shouldLoop: false,
                    colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange],
                  ),
                ),
              ],
            ),
          );
        }
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isUser ? AppColors.myBubble : AppColors.botBubble,
          borderRadius: BorderRadius.only(topLeft: const Radius.circular(20), topRight: const Radius.circular(20), bottomLeft: isUser ? const Radius.circular(20) : Radius.zero, bottomRight: isUser ? Radius.zero : const Radius.circular(20)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))],
        ),
        child: Text(text, style: TextStyle(color: isUser ? Colors.white : AppColors.primaryDarkBlue, fontSize: 15)),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        decoration: BoxDecoration(
          color: AppColors.botBubble,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
            bottomLeft: Radius.zero,
          ),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))],
        ),
        child: const _TypingDots(),
      ),
    );
  }
}

class _TypingDots extends StatefulWidget {
  const _TypingDots();

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(3, (index) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Opacity(
                opacity: (math.sin((_controller.value * 2 * math.pi) + (index * 1.0)) + 1) / 2 * 0.5 + 0.3,
                child: const CircleAvatar(radius: 3, backgroundColor: Colors.grey),
              );
            },
          );
        }),
      ),
    );
  }
}