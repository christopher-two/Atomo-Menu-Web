-- ==============================================================================
-- UNIFIED FINAL SCHEMA SCRIPT
-- ==============================================================================
-- Implements:
-- 1. RSVP Module (invitation_responses)
-- 2. Branding (primary_color, font_family)
-- 3. Social Profile (social_links)
-- 4. Subscription Integrity (Unique User, Triggers)
-- 5. Performance (Full Indexing)
-- 6. Security (Comprehensive RLS)

-- Enable extensions
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ==========================================
-- 0. UTILS
-- ==========================================

-- Function to handle timestamp updates
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ==========================================
-- 1. PROFILES & USERS
-- ==========================================

CREATE TABLE IF NOT EXISTS public.profiles (
  id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  username text NOT NULL UNIQUE,
  display_name text,
  avatar_url text,
  social_links jsonb DEFAULT '{}'::jsonb, -- NEW: Social Profile
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT profiles_pkey PRIMARY KEY (id)
);

-- Trigger for profiles
DROP TRIGGER IF EXISTS handle_profiles_updated_at ON public.profiles;
CREATE TRIGGER handle_profiles_updated_at BEFORE UPDATE ON public.profiles FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- ==========================================
-- 2. MODULE: PORTFOLIOS
-- ==========================================

CREATE TABLE IF NOT EXISTS public.portfolios (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  title text NOT NULL,
  description text,
  is_visible boolean DEFAULT true,
  slug text UNIQUE,
  template_id text DEFAULT 'minimalist',
  -- Branding Consistency
  primary_color text DEFAULT '#000000',
  font_family text DEFAULT 'Inter',
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT portfolios_pkey PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS public.portfolio_items (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  portfolio_id uuid NOT NULL REFERENCES public.portfolios(id) ON DELETE CASCADE,
  title text NOT NULL,
  description text,
  image_url text,
  project_url text,
  sort_order integer DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT portfolio_items_pkey PRIMARY KEY (id)
);

-- ==========================================
-- 3. MODULE: CVs
-- ==========================================

CREATE TABLE IF NOT EXISTS public.cvs (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  title text NOT NULL,
  professional_summary text,
  is_visible boolean DEFAULT true,
  template_id text DEFAULT 'standard',
  -- Branding Consistency
  primary_color text DEFAULT '#000000',
  font_family text DEFAULT 'Inter',
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT cvs_pkey PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS public.cv_experience (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  cv_id uuid NOT NULL REFERENCES public.cvs(id) ON DELETE CASCADE,
  role text NOT NULL,
  company text NOT NULL,
  start_date date,
  end_date date,
  is_current boolean DEFAULT false,
  description text,
  sort_order integer DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT cv_experience_pkey PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS public.cv_education (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  cv_id uuid NOT NULL REFERENCES public.cvs(id) ON DELETE CASCADE,
  degree text NOT NULL,
  institution text NOT NULL,
  start_date date,
  end_date date,
  is_current boolean DEFAULT false,
  description text,
  sort_order integer DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT cv_education_pkey PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS public.cv_skills (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  cv_id uuid NOT NULL REFERENCES public.cvs(id) ON DELETE CASCADE,
  name text NOT NULL,
  proficiency text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT cv_skills_pkey PRIMARY KEY (id)
);

-- ==========================================
-- 4. MODULE: SHOPS
-- ==========================================

CREATE TABLE IF NOT EXISTS public.shops (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name text NOT NULL,
  description text,
  is_active boolean DEFAULT true,
  slug text UNIQUE,
  -- Branding Consistency
  primary_color text DEFAULT '#000000',
  font_family text DEFAULT 'Inter',
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT shops_pkey PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS public.product_categories (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  shop_id uuid NOT NULL REFERENCES public.shops(id) ON DELETE CASCADE,
  name text NOT NULL,
  sort_order integer DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT product_categories_pkey PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS public.products (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  shop_id uuid NOT NULL REFERENCES public.shops(id) ON DELETE CASCADE,
  category_id uuid REFERENCES public.product_categories(id) ON DELETE SET NULL,
  name text NOT NULL,
  description text,
  price numeric NOT NULL,
  image_url text,
  is_available boolean DEFAULT true,
  stock integer DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT products_pkey PRIMARY KEY (id)
);

-- ==========================================
-- 5. MODULE: INVITATIONS
-- ==========================================

CREATE TABLE IF NOT EXISTS public.invitations (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  event_name text NOT NULL,
  event_date timestamp with time zone,
  location text,
  description text,
  slug text UNIQUE,
  is_active boolean DEFAULT true,
  template_id text DEFAULT 'elegant',
  -- Branding Consistency
  primary_color text DEFAULT '#000000',
  font_family text DEFAULT 'Inter',
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT invitations_pkey PRIMARY KEY (id)
);

-- NEW: RSVP / Invitation Responses
CREATE TABLE IF NOT EXISTS public.invitation_responses (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  invitation_id uuid NOT NULL REFERENCES public.invitations(id) ON DELETE CASCADE,
  guest_name text NOT NULL,
  status text NOT NULL DEFAULT 'pending', -- pending, accepted, declined
  dietary_notes text,
  plus_one boolean DEFAULT false,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT invitation_responses_pkey PRIMARY KEY (id)
);

-- ==========================================
-- 6. MODULE: MENUS
-- ==========================================

CREATE TABLE IF NOT EXISTS public.menus (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name text NOT NULL,
  description text,
  is_active boolean DEFAULT true,
  slug text UNIQUE,
  template_id text DEFAULT 'minimalist',
  primary_color text DEFAULT '#000000',
  font_family text DEFAULT 'Inter',
  logo_url text,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT menus_pkey PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS public.menu_categories (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  menu_id uuid NOT NULL REFERENCES public.menus(id) ON DELETE CASCADE,
  name text NOT NULL,
  sort_order integer DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT menu_categories_pkey PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS public.dishes (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  menu_id uuid NOT NULL REFERENCES public.menus(id) ON DELETE CASCADE,
  category_id uuid REFERENCES public.menu_categories(id) ON DELETE SET NULL,
  name text NOT NULL,
  description text,
  price numeric NOT NULL,
  image_url text,
  is_visible boolean DEFAULT true,
  sort_order integer DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT dishes_pkey PRIMARY KEY (id)
);

-- ==========================================
-- 7. MODULE: SUBSCRIPTIONS
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
  user_id uuid NOT NULL UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE, -- Integrity: UNIQUE user_id
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
DROP TRIGGER IF EXISTS handle_subscriptions_updated_at ON public.subscriptions;
CREATE TRIGGER handle_subscriptions_updated_at BEFORE UPDATE ON public.subscriptions FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();


-- ==========================================
-- 8. PERFORMANCE: INDEXES
-- ==========================================
-- Explicit INDEX creation for all Foreign Keys and Slugs

-- Users & Profiles
-- (profiles.id is PK, indexed)

-- Portfolios
CREATE INDEX IF NOT EXISTS idx_portfolios_user_id ON public.portfolios(user_id);
CREATE INDEX IF NOT EXISTS idx_portfolios_slug ON public.portfolios(slug);
CREATE INDEX IF NOT EXISTS idx_portfolio_items_portfolio_id ON public.portfolio_items(portfolio_id);

-- CVs
CREATE INDEX IF NOT EXISTS idx_cvs_user_id ON public.cvs(user_id);
CREATE INDEX IF NOT EXISTS idx_cv_experience_cv_id ON public.cv_experience(cv_id);
CREATE INDEX IF NOT EXISTS idx_cv_education_cv_id ON public.cv_education(cv_id);
CREATE INDEX IF NOT EXISTS idx_cv_skills_cv_id ON public.cv_skills(cv_id);

-- Shops
CREATE INDEX IF NOT EXISTS idx_shops_user_id ON public.shops(user_id);
CREATE INDEX IF NOT EXISTS idx_shops_slug ON public.shops(slug);
CREATE INDEX IF NOT EXISTS idx_product_categories_shop_id ON public.product_categories(shop_id);
CREATE INDEX IF NOT EXISTS idx_products_shop_id ON public.products(shop_id);
CREATE INDEX IF NOT EXISTS idx_products_category_id ON public.products(category_id);

-- Invitations
CREATE INDEX IF NOT EXISTS idx_invitations_user_id ON public.invitations(user_id);
CREATE INDEX IF NOT EXISTS idx_invitations_slug ON public.invitations(slug);
-- NEW: Invitation Responses Index
CREATE INDEX IF NOT EXISTS idx_invitation_responses_invitation_id ON public.invitation_responses(invitation_id);

-- Menus
CREATE INDEX IF NOT EXISTS idx_menus_user_id ON public.menus(user_id);
CREATE INDEX IF NOT EXISTS idx_menus_slug ON public.menus(slug);
CREATE INDEX IF NOT EXISTS idx_menu_categories_menu_id ON public.menu_categories(menu_id);
CREATE INDEX IF NOT EXISTS idx_dishes_menu_id ON public.dishes(menu_id);
CREATE INDEX IF NOT EXISTS idx_dishes_category_id ON public.dishes(category_id);

-- Subscriptions
CREATE INDEX IF NOT EXISTS idx_subscriptions_user_id ON public.subscriptions(user_id);
CREATE INDEX IF NOT EXISTS idx_subscriptions_plan_id ON public.subscriptions(plan_id);


-- ==========================================
-- 9. SECURITY: RLS POLICIES
-- ==========================================

-- HELPER: Ensure RLS is enabled on all tables
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.portfolios ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.portfolio_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cvs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cv_experience ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cv_education ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cv_skills ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.shops ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.product_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.invitations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.invitation_responses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.menus ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.menu_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.dishes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subscriptions ENABLE ROW LEVEL SECURITY;

-- --------------------------------------------------------
-- PROFILES
-- --------------------------------------------------------
DROP POLICY IF EXISTS "Public profiles" ON public.profiles;
CREATE POLICY "Public profiles" ON public.profiles FOR SELECT USING (true);

DROP POLICY IF EXISTS "Owner manage profile" ON public.profiles;
CREATE POLICY "Owner manage profile" ON public.profiles FOR ALL USING (auth.uid() = id);

-- --------------------------------------------------------
-- PORTFOLIOS
-- --------------------------------------------------------
DROP POLICY IF EXISTS "Public portfolios" ON public.portfolios;
CREATE POLICY "Public portfolios" ON public.portfolios FOR SELECT USING (is_visible = true);

DROP POLICY IF EXISTS "Owner manage portfolios" ON public.portfolios;
CREATE POLICY "Owner manage portfolios" ON public.portfolios FOR ALL USING (auth.uid() = user_id);

-- Portfolio Items
DROP POLICY IF EXISTS "Public portfolio items" ON public.portfolio_items;
CREATE POLICY "Public portfolio items" ON public.portfolio_items FOR SELECT USING (
  EXISTS (SELECT 1 FROM public.portfolios WHERE id = portfolio_id AND is_visible = true)
);

DROP POLICY IF EXISTS "Owner manage portfolio items" ON public.portfolio_items;
CREATE POLICY "Owner manage portfolio items" ON public.portfolio_items FOR ALL USING (
  EXISTS (SELECT 1 FROM public.portfolios WHERE id = portfolio_id AND user_id = auth.uid())
);

-- --------------------------------------------------------
-- CVs
-- --------------------------------------------------------
DROP POLICY IF EXISTS "Public cvs" ON public.cvs;
CREATE POLICY "Public cvs" ON public.cvs FOR SELECT USING (is_visible = true);

DROP POLICY IF EXISTS "Owner manage cvs" ON public.cvs;
CREATE POLICY "Owner manage cvs" ON public.cvs FOR ALL USING (auth.uid() = user_id);

-- CV Children (Experience, Education, Skills)
DROP POLICY IF EXISTS "Public cv_experience" ON public.cv_experience;
CREATE POLICY "Public cv_experience" ON public.cv_experience FOR SELECT USING (
  EXISTS (SELECT 1 FROM public.cvs WHERE id = cv_id AND is_visible = true)
);
DROP POLICY IF EXISTS "Owner manage cv_experience" ON public.cv_experience;
CREATE POLICY "Owner manage cv_experience" ON public.cv_experience FOR ALL USING (
  EXISTS (SELECT 1 FROM public.cvs WHERE id = cv_id AND user_id = auth.uid())
);

DROP POLICY IF EXISTS "Public cv_education" ON public.cv_education;
CREATE POLICY "Public cv_education" ON public.cv_education FOR SELECT USING (
  EXISTS (SELECT 1 FROM public.cvs WHERE id = cv_id AND is_visible = true)
);
DROP POLICY IF EXISTS "Owner manage cv_education" ON public.cv_education;
CREATE POLICY "Owner manage cv_education" ON public.cv_education FOR ALL USING (
  EXISTS (SELECT 1 FROM public.cvs WHERE id = cv_id AND user_id = auth.uid())
);

DROP POLICY IF EXISTS "Public cv_skills" ON public.cv_skills;
CREATE POLICY "Public cv_skills" ON public.cv_skills FOR SELECT USING (
  EXISTS (SELECT 1 FROM public.cvs WHERE id = cv_id AND is_visible = true)
);
DROP POLICY IF EXISTS "Owner manage cv_skills" ON public.cv_skills;
CREATE POLICY "Owner manage cv_skills" ON public.cv_skills FOR ALL USING (
  EXISTS (SELECT 1 FROM public.cvs WHERE id = cv_id AND user_id = auth.uid())
);

-- --------------------------------------------------------
-- SHOPS
-- --------------------------------------------------------
DROP POLICY IF EXISTS "Public shops" ON public.shops;
CREATE POLICY "Public shops" ON public.shops FOR SELECT USING (is_active = true);

DROP POLICY IF EXISTS "Owner manage shops" ON public.shops;
CREATE POLICY "Owner manage shops" ON public.shops FOR ALL USING (auth.uid() = user_id);

-- Shop Children
DROP POLICY IF EXISTS "Public product categories" ON public.product_categories;
CREATE POLICY "Public product categories" ON public.product_categories FOR SELECT USING (
  EXISTS (SELECT 1 FROM public.shops WHERE id = shop_id AND is_active = true)
);
DROP POLICY IF EXISTS "Owner manage product categories" ON public.product_categories;
CREATE POLICY "Owner manage product categories" ON public.product_categories FOR ALL USING (
  EXISTS (SELECT 1 FROM public.shops WHERE id = shop_id AND user_id = auth.uid())
);

DROP POLICY IF EXISTS "Public products" ON public.products;
CREATE POLICY "Public products" ON public.products FOR SELECT USING (
  is_available = true AND
  EXISTS (SELECT 1 FROM public.shops WHERE id = shop_id AND is_active = true)
);
DROP POLICY IF EXISTS "Owner manage products" ON public.products;
CREATE POLICY "Owner manage products" ON public.products FOR ALL USING (
  EXISTS (SELECT 1 FROM public.shops WHERE id = shop_id AND user_id = auth.uid())
);

-- --------------------------------------------------------
-- INVITATIONS
-- --------------------------------------------------------
DROP POLICY IF EXISTS "Public invitations" ON public.invitations;
CREATE POLICY "Public invitations" ON public.invitations FOR SELECT USING (is_active = true);

DROP POLICY IF EXISTS "Owner manage invitations" ON public.invitations;
CREATE POLICY "Owner manage invitations" ON public.invitations FOR ALL USING (auth.uid() = user_id);

-- Invitation Responses using invitation_responses
DROP POLICY IF EXISTS "Public create response" ON public.invitation_responses;
CREATE POLICY "Public create response" ON public.invitation_responses FOR INSERT WITH CHECK (
  EXISTS (SELECT 1 FROM public.invitations WHERE id = invitation_id AND is_active = true)
);
-- Guests can read their own responses? Or public read? Usually public shouldn't see guest list.
-- Owner sees all responses.
DROP POLICY IF EXISTS "Owner manage responses" ON public.invitation_responses;
CREATE POLICY "Owner manage responses" ON public.invitation_responses FOR ALL USING (
  EXISTS (SELECT 1 FROM public.invitations WHERE id = invitation_id AND user_id = auth.uid())
);

-- --------------------------------------------------------
-- MENUS
-- --------------------------------------------------------
DROP POLICY IF EXISTS "Public menus" ON public.menus;
CREATE POLICY "Public menus" ON public.menus FOR SELECT USING (is_active = true);

DROP POLICY IF EXISTS "Owner manage menus" ON public.menus;
CREATE POLICY "Owner manage menus" ON public.menus FOR ALL USING (auth.uid() = user_id);

-- Menu Children
DROP POLICY IF EXISTS "Public menu categories" ON public.menu_categories;
CREATE POLICY "Public menu categories" ON public.menu_categories FOR SELECT USING (
  EXISTS (SELECT 1 FROM public.menus WHERE id = menu_id AND is_active = true)
);
DROP POLICY IF EXISTS "Owner manage menu categories" ON public.menu_categories;
CREATE POLICY "Owner manage menu categories" ON public.menu_categories FOR ALL USING (
  EXISTS (SELECT 1 FROM public.menus WHERE id = menu_id AND user_id = auth.uid())
);

DROP POLICY IF EXISTS "Public dishes" ON public.dishes;
CREATE POLICY "Public dishes" ON public.dishes FOR SELECT USING (
  is_visible = true AND
  EXISTS (SELECT 1 FROM public.menus WHERE id = menu_id AND is_active = true)
);
DROP POLICY IF EXISTS "Owner manage dishes" ON public.dishes;
CREATE POLICY "Owner manage dishes" ON public.dishes FOR ALL USING (
  EXISTS (SELECT 1 FROM public.menus WHERE id = menu_id AND user_id = auth.uid())
);

-- --------------------------------------------------------
-- SUBSCRIPTIONS
-- --------------------------------------------------------
DROP POLICY IF EXISTS "Owner view subscription" ON public.subscriptions;
CREATE POLICY "Owner view subscription" ON public.subscriptions FOR SELECT USING (auth.uid() = user_id);
-- No insert/update for user typically; handled by webhook/admin. But if user can self-manage:
-- For now restricting into read-only for user, as payments usually handled by service_role.

DROP POLICY IF EXISTS "Public view plans" ON public.plans;
CREATE POLICY "Public view plans" ON public.plans FOR SELECT USING (is_active = true);

