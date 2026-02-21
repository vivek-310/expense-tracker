import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { SubscriptionsRepository, Subscription } from './subscriptions.repository';
import { UsersService } from '../users/users.service';
import { SubscriptionPlan } from '../features/enums/subscription-plan.enum';

@Injectable()
export class SubscriptionsService {
    constructor(
        private subscriptionsRepository: SubscriptionsRepository,
        private usersService: UsersService,
    ) { }

    async createFreeSubscription(userId: string): Promise<Subscription> {
        const now = new Date().toISOString();

        const subscription = await this.subscriptionsRepository.create({
            userId,
            plan: SubscriptionPlan.FREE,
            startDate: now,
            endDate: null,
            status: 'ACTIVE',
            autoRenew: false,
        });

        return subscription;
    }

    async activateProSubscription(
        userId: string,
        months: number = 1,
    ): Promise<Subscription> {
        const now = new Date();
        const endDate = new Date(now);
        endDate.setMonth(endDate.getMonth() + months);

        const subscription = await this.subscriptionsRepository.update(userId, {
            plan: SubscriptionPlan.PRO,
            startDate: now.toISOString(),
            endDate: endDate.toISOString(),
            status: 'ACTIVE',
            autoRenew: false,
        });

        // Update user's current plan
        await this.usersService.updatePlan(userId, SubscriptionPlan.PRO);

        return subscription;
    }

    async getSubscription(userId: string): Promise<Subscription> {
        const subscription = await this.subscriptionsRepository.findByUserId(userId);
        if (!subscription) {
            throw new NotFoundException('Subscription not found');
        }

        // Check if subscription has expired
        if (subscription.endDate && new Date(subscription.endDate) < new Date()) {
            // Downgrade to FREE if expired
            await this.downgradeToFree(userId);
            return this.subscriptionsRepository.findByUserId(userId);
        }

        return subscription;
    }

    async downgradeToFree(userId: string): Promise<Subscription> {
        const subscription = await this.subscriptionsRepository.update(userId, {
            plan: SubscriptionPlan.FREE,
            endDate: null,
            status: 'ACTIVE',
        });

        // Update user's current plan
        await this.usersService.updatePlan(userId, SubscriptionPlan.FREE);

        return subscription;
    }

    async cancelSubscription(userId: string): Promise<Subscription> {
        return this.subscriptionsRepository.update(userId, {
            status: 'CANCELLED',
            autoRenew: false,
        });
    }

    async isSubscriptionActive(userId: string): Promise<boolean> {
        const subscription = await this.getSubscription(userId);
        return subscription.status === 'ACTIVE';
    }
}
