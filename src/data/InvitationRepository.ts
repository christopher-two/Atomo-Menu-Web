import { supabase } from "../lib/supabase";
import type { Invitation } from "../domain/models/Invitation";

export class InvitationRepository {
    async getBySlug(slug: string): Promise<Invitation | null> {
        const { data, error } = await supabase
            .from("invitations")
            .select("*")
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
            .select("*")
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
}
