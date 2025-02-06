import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;

class ImageProcessing extends StatefulWidget {
  final String imagePath;

  ImageProcessing({required this.imagePath});

  @override
  _ImageProcessingState createState() => _ImageProcessingState();
}

class _ImageProcessingState extends State<ImageProcessing> {
  ui.Image? _image;
  List<Offset> redPoints = [];

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    final ByteData data = await rootBundle.load(widget.imagePath);
    final Uint8List bytes = data.buffer.asUint8List();
    final image = await decodeImageFromList(bytes);
    setState(() {
      _image = image;
    });

    _detectRedPoints(image);
  }

  void _detectRedPoints(ui.Image image) {
    List<Offset> points = [];
    image.toByteData(format: ui.ImageByteFormat.rawRgba).then((byteData) {
      if (byteData != null) {
        final buffer = byteData.buffer.asUint8List();
        for (int i = 0; i < buffer.length; i += 4) {
          final red = buffer[i];
          final green = buffer[i + 1];
          final blue = buffer[i + 2];
          if (red > 130 && green < 100 && blue < 100) {
            int index = i ~/ 4;
            int x = index % image.width;
            int y = index ~/ image.width;
            points.add(Offset(x.toDouble(), y.toDouble()));
          }
        }
      }
    }).then((_) {
      setState(() {
        redPoints = _groupNearbyPoints(points, 10);
      });
    });
  }

  List<Offset> _groupNearbyPoints(List<Offset> points, double maxDistance) {
    List<List<Offset>> groups = [];

    for (var point in points) {
      bool added = false;
      for (var group in groups) {
        if (_isNearby(group.last, point, maxDistance)) {
          group.add(point);
          added = true;
          break;
        }
      }
      if (!added) {
        groups.add([point]);
      }
    }

    List<Offset> groupedPoints = [];
    for (var group in groups) {
      double sumX = 0;
      double sumY = 0;
      for (var point in group) {
        sumX += point.dx;
        sumY += point.dy;
      }
      groupedPoints.add(Offset(sumX / group.length, sumY / group.length));
    }

    return groupedPoints;
  }

  bool _isNearby(Offset point1, Offset point2, double maxDistance) {
    double distance =
        (point1.dx - point2.dx).abs() + (point1.dy - point2.dy).abs();
    return distance <= maxDistance;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Phát hiện điểm đỏ")),
      body: Center(
        child: _image == null
            ? CircularProgressIndicator()
            : FittedBox(
          fit: BoxFit.contain,
          child: SizedBox(
            width: _image!.width.toDouble(),
            height: _image!.height.toDouble(),
            child: CustomPaint(
              painter: RedPointsPainter(_image!, redPoints),
            ),
          ),
        ),
      ),
    );
  }
}

class RedPointsPainter extends CustomPainter {
  final ui.Image image;
  final List<Offset> redPoints;

  RedPointsPainter(this.image, this.redPoints);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..isAntiAlias = true
      ..filterQuality = FilterQuality.high;
    canvas.drawImage(image, Offset(0, 0), paint);

    final redPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (var point in redPoints) {
      canvas.drawCircle(point, 10.0, redPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
