import { supabase } from "../lib/supabase";
import type { Invitation } from "../domain/models/Invitation";

export class InvitationRepository {
    async getBySlug(slug: string): Promise<Invitation | null> {
        const { data, error } = await supabase
            .from("invitations")
            .select("id, slug, title, description, event_date, location, user_id, is_active, created_at, updated_at")
            .eq("slug", slug)
            .eq("is_active", true)
            .single();

        if (error) {
            if (error.code !== "PGRST116") {
                console.error(`Error fetching invitation ${slug}:`, error.message);
            }
            return null;
        }

        return data as Invitation;
    }

    async getBySlugAndUser(slug: string, userId: string): Promise<Invitation | null> {
        const { data, error } = await supabase
            .from("invitations")
            .select("id, slug, title, description, event_date, location, user_id, is_active, created_at, updated_at")
            .eq("slug", slug)
            .eq("user_id", userId)
            .eq("is_active", true)
            .single();

        if (error) {
            if (error.code !== "PGRST116") {
                console.error(`Error fetching invitation ${slug} for user ${userId}:`, error.message);
            }
            return null;
        }

        return data as Invitation;
    }
    async getByUserId(userId: string): Promise<Invitation | null> {
        const { data, error } = await supabase
            .from("invitations")
            .select("id, slug, title, description, event_date, location, user_id, is_active, created_at, updated_at")
            .eq("user_id", userId)
            .eq("is_active", true)
            .limit(1)
            .maybeSingle();

        if (error) {
            console.error(`Error fetching invitation for user ${userId}:`, error.message);
            return null;
        }

        return data as Invitation;
    }
}
