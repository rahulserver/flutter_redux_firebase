package com.example.flutter_redux_firebase.utils;

import androidx.annotation.NonNull;

import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.firestore.DocumentReference;
import com.google.firebase.firestore.DocumentSnapshot;
import com.google.firebase.firestore.FirebaseFirestore;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.TimeZone;

import io.flutter.Log;
import io.flutter.plugin.common.MethodChannel;

public class FirestoreUtils {
    MethodChannel.Result result;
    String twitterHandle;

    public FirestoreUtils(MethodChannel.Result result, String twitterHandle) {
        this.result = result;
        this.twitterHandle = twitterHandle;
    }

    public void checkUser() {
        FirebaseFirestore db = FirebaseFirestore.getInstance();
        DocumentReference docRef = db.collection("users")
                .document(twitterHandle);

        docRef.get().addOnCompleteListener(new OnCompleteListener<DocumentSnapshot>() {
            @Override
            public void onComplete(@NonNull Task<DocumentSnapshot> task) {
                if (task.isSuccessful()) {
                    DocumentSnapshot document = task.getResult();
                    if (document.exists()) {
                        Log.d("FIRESTORE", "Document exists " + document.getData().toString());
                    } else {
                        Log.d("FIRESTORE", "Document does not exist");
                    }
                    result.success(document.getData());
                    Log.d("FIRESTORE", String.valueOf(document.getData()));
                } else {
                    Log.d("FIRESTORE", "Failed with: ", task.getException());
                    result.error("Error", "Error", task.getException().getMessage());
                }
            }
        });
    }

    public void setTimestampForUser() {
        FirebaseFirestore db = FirebaseFirestore.getInstance();
        DocumentReference docRef = db.collection("users").document(twitterHandle);
        HashMap<String, Object> data = new HashMap<>();
        data.put("last_timestamp", System.currentTimeMillis());
        data.put("ist_string", getTimeStringInIST());
        docRef.update(data);
        // TODO handle success or failed events. Currently we don't bother
        result.success("done");
    }

    private String getTimeStringInIST() {
        SimpleDateFormat sd = new SimpleDateFormat(
                "dd-MM-yyyy 'at' HH:mm:ss z");
        Date date = new Date();
        // TODO: Avoid using the abbreviations when fetching time zones.
        // Use the full Olson zone ID instead.
        sd.setTimeZone(TimeZone.getTimeZone("IST"));
        return sd.format(date);
    }
}

class FirebaseResponse {
    boolean exists = false;
    boolean active = false;
    String twitterHandle;
    String email;

    public FirebaseResponse(boolean exists, boolean active, String twitterHandle, String email) {
        this.exists = exists;
        this.active = active;
        this.twitterHandle = twitterHandle;
        this.email = email;
    }

    public boolean isExists() {
        return exists;
    }

    public void setExists(boolean exists) {
        this.exists = exists;
    }

    public boolean isActive() {
        return active;
    }

    public void setActive(boolean active) {
        this.active = active;
    }

    public String getTwitterHandle() {
        return twitterHandle;
    }

    public void setTwitterHandle(String twitterHandle) {
        this.twitterHandle = twitterHandle;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }
}
