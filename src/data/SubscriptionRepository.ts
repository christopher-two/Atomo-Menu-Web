import { supabase } from "../lib/supabase";
import type { Subscription, Plan } from "../domain/models/Subscription";

export class SubscriptionRepository {
    async getUserSubscription(userId: string): Promise<Subscription | null> {
        const { data, error } = await supabase
            .from("subscriptions")
            .select(`
                *,
                plan:plans(*)
            `)
            .eq("user_id", userId)
            .single();

        if (error) {
            console.warn(`Error fetching subscription for user ${userId}:`, error.message);
            return null;
        }

        return data as Subscription;
    }

    async getPlans(): Promise<Plan[]> {
        const { data, error } = await supabase
            .from("plans")
            .select("*")
            .eq("is_active", true);

        if (error) {
            console.error("Error fetching plans:", error);
            return [];
        }

        return data as Plan[];
    }
}
