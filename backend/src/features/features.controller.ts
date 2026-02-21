import { Controller, Get, UseGuards, Request } from '@nestjs/common';
import { FeaturesService } from './features.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@Controller('features')
@UseGuards(JwtAuthGuard)
export class FeaturesController {
    constructor(private featuresService: FeaturesService) { }

    @Get()
    async getUserFeatures(@Request() req) {
        const features = await this.featuresService.getUserFeatures(req.user.userId);
        return { features };
    }
}
