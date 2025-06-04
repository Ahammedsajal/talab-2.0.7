import 'package:Talab/ui/theme/theme.dart';
import 'package:Talab/utils/custom_text.dart';
import 'package:Talab/utils/extensions/extensions.dart';
import 'package:Talab/utils/ui_utils.dart';
import 'package:flutter/material.dart';

class CategoryHomeCard extends StatelessWidget {
  final String title;
  final String url;
  final VoidCallback onTap;
  const CategoryHomeCard({
    super.key,
    required this.title,
    required this.url,
    required this.onTap,
  });

  @override
Widget build(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  // Responsive sizing: scale between mobile (70) and tablet (100)
  final cardWidth = screenWidth < 768 ? 70.0 : (screenWidth < 1024 ? 70 + (screenWidth - 768) * 0.1176 : 100.0);
  final cardHeight = screenWidth < 768 ? 70.0 : (screenWidth < 1024 ? 70 + (screenWidth - 768) * 0.1176 : 100.0);
  final imageSize = screenWidth < 768 ? 48.0 : (screenWidth < 1024 ? 48 + (screenWidth - 768) * 0.0627 : 64.0);
  final fontSize = screenWidth < 768 ? context.font.smaller : (screenWidth < 1024 ? context.font.smaller + (context.font.normal - context.font.smaller) * ((screenWidth - 768) / 256) : context.font.normal);

  String extension = url.split(".").last.toLowerCase();
  bool isFullImage = false;

  if (extension == "png" || extension == "svg") {
    isFullImage = false;
  } else {
    isFullImage = true;
  }
  return SizedBox(
    width: cardWidth,
    child: GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Container(
          child: Column(
            children: [
              if (isFullImage) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    height: cardHeight,
                    width: double.infinity,
                    color: context.color.secondaryColor,
                    child: UiUtils.imageType(url, fit: BoxFit.cover),
                  ),
                ),
              ] else ...[
                Container(
                  clipBehavior: Clip.antiAlias,
                  height: cardHeight,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                        color: context.color.borderColor.darken(60),
                        width: 1),
                    color: context.color.secondaryColor,
                  ),
                  child: Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: SizedBox(
                        width: imageSize,
                        height: imageSize,
                        child: UiUtils.imageType(url, fit: BoxFit.cover),
                      ),
                    ),
                  ),
                ),
              ],
              Expanded(
                  child: Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: CustomText(
                        title,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        fontSize: fontSize,
                        color: context.color.textDefaultColor,
                      )))
            ],
          ),
        ),
      ),
    ),
  );
}}