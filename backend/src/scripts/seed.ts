/**
 * Seed Script - Initializes database with default data
 * 
 * This script creates:
 * 1. Default plan features (FREE and PRO)
 * 2. Admin user
 * 
 * Run: npm run seed
 */

import { ConfigModule, ConfigService } from '@nestjs/config';
import { NestFactory } from '@nestjs/core';
import { Module } from '@nestjs/common';
import { PrismaModule } from '../prisma/prisma.module';
import { UsersModule } from '../users/users.module';
import { SubscriptionsModule } from '../subscriptions/subscriptions.module';
import { FeaturesModule } from '../features/features.module';
import { UsersService } from '../users/users.service';
import { SubscriptionsService } from '../subscriptions/subscriptions.service';
import { PlanFeaturesRepository } from '../features/plan-features.repository';
import { SubscriptionPlan } from '../features/enums/subscription-plan.enum';
import { FeatureName } from '../features/enums/feature-name.enum';
import { UserRole } from '../common/enums/user.enum';

@Module({
    imports: [
        ConfigModule.forRoot({
            isGlobal: true,
            envFilePath: '.env',
        }),
        PrismaModule,
        UsersModule,
        SubscriptionsModule,
        FeaturesModule,
    ],
})
class SeedModule { }

async function seedPlanFeatures(planFeaturesRepo: PlanFeaturesRepository) {
    console.log('🌱 Seeding plan features...');

    // FREE plan features
    const freeFeatures = [
        { plan: SubscriptionPlan.FREE, feature: FeatureName.SPLIT, enabled: false },
        { plan: SubscriptionPlan.FREE, feature: FeatureName.EXPORT, enabled: false },
        { plan: SubscriptionPlan.FREE, feature: FeatureName.CLOUD_SYNC, enabled: false },
    ];

    // PRO plan features
    const proFeatures = [
        { plan: SubscriptionPlan.PRO, feature: FeatureName.SPLIT, enabled: true },
        { plan: SubscriptionPlan.PRO, feature: FeatureName.EXPORT, enabled: true },
        { plan: SubscriptionPlan.PRO, feature: FeatureName.CLOUD_SYNC, enabled: true },
    ];

    const allFeatures = [...freeFeatures, ...proFeatures];

    for (const { plan, feature, enabled } of allFeatures) {
        try {
            await planFeaturesRepo.create({
                plan,
                feature,
                enabled,
            });
            console.log(`   ✓ ${plan} - ${feature}: ${enabled}`);
        } catch (error) {
            console.log(`   ℹ ${plan} - ${feature} already exists`);
        }
    }
}

async function seedAdminUser(
    usersService: UsersService,
    subscriptionsService: SubscriptionsService,
    configService: ConfigService,
) {
    console.log('🌱 Seeding admin user...');

    const adminEmail = configService.get<string>('ADMIN_EMAIL') || 'admin@example.com';
    const adminPassword = configService.get<string>('ADMIN_PASSWORD') || 'Admin123!';

    try {
        // Check if admin already exists
        const existingAdmin = await usersService.findByEmail(adminEmail);
        if (existingAdmin) {
            console.log('   ℹ Admin user already exists');
            return;
        }

        // Create admin user
        const admin = await usersService.createUser(
            adminEmail,
            adminPassword,
            'Admin User',
            UserRole.ADMIN,
        );

        // Create FREE subscription first
        await subscriptionsService.createFreeSubscription(admin.userId);

        // Then upgrade to PRO subscription for admin
        await subscriptionsService.activateProSubscription(admin.userId, 12);

        console.log(`   ✓ Admin created: ${adminEmail}`);
        console.log(`   ✓ Password: ${adminPassword}`);
        console.log('   ⚠ CHANGE THE ADMIN PASSWORD IN PRODUCTION!');
    } catch (error) {
        console.error('   ✗ Error creating admin:', error.message);
    }
}

async function seedDemoUser(
    usersService: UsersService,
    subscriptionsService: SubscriptionsService,
) {
    console.log('🌱 Seeding demo user...');

    const demoEmail = 'test@gmail.com';
    const demoPassword = 'test123';

    try {
        const existing = await usersService.findByEmail(demoEmail);
        if (existing) {
            console.log('   ℹ Demo user already exists');
            return;
        }

        const demo = await usersService.createUser(
            demoEmail,
            demoPassword,
            'Demo User',
            UserRole.USER,
        );

        await subscriptionsService.createFreeSubscription(demo.userId);
        // Start demo on FREE so switching to PRO feels meaningful
        console.log(`   ✓ Demo user created: ${demoEmail}`);
        console.log(`   ✓ Password: ${demoPassword}`);
    } catch (error) {
        console.error('   ✗ Error creating demo user:', error.message);
    }
}

async function seed() {
    console.log('🚀 Starting database seed...\n');

    const app = await NestFactory.createApplicationContext(SeedModule);

    try {
        const planFeaturesRepo = app.get(PlanFeaturesRepository);
        const usersService = app.get(UsersService);
        const subscriptionsService = app.get(SubscriptionsService);
        const configService = app.get(ConfigService);

        await seedPlanFeatures(planFeaturesRepo);
        console.log();
        await seedAdminUser(usersService, subscriptionsService, configService);
        console.log();
        await seedDemoUser(usersService, subscriptionsService);

        console.log('\n✅ Seed completed successfully!');
    } catch (error) {
        console.error('\n❌ Seed failed:', error);
        console.error(error);
        process.exit(1);
    } finally {
        await app.close();
    }
}

seed();
