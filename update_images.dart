import 'dart:io';

import 'package:flutter/foundation.dart';

void main() {
  final dir = Directory('lib');
  final files = dir
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart') && !f.path.contains('custom_network_image.dart'));

  for (final file in files) {
    String content = file.readAsStringSync();
    bool changed = false;

    // Replace Image.network(...) with CustomNetworkImage(imageUrl: ...)
    // It's a simple replace, we just find "Image.network(" and replace it.
    if (content.contains('Image.network(')) {
      content = content.replaceAll('Image.network(', 'CustomNetworkImage(imageUrl: ');
      changed = true;
    }

    if (changed) {
      if (!content.contains('custom_network_image.dart')) {
        content = "import 'package:z_ecommerce/presentation/widgets/common/custom_network_image.dart';\n$content";
      }
      file.writeAsStringSync(content);
      if (kDebugMode) {
        print('Updated \${file.path}');
      }
    }
  }
}
