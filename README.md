# 🌾 Digital Farmer App: Cultivating Success, One Tap at a Time 🚀

---

Welcome to the **Digital Farmer App**, a modern, Flutter-based mobile application designed to empower farmers with real-time agricultural tips, crucial weather updates, and a vibrant community platform. Our mission is simple: to bring the power of technology directly into the hands of farmers, helping them cultivate greater success and build stronger connections.

Say goodbye to guesswork and hello to informed decisions! The Digital Farmer App is your ultimate companion for accessing vital resources, connecting effortlessly with peers, and managing your farm life with unprecedented ease.

---

## ✨ Why You'll Love the Digital Farmer App:
* **AI-Powered Farming Insights 🤖:** Harness the power of artificial intelligence to receive personalized crop recommendations, pest detection, soil health analysis, and yield predictions tailored to your farm’s unique conditions.
* **Secure & Seamless Access 🔒:** Sign up or sign in with ease using email and a secure OTP verification. Your data, your farm – protected.
* **Hyper-Local Insights 📍:** Grant location access on first install to unlock tailored agricultural tips and precise, real-time weather data relevant to your specific location.
* **Effortless Profile Management 🧑‍🌾:** Update your picture and personal details via the intuitive **Settings** tab. Make the app truly yours!
* **Thriving Community Hub 💬:** Connect, collaborate, and share invaluable knowledge with fellow registered farmers through the dedicated **Chat** tab. Grow together, learn from each other!
* **Rich Content Library 🌱:** Access a comprehensive collection of agricultural tips, in-depth tutorials, and best practices – available instantly after authentication. Knowledge at your fingertips!
* **Stunning & Responsive UI 🎨:** Experience a clean, modern design optimized for both Android and iOS, ensuring a delightful user experience. Farming has never looked this good!

---

## 🚀 Get Started: Your Digital Farming Journey Begins Here!

Ready to transform your farm? Follow these steps to set up and run the Digital Farmer App locally.

### 📋 Prerequisites:

Before you begin, ensure you have:

* **Flutter SDK** (latest stable version recommended)
* **Dart SDK** (included with Flutter)
* **VS Code** or **Android Studio** (for development)
* **Git** (for cloning the repository)
* **Backend APIs** (FastAPI and Express) – *crucial for full app functionality.*

### 🛠️ Installation Steps:

1.  **Clone the Repository:**
    ```bash
    git clone [https://github.com/username/digital-farmer-app.git](https://github.com/username/digital-farmer-app.git)
    cd digital-farmer-app
    ```
2.  **Install Dependencies:**
    ```bash
    flutter pub get
    ```
    This command fetches all the necessary packages for the project.
3.  **Configure Backend APIs:**
    You'll need to update the API endpoints to connect with your FastAPI and Express backends. Open `lib/service/api/base_api.dart` and modify the base URLs:
##### 🔗 API Base URLs Example Configuration



```dart
static const String aiBaseUrl = kIsWeb 
    ? 'https://your-fastapi-ip/api' 
    : 'https://your-fastapi-ip/api';

static const String imageBaseUrl = kIsWeb 
    ? 'https://your-express-ip' 
    : 'https://your-express-ip';

static const String apiBaseUrl = kIsWeb 
    ? 'https://your-express-ip/api' 
    : 'https://your-express-ip/api';

```

For Example:

```dart
static const String apiBaseUrl = kIsWeb ?                    
'http://localhost:8000/api':'http://10.175.28.72:8000/api';
static const String imageBaseUrl =kIsWeb ? 'http://localhost:8000':'http://10.175.28.72:8000';
static const String aiBaseUrl = kIsWeb ? 'http://localhost:8000': 'http://10.175.28.72:7000';  

```
*Ensure these URLs point to your running backend services.*

------
4.  **Run the App:**
    Connect a physical device or launch an emulator. Then, run the application using:
    ```bash
    flutter run
    ```
    The app should now launch on your device/emulator!

---

## 📲 First-Time Setup & Key Actions:

* **Grant Location Permission:** On first launch, the app will request location access. Granting this is essential for receiving region-specific tips and accurate weather data.
* **Authenticate:** Sign up or sign in, then verify your email via OTP. This step unlocks all core features, including community chat and content access.

---

## 📚 Resources for New Flutter Developers:

New to Flutter or mobile development? No problem! Here are some excellent resources to help you get up to speed:

* [**Write Your First Flutter App**](https://docs.flutter.dev/get-started/codelab): A great starting point for hands-on learning.
* [**Flutter Cookbook**](https://docs.flutter.dev/cookbook): Practical recipes for common Flutter tasks.
* [**Flutter Documentation**](https://docs.flutter.dev/): The official go-to resource for comprehensive tutorials and API references.

---

## 🤝 Contribute: Help Us Grow!

We believe in the power of open source and warmly welcome contributions from the community! Your ideas and code can help us make the Digital Farmer App even better.

**To contribute:**

1.  **Fork** this repository.
2.  Create a new feature branch: `git checkout -b feature/your-awesome-feature`.
3.  Make your changes and commit them: `git commit -m 'feat: Add your amazing feature'`.
4.  Push your branch: `git push origin feature/your-awesome-feature`.
5.  Open a **Pull Request** and describe your changes. We'll review it promptly!

---


## 📧 Contact:

For support, inquiries, or just to share your feedback, feel free to reach out to us at:
**ethiopianfarmers@gmail.com**

---

🌟 **Join us in empowering farmers with technology, one tap at a time!**
