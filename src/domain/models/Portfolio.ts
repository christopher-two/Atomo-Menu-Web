export interface Portfolio {
    id: string;
    user_id: string;
    title: string;
    description: string;
    is_visible: boolean;
    slug: string;
    template_id: string;
    items?: PortfolioItem[];
}

export interface PortfolioItem {
    id: string;
    portfolio_id: string;
    title: string;
    description: string;
    image_url: string;
    project_url: string;
    sort_order: number;
}
