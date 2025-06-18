# 📌 떠나Go

<p align="center">
  <b>당신의 현재 위치에서 출발하는, 단 하나뿐인 여행 플랜</b><br>
  나만을 위한 여행지와 코스를 추천해주는 위치 기반 스마트 여행 가이드, <b>떠나Go</b>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/platform-iOS-blue" />
  <img src="https://img.shields.io/badge/language-Swift-orange" />
  <img src="https://img.shields.io/badge/license-MIT-green" />
</p>


<br/>


## 📷 스크린샷

| 메인 화면 | 장소 화면 | 상세 화면 | 경로 화면 | 일정 화면 |
|-----------|------------|------------|------------|------------|
|<img src="https://github.com/user-attachments/assets/81dc28d5-94f2-4ef2-bb7d-d14a2cb296ea" width="190"/>  | <img src="https://github.com/user-attachments/assets/c3b6c8c2-def5-4307-85ca-9e5dd8721876" width="190"/> | <img src="https://github.com/user-attachments/assets/835eb99c-b480-4609-9bb9-c2ca5672842f" width="190"/> | <img src="https://github.com/user-attachments/assets/525a1317-933b-426e-ad20-6acb43d6fe2c" width="190"/> | <img src="https://github.com/user-attachments/assets/175465c5-ddc9-41b3-91a1-32f6aa6bf49d" width="190"/>

---
<br/>
<br/>


## 📖 소개

떠나Go는 사용자의 현재 위치와 관심사를 교통수단 등을 종합하여 맞춤형 여행지를 추천하고 최적의 여행 코스를 자동으로 생성해주는위치 기반 스마트 여행 가이드 앱입니다.

복잡한 여행 계획 없이도 누구나 쉽게 나만의 일정을 만들 수 있으며,실시간 지도 연동과 경로 안내로 현장에서도 유용하게 활용할 수 있습니다.

> “지금 이 자리에서 시작하는 나만의 여행”

<br/>

## 🚀 주요 기능

### ✅ 위치 기반 여행지 추천
사용자의 **현재 위치**와 **관심사**를 바탕으로  
가까운 여행지를 **실시간으로 추천**해줍니다.

---

### ✅ 경로 기반 여행 코스 안내
선택한 장소들을 **지도 상에서 시각화**하고,  
**효율적인 동선**과 **예상 소요 시간**까지 함께 안내받을 수 있습니다.

---

### ✅ 쉬운 여행 계획과 저장
여행 코스를 **드래그 앤 드롭**으로 간편하게 구성하고 저장할 수 있으며,  
언제든지 **다시 열람하거나 수정**할 수 있습니다.


---
<br/>
<br/>

## 🔗 API 출처

- 📌 **한국관광공사 TourAPI 4.0**  
  https://www.data.go.kr/tcs/dss/selectApiDataDetailView.do?publicDataPk=15101578  
  → 관광지 정보, 카테고리, 위치 기반 장소 검색 등에 사용

- 📍 **Apple MapKit (CoreLocation 포함)**  
  → 사용자 위치 추적 및 지도 렌더링에 사용
---
<br/>
<br/>

## 🧾 Git 커밋 컨벤션

| 타입 | 설명 |
|------|------|
| `feat` | 새로운 기능 추가 |
| `fix` | 버그 수정 |
| `docs` | 문서 수정 |
| `style` | 코드 스타일 변경 (세미콜론, 들여쓰기 등) |
| `design` | UI 디자인 변경 (색상, 레이아웃 등) |
| `test` | 테스트 코드 추가 또는 테스트 리팩토링 |
| `refactor` | 리팩토링 (기능 변화 없는 코드 개선) |
| `build` | 빌드 관련 파일 수정 |
| `ci` | CI 설정 관련 변경 |
| `perf` | 성능 개선 |
| `chore` | 자잘한 수정이나 빌드/배포 작업 |
| `rename` | 파일명 또는 폴더명 변경 |
| `remove` | 파일 삭제 |

> 커밋 메시지 작성 시 위 컨벤션을 따라 일관성을 유지해 주세요.

<br/>
<br/>


## 🛠️ 기술 스택

| 항목 | 내용 |
|------|------|
| 💻 Framework | ![UIKit](https://img.shields.io/badge/UIKit-Framework-blue) ![CoreLocation](https://img.shields.io/badge/CoreLocation-Framework-lightgrey) |
| 🗃 Database | ![CoreData](https://img.shields.io/badge/CoreData-Database-blueviolet) |
| 🛠️ Tooling | ![Xcode](https://img.shields.io/badge/Xcode-IDE-147EFB?logo=xcode&logoColor=white) ![Figma](https://img.shields.io/badge/Figma-Design-red?logo=figma&logoColor=white) ![Postman](https://img.shields.io/badge/Postman-API-orange?logo=postman) ![Discord](https://img.shields.io/badge/Discord-Chat-5865F2?logo=discord&logoColor=white) ![GitHub](https://img.shields.io/badge/GitHub-Repo-black?logo=github) |

---

## ⚙️ 설치 및 실행 방법
### ⚡️ 1. 프로젝트 설치 방법

```bash
# 1. 레포지토리 클론
git clone https://github.com/iOS-EST-2nd-LeaveGo/LeaveGo.git
```


### 🔐 2. API 키 설정

공공데이터 포털에서 발급받은 **API 키**를 `Secrets.plist` 파일에 등록해주세요.

```xml
<!-- Secrets.plist -->
<dict>
    <key>API_KEY</key>
    <string>여기에_본인의_API_KEY_를_입력하세요</string>
</dict>

```
### 🏃‍➡️ 3. 프로젝트 실행

1. Xcode에서 `LeaveGo.xcodeproj` 파일을 엽니다.
2. 시뮬레이터 또는 실제 디바이스에서 실행합니다.

```bash
# 실행 단축키 (macOS 기준)
⌘ + R
```
