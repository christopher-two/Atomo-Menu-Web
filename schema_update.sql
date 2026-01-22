-- Enable UUID extension if not enabled
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Profiles Table (Maps user_id to username)
CREATE TABLE IF NOT EXISTS public.profiles (
  id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  username text NOT NULL UNIQUE,
  display_name text,
  avatar_url text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT profiles_pkey PRIMARY KEY (id)
);

-- Portfolios Table
CREATE TABLE IF NOT EXISTS public.portfolios (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  title text NOT NULL,
  description text,
  is_visible boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  slug text UNIQUE,
  template_id text DEFAULT 'minimalist',
  CONSTRAINT portfolios_pkey PRIMARY KEY (id),
  CONSTRAINT portfolios_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE
);

-- Portfolio Items (Projects)
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

-- CVs Table
CREATE TABLE IF NOT EXISTS public.cvs (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  title text NOT NULL,
  professional_summary text,
  is_visible boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  template_id text DEFAULT 'standard',
  CONSTRAINT cvs_pkey PRIMARY KEY (id),
  CONSTRAINT cvs_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE
);

-- Shops Table
CREATE TABLE IF NOT EXISTS public.shops (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  name text NOT NULL,
  description text,
  is_active boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  slug text UNIQUE,
  CONSTRAINT shops_pkey PRIMARY KEY (id),
  CONSTRAINT shops_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE
);

-- Products Table
CREATE TABLE IF NOT EXISTS public.products (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  shop_id uuid NOT NULL,
  name text NOT NULL,
  description text,
  price numeric NOT NULL,
  image_url text,
  is_available boolean DEFAULT true,
  stock integer DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT products_pkey PRIMARY KEY (id),
  CONSTRAINT products_shop_id_fkey FOREIGN KEY (shop_id) REFERENCES public.shops(id) ON DELETE CASCADE
);

-- Invitations Table
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
  CONSTRAINT invitations_pkey PRIMARY KEY (id),
  CONSTRAINT invitations_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE
);

-- RLS Policies (Row Level Security) - Basic Setup

-- Profiles: Public read, User update
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public profiles are viewable by everyone." ON public.profiles FOR SELECT USING (true);
CREATE POLICY "Users can insert their own profile." ON public.profiles FOR INSERT WITH CHECK (auth.uid() = id);
CREATE POLICY "Users can update own profile." ON public.profiles FOR UPDATE USING (auth.uid() = id);

-- Portfolios: Public read visible, User all
ALTER TABLE public.portfolios ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public portfolios are viewable by everyone." ON public.portfolios FOR SELECT USING (is_visible = true);
CREATE POLICY "Users can insert their own portfolio." ON public.portfolios FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own portfolio." ON public.portfolios FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own portfolio." ON public.portfolios FOR DELETE USING (auth.uid() = user_id);

-- Apply similar logic to other tables as needed (omitted for brevity but recommended)

-- Menus Table
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
  CONSTRAINT menus_pkey PRIMARY KEY (id),
  CONSTRAINT menus_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE
);

-- Dishes Table
CREATE TABLE IF NOT EXISTS public.dishes (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  menu_id uuid NOT NULL,
  name text NOT NULL,
  description text, -- Added description field
  price numeric NOT NULL,
  image_url text,
  is_visible boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT dishes_pkey PRIMARY KEY (id),
  CONSTRAINT dishes_menu_id_fkey FOREIGN KEY (menu_id) REFERENCES public.menus(id) ON DELETE CASCADE
);

-- RLS for Menus
ALTER TABLE public.menus ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public menus are viewable by everyone." ON public.menus FOR SELECT USING (is_active = true);
CREATE POLICY "Users can manage own menu." ON public.menus FOR ALL USING (auth.uid() = user_id);

-- RLS for Dishes
ALTER TABLE public.dishes ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public dishes are viewable by everyone." ON public.dishes FOR SELECT USING (is_visible = true);
CREATE POLICY "Users can manage own dishes." ON public.dishes FOR ALL USING (
  EXISTS (SELECT 1 FROM public.menus WHERE id = menu_id AND user_id = auth.uid())
);

-- Safe column addition for description in dishes
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_name = 'dishes'
        AND column_name = 'description'
    ) THEN
        ALTER TABLE public.dishes ADD COLUMN description text;
    END IF;
END $$;

-- Menu Categories Table
CREATE TABLE IF NOT EXISTS public.menu_categories (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  menu_id uuid NOT NULL,
  name text NOT NULL,
  sort_order integer DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT menu_categories_pkey PRIMARY KEY (id),
  CONSTRAINT menu_categories_menu_id_fkey FOREIGN KEY (menu_id) REFERENCES public.menus(id) ON DELETE CASCADE
);

-- RLS for Categories
ALTER TABLE public.menu_categories ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public categories are viewable by everyone." ON public.menu_categories FOR SELECT USING (
  EXISTS (SELECT 1 FROM public.menus WHERE id = menu_id AND is_active = true)
);
CREATE POLICY "Users can manage own categories." ON public.menu_categories FOR ALL USING (
  EXISTS (SELECT 1 FROM public.menus WHERE id = menu_id AND user_id = auth.uid())
);

-- Add category_id to dishes (Safe Add)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_name = 'dishes'
        AND column_name = 'category_id'
    ) THEN
        ALTER TABLE public.dishes ADD COLUMN category_id uuid REFERENCES public.menu_categories(id) ON DELETE SET NULL;
    END IF;
END $$;

-- ==========================================
-- NEW RLS POLICIES
-- ==========================================

-- 1. Portfolio Items
ALTER TABLE public.portfolio_items ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public portfolio items are viewable if portfolio is visible." 
ON public.portfolio_items FOR SELECT USING (
  EXISTS (SELECT 1 FROM public.portfolios WHERE id = portfolio_id AND is_visible = true)
);

CREATE POLICY "Users can manage own portfolio items." 
ON public.portfolio_items FOR ALL USING (
  EXISTS (SELECT 1 FROM public.portfolios WHERE id = portfolio_id AND user_id = auth.uid())
);

-- 2. CVs
ALTER TABLE public.cvs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public CVs are viewable by everyone." 
ON public.cvs FOR SELECT USING (is_visible = true);

CREATE POLICY "Users can manage own CVs." 
ON public.cvs FOR ALL USING (auth.uid() = user_id);

-- 3. Shops
ALTER TABLE public.shops ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public shops are viewable by everyone." 
ON public.shops FOR SELECT USING (is_active = true);

CREATE POLICY "Users can manage own shops." 
ON public.shops FOR ALL USING (auth.uid() = user_id);

-- 4. Products
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public products are viewable if shop is active." 
ON public.products FOR SELECT USING (
  is_available = true AND 
  EXISTS (SELECT 1 FROM public.shops WHERE id = shop_id AND is_active = true)
);

CREATE POLICY "Users can manage own products." 
ON public.products FOR ALL USING (
  EXISTS (SELECT 1 FROM public.shops WHERE id = shop_id AND user_id = auth.uid())
);

-- 5. Invitations
ALTER TABLE public.invitations ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public invitations are viewable if active." 
ON public.invitations FOR SELECT USING (is_active = true);

CREATE POLICY "Users can manage own invitations." 
ON public.invitations FOR ALL USING (auth.uid() = user_id);


-- ==========================================
-- OPTIMIZATIONS (INDICES)
-- ==========================================

-- Indices on Foreign Keys for better JOIN performance
CREATE INDEX IF NOT EXISTS idx_portfolios_user_id ON public.portfolios(user_id);
CREATE INDEX IF NOT EXISTS idx_cvs_user_id ON public.cvs(user_id);
CREATE INDEX IF NOT EXISTS idx_shops_user_id ON public.shops(user_id);
CREATE INDEX IF NOT EXISTS idx_invitations_user_id ON public.invitations(user_id);
CREATE INDEX IF NOT EXISTS idx_menus_user_id ON public.menus(user_id);

CREATE INDEX IF NOT EXISTS idx_portfolio_items_portfolio_id ON public.portfolio_items(portfolio_id);
CREATE INDEX IF NOT EXISTS idx_products_shop_id ON public.products(shop_id);
CREATE INDEX IF NOT EXISTS idx_dishes_menu_id ON public.dishes(menu_id);
CREATE INDEX IF NOT EXISTS idx_dishes_category_id ON public.dishes(category_id);
CREATE INDEX IF NOT EXISTS idx_menu_categories_menu_id ON public.menu_categories(menu_id);

-- Indices on Slugs for faster lookups (UNIQUE constraints create indices, but good to be explicit for understanding)
-- Note: 'slug' columns are already marked UNIQUE in table definitions which creates an index implicitly.
-- Adding partial indices or composite indices if needed, but standard UNIQUE is usually sufficient for single row lookups.

-- ==========================================
-- SUBSCRIPTION SYSTEM
-- ==========================================

-- Plans Table
CREATE TABLE IF NOT EXISTS public.plans (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name text NOT NULL, -- e.g. "Free", "Pro", "Enterprise"
  description text,
  price numeric NOT NULL DEFAULT 0,
  currency text DEFAULT 'USD',
  interval text DEFAULT 'month', -- 'month', 'year', 'lifetime'
  features jsonb DEFAULT '{}'::jsonb, -- Store list of features enabled
  is_active boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT plans_pkey PRIMARY KEY (id)
);

-- Subscriptions Table
CREATE TABLE IF NOT EXISTS public.subscriptions (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  plan_id uuid NOT NULL REFERENCES public.plans(id),
  status text NOT NULL DEFAULT 'active', -- 'active', 'canceled', 'past_due', 'trialing'
  current_period_start timestamp with time zone DEFAULT now(),
  current_period_end timestamp with time zone,
  cancel_at_period_end boolean DEFAULT false,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT subscriptions_pkey PRIMARY KEY (id)
);

-- RLS for Subscriptions (Users can read their own, Admins/System manage them)
ALTER TABLE public.subscriptions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own subscription." 
ON public.subscriptions FOR SELECT USING (auth.uid() = user_id);

-- Plans are public read-only (so frontend can display pricing)
ALTER TABLE public.plans ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Plans are viewable by everyone." 
ON public.plans FOR SELECT USING (is_active = true);
