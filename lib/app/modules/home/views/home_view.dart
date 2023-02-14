import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Obx(
      () => SizedBox(
        width: Get.width,
        child: Stack(
          children: [
            Obx(
              () => controller.isLoading.value
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : CameraPreview(controller.cameraController),
            ),
            ...controller.blocks
                .map((element) => Positioned.fromRect(
                    rect: element.boundingBox,
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(
                        color: Colors.red,
                      )),
                      child: Text(element.text,
                          style: TextStyle(color: Colors.red)),
                    )))
                .toList()
          ],
        ),
      ),
    ));
  }
}
