import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { SplitsRepository, Split } from './splits.repository';
import { ExpensesService } from '../expenses/expenses.service';
import { CreateSplitDto } from './dto/create-split.dto';

@Injectable()
export class SplitsService {
    constructor(
        private splitsRepository: SplitsRepository,
        private expensesService: ExpensesService,
    ) { }

    async createSplit(userId: string, createDto: CreateSplitDto): Promise<Split> {
        // Verify expense exists and belongs to user
        const expense = await this.expensesService.getExpense(userId, createDto.expenseId);

        // Validate that split amounts don't exceed expense amount
        const totalSplit = createDto.splits.reduce((sum, split) => sum + split.amount, 0);
        if (totalSplit > expense.amount) {
            throw new BadRequestException('Split amounts cannot exceed expense amount');
        }

        // Create split with all split items
        const splitItems = createDto.splits.map(s => ({
            friendId: s.friendId,
            friendName: s.friendName || s.friendId,
            amount: s.amount,
            settled: false,
        }));

        const split = await this.splitsRepository.create({
            expenseId: createDto.expenseId,
            userId,
            totalAmount: expense.amount,
            splits: splitItems,
        });

        return split;
    }

    async getSplitsByExpense(userId: string, expenseId: string): Promise<Split | null> {
        // Verify expense belongs to user
        await this.expensesService.getExpense(userId, expenseId);

        return this.splitsRepository.findByExpenseId(expenseId);
    }

    async settleSplit(userId: string, expenseId: string, friendId: string): Promise<Split> {
        // Verify expense belongs to user
        await this.expensesService.getExpense(userId, expenseId);

        // Verify split exists
        const split = await this.splitsRepository.findByExpenseId(expenseId);
        if (!split) {
            throw new NotFoundException('Split not found');
        }

        // Check if friend exists in splits
        const friendSplit = split.splits.find(s => s.friendId === friendId);
        if (!friendSplit) {
            throw new NotFoundException('Friend not found in split');
        }

        if (friendSplit.settled) {
            throw new BadRequestException('Split is already settled');
        }

        return this.splitsRepository.settle(expenseId, friendId);
    }
}
