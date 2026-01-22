-- Enable UUID extension if not enabled
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ==========================================
-- 1. FUNCTIONS & TRIGGERS
-- ==========================================

-- Function to handle updated_at timestamps
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ==========================================
-- 2. CORE TABLES (Profiles)
-- ==========================================

CREATE TABLE IF NOT EXISTS public.profiles (
  id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  username text NOT NULL UNIQUE,
  display_name text,
  avatar_url text,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT profiles_pkey PRIMARY KEY (id)
);

-- ==========================================
-- 3. MODULE: PORTFOLIOS
-- ==========================================

CREATE TABLE IF NOT EXISTS public.portfolios (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  title text NOT NULL,
  description text,
  is_visible boolean DEFAULT true,
  slug text UNIQUE,
  template_id text DEFAULT 'minimalist',
  -- Aesthetic Consistency
  primary_color text DEFAULT '#000000',
  font_family text DEFAULT 'Inter',
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT portfolios_pkey PRIMARY KEY (id),
  CONSTRAINT portfolios_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS public.portfolio_items (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  portfolio_id uuid NOT NULL,
  title text NOT NULL,
  description text,
  image_url text,
  project_url text,
  sort_order integer DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT portfolio_items_pkey PRIMARY KEY (id),
  CONSTRAINT portfolio_items_portfolio_id_fkey FOREIGN KEY (portfolio_id) REFERENCES public.portfolios(id) ON DELETE CASCADE
);

-- ==========================================
-- 4. MODULE: CVs (Normalized)
-- ==========================================

CREATE TABLE IF NOT EXISTS public.cvs (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  title text NOT NULL,
  professional_summary text,
  is_visible boolean DEFAULT true,
  template_id text DEFAULT 'standard',
  -- Aesthetic Consistency
  primary_color text DEFAULT '#000000',
  font_family text DEFAULT 'Inter',
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT cvs_pkey PRIMARY KEY (id),
  CONSTRAINT cvs_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE
);

-- CV Experience
CREATE TABLE IF NOT EXISTS public.cv_experience (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  cv_id uuid NOT NULL,
  role text NOT NULL,
  company text NOT NULL,
  start_date date,
  end_date date,
  is_current boolean DEFAULT false,
  description text,
  sort_order integer DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT cv_experience_pkey PRIMARY KEY (id),
  CONSTRAINT cv_experience_cv_id_fkey FOREIGN KEY (cv_id) REFERENCES public.cvs(id) ON DELETE CASCADE
);

-- CV Education
CREATE TABLE IF NOT EXISTS public.cv_education (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  cv_id uuid NOT NULL,
  degree text NOT NULL,
  institution text NOT NULL,
  start_date date,
  end_date date,
  is_current boolean DEFAULT false,
  description text,
  sort_order integer DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT cv_education_pkey PRIMARY KEY (id),
  CONSTRAINT cv_education_cv_id_fkey FOREIGN KEY (cv_id) REFERENCES public.cvs(id) ON DELETE CASCADE
);

-- CV Skills
CREATE TABLE IF NOT EXISTS public.cv_skills (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  cv_id uuid NOT NULL,
  name text NOT NULL,
  proficiency text, -- e.g. 'Beginner', 'Intermediate', 'Expert'
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT cv_skills_pkey PRIMARY KEY (id),
  CONSTRAINT cv_skills_cv_id_fkey FOREIGN KEY (cv_id) REFERENCES public.cvs(id) ON DELETE CASCADE
);

-- ==========================================
-- 5. MODULE: SHOPS (E-commerce)
-- ==========================================

CREATE TABLE IF NOT EXISTS public.shops (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  name text NOT NULL,
  description text,
  is_active boolean DEFAULT true,
  slug text UNIQUE,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT shops_pkey PRIMARY KEY (id),
  CONSTRAINT shops_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE
);

-- Product Categories
CREATE TABLE IF NOT EXISTS public.product_categories (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  shop_id uuid NOT NULL,
  name text NOT NULL,
  sort_order integer DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT product_categories_pkey PRIMARY KEY (id),
  CONSTRAINT product_categories_shop_id_fkey FOREIGN KEY (shop_id) REFERENCES public.shops(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS public.products (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  shop_id uuid NOT NULL,
  category_id uuid, -- Added FK
  name text NOT NULL,
  description text,
  price numeric NOT NULL,
  image_url text,
  is_available boolean DEFAULT true,
  stock integer DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT products_pkey PRIMARY KEY (id),
  CONSTRAINT products_shop_id_fkey FOREIGN KEY (shop_id) REFERENCES public.shops(id) ON DELETE CASCADE,
  CONSTRAINT products_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.product_categories(id) ON DELETE SET NULL
);

-- Safe column check for category_id in products (if running as update)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'products' AND column_name = 'category_id') THEN
        ALTER TABLE public.products ADD COLUMN category_id uuid REFERENCES public.product_categories(id) ON DELETE SET NULL;
    END IF;
END $$;

-- ==========================================
-- 6. MODULE: INVITATIONS
-- ==========================================

CREATE TABLE IF NOT EXISTS public.invitations (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  event_name text NOT NULL,
  event_date timestamp with time zone,
  location text,
  description text,
  slug text UNIQUE,
  is_active boolean DEFAULT true,
  template_id text DEFAULT 'elegant',
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT invitations_pkey PRIMARY KEY (id),
  CONSTRAINT invitations_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE
);

-- ==========================================
-- 7. MODULE: MENUS
-- ==========================================

CREATE TABLE IF NOT EXISTS public.menus (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  name text NOT NULL,
  description text,
  template_id text DEFAULT 'minimalist',
  primary_color text DEFAULT '#000000',
  font_family text DEFAULT 'Inter',
  logo_url text,
  slug text UNIQUE,
  is_active boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT menus_pkey PRIMARY KEY (id),
  CONSTRAINT menus_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS public.menu_categories (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  menu_id uuid NOT NULL,
  name text NOT NULL,
  sort_order integer DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT menu_categories_pkey PRIMARY KEY (id),
  CONSTRAINT menu_categories_menu_id_fkey FOREIGN KEY (menu_id) REFERENCES public.menus(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS public.dishes (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  menu_id uuid NOT NULL,
  category_id uuid,
  name text NOT NULL,
  description text,
  price numeric NOT NULL,
  image_url text,
  is_visible boolean DEFAULT true,
  sort_order integer DEFAULT 0, -- Added sort_order
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT dishes_pkey PRIMARY KEY (id),
  CONSTRAINT dishes_menu_id_fkey FOREIGN KEY (menu_id) REFERENCES public.menus(id) ON DELETE CASCADE,
  CONSTRAINT dishes_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.menu_categories(id) ON DELETE SET NULL
);

-- Safe column checks for dishes
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'dishes' AND column_name = 'description') THEN
        ALTER TABLE public.dishes ADD COLUMN description text;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'dishes' AND column_name = 'category_id') THEN
        ALTER TABLE public.dishes ADD COLUMN category_id uuid REFERENCES public.menu_categories(id) ON DELETE SET NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'dishes' AND column_name = 'sort_order') THEN
        ALTER TABLE public.dishes ADD COLUMN sort_order integer DEFAULT 0;
    END IF;
END $$;


-- ==========================================
-- 8. MODULE: SUBSCRIPTIONS
-- ==========================================

CREATE TABLE IF NOT EXISTS public.plans (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name text NOT NULL,
  description text,
  price numeric NOT NULL DEFAULT 0,
  currency text DEFAULT 'USD',
  interval text DEFAULT 'month',
  features jsonb DEFAULT '{}'::jsonb,
  is_active boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT plans_pkey PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS public.subscriptions (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
  plan_id uuid NOT NULL REFERENCES public.plans(id),
  status text NOT NULL DEFAULT 'active',
  current_period_start timestamp with time zone DEFAULT now(),
  current_period_end timestamp with time zone,
  cancel_at_period_end boolean DEFAULT false,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT subscriptions_pkey PRIMARY KEY (id)
);

-- Trigger for subscriptions updated_at
DROP TRIGGER IF EXISTS on_auth_user_updated ON public.subscriptions; -- Cleanup if needed, though name mismatches usually
DROP TRIGGER IF EXISTS handle_subscriptions_updated_at ON public.subscriptions;

CREATE TRIGGER handle_subscriptions_updated_at
BEFORE UPDATE ON public.subscriptions
FOR EACH ROW
EXECUTE FUNCTION public.handle_updated_at();


-- ==========================================
-- 9. OPTIMIZATIONS (INDICES)
-- ==========================================

-- FK Indices
CREATE INDEX IF NOT EXISTS idx_portfolios_user_id ON public.portfolios(user_id);
CREATE INDEX IF NOT EXISTS idx_portfolio_items_portfolio_id ON public.portfolio_items(portfolio_id);

CREATE INDEX IF NOT EXISTS idx_cvs_user_id ON public.cvs(user_id);
CREATE INDEX IF NOT EXISTS idx_cv_experience_cv_id ON public.cv_experience(cv_id);
CREATE INDEX IF NOT EXISTS idx_cv_education_cv_id ON public.cv_education(cv_id);
CREATE INDEX IF NOT EXISTS idx_cv_skills_cv_id ON public.cv_skills(cv_id);

CREATE INDEX IF NOT EXISTS idx_shops_user_id ON public.shops(user_id);
CREATE INDEX IF NOT EXISTS idx_product_categories_shop_id ON public.product_categories(shop_id);
CREATE INDEX IF NOT EXISTS idx_products_shop_id ON public.products(shop_id);
CREATE INDEX IF NOT EXISTS idx_products_category_id ON public.products(category_id);

CREATE INDEX IF NOT EXISTS idx_invitations_user_id ON public.invitations(user_id);

CREATE INDEX IF NOT EXISTS idx_menus_user_id ON public.menus(user_id);
CREATE INDEX IF NOT EXISTS idx_menu_categories_menu_id ON public.menu_categories(menu_id);
CREATE INDEX IF NOT EXISTS idx_dishes_menu_id ON public.dishes(menu_id);
CREATE INDEX IF NOT EXISTS idx_dishes_category_id ON public.dishes(category_id);

CREATE INDEX IF NOT EXISTS idx_subscriptions_user_id ON public.subscriptions(user_id);

-- Slug Indices (Partial/optimizations)
CREATE INDEX IF NOT EXISTS idx_portfolios_slug ON public.portfolios(slug);
CREATE INDEX IF NOT EXISTS idx_shops_slug ON public.shops(slug);
CREATE INDEX IF NOT EXISTS idx_invitations_slug ON public.invitations(slug);
CREATE INDEX IF NOT EXISTS idx_menus_slug ON public.menus(slug);


-- ==========================================
-- 10. ROW LEVEL SECURITY (RLS)
-- ==========================================

-- Macro: Authenticated user matches IDs

-- PROFILES
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Public profiles" ON public.profiles;
CREATE POLICY "Public profiles" ON public.profiles FOR SELECT USING (true);
DROP POLICY IF EXISTS "Owner manage profile" ON public.profiles;
CREATE POLICY "Owner manage profile" ON public.profiles FOR ALL USING (auth.uid() = id);

-- PORTFOLIOS
ALTER TABLE public.portfolios ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Public portfolios" ON public.portfolios;
CREATE POLICY "Public portfolios" ON public.portfolios FOR SELECT USING (is_visible = true);
DROP POLICY IF EXISTS "Owner manage portfolios" ON public.portfolios;
CREATE POLICY "Owner manage portfolios" ON public.portfolios FOR ALL USING (auth.uid() = user_id);

ALTER TABLE public.portfolio_items ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Public portfolio items" ON public.portfolio_items;
CREATE POLICY "Public portfolio items" ON public.portfolio_items FOR SELECT USING (
  EXISTS(SELECT 1 FROM public.portfolios WHERE id = portfolio_id AND is_visible = true)
);
DROP POLICY IF EXISTS "Owner manage portfolio items" ON public.portfolio_items;
CREATE POLICY "Owner manage portfolio items" ON public.portfolio_items FOR ALL USING (
  EXISTS(SELECT 1 FROM public.portfolios WHERE id = portfolio_id AND user_id = auth.uid())
);

-- CVs
ALTER TABLE public.cvs ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Public cvs" ON public.cvs;
CREATE POLICY "Public cvs" ON public.cvs FOR SELECT USING (is_visible = true);
DROP POLICY IF EXISTS "Owner manage cvs" ON public.cvs;
CREATE POLICY "Owner manage cvs" ON public.cvs FOR ALL USING (auth.uid() = user_id);

-- CV sub-tables
ALTER TABLE public.cv_experience ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Public cv_experience" ON public.cv_experience;
CREATE POLICY "Public cv_experience" ON public.cv_experience FOR SELECT USING (
  EXISTS(SELECT 1 FROM public.cvs WHERE id = cv_id AND is_visible = true)
);
DROP POLICY IF EXISTS "Owner manage cv_experience" ON public.cv_experience;
CREATE POLICY "Owner manage cv_experience" ON public.cv_experience FOR ALL USING (
  EXISTS(SELECT 1 FROM public.cvs WHERE id = cv_id AND user_id = auth.uid())
);

ALTER TABLE public.cv_education ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Public cv_education" ON public.cv_education;
CREATE POLICY "Public cv_education" ON public.cv_education FOR SELECT USING (
  EXISTS(SELECT 1 FROM public.cvs WHERE id = cv_id AND is_visible = true)
);
DROP POLICY IF EXISTS "Owner manage cv_education" ON public.cv_education;
CREATE POLICY "Owner manage cv_education" ON public.cv_education FOR ALL USING (
  EXISTS(SELECT 1 FROM public.cvs WHERE id = cv_id AND user_id = auth.uid())
);

ALTER TABLE public.cv_skills ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Public cv_skills" ON public.cv_skills;
CREATE POLICY "Public cv_skills" ON public.cv_skills FOR SELECT USING (
  EXISTS(SELECT 1 FROM public.cvs WHERE id = cv_id AND is_visible = true)
);
DROP POLICY IF EXISTS "Owner manage cv_skills" ON public.cv_skills;
CREATE POLICY "Owner manage cv_skills" ON public.cv_skills FOR ALL USING (
  EXISTS(SELECT 1 FROM public.cvs WHERE id = cv_id AND user_id = auth.uid())
);


-- SHOPS & PRODUCTS
ALTER TABLE public.shops ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Public shops" ON public.shops;
CREATE POLICY "Public shops" ON public.shops FOR SELECT USING (is_active = true);
DROP POLICY IF EXISTS "Owner manage shops" ON public.shops;
CREATE POLICY "Owner manage shops" ON public.shops FOR ALL USING (auth.uid() = user_id);

ALTER TABLE public.product_categories ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Public product categories" ON public.product_categories;
CREATE POLICY "Public product categories" ON public.product_categories FOR SELECT USING (
  EXISTS(SELECT 1 FROM public.shops WHERE id = shop_id AND is_active = true)
);
DROP POLICY IF EXISTS "Owner manage product categories" ON public.product_categories;
CREATE POLICY "Owner manage product categories" ON public.product_categories FOR ALL USING (
  EXISTS(SELECT 1 FROM public.shops WHERE id = shop_id AND user_id = auth.uid())
);

ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Public products" ON public.products;
CREATE POLICY "Public products" ON public.products FOR SELECT USING (
  is_available = true AND
  EXISTS(SELECT 1 FROM public.shops WHERE id = shop_id AND is_active = true)
);
DROP POLICY IF EXISTS "Owner manage products" ON public.products;
CREATE POLICY "Owner manage products" ON public.products FOR ALL USING (
  EXISTS(SELECT 1 FROM public.shops WHERE id = shop_id AND user_id = auth.uid())
);

-- INVITATIONS
ALTER TABLE public.invitations ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Public invitations" ON public.invitations;
CREATE POLICY "Public invitations" ON public.invitations FOR SELECT USING (is_active = true);
DROP POLICY IF EXISTS "Owner manage invitations" ON public.invitations;
CREATE POLICY "Owner manage invitations" ON public.invitations FOR ALL USING (auth.uid() = user_id);

-- MENUS
ALTER TABLE public.menus ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Public menus" ON public.menus;
CREATE POLICY "Public menus" ON public.menus FOR SELECT USING (is_active = true);
DROP POLICY IF EXISTS "Owner manage menus" ON public.menus;
CREATE POLICY "Owner manage menus" ON public.menus FOR ALL USING (auth.uid() = user_id);

ALTER TABLE public.menu_categories ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Public menu categories" ON public.menu_categories;
CREATE POLICY "Public menu categories" ON public.menu_categories FOR SELECT USING (
  EXISTS(SELECT 1 FROM public.menus WHERE id = menu_id AND is_active = true)
);
DROP POLICY IF EXISTS "Owner manage menu categories" ON public.menu_categories;
CREATE POLICY "Owner manage menu categories" ON public.menu_categories FOR ALL USING (
  EXISTS(SELECT 1 FROM public.menus WHERE id = menu_id AND user_id = auth.uid())
);

ALTER TABLE public.dishes ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Public dishes" ON public.dishes;
CREATE POLICY "Public dishes" ON public.dishes FOR SELECT USING (
  is_visible = true AND
  EXISTS(SELECT 1 FROM public.menus WHERE id = menu_id AND is_active = true)
);
DROP POLICY IF EXISTS "Owner manage dishes" ON public.dishes;
CREATE POLICY "Owner manage dishes" ON public.dishes FOR ALL USING (
  EXISTS(SELECT 1 FROM public.menus WHERE id = menu_id AND user_id = auth.uid())
);


-- SUBSCRIPTIONS
ALTER TABLE public.subscriptions ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Owner view subscription" ON public.subscriptions;
CREATE POLICY "Owner view subscription" ON public.subscriptions FOR SELECT USING (auth.uid() = user_id);

ALTER TABLE public.plans ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Public view plans" ON public.plans;
CREATE POLICY "Public view plans" ON public.plans FOR SELECT USING (is_active = true);
