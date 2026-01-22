import { supabase } from "../lib/supabase";

export class AnalyticsService {
    /**
     * Increment view count for a resource securely via RPC.
     */
    async incrementViewCount(resourceId: string, resourceType: string): Promise<void> {
        const { error } = await supabase.rpc("increment_view_count", {
            req_resource_id: resourceId,
            req_resource_type: resourceType,
        });

        if (error) {
            console.error("Error incrementing view count:", error);
        }
    }

    /**
     * Get analytics summary for the dashboard.
     */
    async getMyAnalyticsSummary() {
        // The return type depends on what the RPC returns. 
        // Assuming it returns a list of rows with resource_id, views, etc.
        const { data, error } = await supabase.rpc("get_my_analytics_summary");

        if (error) {
            console.error("Error fetching analytics summary:", error);
            throw error;
        }

        return data;
    }
}
