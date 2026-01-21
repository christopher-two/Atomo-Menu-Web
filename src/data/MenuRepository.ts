import { supabase } from "../lib/supabase";
import type { Menu } from "../domain/models/DigitalMenu";

export class MenuRepository {
    async getBySlug(slug: string): Promise<Menu | null> {
        const { data, error } = await supabase
            .from("menus")
            .select("*, dishes(*)")
            .eq("is_active", true)
            .eq("slug", slug)
            .single();

        if (error) {
            console.error("Error fetching menu:", error);
            return null;
        }

        return data as Menu;
    }

    async getByUserId(userId: string): Promise<Menu | null> {
        const { data, error } = await supabase
            .from("menus")
            .select("*, dishes(*)")
            .eq("user_id", userId)
            .eq("is_active", true)
            .limit(1)
            .single();

        if (error) {
            console.warn(`Error fetching active menu for user ${userId}:`, error.message);
            return null;
        }
        return data as Menu;
    }
}
