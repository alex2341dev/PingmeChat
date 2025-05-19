import 'dart:convert';
import 'dart:core';
import 'dart:io';

import 'package:pingmechat/widgets/pingme_chat_app.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' as webrtc_impl;
import 'package:matrix/matrix.dart';
import 'package:vibration/vibration.dart';
import 'package:webrtc_interface/webrtc_interface.dart' hide Navigator;
import 'package:pingmechat/pages/chat_list/chat_list.dart';
import 'package:pingmechat/pages/dialer/dialer.dart';
import 'package:pingmechat/utils/platform_infos.dart';
import '../../utils/voip/user_media_manager.dart';
import '../widgets/matrix.dart';
import 'package:matrix/src/voip/models/voip_id.dart';

class VoIPFixed extends VoIP {
  VoIPFixed(super.client, super.delegate);

  @override
  Future<void> onCallInvite(
    Room room,
    String remoteUserId,
    String? remoteDeviceId,
    Map<String, dynamic> content,
  ) async {
    if (remoteUserId != client.userID) {
      super.onCallInvite(room, remoteUserId, remoteDeviceId, content);
    }
  }
}

class VoipPlugin with WidgetsBindingObserver implements WebRTCDelegate {
  final MatrixState matrix;
  Client get client => matrix.client;

  VoipPlugin(this.matrix) {
    voip = VoIPFixed(client, this);

    if (!kIsWeb && !Platform.isWindows) {
      final wb = WidgetsBinding.instance;
      wb.addObserver(this);
      didChangeAppLifecycleState(wb.lifecycleState);
    }

    initCallInvite();

    client.onCallEvents.stream.listen((events) async {
      for (final event in events) {
        if (event.type == EventTypes.CallReject ||
            event.type == EventTypes.CallHangup) {
          Room? room;

          if (event is Event) {
            room = event.room;
          } else if (event is ToDeviceEvent) {
            final roomId = event.content.tryGet<String>('room_id');

            if (roomId != null) {
              room = client.getRoomById(roomId);
            } else {
              continue;
            }
          } else {
            continue;
          }

          final callId = event.content['call_id'] as String?;

          if (callId == null) {
            continue;
          }

          final call = voip.calls[VoipId(roomId: room!.id, callId: callId)];

          if (call != null) {
            if (event.type == EventTypes.CallReject) {
              call.reject();
            } else {
              call.hangup(reason: CallErrorCode.userHangup);
            }
          }
        }
      }
    });
  }
  bool background = false;
  bool speakerOn = false;
  late VoIP voip;
  OverlayEntry? overlayEntry;
  BuildContext get context => matrix.context;

  void initCallInvite() async {
    final callCandidatesJson = matrix.store.getString('CallInvite');

    if (callCandidatesJson != null) {
      final Map<String, dynamic> callCandidatesJsonMap =
          jsonDecode(callCandidatesJson);

      final room = matrix.client.getRoomById(callCandidatesJsonMap['room_id']);
      final event = Event.fromJson(callCandidatesJsonMap, room!);

      final serverEvent = Matrix.of(context)
          .client
          .onCallEvents
          .value
          ?.firstWhere((c) => c.content["call_id"] == event.content['call_id']);

      if (serverEvent != null &&
          (serverEvent.type != EventTypes.CallHangup ||
              serverEvent.type != EventTypes.CallReject)) {
        voip.onCallInvite(
          room,
          event.senderId,
          event.content.tryGet<String>('invitee_device_id'),
          event.content,
        );
      }

      await matrix.store.remove('CallInvite');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState? state) {
    background = (state == AppLifecycleState.detached ||
        state == AppLifecycleState.paused);
  }

  void addCallingOverlay(String callId, CallSession call) {
    final context = kIsWeb || Platform.isWindows
        ? ChatList.contextForVoip!
        : this.context; // web is weird

    if (overlayEntry != null) {
      Logs().e('[VOIP] addCallingOverlay: The call session already exists?');
      overlayEntry!.remove();
    }
    // Overlay.of(context) is broken on web
    // falling back on a dialog
    if (kIsWeb || Platform.isWindows) {
      overlayEntry = OverlayEntry(
        builder: (_) => Calling(
          context: navigatorKey.currentContext!,
          client: client,
          callId: callId,
          call: call,
          onClear: () {
            overlayEntry?.remove();
            overlayEntry = null;
          },
        ),
      );
      Navigator.of(navigatorKey.currentContext!).overlay?.insert(overlayEntry!);
    } else {
      overlayEntry = OverlayEntry(
        builder: (_) => Calling(
          context: navigatorKey.currentContext!,
          client: client,
          callId: callId,
          call: call,
          onClear: () {
            overlayEntry?.remove();
            overlayEntry = null;
          },
        ),
      );
      Navigator.of(navigatorKey.currentContext!).overlay?.insert(overlayEntry!);
    }
  }

  @override
  MediaDevices get mediaDevices => webrtc_impl.navigator.mediaDevices;

  Future<void> setMicrophoneDevice(String? deviceId) async {
    try {
      final devices = await mediaDevices.enumerateDevices();
      final audioDevices =
          devices.where((device) => device.kind == 'audioinput').toList();

      if (audioDevices.isNotEmpty) {
        final selectedDevice = deviceId != null
            ? audioDevices.firstWhere((device) => device.deviceId == deviceId)
            : audioDevices.isNotEmpty
                ? audioDevices.first
                : throw Exception("Device not found");

        final stream = await mediaDevices.getUserMedia({
          'audio': {'deviceId': selectedDevice.deviceId}
        });
      }
    } catch (e) {
      Logs().i("$e");
    }
  }

  @override
  bool get isWeb => kIsWeb || Platform.isWindows;

  @override
  Future<RTCPeerConnection> createPeerConnection(
    Map<String, dynamic> configuration, [
    Map<String, dynamic> constraints = const {},
  ]) {
    return webrtc_impl.createPeerConnection(configuration, constraints);
  }

  Future<bool> get hasCallingAccount async => false;

  @override
  Future<void> playRingtone() async {
    if (PlatformInfos.isAndroid) {
      Vibration.vibrate(
        pattern: [
          500,
          1000,
          500,
          1000,
        ],
        repeat: 0,
      );
    }

    if (!background && !await hasCallingAccount) {
      try {
        await UserMediaManager().startRingingTone();
      } catch (_) {}
    }
  }

  @override
  Future<void> stopRingtone() async {
    if (PlatformInfos.isAndroid) {
      Vibration.cancel();
    }

    if (!background && !await hasCallingAccount) {
      try {
        await UserMediaManager().stopRingingTone();
      } catch (_) {}
    }
  }

  @override
  Future<void> handleNewCall(CallSession call) async {
    await matrix.store.remove('CallInvite');

    if (PlatformInfos.isAndroid) {
      try {
        final wasForeground = await FlutterForegroundTask.isAppOnForeground;

        await matrix.store.setString(
          'wasForeground',
          wasForeground == true ? 'true' : 'false',
        );
        FlutterForegroundTask.setOnLockScreenVisibility(true);
        FlutterForegroundTask.wakeUpScreen();
        FlutterForegroundTask.launchApp();
      } catch (e) {
        Logs().e('VOIP foreground failed $e');
      }

      addCallingOverlay(call.callId, call);
    } else {
      addCallingOverlay(call.callId, call);
    }
  }

  @override
  Future<void> handleCallEnded(CallSession session) async {
    await matrix.store.remove('CallInvite');

    if (overlayEntry != null) {
      overlayEntry!.remove();
      overlayEntry = null;
      if (PlatformInfos.isAndroid) {
        FlutterForegroundTask.setOnLockScreenVisibility(false);
        FlutterForegroundTask.stopService();
        final wasForeground = matrix.store.getString('wasForeground');
        wasForeground == 'false' ? FlutterForegroundTask.minimizeApp() : null;
      }
    }
  }

  @override
  Future<void> handleGroupCallEnded(GroupCallSession groupCall) async {
    // TODO: implement handleGroupCallEnded
  }

  @override
  Future<void> handleNewGroupCall(GroupCallSession groupCall) async {
    // TODO: implement handleNewGroupCall
  }

  @override
  // TODO: implement canHandleNewCall
  bool get canHandleNewCall =>
      voip.currentCID == null && voip.currentGroupCID == null;

  @override
  Future<void> handleMissedCall(CallSession session) async {
    // TODO: implement handleMissedCall
  }

  @override
  // TODO: implement keyProvider
  EncryptionKeyProvider? get keyProvider => throw UnimplementedError();

  @override
  Future<void> registerListeners(CallSession session) async {
    // TODO: implement registerListeners
  }
}
