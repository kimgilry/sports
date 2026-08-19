#!/usr/bin/env bash
set -euo pipefail

APP_DIR="$HOME/workspace/PureSoccerAnalyzer"
APK_OUT="$HOME/workspace/퓨어축구분석기_V1.1.apk"

echo "================================================"
echo "  퓨어축구분석기 V1.1 - 모바일 Codespaces 원클릭"
echo "================================================"

mkdir -p "$HOME/workspace"
rm -rf "$APP_DIR"
mkdir -p "$APP_DIR/app/src/main/java/com/pureanalysis/soccer"
mkdir -p "$APP_DIR/app/src/main/res/values"
mkdir -p "$APP_DIR/app/src/main/res/drawable"

echo "[1/5] Java 17 강제 준비..."
sudo apt-get update -y >/dev/null
sudo apt-get install -y openjdk-17-jdk wget unzip >/dev/null

JAVA17="$(dirname "$(dirname "$(readlink -f "$(command -v javac)")")")"
if [ -d /usr/lib/jvm/java-17-openjdk-amd64 ]; then
  JAVA17="/usr/lib/jvm/java-17-openjdk-amd64"
fi
export JAVA_HOME="$JAVA17"
export PATH="$JAVA_HOME/bin:$PATH"

echo "JAVA_HOME=$JAVA_HOME"
java -version

MAJOR="$(java -version 2>&1 | awk -F[\".] '/version/ {print $2}')"
if [ "${MAJOR:-0}" -lt 17 ]; then
  echo "Java 17 전환 실패"
  exit 1
fi

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

cat > "$APP_DIR/gradle.properties" <<EOF
org.gradle.jvmargs=-Xmx2048m -Dfile.encoding=UTF-8
android.useAndroidX=true
org.gradle.java.home=$JAVA_HOME
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
        versionCode 2
        versionName "1.1"
    }

    buildTypes {
        debug { debuggable true }
        release { minifyEnabled false }
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
        <activity android:name=".MainActivity" android:exported="true">
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
            Toast.makeText(this, name + " 경기 시작 전 정보만 재검증", Toast.LENGTH_SHORT).show()
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
        header.addView(txt("⚽ 퓨어축구 분석기 V1.1",24,TEXT,true));
        header.addView(txt("배당 제외 · PRE-GAME ONLY · PASS 우선",13,BLUE,false));
        header.addView(txt("경기 시작 후 데이터는 분석에 절대 반영하지 않음",13,YELLOW,true));

        lastUpdate = txt("마지막 업데이트: --:--:--",12,SUB,false);
        header.addView(lastUpdate);

        Button refresh = button("↻ 경기 시작 전 정보 재검증");
        refresh.setOnClickListener(v -> {
            String now = new SimpleDateFormat("HH:mm:ss", Locale.KOREA).format(new Date());
            lastUpdate.setText("마지막 업데이트: " + now);
            Toast.makeText(this,
                "시작 전 라인업 · 부상 · 일정 · 날씨 · 반례조건만 다시 검사합니다.",
                Toast.LENGTH_SHORT).show();
        });
        header.addView(refresh);
        body.addView(header);

        LinearLayout lock = card();
        lock.addView(txt("🔒 경기 시작 잠금 규칙",19,TEXT,true));
        lock.addView(txt("예정 → 사전분석 → 라인업확정 → 🔵/PASS → 경기 시작 5분 전 잠금",14,TEXT,false));
        lock.addView(txt("LIVE 경기: 분석 제외 · 실시간 스코어/경기내용 미사용",14,YELLOW,true));
        lock.addView(txt("종료 경기: 결과만 적중/실패 누적기록에 반영",14,GREEN,true));
        body.addView(lock);

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
        realtime.addView(txt("실시간 PRE-GAME 검증 상태",19,TEXT,true));
        realtime.addView(txt("⏳ 확정 라인업 대기",15,YELLOW,true));
        realtime.addView(txt(
            "예상 라인업 · 부상/징계 · 골키퍼 · 최근 xG/xGA · 휴식/원정 · 전술상성 · 세트피스 · 날씨",
            13,SUB,false
        ));
        realtime.addView(txt("라인업 발표 예상까지 00:42:18",16,BLUE,true));
        realtime.addView(txt(
            "라인업 확정 → 유사패배 반례 → 반례의 반례 → 뉴스/날씨 → 🔵 또는 PASS",
            13,TEXT,false
        ));
        body.addView(realtime);

        LinearLayout record = card();
        record.addView(txt("누적 기록",19,TEXT,true));
        record.addView(txt("아시아 조합  0승 0패 · PASS 0회",14,GREEN,true));
        record.addView(txt("유럽 조합    0승 0패 · PASS 0회",14,GREEN,true));
        record.addView(txt("LIVE 정보가 분석에 들어간 픽: 0",14,YELLOW,true));
        record.addView(txt("※ 종료 후 최종 결과만 정산에 사용",13,SUB,false));
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

echo "[2/5] Gradle 준비..."
mkdir -p "$HOME/.local/gradle"
if [ ! -x "$HOME/.local/gradle/gradle-8.7/bin/gradle" ]; then
  wget -q https://services.gradle.org/distributions/gradle-8.7-bin.zip -O /tmp/gradle.zip
  unzip -q -o /tmp/gradle.zip -d "$HOME/.local/gradle"
fi
export PATH="$HOME/.local/gradle/gradle-8.7/bin:$PATH"

echo "[3/5] Android SDK 준비..."
export ANDROID_HOME="$HOME/android-sdk"
export ANDROID_SDK_ROOT="$ANDROID_HOME"

rm -rf "$ANDROID_HOME/cmdline-tools/latest"
mkdir -p "$ANDROID_HOME/cmdline-tools/latest"

wget -q https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -O /tmp/cmdtools.zip
rm -rf /tmp/cmdtools
mkdir -p /tmp/cmdtools
unzip -q /tmp/cmdtools.zip -d /tmp/cmdtools
cp -R /tmp/cmdtools/cmdline-tools/* "$ANDROID_HOME/cmdline-tools/latest/"

export PATH="$JAVA_HOME/bin:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH"

echo "sdkmanager Java 확인:"
java -version

yes | "$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" --licenses >/dev/null || true
"$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" \
  "platform-tools" \
  "platforms;android-35" \
  "build-tools;35.0.0" >/dev/null

echo "[4/5] APK 빌드..."
cd "$APP_DIR"
gradle --no-daemon :app:assembleDebug

echo "[5/5] APK 복사..."
cp "$APP_DIR/app/build/outputs/apk/debug/app-debug.apk" "$APK_OUT"

echo ""
echo "================================================"
echo "완료!"
echo "APK:"
echo "$APK_OUT"
echo ""
echo "Codespaces 왼쪽 파일:"
echo "workspace → 퓨어축구분석기_V1.1.apk"
echo "================================================"
