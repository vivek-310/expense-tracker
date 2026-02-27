import { Injectable } from '@nestjs/common';
import { FeaturesService } from '../features/features.service';
import { SubscriptionsService } from '../subscriptions/subscriptions.service';
import { UsersService } from '../users/users.service';
import { SubscriptionPlan } from '../features/enums/subscription-plan.enum';
import { FeatureName } from '../features/enums/feature-name.enum';
import { UserStatus } from '../common/enums/user.enum';

@Injectable()
export class AdminService {
    constructor(
        private featuresService: FeaturesService,
        private subscriptionsService: SubscriptionsService,
        private usersService: UsersService,
    ) { }

    async togglePlanFeature(
        plan: SubscriptionPlan,
        feature: FeatureName,
        enabled: boolean,
    ) {
        await this.featuresService.togglePlanFeature(plan, feature, enabled);
        return {
            message: `Feature ${feature} ${enabled ? 'enabled' : 'disabled'} for plan ${plan}`,
        };
    }

    async toggleUserFeature(
        userId: string,
        feature: FeatureName,
        enabled: boolean,
        reason?: string,
        expiresAt?: string,
    ) {
        await this.featuresService.setUserFeatureOverride(
            userId,
            feature,
            enabled,
            reason,
            expiresAt,
        );
        return {
            message: `Feature override created for user ${userId}`,
        };
    }

    async removeUserFeatureOverride(userId: string, feature: FeatureName) {
        await this.featuresService.removeUserFeatureOverride(userId, feature);
        return {
            message: `Feature override removed for user ${userId}`,
        };
    }

    async activateUserSubscription(
        userId: string,
        plan: SubscriptionPlan,
        months: number,
    ) {
        if (plan === SubscriptionPlan.PRO) {
            await this.subscriptionsService.activateProSubscription(userId, months);
        } else {
            await this.subscriptionsService.downgradeToFree(userId);
        }

        return {
            message: `Subscription activated for user ${userId}`,
        };
    }

    async updateUserStatus(userId: string, status: UserStatus) {
        await this.usersService.updateStatus(userId, status);
        return {
            message: `User status updated to ${status}`,
        };
    }

    async getPlanFeatures(plan: SubscriptionPlan) {
        const features = await this.featuresService.getPlanFeatures(plan);
        return { plan, features };
    }

    async getAllUsersWithExpenses() {
        // Here we need to call UsersRepository method which we need to make sure is available.
        // The repository was injected via UsersService, but let's see if UsersService has the method.
        // Actually, UsersService is injected, not UsersRepository.
        return this.usersService.findAllWithExpenses();
    }
}
