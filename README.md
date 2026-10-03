# 💰 Expense Tracker — แอปบันทึกรายรับ-รายจ่าย

แอป Flutter สำหรับบันทึกรายรับ-รายจ่ายประจำวัน เข้าสู่ระบบอย่างปลอดภัยผ่าน OIDC Server (django-oidc-provider)
เหมาะสำหรับนักศึกษาและคนทั่วไปที่อยากรู้ว่าเงินแต่ละเดือนหายไปไหน — บันทึกง่าย แยกหมวดหมู่ และดูสรุปเป็นกราฟได้ทันที

## ✨ Features

**ฟีเจอร์หลัก**

- 🔐 **OIDC Login/Logout** — Authorization Code Flow + PKCE (public client) ไปยัง django-oidc-provider
  - แอปไม่เคยเห็นรหัสผ่าน: ล็อกอินที่หน้าของ OIDC Server แล้ว redirect กลับมาที่แอป
  - เก็บ token ใน `flutter_secure_storage` → ปิดแล้วเปิดแอปใหม่ยังล็อกอินอยู่
  - Route Guard (go_router) — ทุกหน้ายกเว้นหน้า Login/สมัครสมาชิก ต้องล็อกอินก่อน
  - แสดงชื่อผู้ใช้จาก userinfo endpoint หลังล็อกอิน
  - Logout ล้าง token ในแอป **และ** ปิด session ที่ OIDC Server (end-session)
- ➕ **Create** — เพิ่มรายการรายรับ/รายจ่ายผ่านฟอร์ม พร้อม validation (จำนวนเงินต้อง > 0)
- 📋 **Read** — หน้ารายการทั้งหมด (List) และหน้ารายละเอียด (Detail)
- ✏️ **Update / 🗑️ Delete** — แก้ไขหรือลบรายการของผู้ใช้ที่ล็อกอินอยู่ (มี dialog ยืนยันก่อนลบ)
- ⚠️ **Error Handling** — แสดง SnackBar/ข้อความเมื่อเน็ตหลุด, backend ปิด, API ผิดพลาด หรือ session หมดอายุ (กลับไปหน้า Login อัตโนมัติ)

**Extra Features**

- 📊 สรุปสถิติด้วยกราฟ (fl_chart) และสรุปแยกตามหมวดหมู่รายรับ/รายจ่าย
- 🌙 Dark Mode สลับได้ และจดจำค่า preference
- 🗂️ หมวดหมู่ที่ผู้ใช้สร้างเองได้ + สมัครสมาชิกจากในแอป

## 🧰 Tech Stack

- **Frontend:** Flutter 3.47 (Dart 3) — สถาปัตยกรรม MVVM: View → ViewModel → Repository → Service
  - `provider` (DI), `go_router` (Route Guard), `dio` (ApiClient), `flutter_secure_storage`, `openid_client`, `fl_chart`
- **Backend:** Django 5.2 + django-oidc-provider 0.9 + Django REST Framework + django-cors-headers
- **Package management:** `uv` (backend), `pub` (frontend)

## 📋 Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.x ขึ้นไป)
- [uv](https://docs.astral.sh/uv/getting-started/installation/) (ติดตั้ง Python ให้เองอัตโนมัติ)
- [Git](https://git-scm.com/downloads)
- [Google Chrome](https://www.google.com/chrome/)

## ▶️ How to Run

```bash
git clone -b project https://github.com/maxnalao/mobiledev69.git
cd mobiledev69
```

### Terminal 1 — Backend (OIDC Server + API) ที่ `http://localhost:8000`

```bash
cd backend
uv sync
uv run manage.py migrate
uv run manage.py creatersakey
uv run manage.py seed_demo_data
uv run manage.py runserver
```

- `creatersakey` — สร้าง RSA key สำหรับเซ็น ID Token ของ OIDC
- `seed_demo_data` — สร้าง OIDC Client ของแอป (`client_id = expense-tracker-flutter`, redirect `http://localhost:50000/callback`), Demo Account และข้อมูลตัวอย่าง
  ไม่ต้องตั้งค่าอะไรใน admin เพิ่ม

### Terminal 2 — Flutter Web App ที่ `http://localhost:50000`

```bash
cd frontend
flutter pub get
flutter run -d chrome --web-port 50000
```

> ⚠️ ต้องใช้ `--web-port 50000` เท่านั้น เพราะต้องตรงกับ redirect URI ของ OIDC Client

### Demo Account

```
username: student01
password: test1234
```

กด **"เข้าสู่ระบบด้วย OIDC"** → ใส่ Demo Account ที่หน้า OIDC Server → กด **Authorize** ที่หน้า Consent → กลับเข้าแอป

(ถ้าต้องการเข้า Django admin ให้สร้างบัญชีเพิ่มด้วย `uv run manage.py createsuperuser` แล้วไปที่ `http://localhost:8000/admin/`)

## 🗂️ โครงสร้างโปรเจกต์

```
backend/                    Django OIDC Server + REST API
├── config/                 settings, urls
└── expenses/               models, API views, OIDC token auth, seed_demo_data
frontend/lib/
├── app.dart                MultiProvider ราก (DI)
├── core/
│   ├── api/                ApiClient (dio)
│   ├── auth/               OIDC (Authorization Code + PKCE) + token store
│   ├── theme/              theme, dark mode
│   └── utils/              Result pattern
└── features/
    ├── auth/               data / presentation (login, signup)
    └── expense/            data / domain / presentation / router (route guard)
```

## 🖼️ Screenshots

| หน้า Login | หน้ารายการ |
| --- | --- |
| ![Login](docs/screenshots/login.png) | ![Home](docs/screenshots/home.png) |

## 🎬 Demo Video

_(ใส่ลิงก์ YouTube แบบ Unlisted ที่นี่)_
