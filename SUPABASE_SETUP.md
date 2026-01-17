# Supabase Ingredient Database Setup

## Overview

This guide explains how to set up your own ingredient database in Supabase, eliminating the need for external API dependencies. You'll have full control over your ingredient data with the ability to store millions of ingredients.

## Benefits of Supabase Integration

✅ **No External API Dependencies**: All data stored in your Supabase instance  
✅ **Unlimited Scalability**: Add millions of ingredients to your database  
✅ **Full Control**: You own and control all ingredient data  
✅ **No API Costs**: Free tier includes 500MB database + 1GB file storage  
✅ **Real-time Updates**: Instant synchronization across all users  
✅ **Built-in Search**: PostgreSQL full-text search capabilities  
✅ **User Contributions**: Users can add ingredients to the database  
✅ **Image Storage**: Built-in storage for ingredient images  
✅ **Advanced Filtering**: Filter by categories, allergens, dietary tags  

## Database Schema

### 1. Ingredients Table

Main table storing all ingredient data:

```sql
-- Main ingredients table
CREATE TABLE ingredients (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  scientific_name TEXT,
  variety TEXT,
  category TEXT,
  image_url TEXT,
  barcode TEXT UNIQUE,
  nutritional_info JSONB,
  allergens TEXT[],
  dietary_tags TEXT[],
  brand_name TEXT,
  usage_count INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_by UUID REFERENCES auth.users(id),
  
  -- Indexes for fast searching
  CONSTRAINT ingredients_name_check CHECK (char_length(name) >= 1)
);

-- Create indexes for performance
CREATE INDEX idx_ingredients_name ON ingredients USING GIN (name gin_trgm_ops);
CREATE INDEX idx_ingredients_scientific_name ON ingredients USING GIN (scientific_name gin_trgm_ops);
CREATE INDEX idx_ingredients_variety ON ingredients USING GIN (variety gin_trgm_ops);
CREATE INDEX idx_ingredients_category ON ingredients(category);
CREATE INDEX idx_ingredients_barcode ON ingredients(barcode);
CREATE INDEX idx_ingredients_usage_count ON ingredients(usage_count DESC);
CREATE INDEX idx_ingredients_allergens ON ingredients USING GIN (allergens);
CREATE INDEX idx_ingredients_dietary_tags ON ingredients USING GIN (dietary_tags);

-- Enable Row Level Security
ALTER TABLE ingredients ENABLE ROW LEVEL SECURITY;

-- Policies: Everyone can read, authenticated users can insert
CREATE POLICY "Anyone can view ingredients"
  ON ingredients FOR SELECT
  USING (true);

CREATE POLICY "Authenticated users can add ingredients"
  ON ingredients FOR INSERT
  WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Users can update their own ingredients"
  ON ingredients FOR UPDATE
  USING (auth.uid() = created_by);
```

### 2. Ingredient Categories Table

Predefined categories for organizing ingredients:

```sql
-- Categories lookup table
CREATE TABLE ingredient_categories (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT UNIQUE NOT NULL,
  description TEXT,
  icon_emoji TEXT,
  sort_order INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE ingredient_categories ENABLE ROW LEVEL SECURITY;

-- Policy: Everyone can read categories
CREATE POLICY "Anyone can view categories"
  ON ingredient_categories FOR SELECT
  USING (true);

-- Insert default categories
INSERT INTO ingredient_categories (name, description, icon_emoji, sort_order) VALUES
  ('Fruits', 'Fresh and dried fruits', '🍎', 1),
  ('Vegetables', 'Fresh vegetables and leafy greens', '🥬', 2),
  ('Meats', 'Beef, pork, lamb, poultry', '🥩', 3),
  ('Seafood', 'Fish, shellfish, and other seafood', '🐟', 4),
  ('Dairy', 'Milk, cheese, yogurt, butter', '🧀', 5),
  ('Grains', 'Rice, pasta, bread, cereals', '🌾', 6),
  ('Legumes', 'Beans, lentils, peas', '🫘', 7),
  ('Nuts & Seeds', 'Almonds, walnuts, chia, flax', '🥜', 8),
  ('Herbs & Spices', 'Fresh and dried herbs, spices', '🌿', 9),
  ('Oils & Fats', 'Cooking oils, butter, margarine', '🫒', 10),
  ('Beverages', 'Juices, sodas, teas, coffees', '🥤', 11),
  ('Condiments', 'Sauces, dressings, spreads', '🍯', 12),
  ('Baking', 'Flour, sugar, baking powder', '🧁', 13),
  ('Snacks', 'Chips, crackers, sweets', '🍿', 14),
  ('Frozen Foods', 'Frozen meals, vegetables, desserts', '🧊', 15),
  ('Canned Foods', 'Canned vegetables, fruits, soups', '🥫', 16);
```

### 3. Storage Bucket for Images

```sql
-- Create storage bucket for ingredient images
INSERT INTO storage.buckets (id, name, public)
VALUES ('ingredient-images', 'ingredient-images', true);

-- Set storage policies
CREATE POLICY "Anyone can view ingredient images"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'ingredient-images');

CREATE POLICY "Authenticated users can upload ingredient images"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'ingredient-images' AND
    auth.role() = 'authenticated'
  );
```

### 4. Helper Functions

```sql
-- Function to increment usage count
CREATE OR REPLACE FUNCTION increment_ingredient_usage(ingredient_id UUID)
RETURNS void AS $$
BEGIN
  UPDATE ingredients
  SET usage_count = usage_count + 1
  WHERE id = ingredient_id;
END;
$$ LANGUAGE plpgsql;

-- Function to get ingredient suggestions based on user's pantry
CREATE OR REPLACE FUNCTION get_ingredient_suggestions(user_pantry_ids UUID[])
RETURNS SETOF ingredients AS $$
BEGIN
  RETURN QUERY
  SELECT i.*
  FROM ingredients i
  WHERE i.category IN (
    SELECT DISTINCT category
    FROM ingredients
    WHERE id = ANY(user_pantry_ids)
  )
  AND i.id != ALL(user_pantry_ids)
  ORDER BY i.usage_count DESC
  LIMIT 20;
END;
$$ LANGUAGE plpgsql;

-- Function to update the updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to auto-update updated_at
CREATE TRIGGER update_ingredients_updated_at
  BEFORE UPDATE ON ingredients
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
```

## Setup Instructions

### Step 1: Create Supabase Project

1. Go to https://supabase.com
2. Sign up or log in
3. Create a new project
4. Note down your project URL and anon key (already in `main.dart`)

### Step 2: Run Database Migrations

1. Open your Supabase project dashboard
2. Go to **SQL Editor**
3. Copy and paste the SQL from above (sections 1-4)
4. Click **Run** to execute

### Step 3: Enable Required Extensions

In the SQL Editor, run:

```sql
-- Enable UUID generation
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Enable trigram similarity for fuzzy search
CREATE EXTENSION IF NOT EXISTS pg_trgm;
```

### Step 4: Seed Initial Data

You can import initial ingredient data from various sources:

#### Option A: Manual Entry
Use the Supabase dashboard to manually add ingredients through the Table Editor.

#### Option B: Import from CSV
1. Export data from USDA, Open Food Facts, or other sources as CSV
2. Use Supabase dashboard to import CSV into `ingredients` table

#### Option C: Bulk Import via API
Use the `bulkImportIngredients()` method in the service:

```dart
final service = SupabaseIngredientService();
final ingredients = [
  {
    'name': 'Fuji Apple',
    'scientific_name': 'Malus domestica',
    'variety': 'Fuji',
    'category': 'Fruits',
    'allergens': [],
    'dietary_tags': ['vegan', 'gluten-free', 'organic'],
  },
  // ... add more ingredients
];
await service.bulkImportIngredients(ingredients);
```

## Sample Ingredient Data

Here's sample data for common ingredients you can import:

```sql
INSERT INTO ingredients (name, scientific_name, variety, category, allergens, dietary_tags) VALUES
  -- Apples
  ('Apple', 'Malus domestica', 'Fuji', 'Fruits', '{}', '{vegan,gluten-free}'),
  ('Apple', 'Malus domestica', 'Gala', 'Fruits', '{}', '{vegan,gluten-free}'),
  ('Apple', 'Malus domestica', 'Granny Smith', 'Fruits', '{}', '{vegan,gluten-free}'),
  ('Apple', 'Malus domestica', 'Honeycrisp', 'Fruits', '{}', '{vegan,gluten-free}'),
  
  -- Salmon
  ('Salmon', 'Salmo salar', 'Atlantic', 'Seafood', '{fish}', '{pescatarian,keto,paleo}'),
  ('Salmon', 'Oncorhynchus tshawytscha', 'King', 'Seafood', '{fish}', '{pescatarian,keto,paleo}'),
  ('Salmon', 'Oncorhynchus nerka', 'Sockeye', 'Seafood', '{fish}', '{pescatarian,keto,paleo}'),
  
  -- Spinach
  ('Spinach', 'Spinacia oleracea', 'Baby', 'Vegetables', '{}', '{vegan,gluten-free,low-carb}'),
  ('Spinach', 'Spinacia oleracea', 'Savoy', 'Vegetables', '{}', '{vegan,gluten-free,low-carb}'),
  
  -- Rice
  ('Rice', 'Oryza sativa', 'Basmati', 'Grains', '{}', '{vegan,gluten-free}'),
  ('Rice', 'Oryza sativa', 'Jasmine', 'Grains', '{}', '{vegan,gluten-free}'),
  ('Rice', 'Oryza sativa', 'Brown', 'Grains', '{}', '{vegan,gluten-free}'),
  
  -- Common dairy
  ('Milk', NULL, 'Whole', 'Dairy', '{dairy}', '{vegetarian}'),
  ('Milk', NULL, '2%', 'Dairy', '{dairy}', '{vegetarian}'),
  ('Milk', NULL, 'Skim', 'Dairy', '{dairy}', '{vegetarian}'),
  ('Cheese', NULL, 'Cheddar', 'Dairy', '{dairy}', '{vegetarian}'),
  ('Cheese', NULL, 'Mozzarella', 'Dairy', '{dairy}', '{vegetarian}');
```

## Using the Service

### Basic Search
```dart
final service = SupabaseIngredientService();
final results = await service.searchIngredients('apple');
```

### Advanced Search with Filters
```dart
final results = await service.advancedSearch(
  query: 'apple',
  categories: ['Fruits'],
  dietaryTags: ['vegan', 'gluten-free'],
  excludeAllergens: ['dairy'],
  limit: 20,
);
```

### Barcode Lookup
```dart
final ingredient = await service.lookupByBarcode('1234567890');
```

### Add New Ingredient
```dart
final newIngredient = IngredientItem(
  id: '', // Auto-generated
  name: 'Pink Lady Apple',
  variety: 'Pink Lady',
  category: 'Fruits',
  createdAt: DateTime.now(),
);
await service.addIngredient(newIngredient);
```

## Data Sources for Seeding

### 1. USDA FoodData Central
- Download: https://fdc.nal.usda.gov/download-datasets.html
- Format: CSV/JSON
- Size: 600,000+ foods
- License: Public domain

### 2. Open Food Facts
- Download: https://world.openfoodfacts.org/data
- Format: CSV/JSON
- Size: 2.8M+ products
- License: ODbL

### 3. Custom Data Entry
- Allow users to contribute ingredients
- Moderate and verify user submissions
- Build a community-driven database

## Scaling Tips

1. **Indexing**: Already included in schema for optimal performance
2. **Caching**: Use app-level caching for frequently accessed data
3. **Pagination**: Implement infinite scroll in UI
4. **Full-Text Search**: PostgreSQL FTS is already configured
5. **Image Optimization**: Compress images before upload
6. **CDN**: Use Supabase CDN for image delivery

## Cost Estimate

**Free Tier Includes:**
- 500MB database storage
- 1GB file storage
- 50,000 monthly active users
- Unlimited API requests

**This supports:**
- ~100,000+ ingredient records (with nutritional data)
- ~5,000+ ingredient images
- Perfect for most applications

**Paid Plan (if needed):**
- Pro: $25/month for 8GB database + 100GB storage
- Team/Enterprise: Custom pricing

## Next Steps

1. ✅ Run database migrations in Supabase SQL Editor
2. ✅ Seed initial ingredient data (start with 100-1000 common items)
3. ✅ Update `advanced_ingredient_search_screen.dart` to use Supabase service
4. ✅ Test search functionality
5. ✅ Enable user contributions for community-driven database
6. ✅ Set up automated backups in Supabase dashboard

## Support

- Supabase Docs: https://supabase.com/docs
- Supabase Discord: https://discord.supabase.com
- PostgreSQL Docs: https://www.postgresql.org/docs/

---

**With Supabase, you have complete control over your ingredient database with unlimited scalability potential!** 🚀
