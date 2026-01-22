export interface SocialLink {
    platform: string;
    url: string;
    icon?: string;
}

export interface Profile {
    id: string; // matches auth.users(id)
    username: string;
    display_name: string | null;
    avatar_url: string | null;
    created_at: string;
    social_links: SocialLink[] | null; // JSONB
}
