import { IsString, IsNotEmpty } from 'class-validator';

export class ActivatePromoDto {
    @IsString()
    @IsNotEmpty()
    code: string;
}
