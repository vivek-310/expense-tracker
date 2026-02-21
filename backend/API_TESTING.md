# API Testing Reference

Quick reference for testing all API endpoints. Replace `YOUR_TOKEN` and `ADMIN_TOKEN` with actual JWT tokens.

## 🧪 Authentication

### Register User
```bash
curl -X POST http://localhost:3000/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "Password123!",
    "name": "Test User"
  }'
```

### Login User
```bash
curl -X POST http://localhost:3000/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "Password123!"
  }'
```

### Get Profile
```bash
curl -X GET http://localhost:3000/auth/profile \
  -H "Authorization: Bearer YOUR_TOKEN"
```

## 👤 Users

### Get My Profile
```bash
curl -X GET http://localhost:3000/users/me \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Update My Profile
```bash
curl -X PATCH http://localhost:3000/users/me \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Updated Name",
    "phone": "+1234567890"
  }'
```

## 🎛️ Features

### Get My Enabled Features
```bash
curl -X GET http://localhost:3000/features \
  -H "Authorization: Bearer YOUR_TOKEN"
```

## 💳 Subscriptions

### Get Subscription Status
```bash
curl -X GET http://localhost:3000/subscriptions/status \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Activate PRO Subscription
```bash
curl -X POST http://localhost:3000/subscriptions/activate \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "plan": "PRO",
    "months": 1
  }'
```

### Cancel Subscription
```bash
curl -X POST http://localhost:3000/subscriptions/cancel \
  -H "Authorization: Bearer YOUR_TOKEN"
```

## 💰 Expenses

### Create Expense
```bash
curl -X POST http://localhost:3000/expenses \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "amount": 50.75,
    "category": "Food",
    "note": "Lunch at restaurant",
    "paymentMethod": "UPI"
  }'
```

### Get All Expenses
```bash
# All expenses
curl -X GET http://localhost:3000/expenses \
  -H "Authorization: Bearer YOUR_TOKEN"

# With date filter
curl -X GET "http://localhost:3000/expenses?startDate=2024-01-01&endDate=2024-01-31" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Get Single Expense
```bash
curl -X GET http://localhost:3000/expenses/EXPENSE_ID \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Update Expense
```bash
curl -X PATCH http://localhost:3000/expenses/EXPENSE_ID \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "amount": 60.00,
    "note": "Updated note"
  }'
```

### Delete Expense
```bash
curl -X DELETE http://localhost:3000/expenses/EXPENSE_ID \
  -H "Authorization: Bearer YOUR_TOKEN"
```

## 🤝 Splits (Feature-Gated: Requires SPLIT)

### Create Split
```bash
curl -X POST http://localhost:3000/splits \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "expenseId": "EXPENSE_ID",
    "splits": [
      {
        "friendId": "FRIEND_USER_ID",
        "amount": 25.00
      },
      {
        "friendId": "ANOTHER_FRIEND_ID",
        "amount": 25.00
      }
    ]
  }'
```

### Get Splits for Expense
```bash
curl -X GET http://localhost:3000/splits/EXPENSE_ID \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Settle Split
```bash
curl -X PATCH http://localhost:3000/splits/EXPENSE_ID/FRIEND_ID/settle \
  -H "Authorization: Bearer YOUR_TOKEN"
```

## 👨‍💼 Admin Endpoints

### Login as Admin
```bash
curl -X POST http://localhost:3000/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@example.com",
    "password": "Admin123!"
  }'
```

### Toggle Plan Feature
```bash
# Enable SPLIT for FREE plan
curl -X POST http://localhost:3000/admin/plan-features \
  -H "Authorization: Bearer ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "plan": "FREE",
    "feature": "SPLIT",
    "enabled": true
  }'

# Disable EXPORT for PRO plan
curl -X POST http://localhost:3000/admin/plan-features \
  -H "Authorization: Bearer ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "plan": "PRO",
    "feature": "EXPORT",
    "enabled": false
  }'
```

### Get Plan Features
```bash
curl -X GET http://localhost:3000/admin/plan-features/FREE \
  -H "Authorization: Bearer ADMIN_TOKEN"

curl -X GET http://localhost:3000/admin/plan-features/PRO \
  -H "Authorization: Bearer ADMIN_TOKEN"
```

### Set User Feature Override
```bash
# Give promotional SPLIT access to a FREE user
curl -X POST http://localhost:3000/admin/user-features \
  -H "Authorization: Bearer ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "USER_ID",
    "feature": "SPLIT",
    "enabled": true,
    "reason": "Promotional access",
    "expiresAt": "2024-12-31T23:59:59Z"
  }'

# Disable EXPORT for a user (abuse prevention)
curl -X POST http://localhost:3000/admin/user-features \
  -H "Authorization: Bearer ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "USER_ID",
    "feature": "EXPORT",
    "enabled": false,
    "reason": "Abuse detected"
  }'
```

### Remove User Feature Override
```bash
curl -X DELETE http://localhost:3000/admin/user-features/USER_ID/SPLIT \
  -H "Authorization: Bearer ADMIN_TOKEN"
```

### Activate User Subscription
```bash
# Give PRO for 3 months
curl -X POST http://localhost:3000/admin/subscriptions/activate \
  -H "Authorization: Bearer ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "USER_ID",
    "plan": "PRO",
    "months": 3
  }'
```

### Update User Status
```bash
# Suspend user
curl -X PATCH http://localhost:3000/admin/users/USER_ID/status \
  -H "Authorization: Bearer ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "status": "SUSPENDED"
  }'

# Reactivate user
curl -X PATCH http://localhost:3000/admin/users/USER_ID/status \
  -H "Authorization: Bearer ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "status": "ACTIVE"
  }'
```

---

## 🧪 Test Scenarios

### Scenario 1: Feature Flag Demo

```bash
# 1. Register and login as regular user
curl -X POST http://localhost:3000/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"demo@test.com","password":"Demo123!","name":"Demo User"}'

# Login and save token
curl -X POST http://localhost:3000/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"demo@test.com","password":"Demo123!"}'

# 2. Check features (SPLIT should be false for FREE)
curl -X GET http://localhost:3000/features \
  -H "Authorization: Bearer YOUR_TOKEN"

# 3. Try to create split (should fail)
curl -X POST http://localhost:3000/splits \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"expenseId":"test","splits":[{"friendId":"friend","amount":10}]}'

# 4. Login as admin
curl -X POST http://localhost:3000/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@example.com","password":"Admin123!"}'

# 5. Enable SPLIT for FREE plan
curl -X POST http://localhost:3000/admin/plan-features \
  -H "Authorization: Bearer ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"plan":"FREE","feature":"SPLIT","enabled":true}'

# 6. Check features again (SPLIT should now be true)
curl -X GET http://localhost:3000/features \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Scenario 2: Subscription Upgrade

```bash
# 1. Check current subscription (should be FREE)
curl -X GET http://localhost:3000/subscriptions/status \
  -H "Authorization: Bearer YOUR_TOKEN"

# 2. Upgrade to PRO (in real app, this would verify payment first)
curl -X POST http://localhost:3000/subscriptions/activate \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"plan":"PRO","months":1}'

# 3. Check features (all should be true now)
curl -X GET http://localhost:3000/features \
  -H "Authorization: Bearer YOUR_TOKEN"
```

---

## 📝 Notes

- Replace `YOUR_TOKEN` with the `accessToken` from login response
- Replace `ADMIN_TOKEN` with admin's `accessToken`
- Replace `USER_ID`, `EXPENSE_ID`, `FRIEND_ID` with actual IDs
- All dates should be in ISO 8601 format
- Feature names: `SPLIT`, `EXPORT`, `CLOUD_SYNC`
- Plans: `FREE`, `PRO`
- User status: `ACTIVE`, `SUSPENDED`

---

## 🔧 Troubleshooting

### 401 Unauthorized
- Token expired or invalid
- Not logged in
- Wrong token used

### 403 Forbidden
- Feature not enabled
- Admin access required
- User account suspended

### 404 Not Found
- Resource doesn't exist
- Wrong ID
- Check if item was deleted

### 400 Bad Request
- Invalid input data
- Validation failed
- Check request body format
