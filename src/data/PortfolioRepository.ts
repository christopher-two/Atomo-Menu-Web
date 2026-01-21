import { supabase } from "../lib/supabase";
import type { Portfolio } from "../domain/models/Portfolio";

export class PortfolioRepository {
    async getByUserId(userId: string): Promise<Portfolio | null> {
        const { data, error } = await supabase
            .from("portfolios")
            .select("*, portfolio_items(*)")
            .eq("user_id", userId)
            .eq("is_visible", true)
            .single();

        if (error) {
            console.warn(`Error fetching portfolio for user ${userId}:`, error.message);
            return null;
        }

        return data as Portfolio;
    }

    async getBySlug(slug: string): Promise<Portfolio | null> {
        const { data, error } = await supabase
            .from("portfolios")
            .select("*, portfolio_items(*)")
            .eq("slug", slug)
            .eq("is_visible", true)
            .single();

        if (error) {
            console.warn(`Error fetching portfolio for slug ${slug}:`, error.message);
            return null;
        }
        return data as Portfolio;
    }
}
