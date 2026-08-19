#!/usr/bin/env bash
set -euo pipefail

APP_DIR="$HOME/workspace/PureSoccerAnalyzer"
APK_OUT="$HOME/workspace/퓨어축구분석기_V1.apk"

echo "=============================================="
echo "   퓨어축구분석기 V1 - 원클릭 APK 빌드"
echo "=============================================="

mkdir -p "$HOME/workspace"
rm -rf "$APP_DIR"
mkdir -p "$APP_DIR/app/src/main/java/com/pureanalysis/soccer"
mkdir -p "$APP_DIR/app/src/main/res/values"
mkdir -p "$APP_DIR/app/src/main/res/drawable"

cat > "$APP_DIR/settings.gradle" <<'EOF'
pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
    }
}
rootProject.name = "PureSoccerAnalyzer"
include(":app")
EOF

cat > "$APP_DIR/build.gradle" <<'EOF'
plugins {
    id 'com.android.application' version '8.5.2' apply false
}
EOF

cat > "$APP_DIR/gradle.properties" <<'EOF'
org.gradle.jvmargs=-Xmx2048m -Dfile.encoding=UTF-8
android.useAndroidX=true
EOF

cat > "$APP_DIR/app/build.gradle" <<'EOF'
plugins {
    id 'com.android.application'
}

android {
    namespace 'com.pureanalysis.soccer'
    compileSdk 35

    defaultConfig {
        applicationId "com.pureanalysis.soccer"
        minSdk 26
        targetSdk 35
        versionCode 1
        versionName "1.0"
    }

    buildTypes {
        debug {
            debuggable true
        }
        release {
            minifyEnabled false
        }
    }
}
EOF

cat > "$APP_DIR/app/src/main/AndroidManifest.xml" <<'EOF'
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
    <uses-permission android:name="android.permission.WAKE_LOCK"/>

    <application
        android:allowBackup="true"
        android:label="퓨어축구 분석기"
        android:theme="@style/AppTheme">
        <activity
            android:name=".MainActivity"
            android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
    </application>
</manifest>
EOF

cat > "$APP_DIR/app/src/main/res/values/styles.xml" <<'EOF'
<resources>
    <style name="AppTheme" parent="android:style/Theme.Material.NoActionBar">
        <item name="android:fontFamily">sans</item>
        <item name="android:statusBarColor">#08111F</item>
        <item name="android:navigationBarColor">#08111F</item>
        <item name="android:windowLightStatusBar">false</item>
        <item name="android:colorAccent">#39A7FF</item>
    </style>
</resources>
EOF

cat > "$APP_DIR/app/src/main/res/drawable/card_bg.xml" <<'EOF'
<shape xmlns:android="http://schemas.android.com/apk/res/android">
    <solid android:color="#121F34"/>
    <corners android:radius="18dp"/>
    <stroke android:width="1dp" android:color="#233B5B"/>
</shape>
EOF

cat > "$APP_DIR/app/src/main/res/drawable/btn_bg.xml" <<'EOF'
<shape xmlns:android="http://schemas.android.com/apk/res/android">
    <solid android:color="#1877F2"/>
    <corners android:radius="14dp"/>
</shape>
EOF

cat > "$APP_DIR/app/src/main/java/com/pureanalysis/soccer/MainActivity.java" <<'EOF'
package com.pureanalysis.soccer;

import android.app.Activity;
import android.os.Bundle;
import android.graphics.Color;
import android.graphics.Typeface;
import android.view.Gravity;
import android.widget.*;
import java.text.SimpleDateFormat;
import java.util.*;

public class MainActivity extends Activity {

    private LinearLayout body;
    private TextView lastUpdate;

    private final int BG = Color.rgb(8,17,31);
    private final int CARD = Color.rgb(18,31,52);
    private final int TEXT = Color.rgb(240,246,255);
    private final int SUB = Color.rgb(157,178,205);
    private final int BLUE = Color.rgb(57,167,255);
    private final int GREEN = Color.rgb(50,211,153);
    private final int YELLOW = Color.rgb(250,190,60);

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        renderHome();
    }

    private int dp(int v) {
        return (int)(v * getResources().getDisplayMetrics().density + 0.5f);
    }

    private TextView txt(String s, int sp, int color, boolean bold) {
        TextView t = new TextView(this);
        t.setText(s);
        t.setTextSize(sp);
        t.setTextColor(color);
        t.setPadding(0, dp(4), 0, dp(4));
        if (bold) t.setTypeface(Typeface.DEFAULT, Typeface.BOLD);
        return t;
    }

    private LinearLayout card() {
        LinearLayout c = new LinearLayout(this);
        c.setOrientation(LinearLayout.VERTICAL);
        c.setPadding(dp(16),dp(14),dp(16),dp(14));
        c.setBackgroundResource(com.pureanalysis.soccer.R.drawable.card_bg);
        LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(-1,-2);
        lp.setMargins(dp(12),dp(8),dp(12),dp(8));
        c.setLayoutParams(lp);
        return c;
    }

    private Button button(String label) {
        Button b = new Button(this);
        b.setText(label);
        b.setTextColor(Color.WHITE);
        b.setTextSize(14);
        b.setAllCaps(false);
        b.setBackgroundResource(com.pureanalysis.soccer.R.drawable.btn_bg);
        return b;
    }

    private void addLeague(String name, String games, int blue, int strong, int hold, int bad) {
        LinearLayout c = card();
        LinearLayout top = new LinearLayout(this);
        top.setGravity(Gravity.CENTER_VERTICAL);

        top.addView(txt(name,17,TEXT,true), new LinearLayout.LayoutParams(0,-2,1f));

        Button b = button("↻");
        b.setOnClickListener(v ->
            Toast.makeText(this, name + " 재분석", Toast.LENGTH_SHORT).show()
        );
        top.addView(b, new LinearLayout.LayoutParams(dp(58),dp(46)));
        c.addView(top);

        c.addView(txt(
            games + "  |  🔵 " + blue + "  🟢 " + strong + "  🟡 " + hold + "  🔴 " + bad,
            14, SUB, false
        ));
        body.addView(c);
    }

    private void addComboCard(String title, String pool, String state, String desc, boolean combo) {
        LinearLayout c = card();
        LinearLayout top = new LinearLayout(this);
        top.setGravity(Gravity.CENTER_VERTICAL);

        top.addView(txt(title,19,TEXT,true), new LinearLayout.LayoutParams(0,-2,1f));
        top.addView(txt(state,14, combo ? GREEN : SUB,true));
        c.addView(top);

        c.addView(txt(pool,12,SUB,false));
        c.addView(txt(desc,15,combo ? TEXT : SUB,true));

        if (combo) {
            c.addView(txt("총 배당 2.08  ※ 조합 생성 시에만 표시",15,GREEN,true));
        }
        body.addView(c);
    }

    private void renderHome() {
        LinearLayout root = new LinearLayout(this);
        root.setOrientation(LinearLayout.VERTICAL);
        root.setBackgroundColor(BG);

        ScrollView scroll = new ScrollView(this);
        body = new LinearLayout(this);
        body.setOrientation(LinearLayout.VERTICAL);
        body.setPadding(dp(4),dp(12),dp(4),dp(16));
        scroll.addView(body);

        LinearLayout header = card();
        header.addView(txt("⚽ 퓨어축구 분석기",24,TEXT,true));
        header.addView(txt("배당 제외 · 경기정보 기반 · PASS 우선",13,BLUE,false));

        lastUpdate = txt("마지막 업데이트: --:--:--",12,SUB,false);
        header.addView(lastUpdate);

        Button refresh = button("↻ 전체 새로고침 / 재검증");
        refresh.setOnClickListener(v -> {
            String now = new SimpleDateFormat("HH:mm:ss", Locale.KOREA).format(new Date());
            lastUpdate.setText("마지막 업데이트: " + now);
            Toast.makeText(this,
                "라인업 · 부상 · 일정 · 날씨 · 반례조건을 다시 검사합니다.",
                Toast.LENGTH_SHORT).show();
        });
        header.addView(refresh);
        body.addView(header);

        addComboCard(
            "🌏 아시아 조합",
            "K리그1 · J1 · AFC 챔피언스리그 엘리트",
            "PASS",
            "🔵 최종통과 1경기\n조합 조건 미충족",
            false
        );

        addComboCard(
            "🇪🇺 유럽 조합",
            "EPL · 라리가 · 분데스리가 · 세리에A · 리그1 · UCL",
            "조합픽 생성",
            "Arsenal 승 + Barcelona 승\n※ 데모 화면",
            true
        );

        addLeague("K리그1","6경기",1,2,2,1);
        addLeague("J1리그","10경기",1,3,4,2);
        addLeague("AFC 챔피언스리그 엘리트","0경기",0,0,0,0);
        addLeague("프리미어리그","10경기",2,2,3,3);
        addLeague("라리가","10경기",1,3,3,3);
        addLeague("분데스리가","9경기",1,2,3,3);
        addLeague("세리에A","10경기",1,2,4,3);
        addLeague("리그1","9경기",0,3,3,3);
        addLeague("UEFA 챔피언스리그","0경기",0,0,0,0);
        addLeague("AFC 아시안컵","대회기간 활성화",0,0,0,0);

        LinearLayout realtime = card();
        realtime.addView(txt("실시간 검증 상태",19,TEXT,true));
        realtime.addView(txt("⏳ 확정 라인업 대기",15,YELLOW,true));
        realtime.addView(txt(
            "예상 라인업 · 부상/징계 · 골키퍼 · 최근 xG/xGA · 휴식/원정 · 전술상성 · 세트피스 · 날씨",
            13,SUB,false
        ));
        realtime.addView(txt("라인업 발표 예상까지 00:42:18",16,BLUE,true));
        realtime.addView(txt(
            "라인업 확정 후 → 유사패배 반례 → 반례의 반례 → 뉴스/날씨 재검증 → 🔵 또는 PASS",
            13,TEXT,false
        ));
        body.addView(realtime);

        LinearLayout record = card();
        record.addView(txt("누적 기록",19,TEXT,true));
        record.addView(txt("아시아 조합  0승 0패 · PASS 0회",14,GREEN,true));
        record.addView(txt("유럽 조합    0승 0패 · PASS 0회",14,GREEN,true));
        record.addView(txt("최종통과 후보 개별 적중률  --",14,SUB,false));
        record.addView(txt(
            "※ 분석에서는 배당을 사용하지 않습니다.\n조합픽 생성 시에만 총 배당을 표시합니다.",
            13,SUB,false
        ));
        body.addView(record);

        LinearLayout nav = new LinearLayout(this);
        nav.setOrientation(LinearLayout.HORIZONTAL);
        nav.setGravity(Gravity.CENTER);
        nav.setBackgroundColor(CARD);

        String[] names = {"홈","리그","분석","기록","알림"};
        for (String n : names) {
            Button b = new Button(this);
            b.setText(n);
            b.setTextColor(n.equals("홈") ? BLUE : SUB);
            b.setAllCaps(false);
            b.setBackgroundColor(Color.TRANSPARENT);
            nav.addView(b,new LinearLayout.LayoutParams(0,dp(54),1f));
        }

        root.addView(scroll,new LinearLayout.LayoutParams(-1,0,1f));
        root.addView(nav);
        setContentView(root);
    }
}
EOF

echo "[1/4] Java / 도구 확인..."
if ! command -v java >/dev/null 2>&1; then
  sudo apt-get update
  sudo apt-get install -y openjdk-17-jdk wget unzip
fi

export JAVA_HOME="${JAVA_HOME:-/usr/lib/jvm/msopenjdk-current}"

echo "[2/4] Gradle 준비..."
mkdir -p "$HOME/.local/gradle"
if [ ! -x "$HOME/.local/gradle/gradle-8.7/bin/gradle" ]; then
  wget -q https://services.gradle.org/distributions/gradle-8.7-bin.zip -O /tmp/gradle.zip
  unzip -q -o /tmp/gradle.zip -d "$HOME/.local/gradle"
fi
export PATH="$HOME/.local/gradle/gradle-8.7/bin:$PATH"

echo "[3/4] Android SDK 준비..."
export ANDROID_HOME="$HOME/android-sdk"
export ANDROID_SDK_ROOT="$ANDROID_HOME"

if [ ! -x "$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" ]; then
  wget -q https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -O /tmp/cmdtools.zip
  rm -rf /tmp/cmdtools
  mkdir -p /tmp/cmdtools
  unzip -q /tmp/cmdtools.zip -d /tmp/cmdtools
  mkdir -p "$ANDROID_HOME/cmdline-tools/latest"
  cp -R /tmp/cmdtools/cmdline-tools/* "$ANDROID_HOME/cmdline-tools/latest/"
fi

export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH"

yes | sdkmanager --licenses >/dev/null || true
sdkmanager "platform-tools" "platforms;android-35" "build-tools;35.0.0" >/dev/null

echo "[4/4] APK 빌드..."
cd "$APP_DIR"
gradle --no-daemon :app:assembleDebug

cp "$APP_DIR/app/build/outputs/apk/debug/app-debug.apk" "$APK_OUT"

echo ""
echo "=============================================="
echo "완료!"
echo "APK 생성 위치:"
echo "$APK_OUT"
echo ""
echo "Codespaces 왼쪽 파일 목록에서:"
echo "workspace → 퓨어축구분석기_V1.apk"
echo "를 다운로드하면 됩니다."
echo "=============================================="
