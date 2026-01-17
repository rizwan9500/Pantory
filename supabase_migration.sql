-- Pantory Ingredient Database Migration
-- Run this in your Supabase SQL Editor to set up the complete ingredient database

-- ============================================
-- STEP 1: Enable Required Extensions
-- ============================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- ============================================
-- STEP 2: Create Main Tables
-- ============================================

-- Ingredient Categories Table
CREATE TABLE IF NOT EXISTS ingredient_categories (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT UNIQUE NOT NULL,
  description TEXT,
  icon_emoji TEXT,
  sort_order INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Main Ingredients Table
CREATE TABLE IF NOT EXISTS ingredients (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  scientific_name TEXT,
  variety TEXT,
  category TEXT REFERENCES ingredient_categories(name) ON UPDATE CASCADE,
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
  
  CONSTRAINT ingredients_name_check CHECK (char_length(name) >= 1)
);

-- ============================================
-- STEP 3: Create Indexes for Performance
-- ============================================

CREATE INDEX IF NOT EXISTS idx_ingredients_name 
  ON ingredients USING GIN (name gin_trgm_ops);

CREATE INDEX IF NOT EXISTS idx_ingredients_scientific_name 
  ON ingredients USING GIN (scientific_name gin_trgm_ops);

CREATE INDEX IF NOT EXISTS idx_ingredients_variety 
  ON ingredients USING GIN (variety gin_trgm_ops);

CREATE INDEX IF NOT EXISTS idx_ingredients_category 
  ON ingredients(category);

CREATE INDEX IF NOT EXISTS idx_ingredients_barcode 
  ON ingredients(barcode);

CREATE INDEX IF NOT EXISTS idx_ingredients_usage_count 
  ON ingredients(usage_count DESC);

CREATE INDEX IF NOT EXISTS idx_ingredients_allergens 
  ON ingredients USING GIN (allergens);

CREATE INDEX IF NOT EXISTS idx_ingredients_dietary_tags 
  ON ingredients USING GIN (dietary_tags);

-- ============================================
-- STEP 4: Enable Row Level Security
-- ============================================

ALTER TABLE ingredients ENABLE ROW LEVEL SECURITY;
ALTER TABLE ingredient_categories ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Anyone can view ingredients" ON ingredients;
DROP POLICY IF EXISTS "Authenticated users can add ingredients" ON ingredients;
DROP POLICY IF EXISTS "Users can update their own ingredients" ON ingredients;
DROP POLICY IF EXISTS "Anyone can view categories" ON ingredient_categories;

-- Create policies for ingredients
CREATE POLICY "Anyone can view ingredients"
  ON ingredients FOR SELECT
  USING (true);

CREATE POLICY "Authenticated users can add ingredients"
  ON ingredients FOR INSERT
  WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Users can update their own ingredients"
  ON ingredients FOR UPDATE
  USING (auth.uid() = created_by);

-- Create policy for categories
CREATE POLICY "Anyone can view categories"
  ON ingredient_categories FOR SELECT
  USING (true);

-- ============================================
-- STEP 5: Create Helper Functions
-- ============================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for auto-updating updated_at
DROP TRIGGER IF EXISTS update_ingredients_updated_at ON ingredients;
CREATE TRIGGER update_ingredients_updated_at
  BEFORE UPDATE ON ingredients
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

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

-- ============================================
-- STEP 6: Seed Initial Categories
-- ============================================

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
  ('Canned Foods', 'Canned vegetables, fruits, soups', '🥫', 16)
ON CONFLICT (name) DO NOTHING;

-- ============================================
-- STEP 7: Seed Sample Ingredient Data
-- ============================================

INSERT INTO ingredients (name, scientific_name, variety, category, allergens, dietary_tags) VALUES
  -- Apples (various varieties)
  ('Apple', 'Malus domestica', 'Fuji', 'Fruits', '{}', '{vegan,gluten-free,organic}'),
  ('Apple', 'Malus domestica', 'Gala', 'Fruits', '{}', '{vegan,gluten-free}'),
  ('Apple', 'Malus domestica', 'Granny Smith', 'Fruits', '{}', '{vegan,gluten-free}'),
  ('Apple', 'Malus domestica', 'Honeycrisp', 'Fruits', '{}', '{vegan,gluten-free}'),
  ('Apple', 'Malus domestica', 'Pink Lady', 'Fruits', '{}', '{vegan,gluten-free}'),
  ('Apple', 'Malus domestica', 'Red Delicious', 'Fruits', '{}', '{vegan,gluten-free}'),
  ('Apple', 'Malus domestica', 'Golden Delicious', 'Fruits', '{}', '{vegan,gluten-free}'),
  
  -- Salmon (various types)
  ('Salmon', 'Salmo salar', 'Atlantic', 'Seafood', '{fish}', '{pescatarian,keto,paleo,high-protein}'),
  ('Salmon', 'Oncorhynchus tshawytscha', 'King', 'Seafood', '{fish}', '{pescatarian,keto,paleo,high-protein}'),
  ('Salmon', 'Oncorhynchus nerka', 'Sockeye', 'Seafood', '{fish}', '{pescatarian,keto,paleo,high-protein}'),
  ('Salmon', 'Oncorhynchus kisutch', 'Coho', 'Seafood', '{fish}', '{pescatarian,keto,paleo,high-protein}'),
  ('Salmon', 'Oncorhynchus gorbuscha', 'Pink', 'Seafood', '{fish}', '{pescatarian,keto,paleo,high-protein}'),
  
  -- Spinach (varieties)
  ('Spinach', 'Spinacia oleracea', 'Baby', 'Vegetables', '{}', '{vegan,gluten-free,low-carb,organic}'),
  ('Spinach', 'Spinacia oleracea', 'Savoy', 'Vegetables', '{}', '{vegan,gluten-free,low-carb}'),
  ('Spinach', 'Spinacia oleracea', 'Flat Leaf', 'Vegetables', '{}', '{vegan,gluten-free,low-carb}'),
  
  -- Rice (varieties)
  ('Rice', 'Oryza sativa', 'Basmati', 'Grains', '{}', '{vegan,gluten-free}'),
  ('Rice', 'Oryza sativa', 'Jasmine', 'Grains', '{}', '{vegan,gluten-free}'),
  ('Rice', 'Oryza sativa', 'Brown', 'Grains', '{}', '{vegan,gluten-free,organic}'),
  ('Rice', 'Oryza sativa', 'White', 'Grains', '{}', '{vegan,gluten-free}'),
  ('Rice', 'Oryza sativa', 'Wild', 'Grains', '{}', '{vegan,gluten-free}'),
  ('Rice', 'Oryza sativa', 'Arborio', 'Grains', '{}', '{vegan,gluten-free}'),
  
  -- Common dairy products
  ('Milk', NULL, 'Whole', 'Dairy', '{dairy}', '{vegetarian}'),
  ('Milk', NULL, '2%', 'Dairy', '{dairy}', '{vegetarian}'),
  ('Milk', NULL, 'Skim', 'Dairy', '{dairy}', '{vegetarian}'),
  ('Milk', NULL, 'Almond', 'Beverages', '{tree-nuts}', '{vegan,dairy-free}'),
  ('Milk', NULL, 'Soy', 'Beverages', '{soy}', '{vegan,dairy-free}'),
  ('Milk', NULL, 'Oat', 'Beverages', '{}', '{vegan,dairy-free}'),
  ('Cheese', NULL, 'Cheddar', 'Dairy', '{dairy}', '{vegetarian}'),
  ('Cheese', NULL, 'Mozzarella', 'Dairy', '{dairy}', '{vegetarian}'),
  ('Cheese', NULL, 'Parmesan', 'Dairy', '{dairy}', '{vegetarian}'),
  ('Yogurt', NULL, 'Greek', 'Dairy', '{dairy}', '{vegetarian,high-protein}'),
  ('Yogurt', NULL, 'Regular', 'Dairy', '{dairy}', '{vegetarian}'),
  
  -- Common vegetables
  ('Tomato', 'Solanum lycopersicum', 'Roma', 'Vegetables', '{}', '{vegan,gluten-free}'),
  ('Tomato', 'Solanum lycopersicum', 'Cherry', 'Vegetables', '{}', '{vegan,gluten-free}'),
  ('Tomato', 'Solanum lycopersicum', 'Beefsteak', 'Vegetables', '{}', '{vegan,gluten-free}'),
  ('Onion', 'Allium cepa', 'Yellow', 'Vegetables', '{}', '{vegan,gluten-free}'),
  ('Onion', 'Allium cepa', 'Red', 'Vegetables', '{}', '{vegan,gluten-free}'),
  ('Onion', 'Allium cepa', 'White', 'Vegetables', '{}', '{vegan,gluten-free}'),
  ('Potato', 'Solanum tuberosum', 'Russet', 'Vegetables', '{}', '{vegan,gluten-free}'),
  ('Potato', 'Solanum tuberosum', 'Red', 'Vegetables', '{}', '{vegan,gluten-free}'),
  ('Potato', 'Solanum tuberosum', 'Yukon Gold', 'Vegetables', '{}', '{vegan,gluten-free}'),
  ('Carrot', 'Daucus carota', 'Regular', 'Vegetables', '{}', '{vegan,gluten-free}'),
  ('Carrot', 'Daucus carota', 'Baby', 'Vegetables', '{}', '{vegan,gluten-free}'),
  
  -- Common meats
  ('Chicken', 'Gallus gallus domesticus', 'Breast', 'Meats', '{}', '{high-protein,keto,paleo}'),
  ('Chicken', 'Gallus gallus domesticus', 'Thigh', 'Meats', '{}', '{high-protein,keto,paleo}'),
  ('Chicken', 'Gallus gallus domesticus', 'Drumstick', 'Meats', '{}', '{high-protein,keto,paleo}'),
  ('Beef', 'Bos taurus', 'Ground', 'Meats', '{}', '{high-protein,keto,paleo}'),
  ('Beef', 'Bos taurus', 'Steak', 'Meats', '{}', '{high-protein,keto,paleo}'),
  ('Pork', 'Sus scrofa domesticus', 'Chop', 'Meats', '{}', '{high-protein,keto,paleo}'),
  ('Pork', 'Sus scrofa domesticus', 'Ground', 'Meats', '{}', '{high-protein,keto,paleo}'),
  
  -- Legumes
  ('Beans', 'Phaseolus vulgaris', 'Black', 'Legumes', '{}', '{vegan,gluten-free,high-protein}'),
  ('Beans', 'Phaseolus vulgaris', 'Kidney', 'Legumes', '{}', '{vegan,gluten-free,high-protein}'),
  ('Beans', 'Phaseolus vulgaris', 'Pinto', 'Legumes', '{}', '{vegan,gluten-free,high-protein}'),
  ('Lentils', 'Lens culinaris', 'Red', 'Legumes', '{}', '{vegan,gluten-free,high-protein}'),
  ('Lentils', 'Lens culinaris', 'Green', 'Legumes', '{}', '{vegan,gluten-free,high-protein}'),
  
  -- Nuts & Seeds
  ('Almonds', 'Prunus dulcis', NULL, 'Nuts & Seeds', '{tree-nuts}', '{vegan,gluten-free,keto}'),
  ('Walnuts', 'Juglans regia', NULL, 'Nuts & Seeds', '{tree-nuts}', '{vegan,gluten-free,keto}'),
  ('Peanuts', 'Arachis hypogaea', NULL, 'Nuts & Seeds', '{peanuts}', '{vegan,gluten-free}'),
  ('Cashews', 'Anacardium occidentale', NULL, 'Nuts & Seeds', '{tree-nuts}', '{vegan,gluten-free}'),
  ('Chia Seeds', 'Salvia hispanica', NULL, 'Nuts & Seeds', '{}', '{vegan,gluten-free}'),
  
  -- Herbs & Spices
  ('Basil', 'Ocimum basilicum', 'Fresh', 'Herbs & Spices', '{}', '{vegan,gluten-free}'),
  ('Oregano', 'Origanum vulgare', 'Dried', 'Herbs & Spices', '{}', '{vegan,gluten-free}'),
  ('Thyme', 'Thymus vulgaris', 'Fresh', 'Herbs & Spices', '{}', '{vegan,gluten-free}'),
  ('Cumin', 'Cuminum cyminum', 'Ground', 'Herbs & Spices', '{}', '{vegan,gluten-free}'),
  ('Paprika', 'Capsicum annuum', 'Ground', 'Herbs & Spices', '{}', '{vegan,gluten-free}')
ON CONFLICT DO NOTHING;

-- ============================================
-- STEP 8: Setup Storage for Images
-- ============================================

-- Note: Run this separately if storage bucket doesn't exist
-- INSERT INTO storage.buckets (id, name, public)
-- VALUES ('ingredient-images', 'ingredient-images', true)
-- ON CONFLICT (id) DO NOTHING;

-- ============================================
-- Migration Complete!
-- ============================================

-- Verify the setup
SELECT 'Categories:', COUNT(*) FROM ingredient_categories;
SELECT 'Ingredients:', COUNT(*) FROM ingredients;

-- Display sample data
SELECT 
  name, 
  variety, 
  category, 
  array_length(allergens, 1) as allergen_count,
  array_length(dietary_tags, 1) as dietary_tag_count
FROM ingredients
LIMIT 10;
