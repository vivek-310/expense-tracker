import { Controller, Get, Post, Body, UseGuards, Request, BadRequestException } from '@nestjs/common';
import { SubscriptionsService } from './subscriptions.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { ActivateSubscriptionDto } from './dto/activate-subscription.dto';
import { ActivatePromoDto } from './dto/activate-promo.dto';

@Controller('subscriptions')
@UseGuards(JwtAuthGuard)
export class SubscriptionsController {
    constructor(private subscriptionsService: SubscriptionsService) { }

    @Get('status')
    async getStatus(@Request() req) {
        return this.subscriptionsService.getSubscription(req.user.userId);
    }

    @Post('activate')
    async activateSubscription(
        @Request() req,
        @Body() activateDto: ActivateSubscriptionDto,
    ) {
        // In production, you would verify payment here
        return this.subscriptionsService.activateProSubscription(
            req.user.userId,
            activateDto.months,
        );
    }

    @Post('promo')
    async redeemPromo(
        @Request() req,
        @Body() promoDto: ActivatePromoDto,
    ) {
        if (promoDto.code.toUpperCase() === 'VIVEK') {
            return this.subscriptionsService.activateProSubscription(req.user.userId, 12);
        }
        throw new BadRequestException('Invalid promo code');
    }

    @Post('cancel')
    async cancelSubscription(@Request() req) {
        return this.subscriptionsService.cancelSubscription(req.user.userId);
    }
}
