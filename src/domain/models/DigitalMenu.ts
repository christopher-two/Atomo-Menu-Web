import type { BaseEntity, Branding } from "./Shared";

export enum MenuTemplate {
    MINIMALIST = "minimalist",
    ELEGANCE = "elegance",
    MODERN = "modern",
    LUXURY = "luxury",
    CYBER = "cyber",
}

export interface Dish extends BaseEntity {
    menu_id: string;
    name: string;
    description: string | null;
    price: number;
    image_url: string | null;
    is_visible: boolean;
    category_id: string | null;
    sort_order: number;
}

export interface MenuCategory extends BaseEntity {
    menu_id: string;
    name: string;
    sort_order: number;
    dishes: Dish[];
}

export interface Menu extends BaseEntity, Branding {
    user_id: string;
    name: string;
    description: string | null;
    slug: string;
    is_active: boolean;
    template_id: MenuTemplate;
    logo_url: string | null;
    categories: MenuCategory[];
    dishes?: Dish[]; // For uncategorized dishes
}
