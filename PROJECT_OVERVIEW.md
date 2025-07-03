# 🐑 SheepFarm Management System - High-Level Documentation

## 📅 Project State (as of June 8, 2025)

| Area                | Current State                                                                 | Planned Refactor/Features                                                                 |
|---------------------|-------------------------------------------------------------------------------|------------------------------------------------------------------------------------------|
| **Authentication**  | Login only. No registration.                                                  | ➕ Add user registration (sign-up) flow.                                                  |
| **Home/Dashboard**  | Single farm per user. Dashboard tiles for navigation.                          | 🏡 Multi-farm support: list farms as cards (name, address), each with its own dashboard.  |
| **Animal Management**| Add/view/manage animals. Some logic for status, gender, sale, logs.           | 🐏 Refactor animal model & UI for all fields, automations, and per-farm scoping.          |
| **User Profile**    | No profile view/update.                                                        | 👤 Add profile/settings screen for viewing/updating user info.                            |
| **Admin Features**  | Admins manage breeds, view logs, override records.                             | 🛠️ Ensure admin-only access, improve dashboard, log all admin actions.                    |
| **Testing**         | Integration & widget tests for major flows.                                    | ✅ Keep tests updated for new flows and refactors.                                        |

---

## 🗂️ Planned Refactor & Feature Additions

### 1️⃣ User Registration
- Add `RegisterScreen` with name, email, password fields.
- Update `AuthService` for registration.
- Add `/register` route and navigation from login.

### 2️⃣ Multi-Farm Support
- Create `Farm` model (name, address, ownerId).
- Home: List user farms as clickable cards.
- Add "Add Farm" button.
- Each farm has its own dashboard (animals, partners, logs, etc.).
- Refactor queries to be farm-specific.

### 3️⃣ User Profile Settings
- Add `ProfileScreen` for viewing/updating user info.
- Update `AuthService` for profile changes.

### 4️⃣ Animal Record Summary & Logic
| Field           | Description/Logic                                                                 |
|-----------------|----------------------------------------------------------------------------------|
| Tag ID          | Manually entered ear tag number                                                   |
| Tag Color       | Indicates ownership (unique per partner)                                          |
| Type            | Sheep or Goat                                                                     |
| Breed           | E.g., Damani, Dimashqi, Mixed (admin can add more)                               |
| Gender          | Male or Female                                                                    |
| Age             | Entered manually (months or birthdate)                                            |
| Status          | Alive (default), Pregnant, Sick, Sold, Dead                                       |
| Pregnancy Logs  | For females only; month, count, etc.                                              |
| Birth Records   | For females only; birth dates, offspring count                                    |
| Health Logs     | Custom entries for illness, treatment, vaccines                                   |
| Sale Info       | Price, date, buyer (defaults to "Unknown")                                       |
| Photo           | Optional animal image                                                             |
| Activity Logs   | Notes/actions with timestamp, user, description                                   |

#### 📝 Activity Logs (per animal)
- Date, description, performed by (user)
- Used for: manual notes, status changes, health/birth events, admin supervision

#### 🔁 Logic & Automations
| Condition/Event         | Effect                                                        |
|------------------------|--------------------------------------------------------------|
| Add new animal         | Status = Alive, log created automatically                     |
| Gender is Male         | Hide pregnancy/birth fields                                   |
| Add pregnancy log      | Auto-set status to Pregnant                                   |
| Mark as sold           | Status = Sold, buyer = "Unknown" if not provided             |
| Mark as dead           | Status = Dead, disables further updates                       |
| Admin edits/deletes    | Action logged in admin activity log                           |

### 5️⃣ Admin Features
- Add/Edit breeds (admin only)
- View all user activity logs
- Edit/override records (admin supervision)

---

## 🚦 Next Steps
1. Implement user registration flow.
2. Add multi-farm support and refactor dashboard.
3. Add user profile/settings screen.
4. Refactor animal management for new logic and per-farm scoping.
5. Enhance admin features and access control.

---

*This document will be updated as features are implemented and the project evolves.*
