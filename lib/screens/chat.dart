// ✅ Ajout d'une popup animée après un signalement

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatScreen extends StatefulWidget {
  final IO.Socket socket;
  final String partnerId;
  final String mood;

  ChatScreen({required this.socket, required this.partnerId, required this.mood});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _reportController = TextEditingController();
  List<Map<String, dynamic>> messages = [];
  bool feedbackShown = false;
  bool isQuitter = false;
  String? welcomeMessage;

  final List<String> welcomeMessages = [
    "🤝 Prenez soin de vous et de l’autre. Ici, l’écoute et le respect sont essentiels.",
    "💬 Vous êtes en lien avec quelqu’un qui ressent la même chose. Parlez librement, avec bienveillance.",
    "🫶 Cet espace est là pour s’exprimer sans jugement. Vous n’êtes pas seul(e).",
    "🌱 Un échange sincère peut faire du bien, à vous deux. Merci d’être là.",
    "🧠 Chacun avance à son rythme. Laissez parler vos émotions, avec douceur.",
    "👂 Ici, on s’écoute. Merci de respecter l’autre personne comme vous aimeriez l’être.",
    "🌈 Ce moment est à vous deux. Soyez authentique, soyez attentionné."
  ];

  @override
  void initState() {
    super.initState();
    final rng = Random();
    welcomeMessage = welcomeMessages[rng.nextInt(welcomeMessages.length)];

    widget.socket.on('message', (data) {
      setState(() {
        messages.add({'text': data['text'], 'fromMe': false});
      });
    });

    widget.socket.on('disconnect_notice', (data) {
      if (data['from'] == widget.partnerId && !feedbackShown) {
        showAnimatedFeedbackPopup(false);
      }
    });

    widget.socket.on('reported_notice', (_) {
      showGeneralDialog(
        context: context,
        barrierDismissible: false,
        barrierLabel: "Signalé",
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, __, ___) {
          return Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Material(
                color: Colors.transparent,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "🚨 Vous avez été signalé(e)",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Vous allez être redirigé(e) vers le menu principal.",
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      },
                      icon: const Icon(Icons.home),
                      label: const Text("Retour au menu"),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        transitionBuilder: (_, anim, __, child) {
          return ScaleTransition(
            scale: CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
            child: child,
          );
        },
      );
    });
  }

  @override
  void dispose() {
    widget.socket.off('message');
    widget.socket.off('disconnect_notice');
    _reportController.dispose();
    super.dispose();
  }

  void sendMessage() {
    String text = _controller.text.trim();
    if (text.isNotEmpty) {
      widget.socket.emit('message', {
        'to': widget.partnerId,
        'text': text,
      });
      setState(() {
        messages.add({'text': text, 'fromMe': true});
      });
      _controller.clear();
    }
  }

  void showAnimatedFeedbackPopup(bool isQuitterUser) {
    setState(() {
      feedbackShown = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Color(0xFF1A1A1A),
        title: Text("Donnez votre avis", style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Cet échange vous a-t-il fait du bien ?", style: TextStyle(color: Colors.white70)),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                feedbackChoice("Oui", isQuitterUser),
                feedbackChoice("Bof", isQuitterUser),
                feedbackChoice("Pas vraiment", isQuitterUser),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget feedbackChoice(String label, bool isQuitterUser) {
    return TextButton(
      onPressed: () {
        widget.socket.emit('feedback', {'mood': widget.mood, 'choice': label});
        if (isQuitterUser) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        } else {
          Navigator.of(context).pop();
          Navigator.of(context).pushReplacementNamed('/waiting', arguments: {'mood': widget.mood});
        }
      },
      child: Text(label, style: TextStyle(color: Colors.deepPurpleAccent)),
    );
  }

  void quitConversationToMenu() {
    widget.socket.emit('left');
    isQuitter = true;
    Future.delayed(Duration(milliseconds: 100), () => showAnimatedFeedbackPopup(true));
  }

  void restartConversation() {
    widget.socket.emit('left');
    Navigator.of(context).pushReplacementNamed('/waiting', arguments: {'mood': widget.mood});
  }

  void reportPartner() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Color(0xFF1A1A1A),
        title: Text("🚨 Signaler l'utilisateur", style: TextStyle(color: Colors.redAccent)),
        content: TextField(
          controller: _reportController,
          maxLines: 4,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Décrivez ce qui s'est passé...",
            hintStyle: TextStyle(color: Colors.white38),
            filled: true,
            fillColor: Colors.black26,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              final reason = _reportController.text.trim();
              if (reason.isNotEmpty) {
                widget.socket.emit('report', {
                  'partnerId': widget.partnerId,
                  'reason': reason,
                  'mood': widget.mood,
                });
                Navigator.of(context).pop();
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    backgroundColor: Color(0xFF1A1A1A),
                    title: Text("❗ Signalement envoyé", style: TextStyle(color: Colors.redAccent)),
                    content: Text("Merci. Nous prenons votre signalement en compte.", style: TextStyle(color: Colors.white70)),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
                        child: Text("Menu", style: TextStyle(color: Colors.white)),
                      ),
                      TextButton(
                        onPressed: restartConversation,
                        child: Text("Nouveau Chat", style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  )
                );
              }
            },
            child: Text("Envoyer", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Color(0xFF0D0D0D),
        elevation: 0,
        leading: Container(),
        title: Column(
          children: [
            Text('MoodPair', style: TextStyle(color: Colors.white)),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(getEmoji(widget.mood), style: TextStyle(fontSize: 16)),
                SizedBox(width: 6),
                Text(widget.mood, style: TextStyle(color: Colors.white54)),
              ],
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.report_problem_rounded, color: Colors.redAccent),
            onPressed: reportPartner,
          ),
          IconButton(
            icon: Icon(Icons.home_rounded, color: Colors.white),
            onPressed: quitConversationToMenu,
          ),
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: restartConversation,
          ),
        ],
      ),
      body: Column(
        children: [
          if (welcomeMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Text(
                welcomeMessage!,
                style: TextStyle(color: Colors.white60, fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
            ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemCount: messages.length,
              itemBuilder: (_, index) {
                final msg = messages[index];
                return Align(
                  alignment: msg['fromMe'] ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 6),
                    padding: EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: msg['fromMe'] ? Color(0xFF7C4DFF) : Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(msg['text'], style: TextStyle(color: Colors.white)),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Color(0xFF0D0D0D),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Envoyer un message',
                      hintStyle: TextStyle(color: Colors.white38),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Color(0xFF1E1E1E),
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                GestureDetector(
                  onTap: sendMessage,
                  child: CircleAvatar(
                    backgroundColor: Colors.deepPurpleAccent,
                    child: Icon(Icons.send, color: Colors.white),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  String getEmoji(String mood) {
    switch (mood.toLowerCase()) {
      case 'heureux': return '😊';
      case 'triste': return '😢';
      case 'frustré': return '😠';
      case 'énergique': return '⚡️';
      case 'blessé': return '💔';
      case 'besoin de parler': return '💬';
      default: return '🙂';
    }
  }
}
