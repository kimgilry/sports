package com.sol.purebaseball;

import java.util.*;

public class AnalysisEngine {
    public enum Grade { EXCLUDE, HOLD, STRONG, FINAL }
    public static class TeamCandidate {
        public String league, team, opponent;
        public int starter, form, bullpen, batting, matchup, rest, defense, weather, newsRisk, counterRisk;
        public TeamCandidate(String league,String team,String opponent,int starter,int form,int bullpen,int batting,int matchup,int rest,int defense,int weather,int newsRisk,int counterRisk){
            this.league=league;this.team=team;this.opponent=opponent;this.starter=starter;this.form=form;this.bullpen=bullpen;this.batting=batting;this.matchup=matchup;this.rest=rest;this.defense=defense;this.weather=weather;this.newsRisk=newsRisk;this.counterRisk=counterRisk;
        }
        public int score(){ return (starter*25 + form*18 + bullpen*15 + batting*12 + matchup*8 + rest*8 + defense*6 + weather*3)/95 - newsRisk/3 - counterRisk/3; }
        public Grade grade(){ int s=score(); if(newsRisk>=60 || counterRisk>=60 || s<54) return Grade.EXCLUDE; if(s<66) return Grade.HOLD; if(s<76) return Grade.STRONG; return Grade.FINAL; }
    }
    public static class Combo { public TeamCandidate a,b; public boolean pass; public Combo(TeamCandidate a,TeamCandidate b,boolean pass){this.a=a;this.b=b;this.pass=pass;} }

    public Combo makeMlbCombo(List<TeamCandidate> all){ return select(all,"MLB",false); }
    public Combo makeAsiaCombo(List<TeamCandidate> all){ return select(all,"ASIA",true); }
    private Combo select(List<TeamCandidate> all,String key,boolean asia){
        List<TeamCandidate> ok=new ArrayList<>();
        for(TeamCandidate c: all){ boolean in=asia?(c.league.equals("KBO")||c.league.equals("NPB")):c.league.equals("MLB"); if(in && c.grade()==Grade.FINAL) ok.add(c); }
        if(ok.size()<2) return new Combo(null,null,true);
        Combo best=null; int bestPair=-999;
        for(int i=0;i<ok.size();i++) for(int j=i+1;j<ok.size();j++){
            TeamCandidate a=ok.get(i), b=ok.get(j);
            int weakest=Math.min(a.score(),b.score());
            int pair=weakest*2 + (a.score()+b.score())/4 - Math.max(a.counterRisk,b.counterRisk)/2 - Math.max(a.newsRisk,b.newsRisk)/2;
            if(pair>bestPair){bestPair=pair;best=new Combo(a,b,false);} }
        return best==null?new Combo(null,null,true):best;
    }
}
