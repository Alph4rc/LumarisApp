package com.example.ios_club_app

import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class WidgetSettingsChannel {
    companion object {
        private const val CHANNEL_NAME = "ios_club_app/widget_settings"
        private const val METHOD_OPEN_WIDGET_SETUP = "openWidgetSetup"
        private const val ARG_TYPE = "type"

        fun register(flutterEngine: FlutterEngine, activity: MainActivity) {
            MethodChannel(
                flutterEngine.dartExecutor.binaryMessenger,
                CHANNEL_NAME
            ).setMethodCallHandler { call: MethodCall, result: MethodChannel.Result ->
                when (call.method) {
                    METHOD_OPEN_WIDGET_SETUP -> {
                        val type = call.argument<String>(ARG_TYPE)
                        result.success(activity.openWidgetSetup(type))
                    }
                    else -> result.notImplemented()
                }
            }
        }
    }
}
