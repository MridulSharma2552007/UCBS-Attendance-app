# 📋 UCBS ATTENDANCE APP - PROJECT STRUCTURE DOCUMENTATION

## 🎯 Overview
This document provides a comprehensive guide to the project structure, explaining each file, folder, and their responsibilities.

---

## 📁 PROJECT ARCHITECTURE

```
ucbs_attendance_app/
├── lib/                          # Main application code
│   ├── core/                     # Core utilities & services
│   ├── data/                     # Data layer (API calls, DB)
│   ├── domain/                   # Business logic & entities
│   ├── presentation/             # UI layer (screens & widgets)
│   ├── main.dart                 # App entry point
│   └── firebase_options.dart     # Firebase configuration
├── android/                      # Android native code
├── ios/                          # iOS native code
├── web/                          # Web platform files
├── assets/                       # Images & static files
├── pubspec.yaml                  # Dependencies & project config
└── .env                          # Environment variables
```

---

## 🔧 CORE LAYER (`lib/core/`)

### Purpose
Contains shared utilities, services, and constants used across the app.

---

### 📄 `core/config/app_config.dart`
**Purpose:** Centralized configuration for API endpoints and credentials

**Key Variables:**
- `supabaseUrl` - Supabase backend URL
- `supabaseAnonKey` - Supabase anonymous key for API access
- `firebaseProjectId` - Firebase project identifier

**Usage:**
```dart
// Initialize Supabase in main.dart
await Supabase.initialize(
  url: AppConfig.supabaseUrl,
  anonKey: AppConfig.supabaseAnonKey,
);
```

**Data Stored:** API credentials, backend URLs

---

### 📄 `core/constants/app_constants.dart`
**Purpose:** Global constants used throughout the app

**Key Constants:**
- `appName` - "UCBS Attendance"
- `appVersion` - "1.0.0"
- `loginRoute`, `homeRoute` - Navigation routes
- `studentRole`, `teacherRole` - User role identifiers
- `detectEndpoint` - Face recognition API endpoint (ngrok)
- `defaultPadding`, `cardRadius` - UI dimensions

**Storage Keys:**
- `isLoggedKey` - Tracks login status
- `roleKey` - Stores user role (Student/Teacher)
- `userNameKey` - Stores user's name
- `studentIdKey` - Student ID
- `employeeIdKey` - Teacher employee ID

**Usage:**
```dart
// Check if user is logged in
bool isLogged = StorageService.getBool(AppConstants.isLoggedKey);
```

---

### 📄 `core/services/auth_service.dart`
**Purpose:** Handles authentication logic for both students and teachers

**Key Functions:**

#### `SignInStudent(BuildContext, Map<String, dynamic>)`
- Stores student data in SharedPreferences
- Updates UserSession provider
- Saves: email, name, roll_no, semester, role

#### `SignInTeacher(BuildContext, Map<String, dynamic>)`
- Stores teacher data in SharedPreferences
- Updates UserSession provider
- Saves: email, name, employee_id, role

#### `signOut(BuildContext)`
- Clears all stored authentication data
- Clears Google Auth session
- Navigates to login screen

#### `isSignedIn()` → `bool`
- Returns login status

#### `getCurrentRole()` → `String?`
- Returns "Student" or "Teacher"

#### `getCurrentUserData()` → `Map<String, dynamic>`
- Returns all stored user information

**Data Stored:**
- User email, name, ID (roll_no or employee_id)
- User role
- Login status

---

### 📄 `core/services/storage_service.dart`
**Purpose:** Wrapper around SharedPreferences for local data persistence

**Key Functions:**

#### String Operations
- `setString(key, value)` - Store string
- `getString(key)` - Retrieve string

#### Boolean Operations
- `setBool(key, value)` - Store boolean
- `getBool(key)` - Retrieve boolean

#### Integer Operations
- `setInt(key, value)` - Store integer
- `getInt(key)` - Retrieve integer

#### Cleanup
- `remove(key)` - Delete specific key
- `clear()` - Clear all data

**Data Stored:**
- User credentials
- User preferences
- Session information
- App settings

**Example:**
```dart
// Store user email
await StorageService.setString('userEmail', 'user@example.com');

// Retrieve user email
String? email = StorageService.getString('userEmail');
```

---

### 📄 `core/services/notification_service.dart`
**Purpose:** Handles push notifications and local alerts

**Key Functions:**
- `init()` - Initialize notification service
- Manages Firebase Cloud Messaging (FCM)
- Handles notification display

**Data Handled:**
- Push notification tokens
- Notification preferences
- Alert messages

---

### 📄 `core/utils/`
**Purpose:** Utility functions and helpers

**Typical Contents:**
- Date/time formatters
- String validators
- Image processors
- Error handlers

---

## 📊 DATA LAYER (`lib/data/`)

### Purpose
Handles all data operations: API calls, database queries, and external service integration.

---

### 📁 `data/services/Firebase/`

#### 📄 `sign_in_with_google.dart`
**Purpose:** Google OAuth authentication

**Key Functions:**
- `signIn()` - Initiate Google sign-in
- `signOut()` - Sign out from Google
- `getCurrentUser()` - Get signed-in user info

**Data Handled:**
- Google account credentials
- User profile (name, email, photo)
- Authentication tokens

---

### 📁 `data/services/supabase/`

#### 📁 `Student/`

##### 📄 `verified_student.dart`
**Purpose:** Verify student credentials in database

**Key Functions:**
- `verifyStudent(rollNo, email)` → `bool`
- Checks if student exists in Supabase
- Validates student credentials

**Data Accessed:**
- Student table in Supabase
- Fields: roll_no, email, name, semester

---

##### 📄 `mark_attendance.dart`
**Purpose:** Record student attendance in database

**Key Functions:**
- `markAttendance(studentId, classId, timestamp)` → `bool`
- Inserts attendance record
- Links student to class session

**Data Stored:**
- Attendance table
- Fields: student_id, class_id, timestamp, status

---

##### 📄 `compare_vector.dart`
**Purpose:** Compare face vectors for recognition

**Key Functions:**
- `compareVector(capturedVector, storedVector)` → `double`
- Calculates similarity score
- Returns confidence percentage

**Data Used:**
- 512-dimensional face vectors
- Stored in Supabase
- Compared with captured face

---

##### 📄 `get_attendance.dart`
**Purpose:** Retrieve student attendance records

**Key Functions:**
- `getAttendance(studentId, semester)` → `List<AttendanceRecord>`
- Fetches attendance history
- Filters by date range

**Data Retrieved:**
- Attendance records
- Class information
- Timestamps

---

##### 📄 `fetch_live_classes.dart`
**Purpose:** Get active classes for student

**Key Functions:**
- `getLiveClasses(studentId)` → `List<Class>`
- Fetches ongoing classes
- Returns class details

**Data Retrieved:**
- Class ID, name, subject
- Teacher information
- Start time, duration

---

#### 📁 `Teacher/`

##### 📄 `verify_teacher.dart`
**Purpose:** Verify teacher credentials

**Key Functions:**
- `verifyTeacher(employeeId, email)` → `bool`
- Checks if teacher exists
- Validates credentials

**Data Accessed:**
- Teacher table in Supabase
- Fields: employee_id, email, name, department

---

##### 📄 `get_subject_name.dart`
**Purpose:** Retrieve subject information

**Key Functions:**
- `getSubjectName(subjectId)` → `String`
- Fetches subject details
- Returns subject code and name

**Data Retrieved:**
- Subject table
- Subject code, name, credits

---

### 📁 `data/models/`
**Purpose:** Data models representing database entities

**Typical Models:**
- `Student` - Student entity
- `Teacher` - Teacher entity
- `Attendance` - Attendance record
- `Class` - Class/Subject entity
- `User` - Generic user model

---

### 📁 `data/repositories/`
**Purpose:** Abstract repositories defining data access contracts

**Pattern:** Repository Pattern
- Defines interfaces for data operations
- Implemented by concrete repositories

---

## 🧠 DOMAIN LAYER (`lib/domain/`)

### Purpose
Contains business logic, use cases, and entity definitions (independent of frameworks).

---

### 📁 `domain/entities/`
**Purpose:** Pure Dart classes representing core business objects

**Typical Entities:**
- `StudentEntity` - Student business object
- `TeacherEntity` - Teacher business object
- `AttendanceEntity` - Attendance record
- `ClassEntity` - Class information

---

### 📁 `domain/repositories/`
**Purpose:** Abstract repository interfaces

**Pattern:** Dependency Inversion
- Defines contracts for data access
- Implementation in data layer

---

### 📁 `domain/usecases/`
**Purpose:** Business logic operations

**Typical Use Cases:**
- `MarkAttendanceUseCase` - Mark student attendance
- `GetAttendanceHistoryUseCase` - Fetch attendance records
- `VerifyStudentUseCase` - Validate student credentials

---

## 🎨 PRESENTATION LAYER (`lib/presentation/`)

### Purpose
UI components, screens, and state management.

---

### 📁 `presentation/providers/`

#### 📄 `Data/user_session.dart`
**Purpose:** Global user state management using Provider pattern

**Key Properties:**
- `email` - Current user's email
- `name` - Current user's name
- `role` - User role (Student/Teacher)
- `isLoggedIn` - Login status

**Key Methods:**
- `setEmail(String)` - Update email
- `setName(String)` - Update name
- `setrole(String)` - Update role
- `clear()` - Clear all data

**Usage:**
```dart
// Access user session
final userSession = context.read<UserSession>();
String userName = userSession.name;

// Update user session
context.read<UserSession>().setName('John Doe');
```

**Data Stored:**
- Current user information
- Session state
- Authentication status

---

### 📁 `presentation/screens/`

#### 📁 `login/`

##### 📁 `Gates/`

###### 📄 `app_gate.dart`
**Purpose:** Entry point that routes to appropriate screen based on login status

**Logic:**
- Checks if user is logged in
- Routes to home or login screen
- Handles role-based navigation

**Navigation Flow:**
```
AppGate
├── If logged in → UserInfo
└── If not logged in → Login
```

---

###### 📄 `user_info.dart`
**Purpose:** Displays user information and role selection

**Shows:**
- User name, email
- Current role
- Logout button

---

##### 📁 `Shared/`

###### 📄 `login.dart`
**Purpose:** Main login screen with role selection

**Features:**
- Role selection (Student/Teacher)
- Navigation to respective login screens
- Google sign-in option

---

###### 📄 `role_selection.dart`
**Purpose:** UI for selecting user role

**Options:**
- Student login
- Teacher login

---

###### 📄 `sign_up.dart`
**Purpose:** User registration screen

**Fields:**
- Email
- Name
- Role selection
- Password (if applicable)

---

###### 📄 `scan_screen.dart`
**Purpose:** Face recognition camera screen

**Features:**
- Camera preview
- Face detection
- Vector extraction
- Attendance marking

**Process:**
1. Capture face from camera
2. Send to AI API (ngrok endpoint)
3. Get 512D vector
4. Compare with stored vectors
5. Mark attendance if match found

---

##### 📁 `Student/`

###### 📄 `student_login.dart`
**Purpose:** Student login form

**Fields:**
- Roll number
- Email
- Semester

**Validation:**
- Checks if student exists in database
- Verifies credentials

---

###### 📄 `sign_in_student.dart`
**Purpose:** Student sign-in processing

**Process:**
1. Validate student credentials
2. Store in SharedPreferences
3. Update UserSession
4. Navigate to home

---

##### 📁 `Teacher/`

###### 📄 `sign_in_teacher.dart`
**Purpose:** Teacher sign-in processing

**Process:**
1. Validate teacher credentials
2. Store in SharedPreferences
3. Update UserSession
4. Navigate to teacher home

---

###### 📄 `teacher_signup.dart`
**Purpose:** Teacher registration form

**Fields:**
- Employee ID
- Email
- Name
- Department

---

#### 📁 `main/`

##### 📁 `teacher/`

###### 📄 `teacher_home.dart`
**Purpose:** Main teacher dashboard

**Features:**
- Navigation to different sections
- Quick stats
- Class management

**Sections:**
- Start Class
- View Reports
- Search Students
- Settings

---

###### 📁 `pages/`

####### 📄 `teacher_mainpage.dart`
**Purpose:** Teacher home page with overview

**Shows:**
- Today's classes
- Attendance summary
- Quick actions

---

####### 📄 `start_class.dart`
**Purpose:** Initiate attendance session

**Features:**
- Select subject
- Set class duration
- Start attendance marking
- Real-time student check-ins

---

####### 📄 `subject_selection.dart`
**Purpose:** Choose subject for class

**Shows:**
- List of assigned subjects
- Class schedule
- Student count

---

####### 📄 `report.dart`
**Purpose:** View attendance reports

**Features:**
- Attendance statistics
- Charts and graphs
- Export options
- Date range filtering

---

####### 📄 `search.dart`
**Purpose:** Search for students

**Features:**
- Search by roll number
- Search by name
- View student details
- Attendance history

---

####### 📄 `student_info.dart`
**Purpose:** Display detailed student information

**Shows:**
- Student name, roll number
- Attendance percentage
- Attendance history
- Performance metrics

---

####### 📄 `settings.dart`
**Purpose:** Teacher settings and preferences

**Options:**
- Profile settings
- Notification preferences
- Logout

---

### 📁 `presentation/widgets/`

#### 📁 `common/`
**Purpose:** Reusable UI components

**Typical Widgets:**
- `CustomButton` - Styled button
- `CustomTextField` - Input field
- `LoadingIndicator` - Loading spinner
- `ErrorWidget` - Error display

---

#### 📁 `charts/`
**Purpose:** Chart and graph components

**Typical Widgets:**
- `AttendanceChart` - Bar/line chart
- `PieChart` - Pie chart for statistics
- `TrendChart` - Trend visualization

---

#### 📁 `web/`
**Purpose:** Web-specific UI components

**Typical Widgets:**
- Web layout components
- Responsive containers
- Web navigation

---

## 📱 MAIN ENTRY POINT

### 📄 `lib/main.dart`
**Purpose:** Application initialization and setup

**Initialization Steps:**
1. `WidgetsFlutterBinding.ensureInitialized()` - Initialize Flutter
2. Load `.env` file with environment variables
3. Initialize `StorageService` - Local storage
4. Initialize Firebase
5. Initialize Supabase
6. Setup Provider for state management
7. Initialize NotificationService
8. Run app with `AppGate` as home

**Key Setup:**
```dart
// Firebase initialization
await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

// Supabase initialization
await Supabase.initialize(
  url: AppConfig.supabaseUrl,
  anonKey: AppConfig.supabaseAnonKey,
);

// Provider setup
MultiProvider(
  providers: [ChangeNotifierProvider(create: (_) => UserSession())],
  child: const MyApp(),
)
```

---

## 🔐 FIREBASE CONFIGURATION

### 📄 `lib/firebase_options.dart`
**Purpose:** Firebase project configuration

**Contains:**
- Firebase project ID
- API keys
- Platform-specific settings (Android, iOS, Web)

**Auto-generated by:** `flutterfire configure`

---

## 📦 DEPENDENCIES

### 📄 `pubspec.yaml`
**Purpose:** Project configuration and dependency management

**Key Dependencies:**

| Package | Purpose |
|---------|---------|
| `flutter` | UI framework |
| `provider` | State management |
| `firebase_core` | Firebase initialization |
| `firebase_auth` | Authentication |
| `supabase_flutter` | Backend database |
| `camera` | Camera access |
| `http` | HTTP requests |
| `shared_preferences` | Local storage |
| `flutter_dotenv` | Environment variables |
| `google_sign_in` | Google OAuth |
| `fl_chart` | Charts and graphs |
| `permission_handler` | Permission management |
| `geolocator` | Location services |

---

## 🌍 ENVIRONMENT VARIABLES

### 📄 `.env`
**Purpose:** Store sensitive configuration

**Typical Variables:**
```
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
FIREBASE_PROJECT_ID=your-project-id
FACE_RECOGNITION_API=https://your-ngrok-url/detect
```

---

## 🤖 FACE RECOGNITION FLOW

### Process:
1. **Capture** → Camera captures student face
2. **Send** → Image sent to Python FastAPI (ngrok endpoint)
3. **Process** → OpenCV + Buffalo model extracts 512D vector
4. **Compare** → Vector compared with stored vectors in Supabase
5. **Match** → If similarity > threshold, mark attendance
6. **Store** → Attendance record saved to database

### Key Files Involved:
- `scan_screen.dart` - UI for capture
- `compare_vector.dart` - Vector comparison logic
- `mark_attendance.dart` - Database insertion

---

## 📊 DATA FLOW DIAGRAM

```
┌─────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                   │
│  (Screens, Widgets, UI Components)                      │
└────────────────────┬────────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────────┐
│                    DOMAIN LAYER                         │
│  (Business Logic, Use Cases, Entities)                  │
└────────────────────┬────────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────────┐
│                    DATA LAYER                           │
│  (Repositories, Services, API Calls)                    │
└────────────────────┬────────────────────────────────────┘
                     │
        ┌────────────┴────────────┐
        │                         │
    ┌───▼────┐            ┌──────▼──────┐
    │Supabase│            │  Firebase   │
    │(DB)    │            │  (Auth)     │
    └────────┘            └─────────────┘
```

---

## 🔄 STATE MANAGEMENT

**Pattern:** Provider Pattern

**Key Provider:**
- `UserSession` - Manages current user state

**Usage:**
```dart
// Read state
final userName = context.read<UserSession>().name;

// Watch state (rebuilds on change)
final userName = context.watch<UserSession>().name;

// Update state
context.read<UserSession>().setName('New Name');
```

---

## 🗄️ DATABASE SCHEMA (Supabase)

### Tables:

#### `students`
- `id` (PK)
- `roll_no` (UNIQUE)
- `email` (UNIQUE)
- `name`
- `semester`
- `face_vector` (512D array)

#### `teachers`
- `id` (PK)
- `employee_id` (UNIQUE)
- `email` (UNIQUE)
- `name`
- `department`

#### `classes`
- `id` (PK)
- `teacher_id` (FK)
- `subject_id` (FK)
- `start_time`
- `end_time`
- `date`

#### `attendance`
- `id` (PK)
- `student_id` (FK)
- `class_id` (FK)
- `timestamp`
- `status` (present/absent)

#### `subjects`
- `id` (PK)
- `code`
- `name`
- `credits`

---

## 🚀 NAVIGATION FLOW

```
AppGate
├── Not Logged In
│   └── Login
│       ├── Student Login
│       │   └── Student Home
│       │       ├── Scan Screen
│       │       ├── Attendance History
│       │       └── Analytics
│       └── Teacher Login
│           └── Teacher Home
│               ├── Start Class
│               ├── Reports
│               ├── Search
│               └── Settings
└── Logged In
    └── Redirect to appropriate home
```

---

## 📝 COMMON WORKFLOWS

### Student Attendance Marking:
1. Student opens app
2. Navigates to "Mark Attendance"
3. Camera screen opens
4. Face captured and sent to API
5. Vector compared with stored vector
6. If match found → Attendance marked
7. Confirmation shown to student

### Teacher Class Management:
1. Teacher logs in
2. Selects subject
3. Starts class session
4. Students check in via face recognition
5. Real-time attendance dashboard
6. Can view reports and analytics

---

## 🔒 SECURITY CONSIDERATIONS

- **Face Vectors:** Stored securely in Supabase
- **Authentication:** Firebase Auth + Google OAuth
- **API Endpoints:** Protected with authentication
- **Local Storage:** Encrypted via SharedPreferences
- **Environment Variables:** Stored in `.env` (not committed)

---

## 📚 NEXT STEPS FOR DEVELOPERS

1. **Setup:** Clone repo, run `flutter pub get`
2. **Configuration:** Add Firebase & Supabase credentials
3. **Testing:** Run `flutter test`
4. **Development:** Follow Clean Architecture principles
5. **Contribution:** Create feature branches, write tests

---

**Last Updated:** 2025
**Version:** 1.0.0
**Maintainer:** UCBS Attendance App Team

