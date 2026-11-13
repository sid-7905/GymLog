# GymLog 🏋️‍♂️

> A dark-themed, Hevy-inspired progressive resistance training mobile tracking app built with **Flutter**, **Node.js**, **Express**, and **MongoDB Atlas**.

---

## 📱 Features

- **Strict Dark Theme**: Material 3 dark aesthetic (`#121212` background, `#1E1E1E` surface, `#B6F36B` neon lime accent) optimized for gym environments.
- **80+ Default Exercise Database**: Pre-populated exercise directory categorized across 7 muscle groups and 6 equipment categories.
- **Live Workout Logging**: Check off completed sets, log exact weights and reps, adjust target sets, and add per-exercise form notes.
- **Interactive Rest Timer**: Built-in floating rest countdown timer overlay with `+30s` and `Skip` controls.
- **Unified Exercise Analytics**: Unified cross-routine historical tracking displaying estimated One-Rep Max (1RM) and total volume progression via `fl_chart`.
- **Body Weight Tracker**: Daily and weekly body weight tracking with visual trendlines.
- **Social Community Feed**: Share finished workouts with media photos, captions, and fist-bump/like interactions.
- **JWT Authentication**: Stateless authentication with salted bcrypt password hashing and token persistence via `flutter_secure_storage`.

---

## 🏗️ Project Architecture

```
App_dev/
├── gymlog/                  # Flutter Mobile Client
│   ├── lib/
│   │   ├── models/          # Strongly-typed Dart data models
│   │   ├── providers/       # State management (Auth, Workout, Routine)
│   │   ├── screens/         # UI Views (Auth, Workout, History, Analytics, Feed)
│   │   ├── services/        # HTTP REST API client services
│   │   └── utils/           # Theme, color constants, exercise library
│   ├── pubspec.yaml
│   └── .env.example
│
├── gymlog_backend/          # Node.js + Express API Gateway
│   ├── config/              # MongoDB Atlas connection & DNS fallback
│   ├── controllers/         # REST API route handlers
│   ├── middleware/          # JWT Bearer authentication middleware
│   ├── models/              # Mongoose schemas (User, Routine, Workout, BodyWeight)
│   ├── routes/              # Express API route declarations
│   ├── seed_demo_data.js    # Automated seed script for demo profile
│   ├── server.js            # Express application bootstrap
│   ├── package.json
│   └── .env.example
│
├── gymlog_documentation.tex # Complete LaTeX Project Documentation Report
├── gymlog_documentation.pdf # Compiled PDF Project Documentation Report
└── README.md
```

---

## 🚀 Getting Started

### 1. Prerequisites
- **Node.js** (v18+) and **npm**
- **Flutter SDK** (v3.19+)
- A **MongoDB Atlas** cluster or local MongoDB instance

---

### 2. Backend Setup (`gymlog_backend/`)

1. Navigate to the backend directory:
   ```bash
   cd gymlog_backend
   npm install
   ```
2. Create your `.env` file based on `.env.example`:
   ```bash
   cp .env.example .env
   ```
   Add your MongoDB Atlas URI and JWT Secret.

3. *(Optional)* Seed demo data (demo athlete `siddhesh@gymlog.app` / `password123`):
   ```bash
   npm run seed
   ```

4. Start the server:
   ```bash
   npm run dev
   # or
   npm start
   ```
   The backend will start on `http://0.0.0.0:5000` (accessible on LAN and local host).

---

### 3. Frontend Setup (`gymlog/`)

1. Navigate to the Flutter directory:
   ```bash
   cd gymlog
   flutter pub get
   ```
2. Create your `.env` file based on `.env.example`:
   ```bash
   cp .env.example .env
   ```
   Set `API_BASE_URL` to your backend URL (e.g. `http://192.168.0.101:5000/api` for physical device over Wi-Fi, or `http://10.0.2.2:5000/api` for Android emulator).

3. Run the app:
   ```bash
   flutter run
   ```

---

## 📄 Documentation

A full academic project documentation report is provided in [`gymlog_documentation.tex`](gymlog_documentation.tex) and the compiled PDF [`gymlog_documentation.pdf`](gymlog_documentation.pdf).

---

## 🔒 Security Note
Never commit `.env` files containing live credentials or production secrets. Use `.env.example` templates for configuration reference.
