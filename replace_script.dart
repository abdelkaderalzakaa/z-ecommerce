import 'dart:io';

import 'package:flutter/foundation.dart';

void main() {
  final directory = Directory('c:\\alzaka_digital_solution\\z_ecommerce\\lib');
  
  final files = directory.listSync(recursive: true).whereType<File>().where((file) => file.path.endsWith('.dart')).toList();
  
  for (var file in files) {
    var content = file.readAsStringSync();
    bool modified = false;

    if (content.contains('PageTitleWithBack')) {
      content = content.replaceAll('PageTitleWithBack', 'TopTitle');
      content = content.replaceAll('isHero: false,', '');
      content = content.replaceAll('isHero: true,', '');
      content = content.replaceAll(
        "import '../../widgets/common/page_title_with_back.dart';",
        "import '../../widgets/common/headers/widgets/top_title.dart';"
      );
      content = content.replaceAll(
        "import '../widgets/common/page_title_with_back.dart';",
        "import '../widgets/common/headers/widgets/top_title.dart';"
      );
      content = content.replaceAll(
        "import 'page_title_with_back.dart';",
        "import 'headers/widgets/top_title.dart';"
      );
      content = content.replaceAll(
        "import '../../common/page_title_with_back.dart';",
        "import '../../common/headers/widgets/top_title.dart';"
      );
      modified = true;
    }

    if (modified) {
      file.writeAsStringSync(content);
      if (kDebugMode) {
        print('Updated: \${file.path}');
      }
    }
  }
}
