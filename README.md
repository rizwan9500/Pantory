# Pantory - Smart Pantry Management App

A freemium subscription-based mobile application for managing your pantry efficiently with a 7-day free trial, Razorpay payment integration, and AI-powered mood-based recipe suggestions.

![Pantory Logo](Pantory.png)

## Features

### Implemented Features ✅
- ✅ User authentication (signup, login, password reset)
- ✅ 7-day free trial system
- ✅ Subscription management with Razorpay integration
- ✅ Complete pantry item management (add, edit, delete, view)
- ✅ Expiry tracking with visual indicators
- ✅ Search functionality
- ✅ Favorites system (Pro feature)
- ✅ Shopping list management
- ✅ Smart shopping list generation (Pro feature)
- ✅ Analytics dashboard with insights (Pro feature)
- ✅ Category-based organization
- ✅ Ad-supported free tier
- ✅ Pro feature gating
- ✅ Help & FAQ
- ✅ Terms of Service
- ✅ Privacy Policy
- ✅ **AI-Powered Mood-Based Recipe Assistant** 🆕
- ✅ **Enhanced Profile with Mood Tracking** 🆕
- ✅ **Advanced Settings & Personalization** 🆕

### Free Features
- ✅ Basic Pantry Management
- ✅ Expiry Reminders
- ✅ Basic Sync Across Devices
- ✅ AI Assistant (Basic conversational features)
- ✅ Mood Tracking
- ⚠️ Ad-supported experience

### Pro Features (Available with Subscription)
- ⭐ Ad-free experience
- ⭐ Offline Mode
- ⭐ Advanced Analytics
- ⭐ Smart Shopping Lists
- ⭐ Priority Support
- ⭐ Exclusive Content
- ⭐ Unlimited Sync
- ⭐ Advanced AI Features (Full mood-based recipe suggestions)

## 🤖 AI Assistant - Your Personal Food Friend

Our AI Assistant is like having a caring friend, sibling, or partner who understands your mood and helps you feel better through food! 

### Mood-Based Recipe Suggestions
The AI Assistant talks with you about your mood and suggests recipes to help elevate your feelings:

- **Feeling Bad/Not Great?** 😔 → The AI suggests comfort foods and uplifting recipes to help you feel better
- **Feeling Okay?** 😐 → Get recipes that can turn your day around and boost your mood
- **Feeling Good?** 🙂 → Discover recipes to take you from good to great!
- **Feeling Great?** 😊 → Maintain those good vibes with energizing meals
- **Feeling Excellent?** 😄 → Keep the momentum with amazing food experiences

### Conversational & Friendly
The AI Assistant:
- Talks like a real friend or caring sibling
- Understands your emotions and responds with empathy
- Provides mood-boosting explanations with each recipe
- Remembers context within conversations
- Offers personalized suggestions based on your pantry items

### How It Works
1. Open the AI Assistant from the home screen or settings
2. Start a conversation about how you're feeling
3. The AI will chat with you and understand your mood
4. Get personalized recipe suggestions designed to elevate your mood
5. Each recipe includes:
   - Mood-boosting benefits explanation
   - Preparation time and difficulty
   - Step-by-step instructions
   - Friendly encouragement

## 📊 Enhanced Profile Features

### Mood Tracking
- Track your daily mood with 5 levels: Excellent, Great, Good, Okay, Bad
- View mood history over time
- Get insights into your emotional patterns
- Connect mood data with AI recipe suggestions

### Activity Statistics
- **Total Items**: Track items in your pantry
- **Categories**: See how many food categories you manage
- **Favorites**: Count of your favorite items
- **Mood Check-ins**: Track your mood tracking consistency

### Personalization
- Customizable profile with avatar
- Activity history and achievements
- Subscription status overview
- Quick access to all settings

## ⚙️ Advanced Settings

### AI Assistant Settings
- **Enable/Disable AI Features**: Control AI functionality
- **Mood Tracking**: Toggle mood-based features
- **Quick AI Access**: Direct link to AI Assistant chat

### Personalization Options
- **Language Selection**: Choose from 7+ languages (English, Spanish, French, German, Hindi, Chinese, Japanese)
- **Theme Customization**: Personalize app appearance (coming soon)
- **Notification Preferences**: Fine-tune how you receive alerts

### Data Management
- **Export Data**: Download your pantry data for backup
- **Import Data**: Restore from previous backups
- **Privacy Controls**: Manage your data and privacy settings

## Subscription Plans

1. **Ad-Free Basic** - ₹99/3 months
   - Remove ads
   - Basic features
   - Sync across devices

2. **Pro Monthly** - ₹299/month (Most Popular)
   - All Pro features
   - No ads
   - Full access

3. **Pro Annual** - ₹999/year (Best Value - Save 72%)
   - All Pro features
   - Best pricing
   - Annual billing

## Getting Started

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK
- Android Studio / Xcode (for mobile development)
- A Razorpay account (for payment integration)
- A Supabase account (for authentication)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/rizwan9500/Pantory.git
cd Pantory
```

2. Install dependencies:
```bash
flutter pub get
```

3. Configure Supabase:
   - Create a new Supabase project at https://supabase.com
   - Get your project URL and anon key
   - Update the Supabase configuration in `lib/main.dart`:
     ```dart
     await Supabase.initialize(
       url: 'YOUR_SUPABASE_URL',
       anonKey: 'YOUR_SUPABASE_ANON_KEY',
     );
     ```
   - Enable Email authentication in Supabase Dashboard

4. Configure Razorpay:
   - Sign up for Razorpay account at https://razorpay.com
   - Get your API keys (Test/Live)
   - Update the Razorpay key in `lib/services/subscription_service.dart`:
     ```dart
     'key': 'YOUR_RAZORPAY_KEY_HERE',
     ```

5. Run the app:
```bash
# For Android
flutter run

# For iOS
flutter run -d ios

# For Web
flutter run -d chrome
```

## Project Structure

```
lib/
├── main.dart                      # App entry point
├── models/                        # Data models
│   ├── user_model.dart            # User data model
│   ├── subscription_plan.dart     # Subscription plans
│   ├── pantry_item.dart           # Pantry item model
│   ├── shopping_list_item.dart    # Shopping list item model
│   └── mood_model.dart            # Mood tracking model 🆕
├── screens/                       # UI screens
│   ├── welcome_screen.dart
│   ├── login_screen.dart
│   ├── signup_screen.dart
│   ├── forgot_password_screen.dart
│   ├── trial_info_screen.dart
│   ├── home_screen.dart
│   ├── subscription_screen.dart
│   ├── profile_screen.dart        # Enhanced with mood tracking 🆕
│   ├── settings_screen.dart       # Enhanced with AI & personalization 🆕
│   ├── shopping_list_screen.dart  # Shopping list management
│   ├── analytics_screen.dart      # Analytics dashboard
│   ├── ai_assistant_screen.dart   # AI mood-based chat 🆕
│   ├── help_screen.dart           # Help & FAQ
│   ├── terms_screen.dart          # Terms of Service
│   └── privacy_screen.dart        # Privacy Policy
├── services/                      # Business logic
│   ├── auth_service.dart          # Authentication
│   ├── subscription_service.dart  # Payment & subscription
│   ├── pantry_service.dart        # Pantry management
│   └── ai_service.dart            # AI & mood-based features 🆕
└── widgets/                       # Reusable widgets (if needed)
```

## User Flows

### New User Sign Up Flow
1. Welcome Screen → Sign Up
2. Create Account (Email/Password or Google)
3. Trial Info Screen (7-day free trial)
4. Home Screen (with trial active)

### AI Mood-Based Recipe Flow 🆕
1. User opens AI Assistant (from home or settings)
2. AI greets and asks about mood
3. User selects or describes their mood
4. AI responds with empathy and asks about food preferences
5. User selects food preference (comfort food, healthy, sweet, etc.)
6. AI suggests 2-4 mood-appropriate recipes with:
   - Mood-boosting explanation
   - Preparation details
   - Step-by-step instructions
7. User can continue chatting or start over with new mood

### Subscription Flow
1. User taps "Upgrade" or trial expires
2. Subscription Plans Screen
3. Select a plan
4. Razorpay Payment Checkout
5. Payment Success → Pro features unlocked

### Trial Management
- 7-day trial starts automatically on signup
- Trial countdown shown in app
- After trial expires, user reverts to free plan
- Pro features locked with upgrade prompts

## Payment Integration

The app uses **Razorpay** for payment processing, supporting:
- Credit Cards
- Debit Cards
- UPI
- QR Code payments
- Net Banking
- Wallets (Paytm, PhonePe, etc.)

### Setting Up Razorpay

1. Create account at https://razorpay.com
2. Get API keys from Dashboard
3. For subscriptions, create plans in Razorpay Dashboard
4. Update the key in `subscription_service.dart`

## Authentication

Uses Supabase Authentication for secure user management.

### Authentication Features:
- Email/Password authentication
- Google OAuth (configured via Supabase)
- Password reset functionality
- Session management
- Automatic trial activation for new users

## Features by User Type

| Feature | Free | Trial | Pro |
|---------|------|-------|-----|
| Basic Pantry Management | ✅ | ✅ | ✅ |
| Expiry Reminders | ✅ | ✅ | ✅ |
| AI Assistant (Basic) | ✅ | ✅ | ✅ |
| Mood Tracking | ✅ | ✅ | ✅ |
| Profile Statistics | ✅ | ✅ | ✅ |
| Ads | ❌ (Has ads) | ✅ | ✅ |
| AI Mood-Based Recipes | Limited | ✅ | ✅ |
| Offline Mode | ❌ | ✅ | ✅ |
| Advanced Analytics | ❌ | ✅ | ✅ |
| Smart Shopping Lists | ❌ | ✅ | ✅ |
| Priority Support | ❌ | ✅ | ✅ |
| Trial Duration | - | 7 days | - |

## Development Roadmap

- [x] Day 1: Setup & Planning
  - [x] Project structure
  - [x] Authentication screens
  - [x] Subscription flow
  - [x] Payment integration
  - [x] Trial management
- [x] Day 2: Advanced Features
  - [x] Offline mode implementation (using local storage)
  - [x] Analytics dashboard
  - [x] Shopping list automation
  - [x] Enhanced UI/UX
  - [x] Complete pantry management with CRUD operations
  - [x] Smart expiry tracking
  - [x] Favorites feature
- [x] Day 3: Content & Polish
  - [x] Help & FAQ page
  - [x] Terms of Service
  - [x] Privacy Policy
  - [x] Settings page completion
  - [x] Profile page enhancements
- [x] Day 4: AI & Mood Features 🆕
  - [x] Mood-based AI conversation system
  - [x] Recipe suggestions based on mood
  - [x] Enhanced profile with mood tracking
  - [x] Advanced settings with personalization
  - [x] Mood history and statistics
  - [x] AI friend/sibling-like personality
  - [x] Mood elevation system (bad → okay → good → great → excellent)
- [ ] Future: Testing & Backend Integration
  - [ ] End-to-end testing
  - [ ] Payment flow testing
  - [ ] Supabase authentication integration (completed)
  - [ ] Cross-device sync backend
  - [ ] Performance optimization
  - [ ] AI model integration with Gemini API

## Testing

To test the app:

1. **Sign Up Flow**: Create a new account and verify trial activation
2. **Login Flow**: Log in with existing account
3. **Trial Features**: Test that Pro features are accessible during trial
4. **Subscription**: Test payment flow with Razorpay test cards
5. **Feature Gating**: Verify that Pro features lock after trial expires

### Razorpay Test Cards

Use these test cards in Razorpay test mode:
- Card Number: 4111 1111 1111 1111
- CVV: Any 3 digits
- Expiry: Any future date

## Building for Production

### Android

```bash
flutter build apk --release
# or
flutter build appbundle --release
```

### iOS

```bash
flutter build ios --release
```

## Environment Variables

Create a `.env` file for sensitive configuration:
```
RAZORPAY_KEY_ID=your_key_here
RAZORPAY_KEY_SECRET=your_secret_here
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
GEMINI_API_KEY=your_gemini_api_key  # Optional: For advanced AI features
```

## 🎯 Key Highlights

### What Makes Pantory Special

1. **Empathetic AI Assistant**: Unlike typical chatbots, our AI talks to you like a caring friend or sibling, understanding your emotions and responding with genuine care.

2. **Mood-Based Food Science**: Recipes are selected not just based on ingredients, but on their proven mood-boosting properties. Each suggestion explains *why* it will help you feel better.

3. **Holistic Wellness**: We believe food is more than fuel - it's medicine for the mind and soul. Our app helps you use your pantry to maintain and improve your emotional well-being.

4. **Personalized Journey**: Track your mood over time, see patterns, and get increasingly personalized recommendations as the AI learns what works for you.

5. **Beautiful, Intuitive UI**: Glass-morphism design with smooth animations creates a premium, calming user experience.

### Technical Innovation

- **State Management**: Provider pattern for efficient state handling
- **Authentication**: Secure Supabase integration
- **Payment Processing**: Seamless Razorpay integration
- **AI Conversation**: Context-aware chat with mood detection
- **Local Storage**: SharedPreferences for offline mood tracking
- **Responsive Design**: Works beautifully on all screen sizes

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support, email support@pantory.com or open an issue in the repository.

## Acknowledgments

- Flutter team for the amazing framework
- Razorpay for seamless payment integration
- Supabase for authentication and backend services
- Google Gemini AI for advanced AI capabilities (planned)
- The open-source community for inspiration and support

---

**Made with ❤️ for efficient pantry management and emotional well-being**

*"Because good food isn't just about nutrition - it's about nourishing your soul."* 🌟
