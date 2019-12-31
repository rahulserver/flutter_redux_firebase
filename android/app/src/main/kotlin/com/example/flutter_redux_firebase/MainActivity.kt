package com.example.flutter_redux_firebase

import android.Manifest
import android.annotation.TargetApi
import android.content.Intent
import android.content.SharedPreferences
import android.content.pm.PackageManager
import android.os.*
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat

import io.flutter.app.FlutterActivity
import io.flutter.plugins.GeneratedPluginRegistrant
import androidx.annotation.NonNull
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import android.util.Log
import android.widget.Toast
import com.example.flutter_redux_firebase.utils.FilePicker
import com.example.flutter_redux_firebase.utils.FirestoreUtils
import com.example.flutter_redux_firebase.utils.XAuthUtils
import twitter4j.auth.AccessToken


class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.flutter_redux_firebase/foreground"
    private var PRIVATE_MODE = 0
    private val PREF_NAME = "mindorks-welcome"

    @TargetApi(Build.VERSION_CODES.O)
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        GeneratedPluginRegistrant.registerWith(this)
        normalFlow();
        if ((ContextCompat.checkSelfPermission(this,
                        Manifest.permission.WRITE_EXTERNAL_STORAGE)
                        != PackageManager.PERMISSION_GRANTED)) {


            // No explanation needed, we can request the permission.
            ActivityCompat.requestPermissions(this,
                    arrayOf(Manifest.permission.WRITE_EXTERNAL_STORAGE),
                    10)

            // MY_PERMISSIONS_REQUEST_READ_CONTACTS is an
            // app-defined int constant. The callback method gets the
            // result of the request.
        }
    }

    override fun onRequestPermissionsResult(requestCode: Int, @NonNull permissions: Array<String>, @NonNull grantResults: IntArray) {
        print("PHERMISSIONS " + requestCode + " , " + permissions + " , " + grantResults);
        when (requestCode) {
            10 -> if (grantResults.get(0) == 0) {
                // Validate the permissions result
                normalFlow();
            } else {
                finish();
            }
        }
    }

    fun normalFlow() {
        var context = this;
        MethodChannel(flutterView, CHANNEL).setMethodCallHandler(
                object : MethodCallHandler {
                    override fun onMethodCall(p0: MethodCall, p1: MethodChannel.Result) {
                        // TODO("not implemented") //To change body of created functions use File | Settings | File Templates.
                        if (p0.method.equals("launch")) {
                            var intent = Intent(context, TweetingForegroundService::class.java);
                            intent.putExtra("minSec", Integer.parseInt(p0.argument<String>("minSec")));
                            intent.putExtra("maxSec", Integer.parseInt(p0.argument<String>("maxSec")));
                            intent.putExtra("excelFile", p0.argument<String>("excelFile"));
                            intent.putExtra("twitterHandle", p0.argument<String>("twitterHandle"));
                            intent.putExtra("password", p0.argument<String>("password"));
                            startService(intent);
                            Toast.makeText(context, "Tweeting started successfully!", 3000).show();
                            finish();
                            p1.success(null);
                        } else if (p0.method.equals("pick")) {
                            FilePicker.showPicker(context, p1, Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS).path);
                        } else if (p0.method.equals("abort")) {
                            var intent = Intent(context, TweetingForegroundService::class.java);
                            intent.putExtra("action", "abort");
                            startService(intent);
                            p1.success(null);
                        } else if (p0.method.equals("checkUser")) {
                            var twitterHandle = p0.argument<String>("twitterHandle");
                            FirestoreUtils(p1, twitterHandle).checkUser();
                        } else if (p0.method.equals("logTime")) {
                            var twitterHandle = p0.argument<String>("twitterHandle");
                            FirestoreUtils(p1, twitterHandle).setTimestampForUser();
                        } else if (p0.method.equals("sharedPrefs.set")) {
                            val sharedPref: SharedPreferences = getSharedPreferences(PREF_NAME, PRIVATE_MODE);
                            var keyToSave = p0.argument<String>("key");
                            var valueToSave = p0.argument<String>("value");
                            sharedPref.edit().putString(keyToSave, valueToSave).apply();
                            p1.success(null);
                        } else if (p0.method.equals("sharedPrefs.get")) {
                            val sharedPref: SharedPreferences = getSharedPreferences(PREF_NAME, PRIVATE_MODE);
                            var keyToGet = p0.argument<String>("key");
                            p1.success(sharedPref.getString(keyToGet, ""));
                        } else if (p0.method.equals("sharedPrefs.all")) {
                            val sharedPref: SharedPreferences = getSharedPreferences(PREF_NAME, PRIVATE_MODE);
                            p1.success(sharedPref.getAll());
                        } else if (p0.method.equals("loginUser")) {
                            Thread(Runnable {
                                var twitterHandle = p0.argument<String>("twitterHandle");
                                var password = p0.argument<String>("password");
                                Log.d("LOGINUSER", twitterHandle);
                                Log.d("LOGINUSER", password);
                                val token: AccessToken? = XAuthUtils.chkLogin(twitterHandle, password);
                                val mainHandler: Handler = Handler(Looper.getMainLooper());
                                val myRunnable = Runnable {
                                    if (token != null) {
                                        var token = token.getToken();
                                        p1.success(token);
                                    } else {
                                        p1.success(null);
                                    }
                                }
                                mainHandler.post(myRunnable);
                            }).start();
                        } else if (p0.method.equals("sharedPrefs.remove")) {
                            val sharedPref: SharedPreferences = getSharedPreferences(PREF_NAME, PRIVATE_MODE);
                            var key = p0.argument<String>("key");
                            sharedPref.edit().remove(key).commit();
                            p1.success(null);
                        }
                    }
                })

    }
}
