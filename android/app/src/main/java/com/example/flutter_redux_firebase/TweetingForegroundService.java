package com.example.flutter_redux_firebase;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Build;
import android.os.IBinder;

import jxl.read.biff.BiffException;
import jxl.write.WriteException;
import twitter4j.auth.AccessToken;

import android.util.Log;

import androidx.annotation.Nullable;
import androidx.core.app.NotificationCompat;

import com.example.flutter_redux_firebase.utils.BooleanExceptionResult;
import com.example.flutter_redux_firebase.utils.ExcelUtils;
import com.example.flutter_redux_firebase.utils.XAuthUtils;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Random;

public class TweetingForegroundService extends Service {
    public static final String CHANNEL_ID = "TweetingForegroundService";
    public static boolean RUNNING = false;
    private int PRIVATE_MODE = 0;
    private String PREF_NAME = "mindorks-welcome";
    private Thread t;

    @Override
    public void onCreate() {
        super.onCreate();
    }

    @Override
    public int onStartCommand(final Intent intent, int flags, int startId) {
        String action = intent.getStringExtra("action");
        if (action != null && action.equals("abort")) {
            stopSelf();
            if (t!=null && t.isAlive()) {
                t.interrupt();
            }
            // for stopping the created thread
            return START_NOT_STICKY;
        }

        if (RUNNING) {
            return START_NOT_STICKY;
        }

        int minSec = intent.getIntExtra("minSec", 60);

        // ensure minSec is not less than 60
        minSec = minSec < 60 ? 60 : minSec;

        int maxSec = intent.getIntExtra("maxSec", 90);
        int temp = 0;
        if (minSec > maxSec) {
            temp = minSec;
            minSec = maxSec;
            maxSec = temp;
        }

        // difference must be atleast 100 sec.
        int difference = maxSec - minSec;
        if (difference < 100) {
            maxSec = minSec + 100;
        }

        final int min = minSec;
        final int max = maxSec;

        createNotificationChannel();

        Intent notificationIntent = new Intent(this, MainActivity.class);
        PendingIntent pendingIntent = PendingIntent.getActivity(this,
                0, notificationIntent, 0);
        NotificationManager nm = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
        NotificationCompat.Builder builder = new NotificationCompat.Builder(this, CHANNEL_ID)
                .setContentTitle("Foreground Service")
                .setSmallIcon(R.mipmap.logo)
                .setContentIntent(pendingIntent)
                .setOnlyAlertOnce(true);

        //do heavy work on a background thread
        t = new Thread(new Runnable() {
            SharedPreferences sp = getSharedPreferences(PREF_NAME, PRIVATE_MODE);

            @Override
            public void run() {
                int success = 0;
                int failed = 0;
                int remaining = 0;
                int total = 0;
                try {
                    RUNNING = true;
                    sp.edit().putString("running", "true").commit();
                    String pathName = intent.getStringExtra("excelFile");
                    String twitterHandle = intent.getStringExtra("twitterHandle");
                    String password = intent.getStringExtra("password");
                    ArrayList<Integer> failedCodes = new ArrayList<>();
                    int consecFailures = 0;
                    AccessToken token = XAuthUtils.chkLogin(twitterHandle, password);
                    File excelFile = new File(pathName);
                    ArrayList<Integer> indices = ExcelUtils.getTweetRowIndices(excelFile);
                    total = indices.size();
                    remaining = total;
                    builder.setProgress(total, success + failed, false);
                    builder.setContentText("REMAINING: " + remaining);
                    Notification notification = builder.build();
                    startForeground(1, notification);
                    Random r = new Random();
                    for (int i = 0; i < indices.size(); i++) {
                        int curIndex = indices.get(i);
                        String tweet = ExcelUtils.getTweetAtCell(excelFile, curIndex);
                        BooleanExceptionResult result = XAuthUtils.postTweet(token, tweet);
                        Log.d("BooleanExceptionResult", result.toString());
                        Log.d("TWEET", tweet);
                        String outTxt = null;
                        int code = 1;
                        if (result.getException() == null) {
                            outTxt = "Tweeted Successfully!";
                            success++;
                            consecFailures = 0;
                            failedCodes.clear();
                        } else {
                            outTxt = result.getException();
                            code = result.getCode();
                            failed++;
                            consecFailures++;
                            failedCodes.add(code);
                        }
                        remaining--;
                        ExcelUtils.putValueInCellModifyOriginalSheet(TweetingForegroundService.this, excelFile, outTxt
                                , curIndex, 1);
                        ExcelUtils.putValueInCellModifyOriginalSheet(TweetingForegroundService.this, excelFile, String.valueOf(code)
                                , curIndex, 2);
                        int interval = r.nextInt(max - min) + min;

                        // check for consecutive failures to be 3 or more. if so, terminate
                        if (consecFailures >= 3) {
                            stopSelf();
                            builder.setStyle(new NotificationCompat.BigTextStyle().bigText(
                                    ("Codes: " + failedCodes)));
                            builder.setContentText("Consecutive Failures");
                            builder.setOnlyAlertOnce(false);
                            nm.notify(1, builder.build());
                            return;
                        }
                        builder.setStyle(new NotificationCompat.BigTextStyle().bigText(
                                ("SUCCESS: " + success + " FAILED: " + failed + " REMAINING: " + remaining)));
                        builder.setContentText("SLEEP(seconds): " + interval);
                        builder.setProgress(total, success + failed, false);
                        nm.notify(1, builder.build());

                        if (i < indices.size() - 1) {
                            // find the random sleep interval
                            Thread.sleep(interval * 1000);
                        }
                    }
                    stopSelf();
                    builder.setContentText("Finished!");
                    builder.setProgress(total, total, false);
                    builder.setStyle(new NotificationCompat.BigTextStyle().bigText(
                            ("SUCCESS: " + success + " FAILED: " + failed + " REMAINING: " + remaining)));
                    nm.notify(1, builder.build());
                } catch (InterruptedException e) {
                    stopSelf();
                    builder.setContentText("Stopped!");
                    builder.setProgress(total, total, false);
                    builder.setStyle(new NotificationCompat.BigTextStyle().bigText(
                            ("SUCCESS: " + success + " FAILED: " + failed + " REMAINING: " + remaining)));
                    nm.notify(1, builder.build());
                } catch (Exception e) {
                    stopSelf();
                    builder.setContentText("Abnormal Termination!");
                    builder.setStyle(new NotificationCompat.BigTextStyle().bigText(e.getMessage() + "\n" + XAuthUtils.traceToString(e)));
                    nm.notify(1, builder.build());
                } finally {
                    RUNNING = false;
                    sp.edit().putString("running", "false").commit();
                    sp.edit().remove("token").commit();
                }
            }
        });
        t.start();

        //stopSelf();

        return START_NOT_STICKY;
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        SharedPreferences sp = getSharedPreferences(PREF_NAME, PRIVATE_MODE);
        sp.edit().putString("running", "false").commit();
        RUNNING = false;
    }

    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    private void createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel serviceChannel = new NotificationChannel(
                    CHANNEL_ID,
                    "Foreground Service Channel",
                    NotificationManager.IMPORTANCE_DEFAULT
            );

            NotificationManager manager = getSystemService(NotificationManager.class);
            manager.createNotificationChannel(serviceChannel);
        }
    }
}