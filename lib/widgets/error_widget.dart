import 'package:flutter/material.dart';

import 'package:pingmechat/utils/error_reporter.dart';

class PingmeChatErrorWidget extends StatefulWidget {
  final FlutterErrorDetails details;
  const PingmeChatErrorWidget(this.details, {super.key});

  @override
  State<PingmeChatErrorWidget> createState() => _PingmeChatErrorWidgetState();
}

class _PingmeChatErrorWidgetState extends State<PingmeChatErrorWidget> {
  static final Set<String> knownExceptions = {};
  @override
  void initState() {
    super.initState();

    if (knownExceptions.contains(widget.details.exception.toString())) {
      return;
    }
    knownExceptions.add(widget.details.exception.toString());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ErrorReporter(context, 'Error Widget').onErrorCallback(
        widget.details.exception,
        widget.details.stack,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.orange,
      child: Placeholder(
        child: Center(
          child: Material(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
