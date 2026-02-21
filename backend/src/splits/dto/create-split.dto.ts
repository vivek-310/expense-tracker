import { IsArray, ValidateNested, IsNumber, Min, IsString, IsOptional, IsUUID } from 'class-validator';
import { Type } from 'class-transformer';

export class SplitItemDto {
    @IsString()
    friendId: string;

    @IsString()
    @IsOptional()
    friendName?: string;

    @IsNumber()
    @Min(0)
    amount: number;
}

export class CreateSplitDto {
    @IsUUID()
    expenseId: string;

    @IsArray()
    @ValidateNested({ each: true })
    @Type(() => SplitItemDto)
    splits: SplitItemDto[];
}
