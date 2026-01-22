import type { BaseEntity, Branding } from "./Shared";

export interface InvitationResponse extends BaseEntity {
    invitation_id: string;
    guest_name: string;
    status: string; // 'pending' | 'accepted' | 'declined'
    dietary_notes: string | null;
    plus_one: boolean;
}

export interface Invitation extends BaseEntity, Branding {
    user_id: string;
    event_name: string;
    event_date: string | null;
    location: string | null;
    description: string | null;
    slug: string;
    is_active: boolean;
    template_id: string;
    responses?: InvitationResponse[]; // Optional, mostly for dashboard
}
