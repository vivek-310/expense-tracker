import { Injectable, NotFoundException } from '@nestjs/common';
import { UsersRepository, User } from './users.repository';
import * as bcrypt from 'bcrypt';
import { v4 as uuidv4 } from 'uuid';
import { UserRole, UserStatus } from '../common/enums/user.enum';
import { SubscriptionPlan } from '../features/enums/subscription-plan.enum';

@Injectable()
export class UsersService {
    constructor(private usersRepository: UsersRepository) { }

    async createUser(
        email: string,
        password: string,
        name?: string,
        role: UserRole = UserRole.USER,
    ): Promise<Omit<User, 'passwordHash'>> {
        const passwordHash = await bcrypt.hash(password, 10);
        const userId = uuidv4();

        const user = await this.usersRepository.create({
            userId,
            email,
            passwordHash,
            name,
            currentPlan: SubscriptionPlan.FREE,
            role,
            status: UserStatus.ACTIVE,
        });

        const { passwordHash: _, ...userWithoutPassword } = user;
        return userWithoutPassword;
    }

    async findById(userId: string): Promise<Omit<User, 'passwordHash'> | null> {
        const user = await this.usersRepository.findById(userId);
        if (!user) return null;

        const { passwordHash: _, ...userWithoutPassword } = user;
        return userWithoutPassword;
    }

    async findByIdOrFail(userId: string): Promise<Omit<User, 'passwordHash'>> {
        const user = await this.findById(userId);
        if (!user) {
            throw new NotFoundException('User not found');
        }
        return user;
    }

    async findByEmail(email: string): Promise<User | null> {
        return this.usersRepository.findByEmail(email);
    }

    async validatePassword(user: User, password: string): Promise<boolean> {
        return bcrypt.compare(password, user.passwordHash);
    }

    async updateUser(
        userId: string,
        updates: { name?: string; phone?: string },
    ): Promise<Omit<User, 'passwordHash'>> {
        const user = await this.usersRepository.update(userId, updates);
        const { passwordHash: _, ...userWithoutPassword } = user;
        return userWithoutPassword;
    }

    async updatePlan(userId: string, plan: SubscriptionPlan): Promise<void> {
        await this.usersRepository.updatePlan(userId, plan);
    }

    async findAllWithExpenses(): Promise<any[]> {
        return this.usersRepository.findAllWithExpenses();
    }

    async updateStatus(userId: string, status: UserStatus): Promise<void> {
        await this.usersRepository.update(userId, { status });
    }
}
