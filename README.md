Sport80
A Track and Field Application built using Dart, Flutter, and Firebase. Designed to help athletes and event managers efficiently track runs, manage events, and monitor performance. Originally a project for a company, it remains unfinished but serves as a strong foundation for future sports tracking tools.

Features
📊 Run Tracking: Log and monitor athlete runs with detailed stats.
📅 Event Management: Create, update, and manage track and field events seamlessly.
📈 Performance Monitoring: Track individual performance over time.
🔄 Real-time Updates: Firebase-powered real-time data synchronization.
📱 Cross-Platform: Built with Flutter, works on Android, iOS, and Web.
🔐 Authentication: Secure login and registration with Firebase Authentication.
Technologies Used
Frontend: Dart, Flutter
Backend: Firebase Firestore (Database), Firebase Authentication
Storage: Firebase Storage
State Management: Flutter Riverpod
Maps Integration: Google Maps API
Dependencies:
firebase_core
firebase_auth
cloud_firestore
firebase_storage
flutter_riverpod
google_maps_flutter
location
image_picker
Getting Started
Follow these steps to set up and run the project locally:

Prerequisites
Install Flutter SDK: Flutter Installation Guide
Set up Firebase for Flutter: Firebase Setup Guide
Ensure you have Android Studio or VS Code set up for Flutter development.
Installation
Clone the Repository

bash
Copy code
git clone https://github.com/R-Juhasz/Sport80.git
cd Sport80
Install Dependencies

bash
Copy code
flutter pub get
Configure Firebase

Create a Firebase project in the Firebase Console.
Download the google-services.json file (for Android) and GoogleService-Info.plist (for iOS).
Place these files in their respective project directories:
android/app/
ios/Runner/
Run the Application

bash
Copy code
flutter run
Screenshots
Home Screen	Event Management	Run Tracking
How to Use
Authentication

Register or log in using Firebase Authentication.
Run Tracking

Add and monitor run statistics, including distance, duration, and pace.
Manage Events

Create events, assign participants, and track event schedules.
Performance Insights

Monitor athletes' stats and visualize trends.
Project Structure
plaintext
Copy code
Sport80/
├── lib/
│   ├── main.dart          # Entry point
│   ├── screens/           # All screens (Home, Runs, Events)
│   ├── models/            # Data models for events and runs
│   ├── providers/         # Riverpod providers
│   ├── services/          # Firebase and API services
│   ├── utils/             # Utility classes and constants
│   └── widgets/           # Reusable UI components
├── assets/
│   ├── images/            # Logos and icons
│   └── screenshots/       # Screenshots for documentation
├── android/               # Android-specific code
├── ios/                   # iOS-specific code
├── pubspec.yaml           # Flutter dependencies
└── README.md              # Project documentation
Contributing
Contributions are welcome! Follow these steps to contribute:

Fork the repository.
Create a new branch for your feature or bug fix:
bash
Copy code
git checkout -b feature/your-feature-name
Commit your changes:
bash
Copy code
git commit -m "Add your feature description"
Push to your branch:
bash
Copy code
git push origin feature/your-feature-name
Open a pull request.
License
This project is licensed under the MIT License. See LICENSE for details.

Contact
For any questions or feedback:

Developer: Ryan Juhasz
GitHub: R-Juhasz
