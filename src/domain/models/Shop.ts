import type { BaseEntity, Branding } from "./Shared";

export interface Product extends BaseEntity {
    shop_id: string;
    category_id: string | null;
    name: string;
    description: string | null;
    price: number;
    image_url: string | null;
    is_available: boolean;
    stock: number;
}

export interface ProductCategory extends BaseEntity {
    shop_id: string;
    name: string;
    sort_order: number;
    products: Product[];
}

export interface Shop extends BaseEntity, Branding {
    user_id: string;
    name: string;
    description: string | null;
    slug: string;
    is_active: boolean;
    categories: ProductCategory[];
}
