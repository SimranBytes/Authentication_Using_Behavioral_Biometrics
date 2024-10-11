package com.example.biometrics;  // Ensure this matches your app's package name

import android.app.Service;
import android.content.Intent;
import android.os.IBinder;
import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.os.Build;
import android.util.Log;

public class MyBackgroundService extends Service {

    @Override
    public void onCreate() {
        super.onCreate();

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel channel = new NotificationChannel(
                    "sensor_service", "Sensor Service", NotificationManager.IMPORTANCE_DEFAULT);
            NotificationManager manager = (NotificationManager) getSystemService(NotificationManager.class);
            manager.createNotificationChannel(channel);
        }

        Notification notification = new Notification.Builder(this, "sensor_service")
                .setContentTitle("Sensor Data Collection")
                .setContentText("Collecting sensor data in the background")
                .setSmallIcon(R.mipmap.ic_launcher) // Ensure this icon exists
                .build();

        startForeground(1, notification);  // Start the service in the foreground
    }


    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        Log.d("MyBackgroundService", "Service started");
        // Background task logic (e.g., data collection) can be placed here.
        return START_STICKY;  // Keep the service running
    }

    @Override
    public IBinder onBind(Intent intent) {
        return null;  // We don't need to bind the service to an activity
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        Log.d("MyBackgroundService", "Service stopped");
    }
}
