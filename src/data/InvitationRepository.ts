import { supabase } from "../lib/supabase";

export interface Invitation {
    id: string;
    user_id: string;
    event_name: string;
    event_date: string;
    location: string;
    description: string;
    slug: string;
    is_active: boolean;
    template_id: string;
}

export class InvitationRepository {
    async getBySlugAndUser(slug: string, userId: string): Promise<Invitation | null> {
        const { data, error } = await supabase
            .from("invitations")
            .select("*")
            .eq("slug", slug)
            .eq("user_id", userId)
            .eq("is_active", true)
            .single();

        if (error) {
            console.warn(`Error fetching invitation ${slug} for user ${userId}:`, error.message);
            return null;
        }
        return data as Invitation;
    }
}
