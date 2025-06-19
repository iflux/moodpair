// ✅ main.dart avec passage de mood et socket vers tous les écrans

import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'screens/mood_selector.dart';
import 'screens/mood_waiting.dart';
import 'screens/chat.dart';

late IO.Socket socket;

void main() {
  socket = IO.io('http://10.188.142.11:3000', IO.OptionBuilder()
      .setTransports(['websocket'])
      .disableAutoConnect()
      .build());

  socket.connect();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MoodPair',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        final args = settings.arguments as Map<String, dynamic>?;

        switch (settings.name) {
          case '/':
            return MaterialPageRoute(
                builder: (_) => MoodSelectorScreen(socket: socket));
          case '/waiting':
            return MaterialPageRoute(
              builder: (_) => MoodWaitingScreen(
                mood: args?['mood'] ?? '',
                socket: socket,
              ),
            );
          case '/chat':
            return MaterialPageRoute(
              builder: (_) => ChatScreen(
                socket: socket,
                partnerId: args?['partnerId'] ?? '',
                mood: args?['mood'] ?? '',
              ),
            );
          default:
            return null;
        }
      },
    );
  }
}
