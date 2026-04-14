# 🏋️ GymBook — Gym Slot Booking App

A full-stack gym slot booking application.

| Layer | Tech |
|---|---|
| Backend | Node.js + Express + MongoDB + JWT |
| Frontend | Flutter + GetX |

## Structure
```
gym/
├── gym-backend/       # Node.js REST API
└── gym_booking_app/   # Flutter app (Android, iOS, Web, Desktop)
```

## Quick Start

### Backend
```bash
cd gym-backend
npm install
cp .env.example .env   # edit MONGO_URI and JWT_SECRET
npm run dev
```

### Flutter
```bash
cd gym_booking_app
flutter pub get
flutter run
```

## Features
- Member registration & login
- Browse & book gym slots by date
- View upcoming & past bookings, cancel bookings
- Admin dashboard with stats
- Admin slot management (create, edit, delete)
- Admin management (add/remove admins)

## First Admin Setup
1. Run the app → Login screen
2. Tap the gym logo **5 times**
3. Tap **Admin Setup** → fill in details + Setup Key from `.env`
