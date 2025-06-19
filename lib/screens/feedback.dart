import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class FeedbackScreen extends StatelessWidget {
  final String mood;
  final IO.Socket socket;

  FeedbackScreen({required this.mood, required this.socket});

  void _handleFeedback(BuildContext context, String choice) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.black,
        title: Text('Merci !', style: GoogleFonts.montserrat(color: Colors.white)),
        content: Text('Votre avis a été enregistré.', style: GoogleFonts.montserrat(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Ferme le popup
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/',
                (route) => false,
              ); // Retour à l'accueil
            },
            child: Text('OK', style: GoogleFonts.montserrat(color: Colors.white)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final choices = ['Oui', 'Bof', 'Pas vraiment'];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('MoodPair', style: GoogleFonts.montserrat()),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Donnez votre avis',
                style: GoogleFonts.montserrat(color: Colors.white, fontSize: 24)),
            const SizedBox(height: 16),
            Text(
              'Cet échange vous a-t-il fait du bien ?',
              style: GoogleFonts.montserrat(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 32),
            ...choices.map((choice) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1C1C1E),
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () => _handleFeedback(context, choice),
                child: Text(
                  choice,
                  style: GoogleFonts.montserrat(fontSize: 16, color: Colors.white),
                ),
              ),
            ))
          ],
        ),
      ),
    );
  }
}
