import { supabase } from "../lib/supabase";

export interface Profile {
    id: string; // matches auth.users(id)
    username: string;
    display_name: string;
    avatar_url?: string;
}

export class ProfileRepository {
    async getByUsername(username: string): Promise<Profile | null> {
        const { data, error } = await supabase
            .from("profiles")
            .select("*")
            .eq("username", username)
            .single();

        if (error) {
            console.warn(`Error fetching profile for username ${username}:`, error.message);
            return null;
        }

        return data as Profile;
    }
}
