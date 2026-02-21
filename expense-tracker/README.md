# 📱 UPI Expense Tracker

A beautiful Flutter app that helps you track expenses with UPI payment integration. The app allows you to scan UPI QR codes, redirect to payment apps, and manually log expenses with local SQLite storage.

## ✨ Features

### Core Functionality
- **Category-based Expense Tracking**: Food, Travel, Entertainment, Shopping, Bills, Others
- **QR Code Scanner**: Scan merchant UPI QR codes for quick expense logging
- **UPI Deep Linking**: Pre-fill payment details in UPI apps (GPay, PhonePe, Paytm, etc.)
- **Local Storage**: SQLite database for offline expense storage
- **Manual Entry**: Save expenses without UPI payment

### Analytics & Insights
- **Spending Summary**: Today, Week, and Month totals
- **Pie Charts**: Visual category-wise spending distribution
- **Category Breakdown**: Percentage and amount per category
- **Expense History**: Date-grouped transaction list

### UI/UX Features
- **Modern Dark Theme**: Vibrant purple gradients with glassmorphism
- **Smooth Animations**: Category cards, transitions, and micro-interactions
- **Swipe to Delete**: Easy expense removal
- **Advanced Filtering**: Filter by category and date range
- **Google Fonts**: Beautiful typography with Poppins and Inter

## 🏗️ Project Structure

```
lib/
├── models/
│   ├── category_model.dart      # Category data model with predefined categories
│   └── expense_model.dart        # Expense data model with serialization
├── services/
│   ├── database_helper.dart      # SQLite CRUD operations and analytics
│   └── upi_service.dart          # UPI QR parsing and deep linking
├── providers/
│   └── expense_provider.dart     # State management with Provider
├── screens/
│   ├── home_screen.dart          # Main dashboard with categories
│   ├── add_expense_screen.dart   # Expense creation form
│   ├── qr_scanner_screen.dart    # QR code scanner with overlay
│   ├── payment_confirmation_screen.dart  # Post-payment confirmation
│   ├── expense_history_screen.dart       # Filterable transaction list
│   └── analytics_screen.dart     # Spending insights and charts
├── widgets/
│   ├── category_card.dart        # Reusable category selection card
│   └── expense_tile.dart         # Expense list item with swipe-to-delete
├── theme/
│   └── app_theme.dart            # Dark theme configuration
└── main.dart                     # App entry point
```

## 📦 Dependencies

```yaml
dependencies:
  sqflite: ^2.3.0           # Local SQLite database
  path: ^1.9.0              # Path utilities
  mobile_scanner: ^3.5.5    # QR code scanning
  url_launcher: ^6.2.2      # UPI deep linking
  fl_chart: ^0.65.0         # Analytics charts
  intl: ^0.19.0             # Date/currency formatting
  provider: ^6.1.1          # State management
  google_fonts: ^6.1.0      # Custom fonts
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.5.2 or higher)
- Android Studio / VS Code
- Android device or emulator

### Installation

1. **Navigate to project directory**
   ```bash
   cd "c:\Users\Lenovo\Desktop\EXPENSE TRACKER\upi_tracker"
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## 📱 How It Works

### 1. Adding an Expense

1. **Select Category**: Tap a category card (Food, Travel, etc.) on home screen
2. **Enter Amount**: Input the expense amount
3. **Scan QR or Manual Entry**: 
   - Scan merchant UPI QR code, OR
   - Manually enter UPI ID
4. **Add Details**: Optional merchant name and notes
5. **Proceed to Payment**: App launches UPI app with pre-filled amount
6. **Confirm**: Return to app and confirm payment completion

### 2. Viewing History

- Navigate to **"View All"** from home screen
- Filter by category or date range
- Swipe left on any expense to delete
- View expenses grouped by date (Today, Yesterday, etc.)

### 3. Analytics

- Tap the bar chart icon on home screen
- View pie chart showing category distribution
- See detailed breakdown with percentages
- Track monthly spending trends

## ⚠️ Important Notes

> [!IMPORTANT]
> **Payment Verification**: This app does NOT verify actual bank transactions. Expense logging is based on user confirmation after UPI payment.

> [!NOTE]
> **Privacy**: All data is stored locally on your device using SQLite. No cloud sync or data collection.

> [!WARNING]
> **UPI Apps Required**: You must have at least one UPI app installed (GPay, PhonePe, Paytm, BHIM) for payment redirection to work.

## 🎨 Design Highlights

- **Dark Theme**: Modern dark background (slate-900) with vibrant accents
- **Gradient Cards**: Each category has unique color gradients
- **Glassmorphism**: Frosted glass effects on major cards
- **Smooth Transitions**: All navigation and state changes are animated
- **Responsive**: Works across different Android screen sizes

## 🔒 Permissions

The app requires:
- **Camera**: For QR code scanning
- **Internet**: For Google Fonts (optional)

## 📄 License

This project is created for educational and personal use.

## 👨‍💻 Developer

Built with ❤️ using Flutter

---

**Ready to track your expenses?** Run the app and start managing your spending smartly!
