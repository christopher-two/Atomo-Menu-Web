import { supabase } from "../lib/supabase";
import type { CV } from "../domain/models/CV";

export class CVRepository {
    async getByUserId(userId: string): Promise<CV | null> {
        console.log("CVRepository.getByUserId: querying for userId", userId);
        const { data, error } = await supabase
            .from("cvs")
            .select(`
                id, user_id, title, professional_summary, is_visible, template_id, primary_color, font_family, created_at,
                education:cv_education(id, institution, degree, start_date, end_date, is_current, description, sort_order),
                experience:cv_experience(id, role, company, start_date, end_date, is_current, description, sort_order),
                skills:cv_skills(id, name, proficiency)
            `)
            .eq("user_id", userId)
            .eq("is_visible", true)
            .single();

        if (error) {
            // If no CV found or another error occurs, return null.
            return null;
        }

        const cv = data as CV;
        this.sortCVContent(cv);
        return cv;
    }

    private sortCVContent(cv: CV) {
        if (cv.education) {
            cv.education.sort((a, b) => a.sort_order - b.sort_order);
        }
        if (cv.experience) {
            cv.experience.sort((a, b) => a.sort_order - b.sort_order);
        }
        if (cv.skills) {
            cv.skills.sort((a, b) => a.sort_order - b.sort_order);
        }
    }
}
