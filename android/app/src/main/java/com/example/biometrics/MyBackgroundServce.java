package com.example.yourapp;

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
            NotificationChannel channel = new NotificationChannel("sensor_service", "Sensor Service", NotificationManager.IMPORTANCE_DEFAULT);
            ((NotificationManager) getSystemService(NotificationManager.class)).createNotificationChannel(channel);
        }

        Notification notification = new Notification.Builder(this, "sensor_service")
                .setContentTitle("Sensor Data Collection")
                .setContentText("Collecting sensor data in the background")
                .setSmallIcon(R.drawable.background_icon)
                .build();

        startForeground(1, notification);
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        Log.d("MyBackgroundService", "Service started");
        // Your background task (e.g., data collection) can start here.
        return START_STICKY;
    }

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        Log.d("MyBackgroundService", "Service stopped");
    }
}
