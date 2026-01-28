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
            console.warn(`Error fetching profile for username ${username}:`, error.message);
            return null;
        }

        console.log("ProfileRepository.getByUsername: found profile", data.username);
        return data as Profile;
    }
}
