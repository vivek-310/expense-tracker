import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { v4 as uuidv4 } from 'uuid';

export interface SplitItemResponse {
    friendId: string;
    friendName: string;
    amount: number;
    settled: boolean;
}

export interface SplitResponse {
    totalAmount: number;
    splits: SplitItemResponse[];
}

export interface Expense {
    expenseId: string;
    userId: string;
    amount: number;
    category: string;
    note?: string;
    paymentMethod?: string;
    date: string;
    createdAt: string;
    updatedAt: string;
    split?: SplitResponse;
}

@Injectable()
export class ExpensesRepository {
    constructor(private prisma: PrismaService) { }

    private mapExpense(expense: any): Expense {
        const result: Expense = {
            expenseId: expense.expenseId,
            userId: expense.userId,
            amount: expense.amount,
            category: expense.category,
            note: expense.note || undefined,
            paymentMethod: expense.paymentMethod || undefined,
            date: expense.date.toISOString(),
            createdAt: expense.createdAt.toISOString(),
            updatedAt: expense.updatedAt.toISOString(),
        };

        if (expense.split) {
            result.split = {
                totalAmount: expense.split.totalAmount,
                splits: expense.split.splits as SplitItemResponse[],
            };
        }

        return result;
    }

    async create(expense: Omit<Expense, 'expenseId' | 'createdAt' | 'updatedAt' | 'date'>): Promise<Expense> {
        const expenseId = uuidv4();

        const createdExpense = await this.prisma.expense.create({
            data: {
                expenseId,
                userId: expense.userId,
                amount: expense.amount,
                category: expense.category,
                note: expense.note,
                paymentMethod: expense.paymentMethod || '',
            },
        });

        return {
            expenseId: createdExpense.expenseId,
            userId: createdExpense.userId,
            amount: createdExpense.amount,
            category: createdExpense.category,
            note: createdExpense.note || undefined,
            paymentMethod: createdExpense.paymentMethod || undefined,
            date: createdExpense.date.toISOString(),
            createdAt: createdExpense.createdAt.toISOString(),
            updatedAt: createdExpense.updatedAt.toISOString(),
        };
    }

    async findById(userId: string, expenseId: string): Promise<Expense | null> {
        const expense = await this.prisma.expense.findFirst({
            where: {
                expenseId,
                userId,
            },
            include: { split: true },
        });

        if (!expense) return null;

        return this.mapExpense(expense);
    }

    async findAllByUser(userId: string, startDate?: string, endDate?: string): Promise<Expense[]> {
        const where: any = { userId };

        if (startDate && endDate) {
            where.date = {
                gte: new Date(startDate),
                lte: new Date(endDate),
            };
        }

        const expenses = await this.prisma.expense.findMany({
            where,
            include: { split: true },
            orderBy: {
                date: 'desc', // Newest first
            },
        });

        return expenses.map(expense => this.mapExpense(expense));
    }

    async update(
        userId: string,
        expenseId: string,
        updates: Partial<Omit<Expense, 'expenseId' | 'userId' | 'createdAt' | 'updatedAt'>>,
    ): Promise<Expense> {
        const expense = await this.prisma.expense.updateMany({
            where: {
                expenseId,
                userId,
            },
            data: updates,
        });

        // Fetch the updated expense
        const updatedExpense = await this.findById(userId, expenseId);
        if (!updatedExpense) {
            throw new Error('Expense not found');
        }

        return updatedExpense;
    }

    async delete(userId: string, expenseId: string): Promise<void> {
        await this.prisma.expense.deleteMany({
            where: {
                expenseId,
                userId,
            },
        });
    }
}
