import {
    Controller,
    Get,
    Post,
    Patch,
    Delete,
    Body,
    Param,
    Query,
    UseGuards,
    Request,
} from '@nestjs/common';
import { ExpensesService } from './expenses.service';
import { CreateExpenseDto } from './dto/create-expense.dto';
import { UpdateExpenseDto } from './dto/update-expense.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@Controller('expenses')
@UseGuards(JwtAuthGuard)
export class ExpensesController {
    constructor(private expensesService: ExpensesService) { }

    @Post()
    async createExpense(@Request() req, @Body() createDto: CreateExpenseDto) {
        return this.expensesService.createExpense(req.user.userId, createDto);
    }

    @Get()
    async getAllExpenses(
        @Request() req,
        @Query('startDate') startDate?: string,
        @Query('endDate') endDate?: string,
    ) {
        const expenses = await this.expensesService.getAllExpenses(
            req.user.userId,
            startDate,
            endDate,
        );
        return { expenses };
    }

    @Get(':id')
    async getExpense(@Request() req, @Param('id') id: string) {
        return this.expensesService.getExpense(req.user.userId, id);
    }

    @Patch(':id')
    async updateExpense(
        @Request() req,
        @Param('id') id: string,
        @Body() updateDto: UpdateExpenseDto,
    ) {
        return this.expensesService.updateExpense(req.user.userId, id, updateDto);
    }

    @Delete(':id')
    async deleteExpense(@Request() req, @Param('id') id: string) {
        await this.expensesService.deleteExpense(req.user.userId, id);
        return { message: 'Expense deleted successfully' };
    }
}
