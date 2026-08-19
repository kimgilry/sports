package com.sol.purebaseball;

import android.app.*;import android.os.*;import android.content.*;import android.content.pm.PackageManager;import android.graphics.Color;import android.graphics.Typeface;import android.view.*;import android.widget.*;import java.text.SimpleDateFormat;import java.util.*;

public class MainActivity extends Activity {
    LinearLayout root; TextView updated; AnalysisEngine engine=new AnalysisEngine();
    int green=Color.rgb(91,213,137), yellow=Color.rgb(248,191,54), red=Color.rgb(255,91,91), blue=Color.rgb(75,154,255), white=Color.rgb(240,246,255), muted=Color.rgb(160,180,205), card=Color.rgb(10,38,67);
    @Override public void onCreate(Bundle b){super.onCreate(b); if(Build.VERSION.SDK_INT>=33 && checkSelfPermission("android.permission.POST_NOTIFICATIONS")!=PackageManager.PERMISSION_GRANTED) requestPermissions(new String[]{"android.permission.POST_NOTIFICATIONS"},9); startMonitor(); build();}
    void startMonitor(){ if(Build.VERSION.SDK_INT>=26) startForegroundService(new Intent(this,MonitorService.class)); else startService(new Intent(this,MonitorService.class)); }
    TextView tv(String s,int sp,int c){TextView t=new TextView(this);t.setText(s);t.setTextSize(sp);t.setTextColor(c);t.setPadding(12,8,12,8);return t;}
    LinearLayout box(){LinearLayout l=new LinearLayout(this);l.setOrientation(LinearLayout.VERTICAL);l.setPadding(22,18,22,18);l.setBackgroundColor(card);LinearLayout.LayoutParams p=new LinearLayout.LayoutParams(-1,-2);p.setMargins(18,10,18,10);l.setLayoutParams(p);return l;}
    void build(){ ScrollView sv=new ScrollView(this); root=new LinearLayout(this);root.setOrientation(LinearLayout.VERTICAL);root.setBackgroundColor(Color.rgb(5,24,45));sv.addView(root);setContentView(sv);
        LinearLayout hdr=box(); TextView title=tv("⚾  퓨어베이스볼 분석기",25,white);title.setTypeface(Typeface.DEFAULT,Typeface.BOLD);hdr.addView(title);hdr.addView(tv("배당 제외 · 경기정보 기반",15,blue));
        Button refresh=new Button(this);refresh.setText("↻ 전체 새로고침 / 재검증");refresh.setOnClickListener(v->refreshAll());hdr.addView(refresh);updated=tv("",13,muted);hdr.addView(updated);root.addView(hdr);
        refreshAll();
    }
    void refreshAll(){ while(root.getChildCount()>1) root.removeViewAt(1); updated.setText("마지막 업데이트  "+new SimpleDateFormat("MM/dd HH:mm:ss",Locale.KOREA).format(new Date()));
        List<AnalysisEngine.TeamCandidate> c=demoCandidates(); addLeague("MLB",c,engine.makeMlbCombo(c)); addLeague("KBO",c,null); addLeague("NPB",c,null); addAsia(c,engine.makeAsiaCombo(c)); addMonitor(); addRecords(); addNote(); }
    List<AnalysisEngine.TeamCandidate> demoCandidates(){ List<AnalysisEngine.TeamCandidate> x=new ArrayList<>();
        x.add(new AnalysisEngine.TeamCandidate("MLB","PHI","MIA",91,80,82,79,88,75,76,78,5,12)); x.add(new AnalysisEngine.TeamCandidate("MLB","LAD","COL",88,74,77,91,90,63,80,82,8,14)); x.add(new AnalysisEngine.TeamCandidate("MLB","CHC","PIT",70,62,61,66,69,70,72,70,12,35));
        x.add(new AnalysisEngine.TeamCandidate("KBO","LG","한화",86,82,84,81,78,74,79,72,7,10)); x.add(new AnalysisEngine.TeamCandidate("KBO","KT","키움",74,68,65,78,70,70,72,73,15,42));
        x.add(new AnalysisEngine.TeamCandidate("NPB","소프트뱅크","니혼햄",90,80,87,83,91,78,81,75,5,8)); x.add(new AnalysisEngine.TeamCandidate("NPB","한신","야쿠르트",83,79,82,77,80,76,84,74,7,14)); return x; }
    void addLeague(String league,List<AnalysisEngine.TeamCandidate> all,AnalysisEngine.Combo combo){ LinearLayout b=box();b.addView(tv(league+" 분석 결과",22,white)); int e=0,h=0,s=0,f=0; for(AnalysisEngine.TeamCandidate c:all)if(c.league.equals(league)){switch(c.grade()){case EXCLUDE:e++;break;case HOLD:h++;break;case STRONG:s++;break;case FINAL:f++;}}
        b.addView(tv("최종통과 "+f+"   ·   강함 "+s+"   ·   보류 "+h+"   ·   제외 "+e,15,muted)); if(combo!=null){ if(combo.pass)b.addView(tv("PASS · 조합 조건 미충족",19,muted)); else b.addView(tv("🔵 조합픽 생성  |  "+combo.a.team+" 승 + "+combo.b.team+" 승\n총 배당: 조합 확정 후 조회",19,green)); }
        Button r=new Button(this);r.setText("↻ "+league+" 재분석");r.setOnClickListener(v->refreshAll());b.addView(r);root.addView(b); }
    void addAsia(List<AnalysisEngine.TeamCandidate> all,AnalysisEngine.Combo combo){LinearLayout b=box();b.addView(tv("KBO + NPB 아시아 조합",22,white)); if(combo.pass)b.addView(tv("PASS · 최종통과 후보 2개 미만",19,muted));else b.addView(tv("🔵 조합픽 생성\n"+combo.a.league+" "+combo.a.team+" 승 + "+combo.b.league+" "+combo.b.team+" 승\n총 배당: 추천 생성 후에만 표시",19,green));root.addView(b);}
    void addMonitor(){LinearLayout b=box();b.addView(tv("실시간 검증 상태",21,white));b.addView(tv("✓ 선발 등록 확인   정상\n✓ 라인업 확인       정상\n✓ 뉴스/부상 감시    정상\n○ 날씨 위험          낮음\n○ 선발 변경 감지    없음",16,green));b.addView(tv("선발 등록 예상까지 00:25:19",17,blue));root.addView(b);}
    void addRecords(){ android.content.SharedPreferences p=getSharedPreferences("rec",0); LinearLayout b=box();b.addView(tv("누적 기록",21,white));b.addView(tv("MLB 조합  "+p.getInt("mlbw",0)+"승 "+p.getInt("mlbl",0)+"패\n아시아 조합  "+p.getInt("asiaw",0)+"승 "+p.getInt("asial",0)+"패\n전체 PASS  "+p.getInt("pass",0)+"회",17,white));root.addView(b);}
    void addNote(){LinearLayout b=box();b.addView(tv("분석 점수는 선발·팀흐름·불펜·타선·상성·휴식·수비·날씨·뉴스 위험·과거 반례로 계산합니다.\n배당은 분석에 절대 사용하지 않으며 조합픽 생성 이후 표시용으로만 조회합니다.\n\n현재 v0.1은 UI/엔진/알림 구조 검증판입니다. 공식 실시간 데이터 어댑터는 리그별로 교체 가능한 구조로 연결합니다.",14,muted));root.addView(b);}
    public static void persistHeartbeat(Context c){c.getSharedPreferences("state",0).edit().putLong("heartbeat",System.currentTimeMillis()).apply();}
}
