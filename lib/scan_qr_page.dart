part of '../_import.dart';

class ScanQr extends StatefulWidget {
  const ScanQr({Key? key}) : super(key: key);

  @override
  State<ScanQr> createState() => _ScanQrState();
}

class _ScanQrState extends State<ScanQr> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  bool _flashOn = false;
  int scanOnce = 0;

  // In order to get hot reload to work we need to pause the camera if the platform
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Scan QR Code",
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_outlined,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: <Widget>[
          Container(
            child: _buildQrView(context),
          ),
          Positioned(
            left: MediaQuery.of(context).size.width * 0.2,
            right: MediaQuery.of(context).size.width * 0.2,
            top: MediaQuery.of(context).size.width * 1.2,
            child: const Text(
              "Arahkan kamera anda ke QR Code yang tersedia pada meja",
              textAlign: TextAlign.center,
            ),
          )
        ],
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 32, right: 32),
        child: FloatingActionButton(
          backgroundColor: Colors.black45,
          child: Icon(
            _flashOn ? Icons.flash_on : Icons.flash_off,
            color: Colors.white,
          ),
          onPressed: () {
            setState(() {
              _flashOn = !_flashOn;
            });
            controller!.toggleFlash();
          },
        ),
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 280.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.yellow,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutBottomOffset: 80,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        while (scanOnce == 0) {
          result = scanData;
          print("result.code: ${result!.code}");
          _checkingUrl(result!);
          controller.pauseCamera();
          break;
        }
        scanOnce++;
        controller.resumeCamera();
      });
    });
  }

  _checkingUrl(Barcode result) async {
    if (result.code!.contains("https")) {
      _launchUrl(result.code!);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('invalid url')),
      );
    }
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  _launchUrl(String validUrl) async {
    String url = validUrl;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
