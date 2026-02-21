import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

export interface SplitItem {
    friendId: string;
    friendName: string;
    amount: number;
    settled: boolean;
}

export interface Split {
    expenseId: string;
    userId: string;
    totalAmount: number;
    splits: SplitItem[];
    createdAt: string;
    updatedAt: string;
}

@Injectable()
export class SplitsRepository {
    constructor(private prisma: PrismaService) { }

    async create(split: Omit<Split, 'createdAt' | 'updatedAt'>): Promise<Split> {
        const created = await this.prisma.split.create({
            data: {
                expenseId: split.expenseId,
                userId: split.userId,
                totalAmount: split.totalAmount,
                splits: split.splits as any, // Prisma will handle JSON serialization
            },
        });

        return {
            expenseId: created.expenseId,
            userId: created.userId,
            totalAmount: created.totalAmount,
            splits: created.splits as unknown as SplitItem[],
            createdAt: created.createdAt.toISOString(),
            updatedAt: created.updatedAt.toISOString(),
        };
    }

    async findByExpenseId(expenseId: string): Promise<Split | null> {
        const split = await this.prisma.split.findUnique({
            where: { expenseId },
        });

        if (!split) return null;

        return {
            expenseId: split.expenseId,
            userId: split.userId,
            totalAmount: split.totalAmount,
            splits: split.splits as unknown as SplitItem[],
            createdAt: split.createdAt.toISOString(),
            updatedAt: split.updatedAt.toISOString(),
        };
    }

    async settle(expenseId: string, friendId: string): Promise<Split> {
        // Get the current split
        const currentSplit = await this.findByExpenseId(expenseId);
        if (!currentSplit) {
            throw new Error('Split not found');
        }

        // Update the specific friend's settled status
        const updatedSplits = currentSplit.splits.map(s =>
            s.friendId === friendId ? { ...s, settled: true } : s
        );

        const updated = await this.prisma.split.update({
            where: { expenseId },
            data: {
                splits: updatedSplits as any,
            },
        });

        return {
            expenseId: updated.expenseId,
            userId: updated.userId,
            totalAmount: updated.totalAmount,
            splits: updated.splits as unknown as SplitItem[],
            createdAt: updated.createdAt.toISOString(),
            updatedAt: updated.updatedAt.toISOString(),
        };
    }
}
