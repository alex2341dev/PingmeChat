import 'package:flutter/material.dart';
import 'package:markdown_editor_plus/widgets/markdown_toolbar.dart';
import 'package:pingmechat/pages/chat/chat.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:markdown_editor_plus/src/toolbar.dart';
import 'package:pingmechat/utils/platform_infos.dart';

class MDEditor extends StatelessWidget {
  final ChatController controller;

  const MDEditor(this.controller, {super.key});

  @override
  Widget build(BuildContext context) {
    if (!controller.isMDEditor) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: MediaQuery.of(context).size.height *
          (PlatformInfos.isMobile ? 0.3 : 0.5),
      child: Column(
        children: [
          const Divider(
            height: 1,
          ),
          MarkdownToolbar(
            controller: controller.sendController,
            toolbar: Toolbar(controller: controller.sendController),
            showPreviewButton: false,
            toolbarBackground: Colors.transparent,
          ),
          Expanded(
            child: TextField(
              controller: controller.sendController,
              maxLines: null,
              expands: true,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.only(
                  left: 6.0,
                  right: 6.0,
                  bottom: 0,
                  top: 3.0,
                ),
                hintText: L10n.of(context).writeAMessage,
                hintMaxLines: 1,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                filled: false,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
