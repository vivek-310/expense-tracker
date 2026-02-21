import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { SubscriptionPlan } from './enums/subscription-plan.enum';
import { FeatureName } from './enums/feature-name.enum';

export interface PlanFeature {
    plan: SubscriptionPlan;
    feature: FeatureName;
    enabled: boolean;
    metadata?: any;
    updatedAt: string;
}

@Injectable()
export class PlanFeaturesRepository {
    constructor(private prisma: PrismaService) { }

    async create(planFeature: Omit<PlanFeature, 'updatedAt'>): Promise<PlanFeature> {
        const created = await this.prisma.planFeature.upsert({
            where: {
                plan_feature: {
                    plan: planFeature.plan,
                    feature: planFeature.feature,
                },
            },
            update: {
                enabled: planFeature.enabled,
            },
            create: {
                plan: planFeature.plan,
                feature: planFeature.feature,
                enabled: planFeature.enabled,
            },
        });

        return {
            plan: created.plan as SubscriptionPlan,
            feature: created.feature as FeatureName,
            enabled: created.enabled,
            metadata: undefined,
            updatedAt: created.updatedAt.toISOString(),
        };
    }

    async findByPlanAndFeature(
        plan: SubscriptionPlan,
        featureName: FeatureName,
    ): Promise<PlanFeature | null> {
        const feature = await this.prisma.planFeature.findUnique({
            where: {
                plan_feature: {
                    plan,
                    feature: featureName,
                },
            },
        });

        if (!feature) return null;

        return {
            plan: feature.plan as SubscriptionPlan,
            feature: feature.feature as FeatureName,
            enabled: feature.enabled,
            metadata: undefined,
            updatedAt: feature.updatedAt.toISOString(),
        };
    }

    async findAllByPlan(plan: SubscriptionPlan): Promise<PlanFeature[]> {
        const features = await this.prisma.planFeature.findMany({
            where: { plan },
        });

        return features.map(f => ({
            plan: f.plan as SubscriptionPlan,
            feature: f.feature as FeatureName,
            enabled: f.enabled,
            metadata: undefined,
            updatedAt: f.updatedAt.toISOString(),
        }));
    }

    async update(
        plan: SubscriptionPlan,
        featureName: FeatureName,
        enabled: boolean,
        metadata?: any,
    ): Promise<PlanFeature> {
        const updated = await this.prisma.planFeature.update({
            where: {
                plan_feature: {
                    plan,
                    feature: featureName,
                },
            },
            data: {
                enabled,
            },
        });

        return {
            plan: updated.plan as SubscriptionPlan,
            feature: updated.feature as FeatureName,
            enabled: updated.enabled,
            metadata,
            updatedAt: updated.updatedAt.toISOString(),
        };
    }
}
