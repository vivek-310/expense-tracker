import { IsNumber, IsString, IsOptional, IsNotEmpty, Min } from 'class-validator';

export class CreateExpenseDto {
    @IsNumber()
    @Min(0)
    amount: number;

    @IsString()
    @IsNotEmpty()
    category: string;

    @IsOptional()
    @IsString()
    note?: string;

    @IsOptional()
    @IsString()
    paymentMethod?: string;
}
