import {
    Controller,
    Get,
    Post,
    Patch,
    Body,
    Param,
    UseGuards,
    Request,
} from '@nestjs/common';
import { SplitsService } from './splits.service';
import { CreateSplitDto } from './dto/create-split.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { FeatureGuard, RequireFeature } from '../features/guards/feature.guard';
import { FeatureName } from '../features/enums/feature-name.enum';

@Controller('splits')
@UseGuards(JwtAuthGuard, FeatureGuard)
export class SplitsController {
    constructor(private splitsService: SplitsService) { }

    @Post()
    @RequireFeature(FeatureName.SPLIT)
    async createSplit(@Request() req, @Body() createDto: CreateSplitDto) {
        const splits = await this.splitsService.createSplit(req.user.userId, createDto);
        return { splits };
    }

    @Get(':expenseId')
    @RequireFeature(FeatureName.SPLIT)
    async getSplitsByExpense(@Request() req, @Param('expenseId') expenseId: string) {
        const splits = await this.splitsService.getSplitsByExpense(
            req.user.userId,
            expenseId,
        );
        return { splits };
    }

    @Patch(':expenseId/:friendId/settle')
    @RequireFeature(FeatureName.SPLIT)
    async settleSplit(
        @Request() req,
        @Param('expenseId') expenseId: string,
        @Param('friendId') friendId: string,
    ) {
        return this.splitsService.settleSplit(req.user.userId, expenseId, friendId);
    }
}
