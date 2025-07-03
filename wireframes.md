# SheepFarm Wireframes

## 1. Login Screen
- AppBar: "SheepFarm Login"
- Form:
  - Email TextField
  - Password TextField (obscure)
  - Login Button
- Error message Snackbar

---

## 2. Home Screen
- AppBar: "Dashboard"
- Welcome Text: "Hello, [User]"
- Grid/List of Actions:
  - Animals (icon)
  - Logs (icon)
  - Admin Logs (icon) **(admin only)**
  - Logout

---

## 3. Animal List Screen
- AppBar: "Animals"
- FloatingActionButton: Add Animal
- ListView of animals:
  - Leading: colored circle of tagColor
  - Title: "#tagNumber - [Type]"
  - Subtitle: breed, birthDate

---

## 4. Animal Detail Screen
- AppBar: "Animal Details"
- Card or Column:
  - Ear Tag ID & Color
  - Type, Breed, Birth Date
  - Sections:
    - Pregnancy History (list)
    - Birth Log (list)
    - Health Logs
    - Sale Info
  - Edit Button (admin/partner)

---

## 5. Add Animal Screen
- AppBar: "Add Animal"
- Form Fields:
  - Tag Number (number)
  - Tag Color (dropdown)
  - Type (dropdown)
  - Breed (text)
  - Birth Date (date picker)
- Save Button

---

## 6. Log History Screen
- AppBar: "Manual Logs"
- Filters Row:
  - Action Type dropdown
  - Animal multi-select
- ListView of logs:
  - Type, Timestamp, Notes, PerformedBy

---

## 7. Admin Activity Log Screen
- AppBar: "Activity Logs"
- Filters Row:
  - Action Type dropdown
  - Partner dropdown
  - Animal ID text
- ListView:
  - "[timestamp] [performedBy] [action] [entity] #entityId"

---

*Wireframes can be refined in Figma using the above structure.*
