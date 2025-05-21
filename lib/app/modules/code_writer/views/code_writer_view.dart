import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/code_writer_controller.dart';

class CodeWriterView extends GetView<CodeWriterController> {
  const CodeWriterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Code Assistant')),
      body: const Center(child: Text('AI Code Assistant Placeholder')),
    );
  }
} 