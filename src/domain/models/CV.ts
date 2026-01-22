import type { BaseEntity, Branding } from "./Shared";

export interface CVEducation extends BaseEntity {
    cv_id: string;
    degree: string;
    institution: string;
    start_date: string | null;
    end_date: string | null;
    is_current: boolean;
    description: string | null;
    sort_order: number;
}

export interface CVExperience extends BaseEntity {
    cv_id: string;
    role: string;
    company: string;
    start_date: string | null;
    end_date: string | null;
    is_current: boolean;
    description: string | null;
    sort_order: number;
}

export interface CVSkill extends BaseEntity {
    cv_id: string;
    name: string;
    proficiency: string | null;
    sort_order: number;
}

export interface CV extends BaseEntity, Branding {
    user_id: string;
    title: string;
    professional_summary: string | null;
    is_visible: boolean;
    template_id: string;
    education: CVEducation[];
    experience: CVExperience[];
    skills: CVSkill[];
}
