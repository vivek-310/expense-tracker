import {
    Controller,
    Post,
    Get,
    Patch,
    Delete,
    Body,
    Param,
    Query,
    UseGuards,
} from '@nestjs/common';
import { AdminService } from './admin.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { AdminGuard } from '../auth/guards/admin.guard';
import { TogglePlanFeatureDto } from './dto/toggle-plan-feature.dto';
import { ToggleUserFeatureDto } from './dto/toggle-user-feature.dto';
import { ActivateUserSubscriptionDto } from './dto/activate-user-subscription.dto';
import { UpdateUserStatusDto } from './dto/update-user-status.dto';
import { SubscriptionPlan } from '../features/enums/subscription-plan.enum';

@Controller('admin')
@UseGuards(JwtAuthGuard, AdminGuard)
export class AdminController {
    constructor(private adminService: AdminService) { }

    // Feature Management
    @Post('plan-features')
    async togglePlanFeature(@Body() dto: TogglePlanFeatureDto) {
        return this.adminService.togglePlanFeature(dto.plan, dto.feature, dto.enabled);
    }

    @Get('plan-features/:plan')
    async getPlanFeatures(@Param('plan') plan: SubscriptionPlan) {
        return this.adminService.getPlanFeatures(plan);
    }

    @Post('user-features')
    async toggleUserFeature(@Body() dto: ToggleUserFeatureDto) {
        return this.adminService.toggleUserFeature(
            dto.userId,
            dto.feature,
            dto.enabled,
            dto.reason,
            dto.expiresAt,
        );
    }

    @Delete('user-features/:userId/:feature')
    async removeUserFeatureOverride(
        @Param('userId') userId: string,
        @Param('feature') feature: string,
    ) {
        return this.adminService.removeUserFeatureOverride(userId, feature as any);
    }

    // Subscription Management
    @Post('subscriptions/activate')
    async activateUserSubscription(@Body() dto: ActivateUserSubscriptionDto) {
        return this.adminService.activateUserSubscription(
            dto.userId,
            dto.plan,
            dto.months,
        );
    }

    // User Management
    @Patch('users/:userId/status')
    async updateUserStatus(
        @Param('userId') userId: string,
        @Body() dto: UpdateUserStatusDto,
    ) {
        return this.adminService.updateUserStatus(userId, dto.status);
    }
}
