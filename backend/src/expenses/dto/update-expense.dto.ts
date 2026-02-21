import { IsNumber, IsString, IsOptional, Min } from 'class-validator';

export class UpdateExpenseDto {
    @IsOptional()
    @IsNumber()
    @Min(0)
    amount?: number;

    @IsOptional()
    @IsString()
    category?: string;

    @IsOptional()
    @IsString()
    note?: string;

    @IsOptional()
    @IsString()
    paymentMethod?: string;
}
