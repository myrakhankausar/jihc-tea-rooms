# JIHC Tea Room

JIHC Tea Room is a Flutter mobile application developed for students living in the JIHC dormitory. The project helps students book tea rooms easily, manage their personal profiles, and track booking activity through a clean interface backed by Firebase services.

This project was created as a university-level software solution that combines Flutter for the frontend and Firebase for authentication, cloud storage, and real-time database functionality.

## Project Description

The goal of JIHC Tea Room is to digitize tea room management inside the dormitory environment. Instead of handling room usage informally, students can register, sign in, choose their gender-based room access, create bookings, manage their profile, and monitor room activity in a structured system.

The application focuses on:

- secure authentication
- Firestore-based user management
- booking creation and tracking
- role-based and user-based data ownership
- profile photo upload and update

## Features

- Email and password registration
- Google Sign-In authentication
- Automatic Firestore user document creation after authentication
- Gender-based room access flow
- Tea room booking creation
- Booking history and booking management
- Profile editing
- Profile photo upload using Firebase Storage
- Real-time Firestore-powered booking updates
- Admin-friendly booking overview support

## Technologies Used

- Flutter
- Dart
- Firebase Authentication
- Cloud Firestore
- Firebase Storage
- Material Design

## Firebase Services Used

- Firebase Authentication
  - Email/Password Sign-In
  - Google Sign-In
- Cloud Firestore
  - User profile storage
  - Booking storage
  - Alert storage design
- Firebase Storage
  - Profile photo upload and retrieval

## Firestore Database Structure

### `users/{uid}`

Each authenticated user is stored using their Firebase Authentication UID as the Firestore document ID.

```text
users/{uid}
  - uid
  - name
  - email
  - photoUrl
  - gender
  - createdAt
```

### `bookings/{bookingId}`

Each booking is stored as a separate document.

```text
bookings/{bookingId}
  - userId
  - teaRoom
  - bookingDate
  - startTime
  - endTime
  - status
```

### `alerts/{alertId}`

Alerts are designed as user-linked notification documents.

```text
alerts/{alertId}
  - userId
  - title
  - message
  - createdAt
```

## CRUD Operations

### Create

- User Registration
- Google Sign In User Creation
- Booking Creation
- Alert Creation

### Read

- Load User Profile
- Load Bookings
- Load Alerts

### Update

- Edit Profile
- Update Profile Photo
- Update Booking Status

### Delete

- Cancel Booking
- Remove Alert

## Installation Instructions

### 1. Clone the repository

```bash
git clone <your-repository-url>
cd jihc_tea_room
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Configure Firebase

- Create a Firebase project in the Firebase Console
- Enable Firebase Authentication
- Enable Cloud Firestore
- Enable Firebase Storage
- Add Android, iOS, or Web app configuration files
- Make sure `firebase_options.dart` is correctly generated

### 4. Run the project

```bash
flutter run
```

## Project Structure

```text
lib/
  models/
    booking_model.dart
    booking_analytics.dart
    user_model.dart

  screens/
    admin_bookings_screen.dart
    booking_details_screen.dart
    create_booking_screen.dart
    edit_booking_screen.dart
    edit_profile_screen.dart
    gender_select_screen.dart
    home_screen.dart
    login_screen.dart
    main_screen.dart
    my_bookings_screen.dart
    notifications_screen.dart
    profile_screen.dart
    register_screen.dart
    room_details_screen.dart
    splash_screen.dart
    upload_photo_screen.dart

  services/
    auth_service.dart
    booking_service.dart
    storage_service.dart

  utils/
    app_constants.dart
    app_text.dart
    booking_utils.dart

  widgets/
    shared_widgets.dart

  main.dart
  firebase_options.dart
```

## Screenshots

Add screenshots of the application here before final submission.

Suggested screenshots:

- Splash Screen
- Login Screen
- Register Screen
- Gender Selection Screen
- Home Screen
- Create Booking Screen
- My Bookings Screen
- Profile Screen
- Admin Bookings Screen

Example markdown:

```md
![Login Screen](screenshots/login.png)
![Home Screen](screenshots/home.png)
![Profile Screen](screenshots/profile.png)
```

## Future Improvements

- Add a dedicated Firestore-backed alerts module
- Add push notifications for bookings and reminders
- Add booking approval workflow for administrators
- Add stronger Firestore security rules documentation
- Add booking conflict analytics dashboard
- Add multilingual support for all screens
- Add unit and integration tests
- Add responsive improvements for web and tablet layouts

## Conclusion

JIHC Tea Room is a practical Flutter + Firebase project designed to improve dormitory tea room management through authentication, cloud data storage, and real-time booking workflows. The project demonstrates the use of modern mobile development tools and provides a strong foundation for future expansion in a university environment.

## Screenshots

### Screenshot 1
![Screenshot1](Screenshot%202026-05-29%20at%2011.28.22.png)

### Screenshot 2
![Screenshot2](Screenshot%202026-05-29%20at%2011.28.57.png)

### Screenshot 3
![Screenshot3](Screenshot%202026-05-29%20at%2011.29.09.png)

### Screenshot 4
![Screenshot4](Screenshot%202026-05-29%20at%2011.29.20.png)

### Screenshot 5
![Screenshot5](Screenshot%202026-05-29%20at%2011.29.39.png)

### Screenshot 6
![Screenshot6](Screenshot%202026-05-29%20at%2011.29.45.png)

### Screenshot 7
![Screenshot7](Screenshot%202026-05-29%20at%2011.29.48.png)
