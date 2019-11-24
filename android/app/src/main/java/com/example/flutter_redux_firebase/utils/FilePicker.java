package com.example.flutter_redux_firebase.utils;

import android.content.Context;
import android.widget.Toast;

import com.example.flutter_redux_firebase.R;
import com.obsez.android.lib.filechooser.ChooserDialog;

import java.io.File;

import io.flutter.plugin.common.MethodChannel;

public class FilePicker {
    public static void showPicker(Context context, MethodChannel.Result p1, String startPath) {
        new ChooserDialog(context)
                .withFilter(false, false, "xls")
                .withStartFile(startPath)
                .withResources(R.string.title_choose_file, R.string.title_choose, R.string.dialog_cancel)
                .withChosenListener(new ChooserDialog.Result() {
                    @Override
                    public void onChoosePath(String path, File pathFile) {
                        Toast.makeText(context, "FILE: " + path, Toast.LENGTH_SHORT).show();
                        p1.success(path);
                    }
                })
                .build()
                .show();
    }
}
