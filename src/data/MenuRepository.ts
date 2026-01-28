import { supabase } from "../lib/supabase";
import type { Menu, MenuCategory } from "../domain/models/DigitalMenu";

export class MenuRepository {
    async getBySlug(slug: string): Promise<Menu | null> {
        const { data, error } = await supabase
            .from("menus")
            .select(`
                id, slug, name, description, user_id, is_active, template_id, logo_url, primary_color, font_family, created_at, updated_at,
                dishes(id, name, description, price, image_url, is_visible, category_id, sort_order),
                categories(id, name, sort_order,
                    dishes(id, name, description, price, image_url, is_visible, category_id, sort_order))
            `)
            .eq("slug", slug)
            .eq("is_active", true)
            .single();

        if (error) {
            // It's common to have no rows found if the slug doesn't exist
            if (error.code !== "PGRST116") {
                console.error(`Error fetching menu ${slug}:`, error.message);
            }
            return null;
        }

        const menu = data as Menu;
        this.sortMenuContent(menu);
        return menu;
    }

    async getByUserId(userId: string): Promise<Menu | null> {
        const { data, error } = await supabase
            .from("menus")
            .select(`
                id, slug, name, description, user_id, is_active, template_id, logo_url, primary_color, font_family, created_at, updated_at,
                dishes(id, name, description, price, image_url, is_visible, category_id, sort_order),
                categories(id, name, sort_order,
                    dishes(id, name, description, price, image_url, is_visible, category_id, sort_order))
            `)
            .eq("user_id", userId)
            .limit(1)
            .maybeSingle();

        if (error) {
            console.error(`Error fetching menu for user ${userId}:`, error.message);
            return null;
        }

        if (!data) return null;

        const menu = data as Menu;
        this.sortMenuContent(menu);
        return menu;
    }

    private sortMenuContent(menu: Menu) {
        if (menu.categories && menu.categories.length > 0) {
            menu.categories.sort((a, b) => a.sort_order - b.sort_order);

            menu.categories.forEach(cat => {
                if (cat.dishes) {
                    cat.dishes.sort((a, b) => a.sort_order - b.sort_order);
                }
            });
        }

        if (menu.dishes && menu.dishes.length > 0) {
            menu.dishes.sort((a, b) => a.sort_order - b.sort_order);
        }
    }
}
