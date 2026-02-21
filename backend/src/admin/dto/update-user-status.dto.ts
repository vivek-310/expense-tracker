import { IsUUID, IsEnum } from 'class-validator';
import { UserStatus } from '../../common/enums/user.enum';

export class UpdateUserStatusDto {
    @IsEnum(UserStatus)
    status: UserStatus;
}
