import {
    Injectable,
    CanActivate,
    ExecutionContext,
    ForbiddenException,
    SetMetadata,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { FeaturesService } from '../features.service';
import { FeatureName } from '../enums/feature-name.enum';

export const FEATURE_KEY = 'feature';
export const RequireFeature = (feature: FeatureName) => SetMetadata(FEATURE_KEY, feature);

@Injectable()
export class FeatureGuard implements CanActivate {
    constructor(
        private reflector: Reflector,
        private featuresService: FeaturesService,
    ) { }

    async canActivate(context: ExecutionContext): Promise<boolean> {
        const requiredFeature = this.reflector.get<FeatureName>(
            FEATURE_KEY,
            context.getHandler(),
        );

        if (!requiredFeature) {
            return true; // No feature required
        }

        const request = context.switchToHttp().getRequest();
        const user = request.user;

        if (!user) {
            throw new ForbiddenException('User not authenticated');
        }

        const isEnabled = await this.featuresService.isFeatureEnabled(
            user.userId,
            requiredFeature,
        );

        if (!isEnabled) {
            throw new ForbiddenException(
                `Feature '${requiredFeature}' is not enabled for your subscription plan. Please upgrade to access this feature.`,
            );
        }

        return true;
    }
}
