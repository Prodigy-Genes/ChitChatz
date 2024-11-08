// emoji_button.dart
// ignore_for_file: library_private_types_in_public_api, avoid_print

import 'package:chatapp/widgets/textfieldwidget.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';

class EmojiButton extends StatefulWidget {
  const EmojiButton({super.key});

  @override
  _EmojiButtonState createState() => _EmojiButtonState();
}

class _EmojiButtonState extends State<EmojiButton> with SingleTickerProviderStateMixin {
  TextEditingController textEditingController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isEmojiPickerVisible = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    textEditingController.dispose();
    super.dispose();
  }

  void _openEmojiPicker(BuildContext context) {
    setState(() => _isEmojiPickerVisible = true);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.4,
          decoration: const BoxDecoration(
            color: Color(0xFFFFF3E0),
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                height: 5,
                width: 40,
                margin: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
              Expanded(
                child: EmojiPicker(
                  onEmojiSelected: (Category? category, Emoji? emoji) {
                    if (emoji != null) {
                      setState(() {
                        textEditingController.text += emoji.emoji;
                      });
                      _animationController.forward().then((_) {
                        _animationController.reverse();
                      });
                    }
                  },
                  onBackspacePressed: () {
                    if (textEditingController.text.isNotEmpty) {
                      final text = textEditingController.text;
                      textEditingController.text = text.substring(0, text.length - 2);
                    }
                  },
                  textEditingController: textEditingController,
                  config: Config(
                    height: MediaQuery.of(context).size.height * 0.35,
                    checkPlatformCompatibility: true,
                    emojiViewConfig: const EmojiViewConfig(
                      emojiSizeMax: 32,
                      backgroundColor: Color(0xFFFFF3E0),
                    ),
                    categoryViewConfig: const CategoryViewConfig(
                      backgroundColor: Colors.transparent,
                      indicatorColor: Colors.orange,
                      iconColorSelected: Colors.orange,
                      tabIndicatorAnimDuration: Duration(milliseconds: 300),
                    ),
                    searchViewConfig: const SearchViewConfig(
                      backgroundColor: Colors.white70,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ).whenComplete(() {
      setState(() => _isEmojiPickerVisible = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(child: CustomTextField(
      textEditingController: textEditingController,
      animationController: _animationController,
      scaleAnimation: _scaleAnimation,
      isEmojiPickerVisible: _isEmojiPickerVisible,
      onEmojiButtonPressed: () => _openEmojiPicker(context),
    )
    ,) ;
  }
}
