import { IsUUID, IsEnum, IsBoolean, IsOptional, IsString, IsISO8601 } from 'class-validator';
import { FeatureName } from '../../features/enums/feature-name.enum';

export class ToggleUserFeatureDto {
    @IsUUID()
    userId: string;

    @IsEnum(FeatureName)
    feature: FeatureName;

    @IsBoolean()
    enabled: boolean;

    @IsOptional()
    @IsString()
    reason?: string;

    @IsOptional()
    @IsISO8601()
    expiresAt?: string;
}
