# SaaS Expense Tracker Backend

A production-grade NestJS backend with Prisma ORM for a subscription-based expense tracking application.

## 🌟 Features

- ✅ **JWT Authentication** - Secure user authentication with email/password
- ✅ **Role-Based Access Control** - User and Admin roles
- ✅ **Subscription Management** - FREE and PRO plans with automatic expiry
- ✅ **Dynamic Feature Flags** - Admin-controlled feature toggles at plan and user level
- ✅ **Expense Tracking** - Full CRUD operations with date filtering
- ✅ **Expense Splitting** - Feature-gated split functionality (PRO only by default)
- ✅ **Prisma ORM** - Type-safe database access with PostgreSQL, MySQL, or SQLite
- ✅ **Clean Architecture** - Modular design with separation of concerns

## 📋 Prerequisites

- Node.js 18+ and npm
- Database: PostgreSQL, MySQL, or SQLite

## 🚀 Quick Start

### 1. Clone and Install

```bash
cd backend
npm install
```

### 2. Configure Environment

Copy `.env.example` to `.env` and update with your values:

```bash
cp .env.example .env
```

Update the following in `.env`:
```env
# JWT Configuration
JWT_SECRET=your-super-secret-jwt-key-change-this

# Database (choose one)
# PostgreSQL:
DATABASE_URL="postgresql://postgres:password@localhost:5432/expense_tracker"

# MySQL:
# DATABASE_URL="mysql://root:password@localhost:3306/expense_tracker"

# SQLite (easiest for development):
# DATABASE_URL="file:./dev.db"

# Admin Credentials
ADMIN_EMAIL=admin@example.com
ADMIN_PASSWORD=ChangeMe123!
```

### 3. Setup Database

**Option A: PostgreSQL (Recommended for Production)**
```bash
# Using Docker
docker run -d \
  --name postgres \
  -e POSTGRES_PASSWORD=password \
  -e POSTGRES_DB=expense_tracker \
  -p 5432:5432 \
  postgres:15
```

**Option B: MySQL**
```bash
# Using Docker
docker run -d \
  --name mysql \
  -e MYSQL_ROOT_PASSWORD=password \
  -e MYSQL_DATABASE=expense_tracker \
  -p 3306:3306 \
  mysql:8
```

**Option C: SQLite (No Setup Required)**
```bash
# Just set DATABASE_URL="file:./dev.db" in .env
```

### 4. Run Prisma Migrations

```bash
# Generate Prisma Client
npx prisma generate

# Create database tables
npx prisma migrate dev --name init
```

### 5. Seed Database

Initialize the database with default plan features and admin user:

```bash
npm run seed
```

This will create:
- ✅ Plan features for FREE and PRO plans
- ✅ Admin user with credentials from `.env`

### 6. Run the Application

```bash
# Development mode (with hot reload)
npm run start:dev

# Production mode
npm run build
npm run start:prod
```

The server will start on `http://localhost:3000`

## 📊 Database Schema

See [PRISMA_SETUP.md](./PRISMA_SETUP.md) for detailed database setup instructions.

### Models

- **User** - User accounts with authentication and subscription info
- **Subscription** - User subscription management (FREE/PRO)
- **PlanFeature** - Plan-level feature flags configuration
- **UserFeatureOverride** - User-specific feature overrides
- **Expense** - Expense tracking with categorization
- **Split** - Expense splitting (PRO feature)

## 🔑 API Endpoints

### Authentication

```http
POST /auth/register
POST /auth/login
GET /auth/profile (Protected)
```

### Users

```http
GET /users/me (Protected)
PATCH /users/me (Protected)
```

### Features

```http
GET /features (Protected)
# Returns enabled features for the current user
```

### Subscriptions

```http
GET /subscriptions/status (Protected)
POST /subscriptions/activate (Protected)
POST /subscriptions/cancel (Protected)
```

### Expenses

```http
POST /expenses (Protected)
GET /expenses?startDate=xxx&endDate=xxx (Protected)
GET /expenses/:id (Protected)
PATCH /expenses/:id (Protected)
DELETE /expenses/:id (Protected)
```

### Splits (Feature-Gated: SPLIT)

```http
POST /splits (Protected + PRO)
GET /splits/:expenseId (Protected + PRO)
PATCH /splits/:expenseId/:friendId/settle (Protected + PRO)
```

### Admin (Admin-Only)

```http
# Feature Management
POST /admin/plan-features
GET /admin/plan-features/:plan
POST /admin/user-features
DELETE /admin/user-features/:userId/:feature

# Subscription Management
POST /admin/subscriptions/activate

# User Management
PATCH /admin/users/:userId/status
```

## 🧪 Testing the API

### 1. Register a User

```bash
curl -X POST http://localhost:3000/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "Password123!",
    "name": "Test User"
  }'
```

### 2. Login

```bash
curl -X POST http://localhost:3000/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "Password123!"
  }'
```

Save the `accessToken` from the response.

### 3. Check Enabled Features

```bash
curl -X GET http://localhost:3000/features \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

### 4. Try Creating a Split (Will Fail for FREE Users)

```bash
curl -X POST http://localhost:3000/splits \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "expenseId": "some-expense-id",
    "splits": [{"friendId": "friend-id", "amount": 50}]
  }'
```

### 5. Admin: Enable Split for FREE Plan

```bash
curl -X POST http://localhost:3000/admin/plan-features \
  -H "Authorization: Bearer ADMIN_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "plan": "FREE",
    "feature": "SPLIT",
    "enabled": true
  }'
```

## 🏗️ Architecture

### Module Structure

```
src/
├── prisma/         # Prisma service and module
├── auth/           # Authentication & JWT
├── users/          # User management
├── subscriptions/  # Subscription logic
├── features/       # Feature flag system (CORE)
├── admin/          # Admin controls
├── expenses/       # Expense CRUD
├── splits/         # Expense splitting
└── common/         # Shared utilities
```

### Feature Resolution Flow

```
User Request
    ↓
JWT Auth Guard
    ↓
Feature Guard (if applicable)
    ↓
Check User Override (highest priority)
    ↓ (if not found)
Check Plan Feature
    ↓ (if not found)
Default: false
    ↓
Allow/Deny
```

## 🔒 Security

- ✅ Passwords hashed with bcrypt
- ✅ JWT tokens with expiration
- ✅ Role-based access control
- ✅ Input validation with class-validator
- ✅ CORS enabled (configure for production)

## 📦 Production Deployment

### 1. Build the Application

```bash
npm run build
```

### 2. Set Environment Variables

Set all `.env` variables in your production environment

### 3. Run Database Migrations

```bash
npx prisma migrate deploy
```

### 4. Start the Application

```bash
npm run start:prod
```

## 🛠️ Development

### Useful Commands

```bash
# Install dependencies
npm install

# Run in development mode
npm run start:dev

# Run tests
npm run test

# Lint code
npm run lint

# Format code
npm run format

# View database in browser
npx prisma studio

# Create a migration
npx prisma migrate dev --name migration_name

# Reset database (WARNING: deletes all data)
npx prisma migrate reset
```

## 📝 Key Concepts

### Subscription Plans

- **FREE**: Default plan, limited features
- **PRO**: Premium plan with all features enabled

### Feature Flags

Features can be controlled at two levels:

1. **Plan Level**: Default features for all users on a plan
2. **User Level**: Individual overrides (promo access, abuse prevention)

### Priority System

`User Override > Plan Feature > Default (false)`

This allows:
- Promotional access for specific users
- Feature testing before general availability
- Abuse prevention (disable features for specific users)

## 🤝 Contributing

This is a production-ready template. Feel free to extend it with:
- Payment gateway integration (Razorpay, Stripe)
- Email notifications
- More subscription plans (GOLD, FAMILY, etc.)
- Advanced analytics
- Budgeting features

## 📄 License

MIT

---

**Built with ❤️ using NestJS, TypeScript, and Prisma ORM**
