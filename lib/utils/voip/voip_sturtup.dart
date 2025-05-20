import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:pingmechat/utils/platform_infos.dart';
import 'package:pingmechat/utils/voip/call_manager.dart';
import 'package:pingmechat/utils/voip/voip_service.dart';
import 'package:pingmechat/widgets/call.dart';
import 'package:pingmechat/widgets/call_banner.dart';
import 'package:pingmechat/widgets/call_banner_controller.dart';
import 'package:pingmechat/widgets/incoming_call.dart';
import 'package:pingmechat/widgets/pingme_chat_app.dart';
import 'package:matrix/matrix.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';

class VoIPStartup {
  static start(VoIPService voIPService, CallManager callManager) async {
    Logs().i("[VoIPStartup][start] Call.");
    try {
      await voIPService.init();

      callManager.events.listen((call) async {
        if (call.call != null) {
          if (call.call!.session.isRinging) {
            ShowIncomingCallDialog.show(
              navigatorKey.currentContext!,
              call.call!.session.callId,
            );

            if (PlatformInfos.isMobile) {
              FlutterForegroundTask.setOnLockScreenVisibility(true);
              FlutterForegroundTask.wakeUpScreen();
              FlutterForegroundTask.launchApp();
            }
          }

          if (PlatformInfos.isMobile
              ? (call.call!.phase == CallPhase.connecting)
              : (call.call!.phase == CallPhase.connecting ||
                  call.call!.phase == CallPhase.inCall)) {
            navigatorKey.currentContext!
                .read<CallBannerController>()
                .showBanner(
                  CallBanner(call.call!.session.callId),
                );
          }

          if (PlatformInfos.isMobile && call.call!.phase == CallPhase.inCall) {
            ShowCallDialog.show(
              navigatorKey.currentContext!,
              call.call!.session.callId,
            );
            navigatorKey.currentContext!
                .read<CallBannerController>()
                .hideBanner();
            Vibration.cancel();
          }

          if (PlatformInfos.isMobile &&
              (call.call!.phase == CallPhase.ended ||
                  call.call!.phase == CallPhase.failed)) {
            FlutterForegroundTask.setOnLockScreenVisibility(false);
            Vibration.cancel();
          }
        }
      });
    } catch (e) {
      Logs().e("[VoIPStartup][start] Call.", e);
    }
  }
}
