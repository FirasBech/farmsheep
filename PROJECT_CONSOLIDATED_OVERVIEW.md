# 🐑 SheepFarm Management System – Consolidated Documentation
(Last updated — July 2025)

This single document merges and de-duplicates:

* `PROJECT_OVERVIEW.md` (high-level roadmap)
* `PROJECT_OVERVIEW_DETAILED.md` (implemented features & deep dives)
* `APP_PLAN_AND_LOGICAL_DIAGRAM.md` (architecture & data models)

Use it as the **source of truth** for current state, future work, and implementation guidance.

---

## 1️⃣ Current State – June 2025

| Area | Implemented | Key Notes |
|------|-------------|-----------|
| **Auth & Roles** | Login / Logout, Registration, Email-verification, Password-reset. Roles: `admin`, `partner`. | Newly registered user defaults to **admin** (can create farms). |
| **Home / Dashboard** | Multi-farm: farm cards → per-farm dashboard. Dashboard tiles adapt to role. | Welcome banner & live stats. |
| **Farm Management** | Create, select, archive, delete, restore farms; per-farm settings & activity log. | Owner & partners tracked via `partnerIds`. |
| **Partner Management** | Add partners to farm, per-farm permissions. | "Create Partner" triggers Cloud Function. |
| **Animal Management** | Add / Edit / Delete, search / filter, status logic, photo upload, per-farm scoping. | Model supports advanced fields (see §4). |
| **Logs** | Manual logs, animal logs, admin activity logs; search & CSV export. | |
| **Offline / Sync** | Firestore persistence, auto-sync, connectivity banner. | |
| **Notifications** | Core service, demo dashboard notification. | |
| **Admin Features** | Breed management, record override, global activity log. | |
| **Testing** | Unit / widget tests, large integration suite (runs in CI). | Windows skips plugin-heavy widgets. |
| **Docs / CI-CD** | Extensive markdown docs, manual pipeline. | |

---

## 2️⃣ Roadmap (Next Major Steps)

1. **User Profile / Settings** – View & edit name / email / password; notification preferences.
2. **Refactor Animal Model & UI** – Add gender, pregnancy, health, sale logic; automate status updates.
3. **Enhanced Admin Suite** – Full user management, audit trail UI, password resets, breed CRUD.
4. **Notifications & Reminders** – Scheduled vaccine / pregnancy alerts; user-configurable.
5. **CI/CD Automation** – GitHub Actions: build, test, deploy, push coverage badge.
6. **Advanced Export & Search** – PDF export, multi-criteria animal/log filters.
7. **Offline Conflict Handling** – UI for conflict resolution, manual sync controls.

---

## 3️⃣ High-Level Architecture

```text
[User] ──▶ [Auth] ──▶ [Farm Selection] ──▶ [Farm Dashboard]
                                 │
                                 ├──▶ [Farm Settings]
                                 ├──▶ [Partner Management]
                                 ├──▶ [Animal Management] ──▶ [Animal Detail/Edit]
                                 ├──▶ [Logs] (Manual / Admin / Animal)
                                 ├──▶ [Notifications]
                                 ├──▶ [User Management] (admin)
                                 └──▶ [Offline Sync]
```

* Global providers: `AuthService`, `DatabaseService`, `OfflineSyncService`, `UserProvider`, `FarmProvider`, `ConnectivityStatus`.
* Routing table in `main.dart`; important routes: `/`, `/home`, `/farms`, `/register`, `/login`, plus per-feature screens.

---

## 4️⃣ Core Data Models

| Model | Fields (essential) | Notes |
|-------|--------------------|-------|
| **User** | `uid`, `email`, `name`, `role`, `createdAt` | Roles: `admin`, `partner`. |
| **Farm** | `id`, `name`, `address`, `ownerId`, `partnerIds[]`, `preferredBreeds[]`, `color`, `notes`, `archived`, `createdAt` | Many-to-many between farms ↔ partners. |
| **Partner** | `id`, `name`, `email`, `color`, `farmIds[]`, `role` | `color` links to tag color on animals. |
| **Animal** | `id`, `tagNumber`, `tagColor`, `type`, `breed`, `gender`, `birthDate`, `status`, `farmId`, `photoUrls[]`, **pregnancyLogs[]**, **birthLogs[]**, **healthLogs[]**, **saleInfo** | Status auto-updates based on logs/actions. |
| **ManualLog** | `id`, `type`, `animalIds[]`, `notes`, `performedBy`, `farmId`, `timestamp` | Farm-level notes/actions. |
| **ActivityLog** | `id`, `action`, `entity`, `entityId`, `details`, `performedBy`, `farmId`, `timestamp` | Admin supervision & audit trail. |

---

## 5️⃣ Business Logic & Automations

| Trigger / Condition | Automatic Effect |
|---------------------|------------------|
| Add new animal | Status → `Alive`, activity log entry. |
| Gender = Male | Pregnancy/Birth fields hidden. |
| Add pregnancy log | Status → `Pregnant`. |
| Mark as sold | Status → `Sold`, default buyer = "Unknown". |
| Mark as dead | Status → `Dead`, disables further edits. |
| Admin edit/delete | ActivityLog entry (`override` / `delete`). |

---

## 6️⃣ Firestore Security Rules (Snapshot)

```js
service cloud.firestore {
  match /databases/{db}/documents {

    // Users
    match /users/{uid} {
      allow read:  if request.auth != null;
      allow write: if request.auth.uid == uid;
    }

    // Farms
    match /farms/{farmId} {
      allow read: if request.auth != null;
      allow create, update, delete: if
        get(/databases/$(db)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }

    // Animals
    match /animals/{animalId} {
      allow read: if request.auth != null;
      allow create, update: if request.auth != null;  // Scoped by farm in code
      allow delete: if hasAdminRole();
    }

    // Manual logs
    match /manualLogs/{logId} {
      allow read, create: if request.auth != null;
      allow update, delete: if resource.data.performedBy == request.auth.uid;
    }

    // Admin activity logs
    match /activityLogs/{logId} {
      allow read, create: if hasAdminRole();
    }

    function hasAdminRole() {
      return get(/databases/$(db)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
  }
}
```

---

## 7️⃣ UI / UX & Accessibility

* Responsive layouts via `LayoutBuilder`; grid counts adjust for > 600 px.
* All interactive tiles & key text have `Semantics` labels and `Key`s for tests.
* Keyboard navigation (`FocusTraversalGroup`).
* Light/Dark themes, modern color scheme.

---

## 8️⃣ Testing Strategy

| Layer | Tools | Scope |
|-------|-------|-------|
| **Unit** | `flutter_test` | Providers, services. |
| **Widget** | `flutter_test`, golden images | Screen UI, overflow fixes. |
| **Integration** | `integration_test` | Full flows: Login → Home → Animal CRUD, offline banner, etc. (CI on Linux/macOS). |
| **Manual QA** | `flutter run` on real device, Firebase rules tests. |

---

## 9️⃣ Development Guidelines

1. **Scope queries by `farmId`**.
2. **Log admin overrides** via `DatabaseService.logAdminAction`.
3. **Disable notifications in tests** with `NotificationService.disableForTests()`.
4. **Default role** now `admin` (change before production).
5. **Run `flutter test` on Windows** before commit; CI runs full suite.

---

## 🔟 Contribution Workflow

```bash
# create feature branch
git checkout -b feat/<description>

# implement & test
flutter test
flutter analyze

# commit & PR
git commit -m "feat: <message>"
```

---

## 1️⃣1️⃣ Contacts

| Topic | Owner |
|-------|-------|
| Firebase rules | **Firas Bech** |
| Docs | Keep this file updated after every major merge |

---

*End of consolidated documentation.* 