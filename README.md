# ๐’ฐ Expense Tracker

เนเธญเธ Flutter เธชเธณเธซเธฃเธฑเธเธเธฑเธเธ—เธถเธเธฃเธฒเธขเธฃเธฑเธ-เธฃเธฒเธขเธเนเธฒเธข เน€เธเนเธฒเธชเธนเนเธฃเธฐเธเธเธเนเธฒเธ OIDC (django-oidc-provider)
เน€เธซเธกเธฒเธฐเธชเธณเธซเธฃเธฑเธเธเธนเนเธ—เธตเนเธ•เนเธญเธเธเธฒเธฃเธ•เธดเธ”เธ•เธฒเธกเธเธฒเธฃเนเธเนเธเนเธฒเธขเธฃเธฒเธขเธงเธฑเธเนเธฅเธฐเธ”เธนเธชเธฃเธธเธเธ เธฒเธเธฃเธงเธกเธฃเธฒเธขเน€เธ”เธทเธญเธ

## โจ Features

- OIDC Login/Logout ๐” (Authorization Code Flow + PKCE)
- CRUD เธฃเธฒเธขเธเธฒเธฃเธฃเธฒเธขเธฃเธฑเธ-เธฃเธฒเธขเธเนเธฒเธข (Create / Read / Update / Delete)
- Error Handling เน€เธกเธทเนเธญเน€เธเนเธ•เธซเธฅเธธเธ”เธซเธฃเธทเธญ session เธซเธกเธ”เธญเธฒเธขเธธ (SnackBar)
- Extra: เธเธฃเธฒเธเธชเธฃเธธเธเธฃเธฒเธขเธฃเธฑเธ-เธฃเธฒเธขเธเนเธฒเธข ๐“ (fl_chart)
- Extra: Dark Mode เธชเธฅเธฑเธเนเธ”เนเนเธฅเธฐเธเธ”เธเธณเธเนเธฒ preference ๐

## ๐งฐ Tech Stack

- Flutter 3.x (MVVM: View / ViewModel / Repository / Service)
- Django 5 + django-oidc-provider + Django REST Framework
- Package management: `uv` (backend), `pub` (frontend)

## ๐“ Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [uv](https://docs.astral.sh/uv/)
- Google Chrome (for `flutter run -d chrome`)

## โ–ถ๏ธ How to Run

### Terminal 1 โ€” Backend (OIDC Server + API)

```bash
cd backend
uv sync
uv run manage.py migrate
uv run manage.py createsuperuser   # create an admin account if you don't have one
uv run manage.py seed_demo_data    # creates the demo account below
uv run manage.py runserver
```

Then open `http://localhost:8000/admin/oidc_provider/client/` and add an OIDC Client:

- Name: `flutter-expense-tracker`
- Client Type: `Public`
- Response Type: `Code` (Authorization Code Flow)
- Redirect URIs: `http://localhost:50000/callback`

Copy the generated **Client ID** into `frontend/lib/core/auth/oidc_config.dart` (`clientId`).

### Terminal 2 โ€” Flutter Web App

```bash
cd frontend
flutter pub get
flutter run -d chrome --web-port 50000
```

โ ๏ธ The `--web-port` above **must match** the redirect URI configured in the OIDC Client.

### Demo Account

```
username: student01
password: test1234
```

## ๐–ผ๏ธ Screenshots

_(add at least 2 screenshots here: login screen, transaction list)_

## ๐ฌ Demo Video

_(add the unlisted YouTube link here once recorded)_
