# Pantory Quick Start Guide

## ⚡ 5-Minute Setup

### Prerequisites
- Flutter SDK installed
- Supabase account (free tier works)
- Android Studio / VS Code with Flutter extension

### Step 1: Clone & Setup (1 minute)
```bash
# Clone repo (already done if you're reading this!)
cd Pantory

# Get dependencies
flutter pub get
```

### Step 2: Create Supabase Database (2 minutes)

#### 2a. Create Project
1. Go to https://supabase.com/dashboard
2. Click "New Project"
3. Name: `pantory`
4. Password: **Save this!**
5. Region: Closest to you
6. Click "Create Project"
7. Wait 2-3 minutes ☕

#### 2b. Run Migration
1. Open your project in Supabase dashboard
2. Click "SQL Editor" (left sidebar)
3. Click "+ New Query"
4. Open `supabase_migration.sql` from repo
5. Copy-paste entire contents
6. Click "RUN" (or Ctrl+Enter)
7. ✅ Done! You now have 70+ sample ingredients

### Step 3: Configure App (1 minute)

1. In Supabase dashboard: Project Settings → API
2. Copy these two values:
   - **Project URL**: `https://xxx.supabase.co`
   - **anon public key**: `eyJ...` (long string)

3. Open `lib/main.dart` in your code editor
4. Find the Supabase initialization (around line 20-25)
5. Replace with your values:
```dart
await Supabase.initialize(
  url: 'YOUR_PROJECT_URL',      // Paste here
  anonKey: 'YOUR_ANON_KEY',     // Paste here
);
```

### Step 4: Run App (1 minute)
```bash
# Connect device/emulator
flutter devices

# Run app
flutter run
```

---

## ✅ What You Get Out of the Box

### Immediate Features (No Extra Setup)
- ✅ User authentication (signup/login)
- ✅ Pantry management (add/edit/delete items)
- ✅ 70+ ingredients in database (search "apple")
- ✅ Mood tracking on profile
- ✅ AI mood detection (natural language)
- ✅ User preferences (dietary, allergies, country)
- ✅ Mood-based recipe suggestions
- ✅ Beautiful UI with glass-morphism
- ✅ Shopping list
- ✅ Analytics dashboard

### Optional Features (Need API Keys)
These work when you add API keys (all optional):

#### Google Cloud Vision (Image Recognition)
- Adds photo-based ingredient search
- **Cost**: Free tier: 1,000 requests/month
- **Setup**: See `API_INTEGRATION_GUIDE.md`

#### Additional Ingredient Databases
- USDA FoodData Central (600K+ items)
- Nutritionix (restaurant foods)
- **Cost**: Free tiers available
- **Setup**: See `API_INTEGRATION_GUIDE.md`

---

## 🎯 First-Time User Flow

### Test These Features:

1. **Signup & Login**
   - Launch app
   - Tap "Get Started"
   - Sign up with email
   - Verify you can log in

2. **Add Ingredient**
   - Home screen → Tap "+ Add Item"
   - Search "apple"
   - See 7 apple varieties from Supabase
   - Select "Fuji Apple"
   - Add to pantry
   - ✅ Should appear on home screen

3. **Set Preferences**
   - Profile → Settings → Food Preferences
   - Select country: "India"
   - Select dietary: "Vegetarian"
   - Select allergy: "Peanuts"
   - Save
   - ✅ Preferences saved

4. **Try AI Assistant**
   - Profile → AI Assistant
   - Type: "Having a rough day"
   - AI detects "bad" mood
   - Select "Comfort Food"
   - See 3 recipes (filtered by your vegetarian preference)
   - ✅ No recipes with peanuts!

5. **Track Mood**
   - Go to Profile
   - Tap 😊 (Great) emoji
   - Check "Mood History" section
   - ✅ Today's mood logged

---

## 🐛 Troubleshooting

### "Supabase not initialized"
**Fix**: Make sure you ran `supabase_migration.sql` in SQL Editor

### "No ingredients found"
**Fix**: Database is empty. Run the migration SQL script

### "Build failed"
```bash
flutter clean
flutter pub get
flutter pub upgrade
flutter run
```

### "Camera permission denied"
**Fix**: 
- Android: Check `android/app/src/main/AndroidManifest.xml` has camera permission
- iOS: Check `ios/Runner/Info.plist` has camera usage description

### "Supabase connection error"
**Fix**: 
1. Check internet connection
2. Verify URL and anon key in `lib/main.dart`
3. Check Supabase project is active (not paused)

---

## 📁 Project Structure

```
Pantory/
├── lib/
│   ├── main.dart                    ← Supabase config here
│   ├── models/                      ← Data structures
│   ├── screens/                     ← UI pages
│   ├── services/                    ← Business logic
│   ├── widgets/                     ← Reusable components
│   └── data/                        ← Static data (countries, etc.)
│
├── docs/
│   ├── ARCHITECTURE_DIAGRAMS.md     ← You are here! (visual guides)
│   └── QUICK_START_GUIDE.md         ← This file
│
├── supabase_migration.sql           ← Database setup (RUN THIS!)
├── SUPABASE_SETUP.md                ← Detailed Supabase guide
├── API_INTEGRATION_GUIDE.md         ← Optional APIs guide
├── README.md                        ← Project overview
└── pubspec.yaml                     ← Dependencies
```

---

## 🚀 What's Next?

### Immediate (Already Works)
1. ✅ Start using the app
2. ✅ Add your pantry items
3. ✅ Set your dietary preferences
4. ✅ Try the AI assistant
5. ✅ Track your mood

### Optional Enhancements
1. **Add More Ingredients**
   - Manually via the app (users contribute)
   - Bulk import CSV (see `SUPABASE_SETUP.md`)
   - Import from USDA/Open Food Facts (see `API_INTEGRATION_GUIDE.md`)

2. **Enable Image Recognition**
   - Get Google Cloud Vision API key (free tier)
   - Configure in `lib/services/image_recognition_service.dart`
   - Take photos of ingredients to add them

3. **Add More Data Sources**
   - USDA for nutritional data
   - Open Food Facts for barcodes
   - Nutritionix for restaurant foods

---

## 📊 Database Info

### What's in the Database After Migration?

**70+ Ingredients Including:**
- 🍎 Fruits: 7 apple varieties, banana, orange, etc.
- 🥬 Vegetables: 3 spinach types, tomatoes, onions, etc.
- 🥩 Meats: Chicken, beef, pork cuts
- 🐟 Seafood: 5 salmon types, tuna, shrimp
- 🥛 Dairy: Milk, cheese, yogurt varieties
- 🌾 Grains: 6 rice varieties, wheat, oats
- 🥜 Legumes: Lentils, chickpeas, beans
- 🌿 Herbs: Basil, cilantro, mint, etc.

**16 Categories:**
- Fruits & Vegetables
- Meat & Poultry
- Seafood & Fish
- Dairy & Alternatives
- Grains & Cereals
- Legumes & Pulses
- Nuts & Seeds
- Herbs & Spices
- Oils & Fats
- Beverages
- Condiments & Sauces
- Baked Goods
- Frozen Foods
- Canned Goods
- Snacks
- Other

---

## 🎯 Key Features Overview

### 1. AI Mood-Based Recipe Assistant
- Natural language mood detection
- Empathetic responses like a friend
- Recipes filtered by your preferences
- Mood elevation suggestions

### 2. Supabase Ingredient Database
- 70+ ingredients included
- Searchable with instant results
- Variety recognition (Fuji apple, not just "apple")
- Scientific names for precision
- Unlimited scalability

### 3. User Preferences System
- 195+ countries with search
- 100+ cuisines
- 33 dietary restrictions
- 60+ allergens
- 150+ disliked foods
- All with searchable dropdowns

### 4. Mood Tracking
- One-tap mood logging
- 7-day history
- Activity statistics
- Persistent local storage

### 5. Advanced Search
- Text search in Supabase
- Image recognition (when configured)
- Barcode scanning
- Multi-source data (optional)

---

## 📞 Need Help?

### Documentation
- **Architecture**: `docs/ARCHITECTURE_DIAGRAMS.md` (detailed flows)
- **Supabase Setup**: `SUPABASE_SETUP.md`
- **API Integration**: `API_INTEGRATION_GUIDE.md`
- **Features**: `AI_FEATURES_SUMMARY.md`

### Common Questions

**Q: Do I need API keys to use the app?**  
A: No! The app works fully with just Supabase. API keys are optional for extra features.

**Q: Is the database free?**  
A: Yes! Supabase free tier includes 500MB database (100K+ ingredients).

**Q: Can users add their own ingredients?**  
A: Yes! Users can add ingredients through the app. Community-driven growth.

**Q: Does mood tracking data leave my device?**  
A: No! Mood data is stored locally in SharedPreferences for privacy.

**Q: How do I add more sample data?**  
A: See `SUPABASE_SETUP.md` for bulk import options (CSV, JSON, SQL).

---

## ✨ Success Checklist

After setup, you should be able to:

- [ ] Launch app without crashes
- [ ] Create account and log in
- [ ] Search for "apple" and see 7 varieties
- [ ] Add ingredient to pantry
- [ ] Set dietary preferences
- [ ] Use AI assistant to get mood-based recipes
- [ ] Log mood on profile
- [ ] See activity statistics
- [ ] Navigate all bottom tabs

If all checks pass: **🎉 You're ready to go!**

---

**Last Updated**: January 2026  
**Version**: 1.0.0  
**Questions?**: Check `docs/ARCHITECTURE_DIAGRAMS.md` for detailed flows
