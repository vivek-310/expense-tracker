import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { SubscriptionPlan } from '../features/enums/subscription-plan.enum';
import { v4 as uuidv4 } from 'uuid';

export interface Subscription {
    subscriptionId: string;
    userId: string;
    plan: SubscriptionPlan;
    startDate: string;
    endDate?: string;
    status: string;
    autoRenew: boolean;
    createdAt: string;
    updatedAt: string;
}

@Injectable()
export class SubscriptionsRepository {
    constructor(private prisma: PrismaService) { }

    async create(subscription: Omit<Subscription, 'subscriptionId' | 'createdAt' | 'updatedAt'>): Promise<Subscription> {
        const subscriptionId = uuidv4();

        const created = await this.prisma.subscription.create({
            data: {
                subscriptionId,
                userId: subscription.userId,
                plan: subscription.plan,
                startDate: new Date(subscription.startDate),
                endDate: subscription.endDate ? new Date(subscription.endDate) : null,
                status: subscription.status,
                autoRenew: subscription.autoRenew,
            },
        });

        return {
            subscriptionId: created.subscriptionId,
            userId: created.userId,
            plan: created.plan as SubscriptionPlan,
            startDate: created.startDate.toISOString(),
            endDate: created.endDate?.toISOString(),
            status: created.status,
            autoRenew: created.autoRenew,
            createdAt: created.createdAt.toISOString(),
            updatedAt: created.updatedAt.toISOString(),
        };
    }

    async findByUserId(userId: string): Promise<Subscription | null> {
        const subscription = await this.prisma.subscription.findFirst({
            where: { userId },
            orderBy: { createdAt: 'desc' },
        });

        if (!subscription) return null;

        return {
            subscriptionId: subscription.subscriptionId,
            userId: subscription.userId,
            plan: subscription.plan as SubscriptionPlan,
            startDate: subscription.startDate.toISOString(),
            endDate: subscription.endDate?.toISOString(),
            status: subscription.status,
            autoRenew: subscription.autoRenew,
            createdAt: subscription.createdAt.toISOString(),
            updatedAt: subscription.updatedAt.toISOString(),
        };
    }

    async update(
        userId: string,
        updates: Partial<Omit<Subscription, 'subscriptionId' | 'userId' | 'createdAt' | 'updatedAt'>>,
    ): Promise<Subscription> {
        // Find the latest subscription for this user
        const existing = await this.findByUserId(userId);
        if (!existing) {
            throw new Error('Subscription not found');
        }

        const dataToUpdate: any = {};
        if (updates.plan) dataToUpdate.plan = updates.plan;
        if (updates.startDate) dataToUpdate.startDate = new Date(updates.startDate);
        if (updates.endDate !== undefined) dataToUpdate.endDate = updates.endDate ? new Date(updates.endDate) : null;
        if (updates.status) dataToUpdate.status = updates.status;
        if (updates.autoRenew !== undefined) dataToUpdate.autoRenew = updates.autoRenew;

        const updated = await this.prisma.subscription.update({
            where: { subscriptionId: existing.subscriptionId },
            data: dataToUpdate,
        });

        return {
            subscriptionId: updated.subscriptionId,
            userId: updated.userId,
            plan: updated.plan as SubscriptionPlan,
            startDate: updated.startDate.toISOString(),
            endDate: updated.endDate?.toISOString(),
            status: updated.status,
            autoRenew: updated.autoRenew,
            createdAt: updated.createdAt.toISOString(),
            updatedAt: updated.updatedAt.toISOString(),
        };
    }
}
