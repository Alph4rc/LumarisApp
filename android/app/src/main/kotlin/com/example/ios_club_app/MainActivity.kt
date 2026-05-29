package com.example.ios_club_app

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    companion object {
        private const val TYPE_TODAY = "today"
        private const val TYPE_TOMORROW = "tomorrow"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        WidgetSettingsChannel.register(flutterEngine, this)
    }

    fun openWidgetSetup(type: String?): String {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
            return "unavailable"
        }

        val appWidgetManager = getSystemService(AppWidgetManager::class.java)
            ?: return "unavailable"

        if (!appWidgetManager.isRequestPinAppWidgetSupported) {
            return "unavailable"
        }

        val providerClass = when (type) {
            TYPE_TOMORROW -> TomorrowCoursesWidgetProvider::class.java
            TYPE_TODAY, null -> TodayCoursesWidgetProvider::class.java
            else -> TodayCoursesWidgetProvider::class.java
        }
        val provider = ComponentName(this, providerClass)
        val requested = appWidgetManager.requestPinAppWidget(provider, null, null)

        return if (requested) "widgetPickerOpened" else "unavailable"
    }
}
