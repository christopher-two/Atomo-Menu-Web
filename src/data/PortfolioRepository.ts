import { supabase } from "../lib/supabase";
import type { Portfolio } from "../domain/models/Portfolio";

export class PortfolioRepository {
    async getBySlug(slug: string): Promise<Portfolio | null> {
        const { data, error } = await supabase
            .from("portfolios")
            .select(`
                id, slug, title, description, user_id, is_visible, template_id, primary_color, font_family, created_at, updated_at,
                items(id, title, description, image_url, project_url, sort_order)
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
        console.log("PortfolioRepository.getByUserId: querying for userId", userId);
        const { data, error } = await supabase
            .from("portfolios")
            .select(`
                id, slug, title, description, user_id, is_visible, template_id, primary_color, font_family, created_at, updated_at,
                items(id, title, description, image_url, project_url, sort_order)
            `)
            .eq("user_id", userId)
            .eq("is_visible", true)
            .limit(1)
            .maybeSingle();

        if (error) {
            console.error(`Error fetching portfolio for user ${userId}:`, error.message);
            return null;
        }

        if (!data) {
            console.log("PortfolioRepository.getByUserId: no data for user", userId);
            return null;
        }

        const portfolio = data as Portfolio;
        if (portfolio && portfolio.items) {
            portfolio.items.sort((a, b) => a.sort_order - b.sort_order);
        }
        console.log("PortfolioRepository.getByUserId: found portfolio", portfolio.id);
        return portfolio;
    }
}
