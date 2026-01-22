import { supabase } from "../lib/supabase";
import type { Shop } from "../domain/models/Shop";

export class ShopRepository {
    async getBySlug(slug: string): Promise<Shop | null> {
        const { data, error } = await supabase
            .from("shops")
            .select(`
                *,
                categories:product_categories(
                    *,
                    products(*)
                )
            `)
            .eq("slug", slug)
            .eq("is_active", true)
            .single();

        if (error) {
            if (error.code !== "PGRST116") {
                console.error(`Error fetching shop ${slug}:`, error.message);
            }
            return null;
        }

        const shop = data as Shop;

        // Sort categories and products
        if (shop.categories) {
            shop.categories.sort((a, b) => a.sort_order - b.sort_order);
            shop.categories.forEach(cat => {
                if (cat.products) {
                    // Products don't have sort_order in schema? 
                }
            });
        }
        return shop;
    }

    async getByUserId(userId: string): Promise<Shop | null> {
        const { data, error } = await supabase
            .from("shops")
            .select(`
                *,
                categories:product_categories(
                    *,
                    products(*)
                )
            `)
            .eq("user_id", userId)
            .eq("is_active", true)
            .limit(1)
            .maybeSingle();

        if (error) {
            console.error(`Error fetching shop for user ${userId}:`, error.message);
            return null;
        }

        if (!data) return null;

        const shop = data as Shop;

        if (shop && shop.categories) {
            shop.categories.sort((a, b) => a.sort_order - b.sort_order);
        }
        return shop;
    }
}
