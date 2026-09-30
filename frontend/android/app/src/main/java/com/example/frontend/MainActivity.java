package com.example.frontend;

import android.content.Intent;
import android.net.Uri;

import androidx.annotation.NonNull;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    private static final String PHONE_CHANNEL = "construction_site/phone";

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), PHONE_CHANNEL)
                .setMethodCallHandler((call, result) -> {
                    if (!"openDialer".equals(call.method)) {
                        result.notImplemented();
                        return;
                    }

                    String phoneNumber = call.argument("phoneNumber");
                    if (phoneNumber == null || phoneNumber.trim().isEmpty()) {
                        result.success(false);
                        return;
                    }

                    Intent intent = new Intent(Intent.ACTION_DIAL);
                    intent.setData(Uri.parse("tel:" + Uri.encode(phoneNumber.trim())));

                    if (intent.resolveActivity(getPackageManager()) == null) {
                        result.success(false);
                        return;
                    }

                    startActivity(intent);
                    result.success(true);
                });
    }
}
