import 'dart:io';
import 'dart:typed_data';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class LostPage extends StatefulWidget {
  @override
  _LostPageState createState() => _LostPageState();
}

class _LostPageState extends State<LostPage> {
  late FaceDetector faceDetector;
  List<double>? savedEmbedding;
  final picker = ImagePicker();
  bool _modelLoaded = false;
  String? _loadError;
  late Interpreter interpreter;
  final ValueNotifier<double> progress = ValueNotifier(0);
  String? resultMessage;

  @override
  void initState() {
    super.initState();
    initModelAndLoadSaved();
  }

  Future<void> initModelAndLoadSaved() async {
    try {
      progress.value = 0;

      // Load TFLite interpreter from asset
      interpreter = await Interpreter.fromAsset('assets/facenet.tflite');
      print("✅ Interpreter loaded");

      // Initialize ML Kit FaceDetector AFTER interpreter is ready
      faceDetector = FaceDetector(
        options: FaceDetectorOptions(
          performanceMode: FaceDetectorMode.accurate,
          enableLandmarks: false,
          enableClassification: false,
        ),
      );

      progress.value = 20;

      // Load saved embedding from storage
      await loadSavedEmbedding();

      setState(() {
        _modelLoaded = true;
      });
      print("✅ Model and detector loaded");
    } catch (e) {
      setState(() {
        _loadError = e.toString();
      });
      print("❌ Model load error: $e");
    }
  }

  Future<void> loadSavedEmbedding() async {
    final prefs = await SharedPreferences.getInstance();
    final savedImagePath = prefs.getString('face_image');
    if (savedImagePath == null) return;

    final file = File(savedImagePath);
    if (!await file.exists()) return;

    final bytes = await file.readAsBytes();
    final image = img.decodeImage(bytes);
    if (image == null) return;

    try {
      savedEmbedding = await getFaceEmbedding(image);
      print("✅ Saved embedding loaded");
    } catch (e) {
      print("❌ Failed to load saved embedding: $e");
    }
  }

  Future<void> compareFaces() async {
    try {
      progress.value = 20;

      final pickedFile = await picker.pickImage(source: ImageSource.camera);
      if (pickedFile == null) {
        _showResult('No photo taken');
        progress.value = 0;
        return;
      }

      progress.value = 40;

      final bytes = await pickedFile.readAsBytes();
      final image = img.decodeImage(bytes);
      if (image == null) {
        _showResult('Could not decode image');
        progress.value = 0;
        return;
      }

      final newEmbedding = await getFaceEmbedding(image);
      progress.value = 80;

      if (savedEmbedding == null) {
        _showResult('No saved face to compare with.');
        progress.value = 0;
        return;
      }

      final sim = cosineSimilarity(savedEmbedding!, newEmbedding);
      progress.value = 100;

      final samePerson = sim > 0.8;
      _showResult(samePerson
          ? '✅ Same person\nSimilarity: ${sim.toStringAsFixed(3)}'
          : '❌ Different person\nSimilarity: ${sim.toStringAsFixed(3)}');

      // Reset progress after a short delay
      Future.delayed(Duration(seconds: 2), () {
        progress.value = 0;
      });
    } catch (e) {
      _showResult('❌ Comparison failed: $e');
      progress.value = 0;
    }
  }

  Future<List<double>> getFaceEmbedding(img.Image image) async {
    try {
      print("🔍 Starting face embedding...");

      // Save temporary image file
      final tempDir = await getTemporaryDirectory();
      final tempPath = '${tempDir.path}/temp.jpg';
      final file = File(tempPath);
      await file.writeAsBytes(img.encodeJpg(image));

      // Detect faces using ML Kit FaceDetector
      final inputImage = InputImage.fromFilePath(tempPath);
      final faces = await faceDetector.processImage(inputImage);
      print("🧠 Detected faces: ${faces.length}");

      if (faces.isEmpty) throw Exception('No face detected');

      // Get the bounding box of the first face
      final face = faces[0].boundingBox;

      // Crop the face region from the original image
      final faceCrop = img.copyCrop(
        image,
        x: face.left.toInt().clamp(0, image.width - 1),
        y: face.top.toInt().clamp(0, image.height - 1),
        width: face.width.toInt().clamp(1, image.width),
        height: face.height.toInt().clamp(1, image.height),
      );

      // Resize to model input size (112x112)
      final resized = img.copyResize(faceCrop, width: 112, height: 112);

      // Convert resized image to 4D input tensor: [1, 112, 112, 3]
      final input = imageTo4DList(resized, 112);

      // Prepare output buffer with shape [1, 128]
      final output = List.filled(1 * 128, 0).reshape([1, 128]);

      // Run inference
      interpreter.run(input, output);

      // Normalize the embedding vector
      final embedding = List<double>.from(output[0]);
      final norm = sqrt(embedding.fold<double>(0, (p, e) => p + e * e));
      print("✅ Embedding computed.");

      return embedding.map((e) => e / norm).toList();
    } catch (e) {
      print("❌ Face embedding failed: $e");
      rethrow;
    }
  }

  List<List<List<List<double>>>> imageTo4DList(img.Image image, int inputSize) {
    List<List<List<List<double>>>> buffer = List.generate(
      1,
          (_) => List.generate(
        inputSize,
            (_) => List.generate(
          inputSize,
              (_) => List.filled(3, 0.0),
        ),
      ),
    );

    for (int y = 0; y < inputSize; y++) {
      for (int x = 0; x < inputSize; x++) {
        final pixel = image.getPixel(x, y);
        final r = pixel.r;
        final g = pixel.g;
        final b = pixel.b;

        buffer[0][y][x][0] = (r - 127.5) / 128;
        buffer[0][y][x][1] = (g - 127.5) / 128;
        buffer[0][y][x][2] = (b - 127.5) / 128;
      }
    }

    return buffer;
  }

  Float32List imageToFloat32List(img.Image image, int inputSize) {
    final buffer = Float32List(1 * inputSize * inputSize * 3);
    int pixelIndex = 0;
    for (int y = 0; y < inputSize; y++) {
      for (int x = 0; x < inputSize; x++) {
        final pixel = image.getPixel(x, y); // This returns a Pixel object now
        final r = pixel.r;
        final g = pixel.g;
        final b = pixel.b;

        buffer[pixelIndex++] = (r - 127.5) / 128;
        buffer[pixelIndex++] = (g - 127.5) / 128;
        buffer[pixelIndex++] = (b - 127.5) / 128;
      }
    }
    return buffer;
  }

  double cosineSimilarity(List<double> e1, List<double> e2) {
    double dot = 0;
    double normA = 0;
    double normB = 0;
    for (int i = 0; i < e1.length; i++) {
      dot += e1[i] * e2[i];
      normA += e1[i] * e1[i];
      normB += e2[i] * e2[i];
    }
    return dot / (sqrt(normA) * sqrt(normB));
  }

  void _showResult(String msg) {
    setState(() => resultMessage = msg);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Result'),
        content: Text(msg),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loadError != null) {
      return Center(child: Text("❌ Model load error: $_loadError"));
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ValueListenableBuilder<double>(
            valueListenable: progress,
            builder: (context, value, _) => Column(
              children: [
                LinearProgressIndicator(value: value / 100),
                SizedBox(height: 8),
                Text("Progress: ${value.toInt()}%"),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (_modelLoaded)
            ElevatedButton(
              onPressed: compareFaces,
              child: Text('Compare Faces'),
            )
          else
            Text('⏳ Waiting for model to load...'),
          if (resultMessage != null) ...[
            const SizedBox(height: 20),
            Text(resultMessage!, textAlign: TextAlign.center),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    faceDetector.close();
    interpreter.close();
    super.dispose();
  }
}
