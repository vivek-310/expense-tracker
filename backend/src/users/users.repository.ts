import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { UserRole, UserStatus } from '../common/enums/user.enum';
import { SubscriptionPlan } from '../features/enums/subscription-plan.enum';

export interface User {
    userId: string;
    email: string;
    passwordHash: string;
    name?: string;
    phone?: string;
    currentPlan: SubscriptionPlan;
    role: UserRole;
    status: UserStatus;
    createdAt: string;
    updatedAt: string;
}

@Injectable()
export class UsersRepository {
    constructor(private prisma: PrismaService) { }

    async create(user: Omit<User, 'createdAt' | 'updatedAt'>): Promise<User> {
        const createdUser = await this.prisma.user.create({
            data: {
                userId: user.userId,
                email: user.email,
                passwordHash: user.passwordHash,
                name: user.name,
                phone: user.phone,
                currentPlan: user.currentPlan,
                role: user.role,
                status: user.status,
            },
        });

        return {
            userId: createdUser.userId,
            email: createdUser.email,
            passwordHash: createdUser.passwordHash,
            name: createdUser.name || undefined,
            phone: createdUser.phone || undefined,
            currentPlan: createdUser.currentPlan as SubscriptionPlan,
            role: createdUser.role as UserRole,
            status: createdUser.status as UserStatus,
            createdAt: createdUser.createdAt.toISOString(),
            updatedAt: createdUser.updatedAt.toISOString(),
        };
    }

    async findById(userId: string): Promise<User | null> {
        const user = await this.prisma.user.findUnique({
            where: { userId },
        });

        if (!user) return null;

        return {
            userId: user.userId,
            email: user.email,
            passwordHash: user.passwordHash,
            name: user.name || undefined,
            phone: user.phone || undefined,
            currentPlan: user.currentPlan as SubscriptionPlan,
            role: user.role as UserRole,
            status: user.status as UserStatus,
            createdAt: user.createdAt.toISOString(),
            updatedAt: user.updatedAt.toISOString(),
        };
    }

    async findByEmail(email: string): Promise<User | null> {
        const user = await this.prisma.user.findUnique({
            where: { email },
        });

        if (!user) return null;

        return {
            userId: user.userId,
            email: user.email,
            passwordHash: user.passwordHash,
            name: user.name || undefined,
            phone: user.phone || undefined,
            currentPlan: user.currentPlan as SubscriptionPlan,
            role: user.role as UserRole,
            status: user.status as UserStatus,
            createdAt: user.createdAt.toISOString(),
            updatedAt: user.updatedAt.toISOString(),
        };
    }

    async update(
        userId: string,
        updates: Partial<Omit<User, 'userId' | 'email' | 'createdAt' | 'updatedAt'>>,
    ): Promise<User> {
        const user = await this.prisma.user.update({
            where: { userId },
            data: updates,
        });

        return {
            userId: user.userId,
            email: user.email,
            passwordHash: user.passwordHash,
            name: user.name || undefined,
            phone: user.phone || undefined,
            currentPlan: user.currentPlan as SubscriptionPlan,
            role: user.role as UserRole,
            status: user.status as UserStatus,
            createdAt: user.createdAt.toISOString(),
            updatedAt: user.updatedAt.toISOString(),
        };
    }

    async updatePlan(userId: string, plan: SubscriptionPlan): Promise<void> {
        await this.prisma.user.update({
            where: { userId },
            data: { currentPlan: plan },
        });
    }
}
