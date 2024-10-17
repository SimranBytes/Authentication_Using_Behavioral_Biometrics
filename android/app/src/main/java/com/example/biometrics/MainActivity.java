package com.example.biometrics;

import android.content.Intent;
import android.os.Bundle;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {

    private static final String CHANNEL = "com.example.biometrics/gestures";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        // Initialize the MethodChannel and assign it to the GestureService
        GestureService.methodChannel = new MethodChannel(
                getFlutterEngine().getDartExecutor().getBinaryMessenger(), CHANNEL
        );

        new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler((call, result) -> {
                    if (call.method.equals("startService")) {
                        startGestureService();
                        result.success("Gesture Service Started");
                    } else {
                        result.notImplemented();
                    }
                });
    }

    // Start the GestureService
    private void startGestureService() {
        Intent intent = new Intent(this, GestureService.class);
        startService(intent);  // Start the Accessibility Service
    }
}
