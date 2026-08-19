package com.sol.purebaseball;

import android.app.*;import android.content.*;import android.os.*;

public class MonitorService extends Service {
    public static final String CHANNEL="purebaseball_monitor";
    private final Handler handler=new Handler(Looper.getMainLooper());
    private final Runnable tick=new Runnable(){ public void run(){ MainActivity.persistHeartbeat(MonitorService.this); handler.postDelayed(this,15*60*1000L);} };
    @Override public void onCreate(){ super.onCreate();
        NotificationManager nm=getSystemService(NotificationManager.class);
        nm.createNotificationChannel(new NotificationChannel(CHANNEL,"경기 전 위험 감시",NotificationManager.IMPORTANCE_LOW));
        Notification n=new Notification.Builder(this,CHANNEL).setContentTitle("퓨어베이스볼 감시중").setContentText("선발·라인업·뉴스·날씨 변경을 주기적으로 확인합니다").setSmallIcon(android.R.drawable.ic_popup_sync).build();
        startForeground(1001,n); handler.post(tick);
    }
    @Override public void onDestroy(){handler.removeCallbacks(tick);super.onDestroy();}
    @Override public android.os.IBinder onBind(Intent i){return null;}
}
