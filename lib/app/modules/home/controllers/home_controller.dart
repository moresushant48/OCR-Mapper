import 'dart:async';
import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class HomeController extends GetxController {
  late CameraController cameraController;
  List<CameraDescription> cameras = [];
  RxBool isLoading = true.obs;

  final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  Timer? timer;

  RxList<TextBlock> blocks = <TextBlock>[].obs;

  @override
  void onInit() async {
    cameras = await availableCameras();
    cameraController =
        CameraController(cameras[0], ResolutionPreset.high, enableAudio: false);
    await cameraController.initialize();
    isLoading.value = false;

    timer = Timer.periodic(
      const Duration(seconds: 4),
      (timer) async {
        log("Started");
        await cameraController.startImageStream((image) async {
          await cameraController.stopImageStream();
          buildOcr(image);
        });
      },
    );

    super.onInit();
  }

  buildOcr(CameraImage cameraImage) async {
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in cameraImage.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize =
        Size(cameraImage.width.toDouble(), cameraImage.height.toDouble());

    final InputImageRotation imageRotation =
        InputImageRotationValue.fromRawValue(cameras[0].sensorOrientation)!;

    final InputImageFormat inputImageFormat =
        InputImageFormatValue.fromRawValue(cameraImage.format.raw)!;

    final planeData = cameraImage.planes.map(
      (Plane plane) {
        return InputImagePlaneMetadata(
          bytesPerRow: plane.bytesPerRow,
          height: plane.height,
          width: plane.width,
        );
      },
    ).toList();

    final inputImageData = InputImageData(
      size: imageSize,
      imageRotation: imageRotation,
      inputImageFormat: inputImageFormat,
      planeData: planeData,
    );

    final inputImage =
        InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);

    RecognizedText result = await textRecognizer.processImage(inputImage);
    blocks.value = result.blocks;
    blocks.refresh();
  }

  @override
  void onClose() {
    if (timer != null) timer!.cancel();
    super.onClose();
  }
}
