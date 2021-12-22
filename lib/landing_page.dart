part of '../_import.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ScanQr()),
            );
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.only(top: 16, bottom: 16),
          ),
          child: const Text(
            "Buka Kamera",
          )),
    );
  }
}
