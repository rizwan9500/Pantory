# Pantory App - Architecture & Flow Documentation

## App Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        PANTORY APP                          │
│                   (Freemium Model with                      │
│                    7-Day Trial & Auto-Renew)                │
└─────────────────────────────────────────────────────────────┘
                              │
                    ┌─────────▼─────────┐
                    │   State Management │
                    │     (Provider)     │
                    └────────┬───────────┘
                             │
        ┌────────────────────┼────────────────────┐
        │                    │                    │
   ┌────▼────┐        ┌──────▼──────┐     ┌──────▼──────┐
   │  Auth   │        │Subscription │     │   Local     │
   │ Service │        │   Service   │     │  Storage    │
   └────┬────┘        └──────┬──────┘     └──────┬──────┘
        │                    │                    │
        │                    │                    │
   ┌────▼────────────────────▼────────────────────▼────┐
   │              UI Screens & Navigation              │
   └───────────────────────────────────────────────────┘
```

## User Journey Flow

### New User Flow

```
┌──────────────┐
│   Welcome    │
│   Screen     │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│   Sign Up    │◄─── Email/Password or Google
│   Screen     │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│  Trial Info  │◄─── Shows 7-day trial benefits
│   Screen     │     and Pro features
└──────┬───────┘
       │
       ▼
┌──────────────┐
│     Home     │◄─── Trial Active: All features unlocked
│   Screen     │     Trial Countdown: Visible in UI
└──────┬───────┘
       │
       ├─── After 7 days ───┐
       │                    │
       ▼                    ▼
┌──────────────┐     ┌──────────────┐
│ Free Plan    │     │ User         │
│ (Ads shown)  │     │ Subscribes   │
│              │     │              │
│ Pro features │     │ Payment via  │
│   locked     │     │  Razorpay    │
└──────────────┘     └──────┬───────┘
                            │
                            ▼
                     ┌──────────────┐
                     │  Pro Plan    │
                     │  (No Ads)    │
                     │  All features│
                     │   unlocked   │
                     └──────────────┘
```

### Returning User Flow

```
┌──────────────┐
│   Welcome    │
│   Screen     │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│    Login     │◄─── Email/Password or Google
│   Screen     │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│     Home     │◄─── Status determines experience
│   Screen     │
└──────┬───────┘
       │
       ├─────────────┬─────────────┬──────────────┐
       │             │             │              │
       ▼             ▼             ▼              ▼
  ┌────────┐   ┌────────┐   ┌─────────┐   ┌──────────┐
  │  Free  │   │ Trial  │   │   Pro   │   │ Expired  │
  │  User  │   │ Active │   │  User   │   │   Sub    │
  └────────┘   └────────┘   └─────────┘   └──────────┘
  • Has ads   • No ads     • No ads      • Reverts to
  • Basic     • All Pro    • All Pro       Free
    features    features     features    • Upgrade
  • Upgrade     unlocked     unlocked      prompts
    prompts   • Countdown  • Manage Sub
```

## Screen Navigation Map

```
                    ┌──────────────────┐
                    │  Welcome Screen  │
                    └────────┬─────────┘
                             │
                    ┌────────┴─────────┐
                    │                  │
            ┌───────▼────────┐  ┌──────▼──────┐
            │  Login Screen  │  │SignUp Screen│
            └───────┬────────┘  └──────┬──────┘
                    │                  │
                    │    ┌─────────────┘
                    │    │
            ┌───────▼────▼─────┐
            │  Trial Info      │ (First time only)
            │  Screen          │
            └───────┬──────────┘
                    │
            ┌───────▼──────────┐
            │   Home Screen    │◄──────────┐
            │  (Bottom Nav)    │           │
            └───────┬──────────┘           │
                    │                      │
        ┌───────────┼───────────┬──────────┤
        │           │           │          │
    ┌───▼───┐   ┌───▼───┐   ┌──▼───┐  ┌──▼────┐
    │Search │   │Favs   │   │Profile│ │Settings│
    │ Tab   │   │ Tab   │   │Screen │ │ Screen │
    └───────┘   └───┬───┘   └───┬───┘ └───┬────┘
                    │           │         │
                    └───────────┼─────────┘
                                │
                        ┌───────▼────────┐
                        │ Subscription   │
                        │    Screen      │
                        └───────┬────────┘
                                │
                        ┌───────▼────────┐
                        │   Razorpay     │
                        │   Payment      │
                        └────────────────┘
```

## Feature Access Matrix

| Feature                    | Free | Trial | Pro |
|----------------------------|------|-------|-----|
| Basic Pantry Management    | ✅   | ✅    | ✅  |
| Expiry Reminders          | ✅   | ✅    | ✅  |
| Ad-Free Experience        | ❌   | ✅    | ✅  |
| Offline Mode              | ❌   | ✅    | ✅  |
| Advanced Analytics        | ❌   | ✅    | ✅  |
| Smart Shopping Lists      | ❌   | ✅    | ✅  |
| Favorites                 | ❌   | ✅    | ✅  |
| Priority Support          | ❌   | ✅    | ✅  |
| Sync Across Devices       | Basic| Full  | Full|
| Trial Duration            | N/A  | 7 days| N/A |

## Subscription Plans Comparison

```
┌─────────────────────────────────────────────────────────────────┐
│                    SUBSCRIPTION PLANS                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐        │
│  │  Ad-Free     │  │ Pro Monthly  │  │ Pro Annual   │        │
│  │   Basic      │  │              │  │              │        │
│  │              │  │ MOST POPULAR │  │  BEST VALUE  │        │
│  ├──────────────┤  ├──────────────┤  ├──────────────┤        │
│  │              │  │              │  │              │        │
│  │   ₹99        │  │   ₹299       │  │   ₹999       │        │
│  │  /3 months   │  │  /month      │  │  /year       │        │
│  │              │  │              │  │              │        │
│  ├──────────────┤  ├──────────────┤  ├──────────────┤        │
│  │ ✓ No Ads     │  │ ✓ No Ads     │  │ ✓ No Ads     │        │
│  │ • Basic      │  │ ✓ All Pro    │  │ ✓ All Pro    │        │
│  │   Features   │  │   Features   │  │   Features   │        │
│  │ • Sync       │  │ ✓ Offline    │  │ ✓ Offline    │        │
│  │              │  │ ✓ Analytics  │  │ ✓ Analytics  │        │
│  │              │  │ ✓ Priority   │  │ ✓ Priority   │        │
│  │              │  │   Support    │  │   Support    │        │
│  │              │  │              │  │ ✓ Exclusive  │        │
│  │              │  │              │  │   Content    │        │
│  │              │  │              │  │              │        │
│  │              │  │              │  │ Save 72%!    │        │
│  └──────────────┘  └──────────────┘  └──────────────┘        │
└─────────────────────────────────────────────────────────────────┘
```

## Payment Flow

```
User Selects Plan
       │
       ▼
┌──────────────────┐
│ Subscription     │
│ Screen           │
│ • View Plans     │
│ • Compare        │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ Razorpay         │
│ Checkout Opens   │
│                  │
│ Payment Methods: │
│ • Credit Card    │
│ • Debit Card     │
│ • UPI            │
│ • QR Code        │
│ • Net Banking    │
│ • Wallets        │
└────────┬─────────┘
         │
    ┌────▼────┐
    │ Success │ or │ Failure │
    └────┬────┘    └────┬────┘
         │              │
         ▼              ▼
┌────────────────┐  ┌──────────┐
│ Update User    │  │  Retry   │
│ Subscription   │  │  Payment │
│ Status         │  └──────────┘
│                │
│ • Set Pro      │
│ • Remove Ads   │
│ • Unlock       │
│   Features     │
└────────────────┘
```

## Data Models

### UserModel
```dart
{
  id: String
  email: String
  name: String?
  createdAt: DateTime
  isTrialActive: bool
  trialEndDate: DateTime?
  subscriptionStatus: SubscriptionStatus
  currentPlan: String?
}
```

### SubscriptionPlan
```dart
{
  id: String
  name: String
  description: String
  price: double
  currency: String
  duration: Duration
  features: List<String>
  isPopular: bool
  includesAdFree: bool
  includesProFeatures: bool
}
```

## Technical Implementation

### State Management (Provider)
- **AuthService**: User authentication and session
- **SubscriptionService**: Payment and subscription logic

### Local Storage (SharedPreferences)
- User credentials
- Trial start date
- Subscription status
- App preferences

### API Integrations
- **Razorpay**: Payment processing
- **Supabase Auth**: User authentication
- **Supabase Database**: Backend storage (ready to integrate)

---

**Note:** This architecture supports scalability and can be extended with additional features like backend APIs, cloud storage, and real-time sync.
