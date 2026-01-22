export enum MenuTemplate {
    MINIMALIST = "minimalist",
    ELEGANCE = "elegance",
    MODERN = "modern",
    LUXURY = "luxury",
    CYBER = "cyber",
}

export interface Dish {
    id: string;
    name: string;
    description: string;
    price: number;
    image_url: string;
    is_visible: boolean;
    category_id?: string;
}

export interface MenuCategory {
    id: string;
    name: string;
    sort_order: number;
    dishes: Dish[];
}

export interface Menu {
    id: string;
    name: string;
    description: string;
    template_id: MenuTemplate | string;
    primary_color: string;
    font_family: string;
    logo_url?: string;
    categories: MenuCategory[];
    // Keep dishes for backward compatibility or uncategorized items if needed, 
    // but primarily we use categories now.
    dishes?: Dish[]; 
}
