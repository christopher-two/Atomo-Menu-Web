import { supabase } from "../lib/supabase";
import type { Profile } from "../domain/models/Profile";

export class ProfileRepository {
    async getByUsername(username: string): Promise<Profile | null> {
        const { data, error } = await supabase
            .from("profiles")
            .select("id, username, display_name, avatar_url, created_at, social_links")
            .eq("username", username)
            .single();

        if (error) {
            // Return null if profile not found or query fails.
            return null;
        }

        return data as Profile;
    }
}
