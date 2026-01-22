import type { BaseEntity, Branding } from "./Shared";

export interface PortfolioItem extends BaseEntity {
    portfolio_id: string;
    title: string;
    description: string | null;
    image_url: string | null;
    project_url: string | null;
    sort_order: number;
}

export interface Portfolio extends BaseEntity, Branding {
    user_id: string;
    title: string;
    description: string | null;
    slug: string;
    is_visible: boolean;
    template_id: string;
    items: PortfolioItem[];
}
