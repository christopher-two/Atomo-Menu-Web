import type { BaseEntity } from "./Shared";

export interface PlanFeatures {
    max_menus?: number;
    max_shops?: number;
    max_cvs?: number;
    max_portfolios?: number;
    max_invitations?: number;
    // Add other limits as needed
}

export interface Plan extends BaseEntity {
    name: string;
    description: string | null;
    price: number;
    currency: string;
    interval: string; // 'month' | 'year'
    features: PlanFeatures;
    is_active: boolean;
}

export interface Subscription extends BaseEntity {
    user_id: string;
    plan_id: string;
    status: string; // 'active' | 'canceled' | 'past_due'
    current_period_start: string;
    current_period_end: string | null;
    cancel_at_period_end: boolean;
    updated_at: string;
    plan?: Plan;
}
