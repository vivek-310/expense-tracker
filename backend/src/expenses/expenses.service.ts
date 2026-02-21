import { Injectable, NotFoundException } from '@nestjs/common';
import { ExpensesRepository, Expense } from './expenses.repository';
import { CreateExpenseDto } from './dto/create-expense.dto';
import { UpdateExpenseDto } from './dto/update-expense.dto';

@Injectable()
export class ExpensesService {
    constructor(private expensesRepository: ExpensesRepository) { }

    async createExpense(userId: string, createDto: CreateExpenseDto): Promise<Expense> {
        return this.expensesRepository.create({
            userId,
            amount: createDto.amount,
            category: createDto.category,
            note: createDto.note,
            paymentMethod: createDto.paymentMethod,
        });
    }

    async getExpense(userId: string, expenseId: string): Promise<Expense> {
        const expense = await this.expensesRepository.findById(userId, expenseId);
        if (!expense) {
            throw new NotFoundException('Expense not found');
        }
        return expense;
    }

    async getAllExpenses(
        userId: string,
        startDate?: string,
        endDate?: string,
    ): Promise<Expense[]> {
        return this.expensesRepository.findAllByUser(userId, startDate, endDate);
    }

    async updateExpense(
        userId: string,
        expenseId: string,
        updateDto: UpdateExpenseDto,
    ): Promise<Expense> {
        return this.expensesRepository.update(userId, expenseId, updateDto);
    }

    async deleteExpense(userId: string, expenseId: string): Promise<void> {
        await this.expensesRepository.delete(userId, expenseId);
    }
}
