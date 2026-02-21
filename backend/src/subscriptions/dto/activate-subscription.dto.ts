import { IsEnum, IsInt, Min, Max } from 'class-validator';
import { SubscriptionPlan } from '../../features/enums/subscription-plan.enum';

export class ActivateSubscriptionDto {
    @IsEnum(SubscriptionPlan)
    plan: SubscriptionPlan;

    @IsInt()
    @Min(1)
    @Max(12)
    months: number = 1;
}
