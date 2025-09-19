# 🏙️ Crowdsourced Civic Issue Reporting and Resolution System

A mobile-first application built with **Flutter**, **GetX**, and **Supabase** that empowers citizens to report civic issues (potholes, garbage, malfunctioning streetlights, etc.) and enables municipal staff to manage and resolve them efficiently through a centralized dashboard.

---

## 🚀 Features

### 👥 Citizen App

* Report civic issues with **photo, auto-location, and description/voice input**
* Track the status of submitted issues (submitted → acknowledged → in progress → resolved)
* Receive **push notifications** on status changes
* View and manage all reports in **My Issues**

### 🛠️ Admin/Staff Portal

* **Dashboard** with live map of reported issues
* Filter issues by category, location, status, and priority
* Assign issues to staff members
* Update issue status and add resolution comments/photos
* Access **analytics**: resolution time, department performance, hotspots

### 📊 Analytics

* Average resolution time per issue type
* Volume of issues by zone/ward
* Department response performance metrics

---

## 🗂️ Tech Stack

* **Frontend:** Flutter (cross-platform: Android, iOS, Web)
* **State Management:** GetX
* **Backend:** Supabase (Postgres, Auth, Storage, Functions, Realtime)
* **Notifications:** Supabase Realtime or Firebase Cloud Messaging
* **Maps & Location:** Google Maps API

---

## 📂 Project Structure

```
lib/
 ├── main.dart
 ├── core/
 │    ├── bindings/
 │    ├── theme/
 │    └── utils/
 ├── data/
 │    ├── models/         # Dart models
 │    ├── services/       # Supabase services
 │    └── repository/     # Data layer
 ├── modules/
 │    ├── auth/           # Login, signup, role-based auth
 │    ├── citizen/        
 │    │     ├── report_issue/
 │    │     ├── issue_tracker/
 │    │     └── profile/
 │    ├── admin/
 │    │     ├── issue_list/
 │    │     ├── map_dashboard/
 │    │     └── analytics/
 └── routes/
      └── app_pages.dart
```

---

## 🛢️ Database Schema (Supabase)

**users**

* id (uuid, pk)
* name, email, role (citizen/staff/admin)
* department\_id (nullable)

**issues**

* id (uuid, pk), title, description, image\_url
* location (lat-long), status, priority
* created\_by (fk → users.id), assigned\_to (fk → users.id)
* created\_at

**departments**

* id (uuid, pk), name (Sanitation, Public Works, etc.)

**comments**

* id (uuid, pk), issue\_id, user\_id, message, created\_at

---

## ⚙️ Core Logic

* **Citizen Flow:** Submit → Auto-route → Track progress → Notifications
* **Admin Flow:** Dashboard → Filter → Assign → Update status → Analytics
* **Routing Engine:** Supabase Function assigns department automatically based on issue type

---

## 🔔 Notifications

* Citizens notified on:

  * Issue acknowledged
  * Work started
  * Issue resolved/rejected

---

## 📦 Installation & Setup

1. **Clone the repo**

   ```bash
   git clone https://github.com/your-username/civic-issue-reporting.git
   cd civic-issue-reporting
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Configure Supabase**

   * Create a Supabase project
   * Add tables using the provided SQL schema
   * Enable authentication and storage
   * Add API keys to `lib/core/utils/constants.dart`

4. **Run the app**

   ```bash
   flutter run
   ```

---

## ✅ Deliverables

* Flutter app (citizen + admin) with **GetX controllers**
* Supabase schema + role-based policies
* Functions for automated routing
* Realtime subscriptions for issue tracking
* Secure image storage
* Documentation for setup and deployment

---

## 📌 Roadmap

* [ ] Implement advanced analytics dashboard
* [ ] Add multi-language support
* [ ] Integrate AI-based priority detection for issues

---

## 🤝 Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you’d like to change.

---

## 📄 License

This project is licensed under the MIT License.
