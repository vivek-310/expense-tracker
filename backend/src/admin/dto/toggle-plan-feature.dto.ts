import { IsEnum, IsBoolean } from 'class-validator';
import { SubscriptionPlan } from '../../features/enums/subscription-plan.enum';
import { FeatureName } from '../../features/enums/feature-name.enum';

export class TogglePlanFeatureDto {
    @IsEnum(SubscriptionPlan)
    plan: SubscriptionPlan;

    @IsEnum(FeatureName)
    feature: FeatureName;

    @IsBoolean()
    enabled: boolean;
}
