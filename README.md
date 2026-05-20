# TaskFlow – Flutter Todo App 📝

> **Assignment #1 | Mobile Application Development (MAD) 2026 | Szabist University**

---

## 👥 Group Members

| Name | Roll Number |
|------|-------------|
| Hafiz Abrar Iqbal | 2280142 |
| [Member 2 Name] | [ID] |
| [Member 3 Name] | [ID] |

---

## 📱 App Overview

**TaskFlow** is a beautifully designed Flutter Todo application that demonstrates:

- ✅ **REST API Integration** — fetches, creates, updates, and deletes todos via [JSONPlaceholder](https://jsonplaceholder.typicode.com/todos)
- ♾️ **Infinite Scroll Pagination** — loads 10 todos per page with auto-fetch on scroll
- ➕ **Add Todo** — validated form dialog with title (min 3 chars) and description fields
- ✔️ **Toggle Complete** — tap the circle icon to mark done/pending (PUT request)
- 🗑️ **Delete Todo** — swipe left to dismiss (DELETE request)
- 🔄 **Pull to Refresh** — swipe down to reload the full list
- 🔍 **Filter Tabs** — filter by All / Pending / Done
- 📊 **Stats Dashboard** — live count of total, done, and pending tasks
- 🌙 **Premium Dark UI** — glassmorphism-inspired dark theme with gradient accents

---

## 🛠️ Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter 3.x |
| Language | Dart 3.x |
| HTTP Client | `http ^1.2.2` |
| API | JSONPlaceholder REST API |
| Architecture | Service + Model + Page pattern |

---

## 🚀 How to Run

```bash
# 1. Clone the repo
git clone https://github.com/YOUR_USERNAME/ass-todo-app-flutter.git
cd ass-todo-app-flutter

# 2. Install dependencies
flutter pub get

# 3. Run on Android device/emulator
flutter run
```

> **Note:** Requires an active internet connection for API calls.

---

## 📁 Project Structure

```
lib/
├── main.dart               # App entry point
├── models/
│   └── todo_model.dart     # Todo data model with JSON serialization
├── services/
│   └── todo_service.dart   # REST API calls (GET, POST, PUT, DELETE)
└── pages/
    └── todo_page.dart      # Main UI — todo list, dialogs, filter, stats
```

---

## 📸 Screenshots

> _Add your screenshots here before submission_

| Home Screen | Add Todo | Filtered View |
|:-----------:|:--------:|:-------------:|
| ![Home](screenshots/home.png) | ![Add](screenshots/add.png) | ![Filter](screenshots/filter.png) |

---

## 🎥 Demo Video

> _Attach a short demo video (< 1 minute) showcasing all functionality_

---

## 📦 Features Checklist

- [x] Fetch todos from REST API with pagination
- [x] Add new todo (POST with validation)
- [x] Toggle todo completed status (PUT)
- [x] Delete todo via swipe gesture (DELETE)
- [x] Pull-to-refresh
- [x] Infinite scroll
- [x] Filter by All / Pending / Done
- [x] Statistics dashboard (total, done, pending)
- [x] Error state with retry
- [x] Empty state display
- [x] Loading indicators
- [x] Animated card interactions
- [x] Premium dark theme UI

---

## 🏫 Assignment Details

- **Course:** Mobile Application Development (MAD)
- **Institution:** Szabist University
- **Year:** 2026
- **Assignment:** #1 – Todo App with REST API
