# Prisma Setup Guide

This guide will help you set up Prisma ORM for the expense tracker backend.

## Prerequisites

- Node.js 18+ installed
- A database: PostgreSQL, MySQL, or SQLite

## Database Options

### Option 1: PostgreSQL (Recommended for Production)

**Using Docker:**
```bash
docker run -d \
  --name postgres \
  -e POSTGRES_PASSWORD=password \
  -e POSTGRES_DB=expense_tracker \
  -p 5432:5432 \
  postgres:15
```

**Environment Variable:**
```env
DATABASE_URL="postgresql://postgres:password@localhost:5432/expense_tracker"
```

### Option 2: MySQL

**Using Docker:**
```bash
docker run -d \
  --name mysql \
  -e MYSQL_ROOT_PASSWORD=password \
  -e MYSQL_DATABASE=expense_tracker \
  -p 3306:3306 \
  mysql:8
```

**Environment Variable:**
```env
DATABASE_URL="mysql://root:password@localhost:3306/expense_tracker"
```

### Option 3: SQLite (Best for Local Development)

No installation required! Just use a file-based database.

**Environment Variable:**
```env
DATABASE_URL="file:./dev.db"
```

## Setup Steps

### 1. Install Dependencies

```bash
npm install
```

This will install both `@prisma/client` and `prisma` (dev dependency).

### 2. Configure Environment

Create a `.env` file (copy from `.env.example`):

```bash
cp .env.example .env
```

Update the `DATABASE_URL` in `.env` based on your chosen database.

### 3. Generate Prisma Client

```bash
npx prisma generate
```

This generates the type-safe Prisma Client from your schema.

### 4. Run Database Migrations

```bash
npx prisma migrate dev --name init
```

This creates the database tables based on your Prisma schema.

### 5. Seed the Database

```bash
npm run seed
```

This populates the database with:
- Default plan features (FREE and PRO)
- Admin user (credentials from `.env`)

### 6. Start the Application

```bash
# Development mode
npm run start:dev

# Production mode
npm run build
npm run start:prod
```

## Useful Prisma Commands

### View Database in Browser

```bash
npx prisma studio
```

Opens a visual database browser at `http://localhost:5555`

### Create a New Migration

After changing `schema.prisma`:

```bash
npx prisma migrate dev --name your_migration_name
```

### Reset Database

**Warning: This deletes all data!**

```bash
npx prisma migrate reset
```

### Generate Types Only

```bash
npx prisma generate
```

### Format Schema File

```bash
npx prisma format
```

## Prisma Schema Location

The Prisma schema is located at:
```
backend/prisma/schema.prisma
```

## Database Models

The schema includes:

1. **User** - User accounts with authentication
2. **Subscription** - User subscription management
3. **PlanFeature** - Plan-level feature flags
4. **UserFeatureOverride** - User-specific feature overrides
5. **Expense** - Expense tracking
6. **Split** - Expense splitting (PRO feature)

## Troubleshooting

### "Cannot find module '@prisma/client'"

Run:
```bash
npx prisma generate
```

### Migration Errors

If you get migration errors, you can reset:
```bash
npx prisma migrate reset
npx prisma migrate dev --name init
npm run seed
```

### Database Connection Issues

- Check that your database is running
- Verify the `DATABASE_URL` in `.env`
- For PostgreSQL/MySQL, ensure the database exists

## Production Deployment

1. Set `DATABASE_URL` in your production environment
2. Run migrations:
   ```bash
   npx prisma migrate deploy
   ```
3. Run seed script if needed
4. Start the application

## Learn More

- [Prisma Documentation](https://www.prisma.io/docs)
- [Prisma Schema Reference](https://www.prisma.io/docs/reference/api-reference/prisma-schema-reference)
- [NestJS + Prisma](https://docs.nestjs.com/recipes/prisma)
