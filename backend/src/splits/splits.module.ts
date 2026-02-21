import { Module } from '@nestjs/common';
import { SplitsController } from './splits.controller';
import { SplitsService } from './splits.service';
import { SplitsRepository } from './splits.repository';
import { ExpensesModule } from '../expenses/expenses.module';
import { FeaturesModule } from '../features/features.module';

@Module({
    imports: [ExpensesModule, FeaturesModule],
    controllers: [SplitsController],
    providers: [SplitsService, SplitsRepository],
    exports: [SplitsService],
})
export class SplitsModule { }
