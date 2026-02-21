import {
    Injectable,
    UnauthorizedException,
    ConflictException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { UsersService } from '../users/users.service';
import { SubscriptionsService } from '../subscriptions/subscriptions.service';
import { UserPayload } from '../common/interfaces/user-payload.interface';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';

@Injectable()
export class AuthService {
    constructor(
        private usersService: UsersService,
        private subscriptionsService: SubscriptionsService,
        private jwtService: JwtService,
    ) { }

    async register(registerDto: RegisterDto) {
        // Check if user exists
        const existingUser = await this.usersService.findByEmail(registerDto.email);
        if (existingUser) {
            throw new ConflictException('User with this email already exists');
        }

        // Create user
        const user = await this.usersService.createUser(
            registerDto.email,
            registerDto.password,
            registerDto.name,
        );

        // Create FREE subscription for new user
        await this.subscriptionsService.createFreeSubscription(user.userId);

        // Generate access token
        const payload = { userId: user.userId, email: user.email, role: user.role };
        const accessToken = this.jwtService.sign(payload);

        return {
            accessToken,
            user: {
                userId: user.userId,
                email: user.email,
                name: user.name,
                currentPlan: user.currentPlan,
                role: user.role,
                status: user.status,
            },
        };
    }

    async login(loginDto: LoginDto) {
        // Find user
        const user = await this.usersService.findByEmail(loginDto.email);
        if (!user) {
            throw new UnauthorizedException('Invalid credentials');
        }

        // Validate password
        const isPasswordValid = await this.usersService.validatePassword(
            user,
            loginDto.password,
        );
        if (!isPasswordValid) {
            throw new UnauthorizedException('Invalid credentials');
        }

        // Generate JWT
        const payload: UserPayload = {
            userId: user.userId,
            email: user.email,
            role: user.role,
            currentPlan: user.currentPlan,
        };

        const accessToken = this.jwtService.sign(payload);

        const { passwordHash: _, ...userWithoutPassword } = user;

        return {
            accessToken,
            user: userWithoutPassword,
        };
    }

    async validateUser(payload: UserPayload) {
        return this.usersService.findById(payload.userId);
    }
}
