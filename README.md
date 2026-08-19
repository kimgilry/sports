# 퓨어베이스볼 분석기 v0.1

## 현재 포함
- 배당 0% 순수 분석 엔진 구조
- MLB 단독 조합 / KBO+NPB 통합 조합
- FINAL 후보 2개 미만이면 PASS
- 선발/흐름/불펜/타선/상성/휴식/수비/날씨/뉴스/반례 위험 점수
- 수동 전체/리그별 재분석 UI
- 화면 꺼짐 상태를 위한 Foreground Monitor Service 기본 구조
- 누적 기록 저장 구조
- 선발 등록 예상 카운트다운 UI
- 조합픽 생성 후에만 총배당 표시하도록 UI 분리

## 중요
v0.1은 앱 UI와 분석/알림 로직 검증판입니다. 현재 화면의 경기 후보는 데모 데이터입니다.
MLB/KBO/NPB 공식 실시간 데이터 파서는 다음 버전에서 SourceAdapter로 연결하도록 분리할 예정입니다.

## GitHub에서 APK 빌드
1. 이 폴더 전체를 GitHub 저장소에 업로드합니다.
2. Actions 탭 > `Build PureBaseball APK` > Run workflow.
3. 완료 후 Artifacts에서 `PureBaseball-debug-apk`를 받습니다.

## 축구 확장
동일한 판정 파이프라인을 재사용하고 투수 요소를 예상/확정 선발라인업, 골키퍼, xG/xGA, 부상/징계, 세트피스, 휴식/이동 요소로 교체할 수 있습니다.
