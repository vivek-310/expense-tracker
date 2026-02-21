import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { FeatureName } from './enums/feature-name.enum';

export interface UserFeatureOverride {
    userId: string;
    feature: FeatureName;
    enabled: boolean;
    reason?: string;
    expiresAt?: string;
    createdAt: string;
    updatedAt: string;
}

@Injectable()
export class UserFeatureOverridesRepository {
    constructor(private prisma: PrismaService) { }

    async create(override: Omit<UserFeatureOverride, 'createdAt' | 'updatedAt'>): Promise<UserFeatureOverride> {
        const created = await this.prisma.userFeatureOverride.create({
            data: {
                userId: override.userId,
                feature: override.feature,
                enabled: override.enabled,
                reason: override.reason,
            },
        });

        return {
            userId: created.userId,
            feature: created.feature as FeatureName,
            enabled: created.enabled,
            reason: created.reason || undefined,
            expiresAt: undefined,
            createdAt: created.createdAt.toISOString(),
            updatedAt: created.updatedAt.toISOString(),
        };
    }

    async findByUserAndFeature(
        userId: string,
        featureName: FeatureName,
    ): Promise<UserFeatureOverride | null> {
        const override = await this.prisma.userFeatureOverride.findUnique({
            where: {
                userId_feature: {
                    userId,
                    feature: featureName,
                },
            },
        });

        if (!override) return null;

        return {
            userId: override.userId,
            feature: override.feature as FeatureName,
            enabled: override.enabled,
            reason: override.reason || undefined,
            expiresAt: undefined,
            createdAt: override.createdAt.toISOString(),
            updatedAt: override.updatedAt.toISOString(),
        };
    }

    async findAllByUser(userId: string): Promise<UserFeatureOverride[]> {
        const overrides = await this.prisma.userFeatureOverride.findMany({
            where: { userId },
        });

        return overrides.map(o => ({
            userId: o.userId,
            feature: o.feature as FeatureName,
            enabled: o.enabled,
            reason: o.reason || undefined,
            expiresAt: undefined,
            createdAt: o.createdAt.toISOString(),
            updatedAt: o.updatedAt.toISOString(),
        }));
    }

    async update(
        userId: string,
        featureName: FeatureName,
        enabled: boolean,
        reason?: string,
        expiresAt?: string,
    ): Promise<UserFeatureOverride> {
        const updated = await this.prisma.userFeatureOverride.update({
            where: {
                userId_feature: {
                    userId,
                    feature: featureName,
                },
            },
            data: {
                enabled,
                reason,
            },
        });

        return {
            userId: updated.userId,
            feature: updated.feature as FeatureName,
            enabled: updated.enabled,
            reason: updated.reason || undefined,
            expiresAt,
            createdAt: updated.createdAt.toISOString(),
            updatedAt: updated.updatedAt.toISOString(),
        };
    }

    async delete(userId: string, featureName: FeatureName): Promise<void> {
        await this.prisma.userFeatureOverride.delete({
            where: {
                userId_feature: {
                    userId,
                    feature: featureName,
                },
            },
        });
    }
}
