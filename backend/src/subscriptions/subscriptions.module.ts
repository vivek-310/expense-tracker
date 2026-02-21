import { Module, forwardRef } from '@nestjs/common';
import { SubscriptionsController } from './subscriptions.controller';
import { SubscriptionsService } from './subscriptions.service';
import { SubscriptionsRepository } from './subscriptions.repository';
import { UsersModule } from '../users/users.module';

@Module({
    imports: [forwardRef(() => UsersModule)],
    controllers: [SubscriptionsController],
    providers: [SubscriptionsService, SubscriptionsRepository],
    exports: [SubscriptionsService, SubscriptionsRepository],
})
export class SubscriptionsModule { }
