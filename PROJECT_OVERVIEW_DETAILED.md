# 🐑 SheepFarm Management System - Detailed Project Overview

---

**Project Status (as of June 8, 2025):**

| ✅ Core Features Implemented |  |
|-----------------------------|--|
| 🔐 Auth & Roles             | Login, logout, registration, email verification, password reset, role-based access, profile update |
| 🏠 Multi-Farm Support       | Create, select, archive, delete, restore farms; dashboard, settings, activity log per farm |
| 👥 Partner Management       | Add/view partners per farm, role-based permissions |
| 🐑 Animal Management        | Add/edit/delete, search/filter, status logic, photo upload, per-farm scoping |
| 📤 Data Export & Search     | Animal/log export (CSV), advanced search/filter for animals/logs |
| 🛠️ Admin Features          | Breed management, activity logs, record override, supervision |
| 👤 User Management          | User management UI (placeholder) |
| 🔄 Offline Sync             | Firestore persistence, auto-sync, connectivity banner |
| 🔔 Notifications            | Core logic, dashboard notification demo |
| 📝 CI/CD & Docs             | Manual/test/dev instructions, docs in place |

| 🕗 Planned/Enhancements (see ENHANCEMENTS.md) |
|------------------------------------------------|
| 🎉 Welcome banner, notification scheduling/settings, advanced dashboard UI |
| 👥 Multiple owners/partners per farm, advanced partner management |
| ⚙️ Advanced farm settings (preferred breeds, color, permissions) |
| 🐑 Advanced animal model (custom fields, more statuses), PDF export |
| 📊 Advanced log filtering/export, audit trails, admin password reset |
| 👤 Full user management integration, advanced offline/manual sync |
| 🤖 Automated CI/CD pipeline, expanded test coverage, ongoing doc updates |

---

## 1️⃣ Authentication & User Management

| Feature         | Details                                                                                 |
|-----------------|-----------------------------------------------------------------------------------------|
| 🔑 Login           | Users log in with email and password. Uses Firebase Auth or custom backend.              |
| 📝 Registration    | Users can register with name, email, password. Email verification sent after registration. |
| 🔄 Auth State      | App uses Provider to track auth state and route users accordingly.                      |
| 👤 User Profile    | Users can view and update their profile (name, email, password).                        |
| 🏷️ Roles           | Users have roles (admin, partner, etc.) that affect permissions and UI.                 |
| 🚪 Logout          | Users can log out from the dashboard.                                                   |
| 🔑 Password Reset  | Users can request password reset via email from login screen.                           |
| 📧 Email Verify    | Email verification for new users after registration.                                    |

---

## 2️⃣ Home/Dashboard

| Feature         | Details                                                                                 |
|-----------------|-----------------------------------------------------------------------------------------|
| 🏠 Dashboard Tiles | Main navigation: Animals, Logs, Add Partner, Admin Logs, Logout, **Profile/Settings (user/admin, role-based tile, async role check)**. |
| 🏡 Multi-Farm      | Users can create/manage multiple farms. Home shows clickable farm cards.       |
| 🔄 Farm Selection  | Selecting a farm scopes all actions (animals, logs, partners) to that farm.   |
| 📱 Responsive UI   | Layout adapts for mobile/tablet/desktop.                                                |
| 👋 Welcome Banner  | Personalized greeting and quick stats.                                        |
| 🔔 Notifications   | Show reminders or alerts (e.g., animal health, tasks).                        |

---

## 3️⃣ Farm Management

| Feature         | Details                                                                                 |
|-----------------|-----------------------------------------------------------------------------------------|
| 🏡 Farm Model      | Each farm has: name, address, owner, created date, unique farm ID, and optional notes.  |
| ➕ Add/Edit Farm   | Users can add new farms and edit existing ones.                                         |
| 📋 Farm List       | Home shows all user farms as cards (name, address, clickable, with farm stats preview). |
| 📊 Farm Dashboard  | Each farm has its own dashboard for animals, partners, logs, settings, etc.             |
| 🗑️ Farm Deletion   | Users can delete a farm (with confirmation and data warning).                 |
| 🔄 Farm Switching  | User can switch between farms at any time from the dashboard.                 |
| 👥 Farm Ownership  | Farms can have multiple owners/partners; ownership is tracked per farm.       |
| ⚙️ Farm Settings   | Each farm can have its own settings (e.g., preferred breeds, color, etc.).    |
| 📝 Farm Activity   | Activity log for farm-level actions (e.g., partner added, farm edited).       |
| 🗃️ Farm Archive    | Option to archive farms instead of deleting (for record-keeping).             |

---

## 4️⃣ Animal Management

| Feature         | Details                                                                                 |
|-----------------|-----------------------------------------------------------------------------------------|
| 🐑 Animal Model    | Tag ID, tag color, type, breed, gender, age, status, pregnancy logs, birth records, health logs, sale info, photo, activity logs. |
| ➕ Add/Edit Animal | Users can add and edit animals. Logic for status, gender, sale, death, etc.             |
| 📋 Animal List     | Shows all animals for the selected farm.                                                |
| 🔍 Animal Details  | View full record, logs, and actions for each animal.                                    |
| 📝 Activity Logs   | Each animal has a journal of actions/notes (date, description, user).                   |
| 🔄 Status Logic    | Status auto-updates (Alive, Pregnant, Sold, Dead, etc.) based on actions.               |
| 🚹 Gender Logic    | Pregnancy/birth fields hidden for males.                                                |
| 💸 Sale/Death      | Marking as sold/dead updates status and disables further edits if dead.                 |
| 🖼️ Photo Upload    | Users can upload a photo for each animal.                                               |
| 🔎 Animal Search   | Search/filter animals by tag, type, status, etc.                              |
| 📤 Animal Export   | Export animal data (CSV, PDF, etc.).                                          |

---

## 5️⃣ Partner/Staff Management

| Feature         | Details                                                                                 |
|-----------------|-----------------------------------------------------------------------------------------|
| 👤 Partner Model   | Name, email, role, color (for tag color), assigned farms.                               |
| ➕ Add Partner     | Admins can invite/add partners to a farm.                                               |
| 📋 Partner List    | Shows all partners for the selected farm.                                               |
| 🏷️ Permissions     | Roles determine access (admin, partner, etc.).                                          |
| ❌ Remove Partner  | Admins can remove partners from a farm.                                       |

---

## 6️⃣ Logging & Activity Tracking

| Feature         | Details                                                                                 |
|-----------------|-----------------------------------------------------------------------------------------|
| 📝 Manual Logs     | Users can add manual logs (notes, actions) for a farm.                                  |
| 🐑 Animal Logs     | Each animal has its own activity log (journal).                                         |
| 🛡️ Admin Logs      | Admins can view all user actions for supervision.                                       |
| 🏷️ Log Types       | Health, pregnancy, birth, sale, death, manual notes, etc.                               |
| ⚙️ Automation      | Many actions auto-create logs (e.g., status changes, admin edits).                      |
| 📤 Log Export      | Export logs for reporting/auditing.                                           |

---

## 7️⃣ Admin Features

| Feature         | Details                                                                                 |
|-----------------|-----------------------------------------------------------------------------------------|
| 🧬 Breed Management| Admins can add/edit breeds for animals.                                                 |
| 🛡️ Activity Logs   | Admins can view all user and animal activity logs.                                      |
| ✏️ Record Override | Admins can edit/override animal and log records.                                        |
| 👁️ Supervision     | All admin actions are logged for transparency.                                          |
| 👤 User Management | Admins can manage users, reset passwords, assign roles.                       |

---

## 8️⃣ Settings & Profile

| Feature         | Details                                                                                 |
|-----------------|-----------------------------------------------------------------------------------------|
| 👤 Profile Screen  | Users can view/update their name, email, password.                                      |
| ⚙️ App Settings    | Admins can manage global settings (breeds, roles, etc.).                      |
| 🔔 Notification Settings | Users can manage notification preferences.                              |

---

## 9️⃣ Data & Storage

| Feature         | Details                                                                                 |
|-----------------|-----------------------------------------------------------------------------------------|
| 🗄️ Database        | Uses Firestore or similar for all data (users, farms, animals, logs, etc.).             |
| 🖼️ Storage         | Animal photos and files stored in Firebase Storage or similar.                          |
| 🔄 Offline Support | App works offline and syncs when online.                                      |
| 🔒 Data Security   | Role-based access, secure rules, and data privacy.                            |

---

## 🔟 Testing & Quality

| Feature         | Details                                                                                 |
|-----------------|-----------------------------------------------------------------------------------------|
| 🧪 Integration Tests| Automated tests for login, navigation, animal management, logs, etc.                   |
| 🧩 Widget Tests    | UI tests for all major screens and widgets.                                             |
| ⚠️ Error Handling  | User-friendly error messages and validation.                                            |
| 🤖 CI/CD          | Continuous integration and deployment pipeline.                                |

---

## 1️⃣1️⃣ UI/UX & Accessibility

| Feature         | Details                                                                                 |
|-----------------|-----------------------------------------------------------------------------------------|
| 📱 Responsive UI   | Works on mobile, tablet, and desktop.                                                   |
| ♿ Accessibility   | Semantics, keyboard navigation, and a11y best practices.                                |
| 🎨 Modern Design   | Clean, modern UI with clear navigation and feedback.                                    |
| 🌓 Theming         | Light/dark mode and color customization.                                      |

---

## 1️⃣2️⃣ Project Structure

| Folder/File | Purpose |
|-------------|---------|
| `main.dart` | App entry point, routing, providers |
| `models/` | Data models (User, Farm, Animal, Partner, Log, etc.) |
| `services/` | Business logic, database, auth, storage |
| `screens/` | UI screens (Login, Home, Farm, Animal, Profile, etc.) |
| `widgets/` | Reusable UI components |
| `providers/` | State management (UserProvider, FarmProvider, etc.) |
| `integration_test/` | Integration tests |
| `test/` | Widget/unit tests |
| `android/`, `ios/`, `web/`, `windows/`, `linux/`, `macos/` | Platform code |
| `README.md` | Project introduction and setup instructions |
| `PROJECT_OVERVIEW.md` | High-level summary |
| `PROJECT_OVERVIEW_DETAILED.md` | This detailed documentation |
| `wireframes.md` | (If present) UI/UX wireframes and design notes |

---

## 🚦 Roadmap (Next Steps)

| # | Task |
|---|------|
| 1 | Implement user registration and profile management |
| 2 | Add multi-farm support and refactor dashboard |
| 3 | Refactor animal management for new logic and per-farm scoping |
| 4 | Enhance admin features and access control |
| 5 | Improve offline support and testing |
| 6 | Add search/export features for animals and logs |
| 7 | Implement notifications and reminders |
| 8 | Add CI/CD and improve documentation |

---

## 🧠 Additional Insights & Best Practices

| 💡 Feature                        | 📝 Description                                                                                         |
|-------------------------------|-----------------------------------------------------------------------------------------------------|
| 🔀 Farm-Level Scoping         | All animals, partners, and logs are scoped per farm. Enables true multi-farm support and separation. |
| 🧑‍🤝‍🧑 Partner/Farm Owner Model| Tag color is tied to partner identity. Consider making this relationship explicit in the data model. |
| 🧾 Log Types Enumeration       | Log types (pregnancy, sale, death, health, etc.) should be enumerated for reporting/filtering.       |
| 🧠 Export & Search            | Support search/export by breed, status, type, and other fields for large-scale usability.             |
| 🧑‍💻 Admin Supervision & Override| Enforce audit trails and admin-only overrides for critical actions (deletion, status change, etc.).  |
| 🗃️ Activity Logs by User/Animal| Maintain both per-animal logs and global admin/user activity logs for full traceability.             |

---

*This document provides a comprehensive overview of all project parts and will be updated as the project evolves.*
