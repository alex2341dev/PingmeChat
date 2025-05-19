import 'package:pingmechat/widgets/resizable_widget.dart';
import 'package:flutter/material.dart';

import 'package:pingmechat/config/themes.dart';

class TwoColumnLayout extends StatelessWidget {
  final Widget mainView;
  final Widget sideView;
  final bool displayNavigationRail;

  const TwoColumnLayout({
    super.key,
    required this.mainView,
    required this.sideView,
    required this.displayNavigationRail,
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        return ScaffoldMessenger(
          child: Scaffold(
            body: Row(
              children: [
                ResizableWidget(
                  minWidthPercent:
                      (PingmeThemes.columnWidth / constraints.maxWidth) * 100,
                  maxWidthPercent: 60,
                  initialWidthPercent: ((PingmeThemes.columnWidth +
                              (displayNavigationRail
                                  ? PingmeThemes.navRailWidth
                                  : 0)) /
                          constraints.maxWidth) *
                      100,
                  screenWidth: constraints.maxWidth,
                  child: Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: const BoxDecoration(),
                    width: PingmeThemes.columnWidth +
                        (displayNavigationRail ? PingmeThemes.navRailWidth : 0),
                    child: mainView,
                  ),
                ),
                Expanded(
                  child: ClipRRect(
                    child: sideView,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
