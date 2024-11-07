// ignore_for_file: library_private_types_in_public_api, avoid_print

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' hide Category;

class EmojiButton extends StatefulWidget {
  const EmojiButton({super.key});

  @override
  _EmojiButtonState createState() => _EmojiButtonState();
}

class _EmojiButtonState extends State<EmojiButton> {
  TextEditingController textEditingController = TextEditingController();

  void _openEmojiPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return EmojiPicker(
          onEmojiSelected: (Category? category, Emoji? emoji) {
            if (emoji != null) {
              // Safely print emoji
              print(emoji.emoji);
              // Here, you can also insert the emoji into your input field
              textEditingController.text += emoji.emoji;
            }
          },
          onBackspacePressed: () {
            // Optional: Handle backspace press
          },
          textEditingController: textEditingController,
          config: Config(
            height: 200,  // Reduced height of the emoji picker
            checkPlatformCompatibility: true,
            emojiViewConfig: EmojiViewConfig(
              emojiSizeMax: 24 * (defaultTargetPlatform == TargetPlatform.iOS ? 1.20 : 1.0),  // Reduced emoji size
            ),
            viewOrderConfig: const ViewOrderConfig(
              top: EmojiPickerItem.categoryBar,
              middle: EmojiPickerItem.emojiView,
              bottom: EmojiPickerItem.searchBar,
            ),
            skinToneConfig: const SkinToneConfig(),
            categoryViewConfig: const CategoryViewConfig(),
            bottomActionBarConfig: const BottomActionBarConfig(),
            searchViewConfig: const SearchViewConfig(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _openEmojiPicker(context),
      borderRadius: BorderRadius.circular(20),  // Smaller corner radius
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.yellow,
          borderRadius: BorderRadius.circular(20),  // Adjusted to match the smaller button size
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),  // Lighter shadow for subtle effect
              offset: const Offset(0, 3),
              blurRadius: 4,
            ),
          ],
        ),
        child: const Padding(
          padding: EdgeInsets.all(8.0),  // Reduced padding for a smaller button
          child: Icon(
            Icons.insert_emoticon,
            color: Colors.white,
            size: 24,  // Reduced icon size for a less cartoony effect
          ),
        ),
      ),
    );
  }
}
