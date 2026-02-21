import { Module, forwardRef } from '@nestjs/common';
import { FeaturesController } from './features.controller';
import { FeaturesService } from './features.service';
import { PlanFeaturesRepository } from './plan-features.repository';
import { UserFeatureOverridesRepository } from './user-feature-overrides.repository';
import { FeatureGuard } from './guards/feature.guard';
import { UsersModule } from '../users/users.module';

@Module({
    imports: [forwardRef(() => UsersModule)],
    controllers: [FeaturesController],
    providers: [
        FeaturesService,
        PlanFeaturesRepository,
        UserFeatureOverridesRepository,
        FeatureGuard,
    ],
    exports: [FeaturesService, FeatureGuard],
})
export class FeaturesModule { }
