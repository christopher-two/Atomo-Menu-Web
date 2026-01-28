import { supabase } from "../lib/supabase";
import type { Portfolio } from "../domain/models/Portfolio";

export class PortfolioRepository {
    async getBySlug(slug: string): Promise<Portfolio | null> {
        const { data, error } = await supabase
            .from("portfolios")
            .select(`
                id, title, description, user_id, is_visible, template_id, primary_color, font_family, created_at,
                items:portfolio_items(id, title, description, image_url, project_url, sort_order)
            `)
            .eq("slug", slug)
            .eq("is_visible", true)
            .single();

        if (error) {
            if (error.code !== "PGRST116") {
                console.error(`Error fetching portfolio ${slug}:`, error.message);
            }
            return null;
        }

        const portfolio = data as Portfolio;
        if (portfolio.items) {
            portfolio.items.sort((a, b) => a.sort_order - b.sort_order);
        }
        return portfolio;
    }

    async getByUserId(userId: string): Promise<Portfolio | null> {
        // Query portfolio for the given user. Keep logging minimal.
        const { data, error } = await supabase
            .from("portfolios")
            .select(`
                id, title, description, user_id, is_visible, template_id, primary_color, font_family, created_at,
                items:portfolio_items(id, title, description, image_url, project_url, sort_order)
            `)
            .eq("user_id", userId)
            .eq("is_visible", true)
            .limit(1)
            .maybeSingle();

        if (error) {
            // If table schema doesn't match, log a concise error.
            console.error(`Error fetching portfolio for user ${userId}: ${error.message}`);
            return null;
        }

        if (!data) {
            return null;
        }

        const portfolio = data as Portfolio;
        if (portfolio && portfolio.items) {
            portfolio.items.sort((a, b) => a.sort_order - b.sort_order);
        }
        return portfolio;
        return portfolio;
    }
}
