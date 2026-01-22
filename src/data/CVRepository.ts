import { supabase } from "../lib/supabase";
import type { CV } from "../domain/models/CV";

export class CVRepository {
    async getByUserId(userId: string): Promise<CV | null> {
        const { data, error } = await supabase
            .from("cvs")
            .select(`
                *,
                education:cv_education(*),
                experience:cv_experience(*),
                skills:cv_skills(*)
            `)
            .eq("user_id", userId)
            .eq("is_visible", true)
            .single();

        if (error) {
            if (error.code !== "PGRST116") {
                console.error(`Error fetching CV for user ${userId}:`, error.message);
            }
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
