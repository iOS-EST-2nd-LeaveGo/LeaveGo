# 📌 떠나Go

<p align="center">
  <b>당신의 현재 위치에서 출발하는, 단 하나뿐인 여행 플랜</b><br>
  나만을 위한 여행지와 코스를 추천해주는 위치 기반 스마트 여행 가이드, <b>떠나Go</b>
</p>

![badge](https://img.shields.io/badge/platform-iOS-blue) ![badge](https://img.shields.io/badge/language-Swift-orange) ![badge](https://img.shields.io/badge/license-MIT-green)

---

## 📷 스크린샷

| 메인 화면 | 장소 화면 | 상세 화면 | 경로 화면 | 일정 화면 |
|-----------|------------|------------|------------|------------|
|<img src="https://github.com/user-attachments/assets/81dc28d5-94f2-4ef2-bb7d-d14a2cb296ea" width="190"/>  | <img src="https://github.com/user-attachments/assets/c3b6c8c2-def5-4307-85ca-9e5dd8721876" width="190"/> | <img src="https://github.com/user-attachments/assets/835eb99c-b480-4609-9bb9-c2ca5672842f" width="190"/> | <img src="https://github.com/user-attachments/assets/525a1317-933b-426e-ad20-6acb43d6fe2c" width="190"/> | <img src="https://github.com/user-attachments/assets/175465c5-ddc9-41b3-91a1-32f6aa6bf49d" width="190"/>

---

## 📖 소개

떠나Go는 사용자의 현재 위치와 관심사를 교통수단 등을 종합하여 맞춤형 여행지를 추천하고 최적의 여행 코스를 자동으로 생성해주는위치 기반 스마트 여행 가이드 앱입니다.

복잡한 여행 계획 없이도 누구나 쉽게 나만의 일정을 만들 수 있으며,실시간 지도 연동과 경로 안내로 현장에서도 유용하게 활용할 수 있습니다.

> “지금 이 자리에서 시작하는 나만의 여행”

---

## 🚀 주요 기능

- ✅ 기능 1: 어떤 걸 할 수 있는지
- ✅ 기능 2: 또 무엇을 제공하는지
- ✅ 기능 3: 사용자 입장에서 매력적인 점

---


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
