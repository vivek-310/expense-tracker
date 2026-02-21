import { Module } from '@nestjs/common';
import { AdminController } from './admin.controller';
import { AdminService } from './admin.service';
import { FeaturesModule } from '../features/features.module';
import { SubscriptionsModule } from '../subscriptions/subscriptions.module';
import { UsersModule } from '../users/users.module';

@Module({
    imports: [FeaturesModule, SubscriptionsModule, UsersModule],
    controllers: [AdminController],
    providers: [AdminService],
})
export class AdminModule { }
