import { UserRole } from '../enums/user.enum';

export interface UserPayload {
    userId: string;
    email: string;
    role: UserRole;
    currentPlan: string;
}
