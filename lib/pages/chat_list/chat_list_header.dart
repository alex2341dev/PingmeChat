import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/l10n.dart';

import 'package:pingmechat/config/themes.dart';
import 'package:pingmechat/pages/chat_list/chat_list.dart';
import 'package:pingmechat/pages/chat_list/client_chooser_button.dart';
import '../../widgets/matrix.dart';

class ChatListHeader extends StatelessWidget implements PreferredSizeWidget {
  final ChatListController controller;
  final bool globalSearch;

  const ChatListHeader({
    super.key,
    required this.controller,
    this.globalSearch = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SliverAppBar(
      floating: true,
      toolbarHeight: 72,
      pinned: PingmeThemes.isColumnMode(context),
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      title: TextField(
        controller: controller.searchController,
        focusNode: controller.searchFocusNode,
        textInputAction: TextInputAction.search,
        onChanged: (text) => controller.onSearchEnter(
          text,
          globalSearch: globalSearch,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: theme.colorScheme.secondaryContainer,
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(99),
          ),
          contentPadding: EdgeInsets.zero,
          hintText: L10n.of(context).searchChatsRooms,
          hintStyle: TextStyle(
            color: theme.colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.normal,
          ),
          floatingLabelBehavior: FloatingLabelBehavior.never,
          prefixIcon: controller.isSearchMode
              ? IconButton(
                  tooltip: L10n.of(context).cancel,
                  icon: const Icon(Icons.close_outlined),
                  onPressed: controller.cancelSearch,
                  color: theme.colorScheme.onPrimaryContainer,
                )
              : IconButton(
                  onPressed: controller.startSearch,
                  icon: Icon(
                    Icons.search_outlined,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
          suffixIcon: controller.isSearchMode && globalSearch
              ? controller.isSearching
                  ? const Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 10.0,
                        horizontal: 12,
                      ),
                      child: SizedBox.square(
                        dimension: 24,
                        child: CircularProgressIndicator.adaptive(
                          strokeWidth: 2,
                        ),
                      ),
                    )
                  : TextButton.icon(
                      onPressed: controller.setServer,
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(99),
                        ),
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                      icon: const Icon(Icons.edit_outlined, size: 16),
                      label: Text(
                        controller.searchServer ??
                            Matrix.of(context).client.homeserver!.host,
                        maxLines: 2,
                      ),
                    )
              : SizedBox(
                  width: 0,
                  child: ClientChooserButton(controller),
                ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}
