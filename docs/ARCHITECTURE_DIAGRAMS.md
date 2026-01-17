# Pantory Architecture Diagrams & Flow Documentation

## Table of Contents
1. [System Architecture](#system-architecture)
2. [Database Setup Guide](#database-setup-guide)
3. [Page Flow Diagrams](#page-flow-diagrams)
4. [Feature Flows](#feature-flows)
5. [Data Flow](#data-flow)
6. [Testing Guide](#testing-guide)

---

## System Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         PANTORY APP                              │
│                                                                   │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │ Presentation │  │   Business   │  │     Data     │          │
│  │    Layer     │→ │     Logic    │→ │    Layer     │          │
│  │  (Screens)   │  │  (Services)  │  │  (Storage)   │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
│         ↓                  ↓                  ↓                   │
│    Flutter UI        State Mgmt      Supabase/Local             │
│                      (Provider)      (SharedPrefs)               │
└─────────────────────────────────────────────────────────────────┘
         ↓                  ↓                  ↓
┌────────────────┐  ┌──────────────┐  ┌───────────────┐
│   Supabase     │  │  External    │  │    Local      │
│   Backend      │  │     APIs     │  │   Storage     │
│                │  │              │  │               │
│ • Auth         │  │ • Google AI  │  │ • SharedPrefs │
│ • Database     │  │ • Image APIs │  │ • Cache       │
│ • Storage      │  │ • Optional   │  │               │
└────────────────┘  └──────────────┘  └───────────────┘
```

### Layer Details

#### 1. Presentation Layer (Screens)
```
lib/screens/
├── welcome_screen.dart          → App entry point
├── onboarding_screen.dart       → First-time user experience
├── login_screen.dart            → Authentication
├── signup_screen.dart           → User registration
├── home_screen.dart             → Main pantry management
├── profile_screen.dart          → User profile + mood tracking
├── settings_screen.dart         → App configuration
├── ai_assistant_screen.dart     → Mood-based AI chat
├── user_preferences_screen.dart → Dietary preferences
├── advanced_ingredient_search_screen.dart → Ingredient search (Supabase)
├── shopping_list_screen.dart    → Shopping management
├── subscription_screen.dart     → Premium features
└── analytics_screen.dart        → Usage statistics
```

#### 2. Business Logic Layer (Services)
```
lib/services/
├── auth_service.dart                    → Supabase authentication
├── pantry_service.dart                  → Pantry CRUD operations
├── ai_service.dart                      → Mood detection + recipes
├── supabase_ingredient_service.dart     → Ingredient database
├── ingredient_search_service.dart       → Multi-source search
├── image_recognition_service.dart       → AI image analysis
├── barcode_scan_service.dart           → Barcode scanning
└── subscription_service.dart            → Payment handling
```

#### 3. Data Layer (Models)
```
lib/models/
├── user_model.dart              → User profile
├── pantry_item.dart             → Pantry items
├── mood_model.dart              → Mood tracking
├── user_preferences.dart        → Dietary preferences
├── shopping_list_item.dart      → Shopping items
└── subscription_plan.dart       → Premium plans
```

---

## Database Setup Guide

### ⭐ DO YOU NEED TO CREATE A DATABASE IN SUPABASE?

**YES - But it's automatic and super easy!**

The database is **automatically created** when you create a Supabase project. You just need to run one SQL file!

### Step-by-Step Setup (5 minutes)

#### Step 1: Create Supabase Project (If Not Done)
1. Go to **https://supabase.com**
2. Click **"New Project"**
3. Enter project name: **"pantory"**
4. Set database password: **SAVE THIS PASSWORD!**
5. Select region: **Choose closest to your users**
6. Click **"Create Project"**
7. Wait **2-3 minutes** for setup ☕

#### Step 2: Run Database Migration
This creates all tables and adds sample data:

1. Open your **Supabase project dashboard**
2. Click **"SQL Editor"** in left sidebar
3. Click **"+ New Query"**
4. Copy-paste contents of **`supabase_migration.sql`** from repo
5. Click **"RUN"** (or press Ctrl+Enter)
6. **✅ Done!** You now have 70+ ingredients ready!

#### What Gets Created:

```sql
✅ Tables Created:
   ├── ingredients (70+ sample items)
   │   ├── Fruits: 7 apple varieties, banana, orange
   │   ├── Seafood: 5 salmon varieties, tuna, shrimp
   │   ├── Vegetables: Spinach, tomatoes, onions
   │   ├── Meats: Chicken, beef, pork
   │   ├── Dairy: Milk, cheese, yogurt
   │   └── More: Grains, legumes, herbs
   │
   └── ingredient_categories (16 categories)
       ├── Fruits & Vegetables
       ├── Meat & Seafood
       ├── Dairy & Alternatives
       └── More...

✅ Indexes Created:
   ├── idx_ingredients_name (fast name search)
   ├── idx_ingredients_barcode (barcode lookup)
   ├── idx_ingredients_category (filtering)
   └── idx_ingredients_search (full-text search)

✅ Storage Bucket:
   └── ingredient-images (for photos)

✅ Security:
   ├── Row Level Security (RLS) enabled
   ├── Public read access (anyone can search)
   └── Authenticated write (only logged-in users add)
```

#### Step 3: Configure App (Already Done!)
Your app is **already configured**! Just verify:

```dart
// lib/main.dart - Already has Supabase initialization
await Supabase.initialize(
  url: 'YOUR_SUPABASE_URL',      // Get from dashboard
  anonKey: 'YOUR_ANON_KEY',      // Get from dashboard
);
```

**Where to find your credentials:**
1. Supabase Dashboard → Project Settings
2. Click "API" in sidebar
3. Copy "Project URL" and "anon public" key
4. Update in `lib/main.dart`

### Database Schema Visualization

```
┌─────────────────────────────────────────────────────────┐
│                    INGREDIENTS TABLE                     │
├─────────────────────────────────────────────────────────┤
│ id (uuid, PK)                  Primary Key              │
│ name (text) ──────────┐                                 │
│ scientific_name (text) │ Full-Text Search              │
│ variety (text) ────────┘                                 │
│ category (text) ────────→ Links to categories           │
│ image_url (text) ───────→ Supabase Storage             │
│ barcode (text) ──────────→ Indexed for fast lookup      │
│ nutritional_info (jsonb) → Flexible nutrition data       │
│ allergens (text[]) ──────→ Array of allergens           │
│ dietary_tags (text[]) ───→ Vegan, Gluten-Free, etc.    │
│ brand_name (text) ───────→ For branded products         │
│ usage_count (int) ───────→ Tracks popularity            │
│ created_at (timestamp)                                  │
│ updated_at (timestamp)                                  │
└─────────────────────────────────────────────────────────┘
           ↓
┌─────────────────────────────────────────────────────────┐
│            INGREDIENT_CATEGORIES TABLE                   │
├─────────────────────────────────────────────────────────┤
│ id (uuid, PK)                                           │
│ name (text) ───────→ Fruits, Vegetables, Meat, etc.    │
│ description (text)                                       │
│ icon (text) ───────→ Emoji representation 🍎 🥩 🥛     │
└─────────────────────────────────────────────────────────┘
```

---

## Page Flow Diagrams

### 1. App Launch Flow

```
START (User opens app)
  ↓
┌─────────────────┐
│ Welcome Screen  │
│                 │
│ "Welcome to     │
│  Pantory!"      │
│                 │
│ [Get Started]   │
└────────┬────────┘
         ↓
    First Time User?
    Yes ↓         No →→→→→→→→→→→→→→┐
         ↓                          ↓
┌────────────────┐         ┌───────────────┐
│  Onboarding    │         │ Login Screen  │
│                │         │               │
│ • Slide 1:     │         │ Email         │
│   Features     │         │ Password      │
│ • Slide 2:     │         │               │
│   AI Assistant │         │ [Login]       │
│ • Slide 3:     │         │ [Sign Up]     │
│   Get Started  │         │ [Forgot Pwd]  │
└────────┬───────┘         └───────┬───────┘
         ↓                          ↓
         └──────→ Login ←───────────┘
                   ↓
         Check Subscription Status
                   ↓
         ┌─────────────────┐
         │  Home Screen    │
         │                 │
         │  Main Pantry    │
         │  Management     │
         └─────────────────┘
```

### 2. Home Screen Navigation

```
┌──────────────────────────────────────────────────────────┐
│                    HOME SCREEN                            │
│                                                           │
│  ┌──────────────────────────────────────────┐            │
│  │  Header: "My Pantry" + [Settings Icon]   │            │
│  └──────────────────────────────────────────┘            │
│                                                           │
│  [Search Pantry Items...]                                │
│                                                           │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐              │
│  │ Fruits   │  │ Veggies  │  │  Meat    │              │
│  │   🍎     │  │   🥕     │  │   🥩     │              │
│  │  12 items│  │  8 items │  │  5 items │              │
│  └──────────┘  └──────────┘  └──────────┘              │
│                                                           │
│  Recent Items:                                           │
│  • Fuji Apple (expires in 5 days)                       │
│  • Chicken Breast (expires in 2 days)                   │
│  • Milk (expires tomorrow) ⚠️                            │
│                                                           │
│  [+ Add New Item]                                        │
│                                                           │
│  Bottom Navigation:                                      │
│  [🏠 Home] [🛒 Shopping] [📊 Stats] [👤 Profile]        │
└──────────────────────────────────────────────────────────┘
         ↓              ↓           ↓           ↓
   ┌──────────┐  ┌──────────┐ ┌────────┐ ┌─────────┐
   │ Add Item │  │Shopping  │ │Analytics│ │ Profile │
   │  Screen  │  │   List   │ │ Screen │ │ Screen  │
   └──────────┘  └──────────┘ └────────┘ └─────────┘
```

### 3. Add Item Flow (Advanced Search)

```
User taps [+ Add New Item]
         ↓
┌────────────────────────────────────────────────┐
│  Advanced Ingredient Search Screen             │
│                                                │
│  ┌─────────┐ ┌─────────┐ ┌─────────┐          │
│  │ 🔍Text  │ │ 📷Camera│ │ 📊Barcode│          │
│  │ Search  │ │  Scan   │ │  Scan    │          │
│  └────┬────┘ └────┬────┘ └────┬─────┘          │
│       ↓           ↓           ↓                 │
│  [Active Tab Shown Below]                      │
└────────────────────────────────────────────────┘

TEXT SEARCH TAB:
┌────────────────────────────────────────────────┐
│ Search: [apple____________] [🔍]               │
│                                                │
│ Results from Supabase (7):                     │
│                                                │
│ ┌──────────────────────────────────┐          │
│ │ 🍎 Fuji Apple                     │          │
│ │ Variety: Fresh Fuji               │          │
│ │ Category: Fruits                  │          │
│ │ Source: Supabase                  │          │
│ │ [+ Add to Pantry]                 │          │
│ └──────────────────────────────────┘          │
│                                                │
│ ┌──────────────────────────────────┐          │
│ │ 🍏 Granny Smith Apple             │          │
│ │ Variety: Tart green apple         │          │
│ │ [+ Add to Pantry]                 │          │
│ └──────────────────────────────────┘          │
│                                                │
│ ... more results ...                           │
└────────────────────────────────────────────────┘
         ↓ User taps [+ Add to Pantry]
┌────────────────────────────────────────────────┐
│ Pantry Item Details                            │
│                                                │
│ Name: Fuji Apple                               │
│ Quantity: [2___] Unit: [pieces ▼]             │
│ Expiry: [Select Date]                          │
│ Location: [Fridge ▼]                           │
│ Notes: [_____________________]                 │
│                                                │
│ [Save to Pantry]                               │
└────────────────────────────────────────────────┘
         ↓
    ✅ Item Added Successfully!
         ↓
    Return to Home Screen
    (Item now appears in Fruits category)

CAMERA TAB:
┌────────────────────────────────────────────────┐
│ [Camera Viewfinder]                            │
│                                                │
│       🎯 Point camera at food item             │
│                                                │
│ [Capture Photo]                                │
└────────────────────────────────────────────────┘
         ↓ Photo taken
┌────────────────────────────────────────────────┐
│ Analyzing image...                             │
│ [Loading spinner]                              │
└────────────────────────────────────────────────┘
         ↓ AI processes image
┌────────────────────────────────────────────────┐
│ Detected: "Apple, Red" (95% confidence)        │
│                                                │
│ Searching in database...                       │
└────────────────────────────────────────────────┘
         ↓
┌────────────────────────────────────────────────┐
│ Found matches:                                 │
│ • Red Delicious Apple ✓                        │
│ • Fuji Apple                                   │
│ • Gala Apple                                   │
│                                                │
│ [Confirm & Add]                                │
└────────────────────────────────────────────────┘

BARCODE TAB:
┌────────────────────────────────────────────────┐
│ [Barcode Scanner Active]                       │
│                                                │
│    ▓▓ ▓ ▓▓ ▓ ▓▓▓ ▓ ▓▓ ▓▓                      │
│    ▓ ▓▓ ▓ ▓▓ ▓ ▓▓ ▓▓ ▓ ▓                      │
│                                                │
│ Align barcode within frame                     │
└────────────────────────────────────────────────┘
         ↓ Barcode detected: 1234567890123
┌────────────────────────────────────────────────┐
│ Looking up barcode...                          │
└────────────────────────────────────────────────┘
         ↓ Found in Supabase
┌────────────────────────────────────────────────┐
│ Product Found!                                 │
│                                                │
│ Name: Organic Milk                             │
│ Brand: Happy Farms                             │
│ Category: Dairy                                │
│                                                │
│ ⚠️ Contains: Dairy (matches your allergies!)   │
│                                                │
│ [Add to Pantry] [Cancel]                       │
└────────────────────────────────────────────────┘
```

---

## Feature Flows

### 4. AI Assistant Mood-Based Recipe Flow

```
User Opens Profile → Taps [Talk to AI Assistant]
         ↓
┌────────────────────────────────────────────────┐
│   AI Assistant Screen                          │
│                                                │
│   💬 Chat Interface                            │
│                                                │
│   AI: "Hey! 👋 How are you feeling today?      │
│        Just tell me in your own words!"        │
│                                                │
│   [Type your message...]                       │
└────────────────────────────────────────────────┘
         ↓ User types: "Having a rough day, stressed"
┌────────────────────────────────────────────────┐
│   User: Having a rough day, stressed          │
│                                                │
│   [Analyzing mood...]                          │
└────────────────────────────────────────────────┘
         ↓ AI Service detects mood
┌─────────────────────────────────────────────┐
│ AI Service Logic:                            │
│                                              │
│ detectMoodFromText("Having a rough day...") │
│                                              │
│ Found indicators:                            │
│ • "rough" → negative                         │
│ • "stressed" → negative                      │
│ • Overall sentiment: negative                │
│                                              │
│ Result: mood = "bad"                         │
└──────────────┬───────────────────────────────┘
               ↓
┌────────────────────────────────────────────────┐
│   AI: "🤗 I'm here for you! I understand      │
│        you're having a tough day.              │
│                                                │
│        What sounds comforting right now?"      │
│                                                │
│   ┌────────────────┐  ┌────────────────┐     │
│   │ Ultimate       │  │ Healthy &      │     │
│   │ Comfort Food   │  │ Energizing     │     │
│   └────────────────┘  └────────────────┘     │
│                                                │
│   ┌────────────────┐  ┌────────────────┐     │
│   │ Something      │  │ Light &        │     │
│   │ Sweet          │  │ Fresh          │     │
│   └────────────────┘  └────────────────┘     │
└────────────────────────────────────────────────┘
         ↓ User selects "Ultimate Comfort Food"
┌────────────────────────────────────────────────┐
│   Loading recipes...                           │
│                                                │
│   Checking your preferences:                   │
│   ✓ Vegetarian                                 │
│   ✓ No peanuts (allergy)                       │
│   ✓ No mushrooms (disliked)                    │
│   ✓ Country: India                             │
└────────────────────────────────────────────────┘
         ↓ Generate mood-based recipes
┌─────────────────────────────────────────────┐
│ Recipe Generation Logic:                     │
│                                              │
│ 1. Filter by mood: "bad" → comfort recipes  │
│ 2. Filter by preference: "comfort food"     │
│ 3. Apply user restrictions:                 │
│    • Remove non-vegetarian                  │
│    • Remove recipes with peanuts            │
│    • Remove recipes with mushrooms          │
│ 4. Include regional: Indian comfort foods   │
│ 5. Sort by mood-boosting properties          │
│                                              │
│ Result: 3 personalized recipes               │
└──────────────┬───────────────────────────────┘
               ↓
┌────────────────────────────────────────────────┐
│   Perfect! Here are 3 mood-boosting recipes:   │
│                                                │
│   🧀 Mac & Cheese (Vegetarian)                │
│   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━             │
│   Why it helps: "Triggers happy childhood     │
│   memories and releases dopamine!"             │
│                                                │
│   Ingredients: Pasta, cheese, milk...          │
│   [View Full Recipe]                           │
│   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━             │
│                                                │
│   🥘 Khichdi (Indian Comfort)                 │
│   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━             │
│   Why it helps: "Warm, soothing, easy to      │
│   digest. Traditional Indian comfort food!"    │
│                                                │
│   Ingredients: Rice, lentils, spices...        │
│   [View Full Recipe]                           │
│   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━             │
│                                                │
│   🍫 Chocolate Lava Cake                       │
│   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━             │
│   Why it helps: "Dark chocolate releases       │
│   endorphins - natural mood lifter!"           │
│                                                │
│   Ingredients: Chocolate, eggs, butter...      │
│   [View Full Recipe]                           │
└────────────────────────────────────────────────┘
         ↓ User taps [View Full Recipe]
┌────────────────────────────────────────────────┐
│   Mac & Cheese Recipe                          │
│                                                │
│   Prep Time: 10 min | Cook: 20 min            │
│   Serves: 4                                    │
│                                                │
│   Ingredients:                                 │
│   • 2 cups pasta                               │
│   • 2 cups cheese (cheddar)                    │
│   • 1 cup milk                                 │
│   • 2 tbsp butter                              │
│   • Salt & pepper                              │
│                                                │
│   Instructions:                                │
│   1. Boil pasta until al dente                 │
│   2. Melt butter in pan                        │
│   3. Add milk and cheese, stir...              │
│                                                │
│   [Add Ingredients to Shopping List]           │
│   [Save Recipe]                                │
└────────────────────────────────────────────────┘
```

### 5. User Preferences Configuration Flow

```
User: Settings → Food Preferences
         ↓
┌────────────────────────────────────────────────┐
│   User Preferences Screen                      │
│                                                │
│   1️⃣ Regional Preferences                      │
│   ┌──────────────────────────────┐            │
│   │ Country: [Tap to Select]     │            │
│   │ 🌍 None selected              │            │
│   └──────────────────────────────┘            │
│                                                │
│   ┌──────────────────────────────┐            │
│   │ Cuisine: [Tap to Select]     │            │
│   │ 🍽️ None selected              │            │
│   └──────────────────────────────┘            │
│                                                │
│   2️⃣ Dietary Restrictions                      │
│   ┌──────────────────────────────┐            │
│   │ [Tap to Select Multiple]     │            │
│   │ 0 selected                    │            │
│   └──────────────────────────────┘            │
│                                                │
│   3️⃣ Allergies ⚠️                              │
│   ┌──────────────────────────────┐            │
│   │ [Tap to Select Multiple]     │            │
│   │ 0 selected                    │            │
│   └──────────────────────────────┘            │
│                                                │
│   4️⃣ Disliked Foods                            │
│   ┌──────────────────────────────┐            │
│   │ [Tap to Select Multiple]     │            │
│   │ 0 selected                    │            │
│   └──────────────────────────────┘            │
│                                                │
│   [Save Preferences]                           │
└────────────────────────────────────────────────┘
         ↓ User taps "Country"
┌────────────────────────────────────────────────┐
│   Select Country                               │
│   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                                │
│   🔍 [Search countries...]                     │
│                                                │
│   Popular Countries:                           │
│   • 🇺🇸 United States                          │
│   • 🇮🇳 India                                  │
│   • 🇬🇧 United Kingdom                         │
│   • 🇨🇦 Canada                                 │
│   • 🇦🇺 Australia                              │
│                                                │
│   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │
│   All Countries (195):                         │
│   • Afghanistan                                │
│   • Albania                                    │
│   • Algeria                                    │
│   ... (scrollable list)                        │
└────────────────────────────────────────────────┘
         ↓ User types "ind" in search
┌────────────────────────────────────────────────┐
│   🔍 [ind_____________]                        │
│                                                │
│   Filtered Results (3):                        │
│   • 🇮🇳 India ✓                                │
│   • 🇮🇩 Indonesia                              │
│   • 🇮🇳 (no more matches)                      │
│                                                │
│   [Cancel]                                     │
└────────────────────────────────────────────────┘
         ↓ User selects "India"
┌────────────────────────────────────────────────┐
│   User Preferences Screen                      │
│                                                │
│   1️⃣ Regional Preferences                      │
│   ┌──────────────────────────────┐            │
│   │ Country: India ✓             │            │
│   │ 🇮🇳                            │            │
│   └──────────────────────────────┘            │
│   ... (rest of form)                           │
└────────────────────────────────────────────────┘
         ↓ User taps "Dietary Restrictions"
┌────────────────────────────────────────────────┐
│   Select Dietary Restrictions                  │
│   (Multiple Selection)                         │
│   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                                │
│   🔍 [Search restrictions...]                  │
│                                                │
│   Common:                                      │
│   ☐ Vegetarian                                 │
│   ☐ Vegan                                      │
│   ☐ Gluten-Free                                │
│   ☐ Dairy-Free                                 │
│                                                │
│   All (33):                                    │
│   ☐ Halal                                      │
│   ☐ Kosher                                     │
│   ☐ Pescatarian                                │
│   ☐ Keto                                       │
│   ☐ Paleo                                      │
│   ... (scrollable)                             │
│                                                │
│   [Clear All] [Done]                           │
└────────────────────────────────────────────────┘
         ↓ User selects "Vegetarian" + "Gluten-Free"
┌────────────────────────────────────────────────┐
│   Selected: 2 ✓                                │
│                                                │
│   ☑ Vegetarian                                 │
│   ☑ Gluten-Free                                │
│                                                │
│   [Clear All] [Done]                           │
└────────────────────────────────────────────────┘
         ↓ User taps [Done]
┌────────────────────────────────────────────────┐
│   User Preferences Screen                      │
│                                                │
│   2️⃣ Dietary Restrictions                      │
│   ┌──────────────────────────────┐            │
│   │ 2 selected                    │            │
│   │                               │            │
│   │ 🌱 Vegetarian                 │            │
│   │ 🌾 Gluten-Free                │            │
│   └──────────────────────────────┘            │
│                                                │
│   ... continue for Allergies + Disliked Foods  │
│                                                │
│   [Save Preferences]                           │
└────────────────────────────────────────────────┘
         ↓ User taps [Save Preferences]
┌────────────────────────────────────────────────┐
│   ✅ Preferences Saved Successfully!           │
│                                                │
│   Your dietary preferences will be used to     │
│   filter recipes and ingredient suggestions.   │
│                                                │
│   [OK]                                         │
└────────────────────────────────────────────────┘
```

### 6. Profile & Mood Tracking Flow

```
User Opens Profile Tab (Bottom Nav)
         ↓
┌────────────────────────────────────────────────┐
│   Profile Screen                               │
│                                                │
│   ┌──────────────────────────────┐            │
│   │  👤 User Profile              │            │
│   │                               │            │
│   │  John Doe                     │            │
│   │  john@example.com             │            │
│   │  [Edit Profile]               │            │
│   └──────────────────────────────┘            │
│                                                │
│   ┌──────────────────────────────┐            │
│   │  😊 Mood Tracker              │            │
│   │                               │            │
│   │  How are you feeling today?   │            │
│   │                               │            │
│   │  😄 😊 🙂 😐 😔              │            │
│   │                               │            │
│   └──────────────────────────────┘            │
│                                                │
│   ┌──────────────────────────────┐            │
│   │  📊 Activity Statistics       │            │
│   │                               │            │
│   │  🏺 Items: 45                 │            │
│   │  📦 Categories: 12            │            │
│   │  ⭐ Favorites: 8              │            │
│   │  😊 Mood Check-ins: 23        │            │
│   └──────────────────────────────┘            │
│                                                │
│   ┌──────────────────────────────┐            │
│   │  📅 Mood History (Last 7)     │            │
│   │                               │            │
│   │  Today: 😊 Great              │            │
│   │  Yesterday: 🙂 Good           │            │
│   │  2 days ago: 😄 Excellent     │            │
│   │  3 days ago: 😊 Great         │            │
│   │  ... (view more)              │            │
│   └──────────────────────────────┘            │
│                                                │
│   [🥗 Food Preferences]                        │
│   [🤖 AI Assistant]                            │
│   [⚙️ Settings]                                │
└────────────────────────────────────────────────┘
         ↓ User taps 😊 (Great) emoji
┌────────────────────────────────────────────────┐
│   Saving mood...                               │
└────────────────────────────────────────────────┘
         ↓
┌─────────────────────────────────────────────┐
│ MoodModel Creation:                          │
│                                              │
│ MoodModel(                                   │
│   mood: "great",                             │
│   timestamp: DateTime.now(),                 │
│   note: null                                 │
│ )                                            │
│                                              │
│ Save to SharedPreferences:                   │
│ • Load existing history                      │
│ • Add new mood to list                       │
│ • Save back to storage                       │
│ • Update stats (check-ins: 24)               │
└──────────────┬───────────────────────────────┘
               ↓
┌────────────────────────────────────────────────┐
│   ✅ Mood Logged Successfully!                 │
│                                                │
│   Current Mood: 😊 Great                       │
│                                                │
│   Keep it up! 🌟                               │
└────────────────────────────────────────────────┘
         ↓
┌────────────────────────────────────────────────┐
│   Profile Screen (Updated)                     │
│                                                │
│   😊 Mood Tracker                              │
│   Current: 😊 Great ✓                          │
│                                                │
│   📊 Activity Statistics                       │
│   😊 Mood Check-ins: 24 (updated!)             │
│                                                │
│   📅 Mood History                              │
│   Today: 😊 Great (just now) ← NEW            │
│   Yesterday: 🙂 Good                           │
│   ...                                          │
└────────────────────────────────────────────────┘
```

---

## Data Flow

### 7. Complete Data Flow Diagram

```
┌──────────────────────────────────────────────────┐
│           USER INTERACTION LAYER                  │
│                                                   │
│  User taps, types, or gestures                   │
└──────────────────┬────────────────────────────────┘
                   ↓
┌──────────────────────────────────────────────────┐
│          PRESENTATION LAYER (UI)                  │
│           Flutter Widgets                         │
│                                                   │
│  • StatefulWidget manages local state            │
│  • Widget tree renders UI                        │
│  • User interactions trigger callbacks           │
│  • Calls service layer methods                   │
└──────────────────┬────────────────────────────────┘
                   ↓
┌──────────────────────────────────────────────────┐
│        STATE MANAGEMENT (Provider)                │
│                                                   │
│  • ChangeNotifier classes                        │
│  • notifyListeners() on state changes            │
│  • Consumers rebuild on updates                  │
│  • Coordinates multiple services                 │
└──────────────────┬────────────────────────────────┘
                   ↓
┌──────────────────────────────────────────────────┐
│              SERVICE LAYER                        │
│           Business Logic                          │
│                                                   │
│  ┌────────────────┐  ┌────────────────┐         │
│  │  AI Service    │  │ Pantry Service │         │
│  │                │  │                │         │
│  │ • detectMood() │  │ • addItem()    │         │
│  │ • getRecipes() │  │ • getItems()   │         │
│  │ • filterBy     │  │ • updateItem() │         │
│  │   Preferences  │  │ • deleteItem() │         │
│  └────────────────┘  └────────────────┘         │
│                                                   │
│  ┌────────────────┐  ┌────────────────┐         │
│  │Ingredient Svc  │  │ Auth Service   │         │
│  │                │  │                │         │
│  │ • search()     │  │ • login()      │         │
│  │ • addIngred()  │  │ • signup()     │         │
│  │ • barcodeLook  │  │ • logout()     │         │
│  └────────────────┘  └────────────────┘         │
└──────────────────┬────────────────────────────────┘
                   ↓
┌──────────────────────────────────────────────────┐
│               DATA LAYER                          │
│                                                   │
│  ┌──────────────────────────────────────┐        │
│  │         SUPABASE                      │        │
│  │                                       │        │
│  │  PostgreSQL Database:                 │        │
│  │  • ingredients table                  │        │
│  │  • ingredient_categories table        │        │
│  │  • Full-text search indexes           │        │
│  │  • Row-level security                 │        │
│  │                                       │        │
│  │  Authentication:                      │        │
│  │  • User signup/login                  │        │
│  │  • Session management                 │        │
│  │  • JWT tokens                         │        │
│  │                                       │        │
│  │  Storage:                             │        │
│  │  • ingredient-images bucket           │        │
│  │  • Public URL generation              │        │
│  └──────────────────────────────────────┘        │
│                                                   │
│  ┌──────────────────────────────────────┐        │
│  │     SharedPreferences (Local)         │        │
│  │                                       │        │
│  │  • User preferences                   │        │
│  │  • Mood history                       │        │
│  │  • App settings                       │        │
│  │  • Cached data                        │        │
│  └──────────────────────────────────────┘        │
│                                                   │
│  ┌──────────────────────────────────────┐        │
│  │     External APIs (Optional)          │        │
│  │                                       │        │
│  │  • Google Cloud Vision                │        │
│  │  • USDA FoodData Central              │        │
│  │  • Open Food Facts                    │        │
│  └──────────────────────────────────────┘        │
└──────────────────┬────────────────────────────────┘
                   ↓
            Data Returns
                   ↓
┌──────────────────────────────────────────────────┐
│          RESPONSE FLOW (Reverse)                  │
│                                                   │
│  Data → Services → State Mgmt → UI Update        │
│                                                   │
│  1. Service receives data                        │
│  2. Service processes/transforms                 │
│  3. State manager updates (notifyListeners)      │
│  4. UI Consumers rebuild                         │
│  5. User sees updated screen                     │
└──────────────────────────────────────────────────┘
```

### 8. Supabase Integration Flow

```
┌────────────────────────────────────────────────┐
│        APP STARTUP (main.dart)                  │
└────────────────┬───────────────────────────────┘
                 ↓
┌────────────────────────────────────────────────┐
│  await Supabase.initialize(                    │
│    url: 'https://xxx.supabase.co',             │
│    anonKey: 'your-anon-key'                    │
│  );                                            │
│                                                │
│  ✅ Supabase Client Ready                      │
└────────────────┬───────────────────────────────┘
                 ↓
         Services Can Now Use:
                 ↓
┌────────────────────────────────────────────────┐
│  final supabase = Supabase.instance.client;   │
│                                                │
│  Available APIs:                               │
│  • supabase.auth → Authentication              │
│  • supabase.from() → Database queries          │
│  • supabase.storage → File storage             │
│  • supabase.rpc() → Database functions         │
└────────────────┬───────────────────────────────┘
                 ↓
        Example Usage Flows:
                 ↓

┌──────────────────────────────────────────────┐
│  AUTHENTICATION EXAMPLE                       │
│                                              │
│  // Login                                    │
│  final response = await supabase.auth        │
│    .signInWithPassword(                      │
│      email: 'user@example.com',              │
│      password: 'password123'                 │
│    );                                        │
│                                              │
│  ↓ Returns User + Session                   │
│                                              │
│  // Auto-refresh session                     │
│  supabase.auth.onAuthStateChange.listen(     │
│    (data) {                                  │
│      // Handle login/logout                  │
│    }                                         │
│  );                                          │
└──────────────────────────────────────────────┘

┌──────────────────────────────────────────────┐
│  DATABASE QUERY EXAMPLE                       │
│                                              │
│  // Search ingredients                       │
│  final results = await supabase              │
│    .from('ingredients')                      │
│    .select()                                 │
│    .ilike('name', '%apple%')                 │
│    .order('usage_count', ascending: false)   │
│    .limit(20);                               │
│                                              │
│  ↓ Returns List<Map<String, dynamic>>       │
│                                              │
│  // Insert new ingredient                    │
│  await supabase                              │
│    .from('ingredients')                      │
│    .insert({                                 │
│      'name': 'Fuji Apple',                   │
│      'category': 'Fruits',                   │
│      ...                                     │
│    });                                       │
│                                              │
│  ↓ Row inserted, ID returned                │
└──────────────────────────────────────────────┘

┌──────────────────────────────────────────────┐
│  STORAGE EXAMPLE                              │
│                                              │
│  // Upload image                             │
│  await supabase.storage                      │
│    .from('ingredient-images')                │
│    .upload(                                  │
│      'apples/fuji-apple.jpg',                │
│      imageFile                               │
│    );                                        │
│                                              │
│  ↓ File uploaded                             │
│                                              │
│  // Get public URL                           │
│  final url = supabase.storage                │
│    .from('ingredient-images')                │
│    .getPublicUrl('apples/fuji-apple.jpg');   │
│                                              │
│  ↓ Returns: https://xxx.supabase.co/...     │
└──────────────────────────────────────────────┘
```

---

## Testing Guide

### Manual Testing Checklist

Copy this checklist and mark items as you test:

```
🔲 AUTHENTICATION & ONBOARDING
   🔲 App launches without crashes
   🔲 Welcome screen displays
   🔲 Onboarding slides work (if first time)
   🔲 Can navigate to signup
   🔲 Email validation works
   🔲 Password requirements enforced
   🔲 Signup creates account successfully
   🔲 Login with credentials works
   🔲 "Forgot password" flow works
   🔲 Session persists on app restart
   🔲 Logout works properly

🔲 SUPABASE DATABASE
   🔲 Migration SQL runs without errors
   🔲 Ingredients table created
   🔲 Ingredient_categories table created
   🔲 Storage bucket created
   🔲 Sample data (70+ ingredients) loaded
   🔲 Indexes created successfully
   🔲 RLS policies active

🔲 HOME & PANTRY MANAGEMENT
   🔲 Home screen displays
   🔲 Bottom navigation works
   🔲 Can see pantry items (empty initially)
   🔲 "+ Add Item" button works
   🔲 Can add item to pantry
   🔲 Items display in categories
   🔲 Can edit pantry item
   🔲 Can delete pantry item
   🔲 Search pantry items works
   🔲 Expiry warnings show correctly

🔲 ADVANCED INGREDIENT SEARCH
   🔲 Search screen opens from "+ Add Item"
   🔲 Three tabs visible (Text, Camera, Barcode)
   🔲 TEXT SEARCH:
      🔲 Can type in search box
      🔲 Search returns results from Supabase
      🔲 Results show name, variety, category
      🔲 Source badge shows "Supabase"
      🔲 No results handled gracefully
      🔲 Can select result
      🔲 Adds to pantry successfully
   🔲 CAMERA TAB:
      🔲 Camera permission granted
      🔲 Camera opens
      🔲 Can take photo
      🔲 Image uploads (if API configured)
      🔲 Detection results display
      🔲 Can search detected item
   🔲 BARCODE TAB:
      🔲 Scanner opens
      🔲 Can scan barcode
      🔲 Barcode lookup works
      🔲 Product details display
      🔲 Can add scanned item

🔲 AI ASSISTANT & MOOD SYSTEM
   🔲 AI Assistant opens from profile
   🔲 Welcome message displays
   🔲 Can type message in chat
   🔲 MOOD DETECTION:
      🔲 Negative text detected as "bad"
      🔲 Positive text detected as "excellent/great"
      🔲 Neutral text detected as "okay/good"
      🔲 Emoji in text affects detection
   🔲 AI responds empathetically
   🔲 Food preference buttons display
   🔲 Can select preference
   🔲 Recipe suggestions load
   🔲 Recipes filtered by user preferences
   🔲 Recipe cards show mood boost explanation
   🔲 Can view full recipe
   🔲 Can add recipe ingredients to shopping

🔲 USER PREFERENCES
   🔲 Preferences screen opens from settings
   🔲 COUNTRY SELECTION:
      🔲 Dropdown opens
      🔲 Search box works
      🔲 Can type to filter
      🔲 Popular countries show first
      🔲 Can select country
      🔲 Selection persists
   🔲 CUISINE SELECTION:
      🔲 Dropdown works
      🔲 Search filters correctly
      🔲 Can select cuisine
   🔲 DIETARY RESTRICTIONS:
      🔲 Multi-select dropdown opens
      🔲 Can select multiple items
      🔲 Search filters options
      🔲 Selected count updates
      🔲 Chips display below
      🔲 Can clear all
      🔲 Done button saves
   🔲 ALLERGIES:
      🔲 Multi-select works
      🔲 Red warning indicators show
      🔲 Search works
      🔲 Multiple selection works
   🔲 DISLIKED FOODS:
      🔲 Multi-select works
      🔲 Search works
      🔲 Can select multiple
   🔲 Save Preferences button works
   🔲 Preferences persist on restart
   🔲 Preferences load in AI assistant

🔲 PROFILE & MOOD TRACKING
   🔲 Profile screen displays
   🔲 User info shows correctly
   🔲 MOOD TRACKER:
      🔲 Mood widget displays
      🔲 Can tap emoji to select mood
      🔲 Mood saves successfully
      🔲 Current mood updates
      🔲 Mood added to history
   🔲 ACTIVITY STATS:
      🔲 Item count accurate
      🔲 Categories count accurate
      🔲 Mood check-ins count updates
   🔲 MOOD HISTORY:
      🔲 Displays last 7 days
      🔲 Timestamps are correct
      🔲 Relative time shows ("2 days ago")
   🔲 Quick links work (Preferences, AI, Settings)

🔲 SETTINGS
   🔲 Settings screen opens
   🔲 All sections display
   🔲 AI Assistant toggle works
   🔲 Mood tracking toggle works
   🔲 Language selector displays (7 languages)
   🔲 Food preferences link works
   🔲 Account management accessible
   🔲 Help & support accessible
   🔲 Privacy policy accessible
   🔲 Terms of service accessible
   🔲 Logout from settings works

🔲 NAVIGATION & UX
   🔲 Bottom nav tabs all work
   🔲 Back button works everywhere
   🔲 No crashes when navigating
   🔲 Smooth transitions
   🔲 Loading indicators show appropriately
   🔲 Error messages are user-friendly
   🔲 Toast/snackbar messages show
   🔲 Deep links work (preferences, AI)

🔲 DATA PERSISTENCE
   🔲 User preferences survive app restart
   🔲 Mood history persists
   🔲 Session token persists
   🔲 Pantry items persist
   🔲 Settings persist

🔲 ERROR HANDLING
   🔲 No internet: graceful degradation
   🔲 Supabase down: error message shows
   🔲 Invalid credentials: proper error
   🔲 Empty search: "No results" message
   🔲 Camera permission denied: explanation
   🔲 Storage full: handled gracefully
```

### Testing Tips

1. **Start Fresh**: Test signup flow with new email
2. **Run Migration**: Execute `supabase_migration.sql` before testing search
3. **Check Logs**: Use `flutter logs` to see errors
4. **Test Offline**: Turn off WiFi to test error handling
5. **Multiple Devices**: Test on different screen sizes
6. **Clear Data**: Test with fresh install (clear app data)

---

## Quick Reference

### Important Files

```
Configuration:
├── lib/main.dart                    → Supabase initialization
├── supabase_migration.sql           → Database setup
└── pubspec.yaml                     → Dependencies

Core Services:
├── lib/services/supabase_ingredient_service.dart
├── lib/services/ai_service.dart
├── lib/services/auth_service.dart
└── lib/services/pantry_service.dart

Key Screens:
├── lib/screens/home_screen.dart
├── lib/screens/advanced_ingredient_search_screen.dart
├── lib/screens/ai_assistant_screen.dart
├── lib/screens/user_preferences_screen.dart
└── lib/screens/profile_screen.dart

Data Models:
├── lib/models/user_preferences.dart
├── lib/models/mood_model.dart
└── lib/models/pantry_item.dart
```

### Key Commands

```bash
# Get dependencies
flutter pub get

# Run app
flutter run

# Check for issues
flutter analyze

# Build for production
flutter build apk          # Android
flutter build ios          # iOS

# Clear app data
flutter clean
```

### Supabase Dashboard Links

```
Your Project: https://supabase.com/dashboard/projects
├── Database → SQL Editor (run migration here)
├── Authentication → Users (view accounts)
├── Storage → ingredient-images (view uploads)
└── API → Settings (get URL + keys)
```

---

**Document Version**: 1.0.0  
**Last Updated**: January 2026  
**Maintained By**: Pantory Development Team

---

## Need Help?

- **Supabase Setup**: See `SUPABASE_SETUP.md`
- **API Integration**: See `API_INTEGRATION_GUIDE.md`
- **Features Overview**: See `AI_FEATURES_SUMMARY.md`
- **Quick Start**: See `README.md`
