import { Injectable } from '@nestjs/common';
import { PlanFeaturesRepository } from './plan-features.repository';
import { UserFeatureOverridesRepository } from './user-feature-overrides.repository';
import { UsersService } from '../users/users.service';
import { FeatureName } from './enums/feature-name.enum';
import { SubscriptionPlan } from './enums/subscription-plan.enum';

@Injectable()
export class FeaturesService {
    constructor(
        private planFeaturesRepository: PlanFeaturesRepository,
        private userOverridesRepository: UserFeatureOverridesRepository,
        private usersService: UsersService,
    ) { }

    /**
     * Core feature resolution logic
     * Priority: User Override > Plan Feature > Default (false)
     */
    async isFeatureEnabled(userId: string, featureName: FeatureName): Promise<boolean> {
        // 1. Check user-specific override first
        const userOverride = await this.userOverridesRepository.findByUserAndFeature(
            userId,
            featureName,
        );

        if (userOverride !== null) {
            return userOverride.enabled;
        }

        // 2. Check plan feature
        const user = await this.usersService.findById(userId);
        if (!user) {
            return false;
        }

        const planFeature = await this.planFeaturesRepository.findByPlanAndFeature(
            user.currentPlan as SubscriptionPlan,
            featureName,
        );

        if (planFeature !== null) {
            return planFeature.enabled;
        }

        // 3. Default to false
        return false;
    }

    /**
     * Get all enabled features for a user
     */
    async getUserFeatures(userId: string): Promise<Record<string, boolean>> {
        const features: Record<string, boolean> = {};

        // Check all features
        for (const featureName of Object.values(FeatureName)) {
            features[featureName] = await this.isFeatureEnabled(userId, featureName as FeatureName);
        }

        return features;
    }

    /**
     * Admin: Toggle feature for a plan
     */
    async togglePlanFeature(
        plan: SubscriptionPlan,
        featureName: FeatureName,
        enabled: boolean,
    ): Promise<void> {
        // Check if feature exists
        const existing = await this.planFeaturesRepository.findByPlanAndFeature(
            plan,
            featureName,
        );

        if (existing) {
            await this.planFeaturesRepository.update(plan, featureName, enabled);
        } else {
            await this.planFeaturesRepository.create({
                plan,
                featureName,
                enabled,
            } as any);
        }
    }

    /**
     * Admin: Set user-specific feature override
     */
    async setUserFeatureOverride(
        userId: string,
        featureName: FeatureName,
        enabled: boolean,
        reason?: string,
        expiresAt?: string,
    ): Promise<void> {
        // Check if override exists
        const existing = await this.userOverridesRepository.findByUserAndFeature(
            userId,
            featureName,
        );

        if (existing) {
            await this.userOverridesRepository.update(
                userId,
                featureName,
                enabled,
                reason,
                expiresAt,
            );
        } else {
            await this.userOverridesRepository.create({
                userId,
                featureName,
                enabled,
                reason,
                expiresAt,
            } as any);
        }
    }

    /**
     * Admin: Remove user-specific feature override
     */
    async removeUserFeatureOverride(
        userId: string,
        featureName: FeatureName,
    ): Promise<void> {
        await this.userOverridesRepository.delete(userId, featureName);
    }

    /**
     * Get all features for a plan
     */
    async getPlanFeatures(plan: SubscriptionPlan): Promise<Record<string, boolean>> {
        const planFeatures = await this.planFeaturesRepository.findAllByPlan(plan);
        const features: Record<string, boolean> = {};

        for (const feature of planFeatures) {
            features[feature.feature] = feature.enabled;
        }

        return features;
    }
}
