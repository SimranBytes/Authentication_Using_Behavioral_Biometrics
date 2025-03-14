package com.example.biometrics;

import android.accessibilityservice.AccessibilityService;
import android.content.Intent;
import android.util.Log;
import android.view.accessibility.AccessibilityEvent;
import io.flutter.plugin.common.MethodChannel;

public class GestureService extends AccessibilityService {

    private static final String TAG = "GestureService";
    public static MethodChannel methodChannel;  // Singleton MethodChannel instance

    @Override
    public void onAccessibilityEvent(AccessibilityEvent event) {
        if (event.getEventType() == AccessibilityEvent.TYPE_TOUCH_INTERACTION_START) {
            Log.d(TAG, "Touch interaction detected!");

            // Send a gesture event to Flutter via the MethodChannel
            if (methodChannel != null) {
                methodChannel.invokeMethod("onGestureDetected", "Touch Interaction Detected");
            }
        }
    }

    @Override
    public void onInterrupt() {
        Log.d(TAG, "Service Interrupted");
    }
}
