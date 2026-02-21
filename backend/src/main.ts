import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { AppModule } from './app.module';

async function bootstrap() {
    const app = await NestFactory.create(AppModule);

    // Enable CORS for Flutter app
    app.enableCors({
        origin: true, // In production, specify your Flutter app domain
        credentials: true,
    });

    // Global validation pipe
    app.useGlobalPipes(
        new ValidationPipe({
            whitelist: true, // Strip properties that don't have decorators
            forbidNonWhitelisted: true, // Throw error if extra properties
            transform: true, // Auto-transform payloads to DTO instances
        }),
    );

    const port = process.env.PORT || 3000;
    await app.listen(port, '0.0.0.0'); // Listen on all network interfaces

    console.log(`🚀 Application is running on: http://localhost:${port}`);
    console.log(`📚 Also accessible at: http://192.168.1.39:${port}`);
    console.log(`📚 API Documentation: http://localhost:${port}/api`);
}

bootstrap();
