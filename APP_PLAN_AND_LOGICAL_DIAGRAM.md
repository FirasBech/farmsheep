# 🗺️ Project SheepFarm: App Plan & Logical Diagram

## Overview
A multi-farm management app for sheep & goats, supporting user roles, animal and log management, partner collaboration, offline sync, notifications, and admin features.

---

## 1. High-Level App Structure

- **Authentication**: Login, registration, email verification, password reset, role-based access
- **Farm Management**: Create/select/archive/delete/restore farms, farm dashboard, settings, activity log
- **Partner Management**: Add/view/edit/remove partners, assign roles, per-farm permissions
- **Animal Management**: Add/edit/delete/search/filter animals, custom fields, statuses, photo upload, export (CSV/PDF)
- **Logs**: Manual logs, advanced filtering/export, audit trails
- **User Management**: Admin user list, role assignment, password reset
- **Offline Sync**: Firestore persistence, manual/auto sync, conflict resolution
- **Notifications**: Scheduling, settings, dashboard UI
- **CI/CD & Docs**: Automated pipeline, test coverage, up-to-date documentation

---

## 2. Logical Flow Diagram (Textual)

```
[User] ──▶ [Auth] ──▶ [Farm Selection] ──▶ [Farm Dashboard]
                                 │
                                 ├──▶ [Farm Settings]
                                 ├──▶ [Partner Management]
                                 ├──▶ [Animal Management]
                                 │         └──▶ [Animal Detail/Edit]
                                 ├──▶ [Logs]
                                 ├──▶ [Notifications]
                                 ├──▶ [User Management] (admin)
                                 └──▶ [Offline Sync]
```

---

## 3. Key Data Models

- **User**: uid, email, displayName, role
- **Farm**: id, name, address, ownerId, partnerIds, preferredBreeds, color, partnerPermissions, notes, archived
- **Partner**: id, name, email, color, farmIds, role
- **Animal**: id, tagNumber, tagColor, type, breed, birthDate, farmId, customFields, statuses, photoUrls
- **ManualLog**: id, type, animalIds, notes, performedBy, farmId, timestamp
- **ActivityLog**: id, action, entity, entityId, details, performedBy, farmId, timestamp

---

## 4. Main Screens/Features

- Home/Dashboard
- Farm List & Selection
- Farm Dashboard & Settings
- Partner List & Management
- Animal List, Detail, Add/Edit, Export
- Log Search/Export, Audit Trail
- User Management (admin)
- Notifications
- Offline Sync Banner/Status

---

## 5. Extensibility & Future Work
- Modular structure for new features (e.g., inventory, analytics)
- Easy to add new export formats, notification types, or partner roles
- Designed for cross-platform (mobile, web, desktop)

---

*For a visual diagram, see wireframes.md or request a generated diagram.*
