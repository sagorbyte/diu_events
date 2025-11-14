# Quick Reference Guide - Student Interface Screens

## How to Access the Screens

### From Any Student Screen:
1. Tap the **hamburger menu icon** (three horizontal lines) in the top-right corner
2. The menu will slide up from the bottom showing all available options

### Menu Options:
- **My Profile** - View and edit your profile
- **My Events** - See all your registered events
- **Updates** - View event updates and notifications
- **Settings** ⭐ - Configure app preferences and view policies
- **Help & Support** ⭐ - Get help and contact support
- **About** ⭐ - Learn about the app and developer
- **Logout** - Sign out of your account

⭐ = Newly implemented screens

---

## Settings Screen

### What You Can Do:
1. **Enable/Disable Notifications:**
   - Toggle push notifications on/off
   - Toggle email notifications on/off
   - Toggle event reminders on/off
   - Toggle event update notifications on/off

2. **View Privacy & Security:**
   - Read the Privacy Policy
   - Read Terms of Use
   - Learn about Data Security measures

3. **View Account Information:**
   - See your complete profile details
   - Check data and storage information

4. **App Information:**
   - View app version
   - See developer information
   - Institution details

### How to Use:
- Simply tap any toggle switch to enable/disable
- Tap on items to view detailed information in dialogs
- All changes are saved automatically (indicated by a brief notification)

---

## Help & Support Screen

### What You Can Do:
1. **Get Quick Help:**
   - Browse Frequently Asked Questions (FAQs)
   - Read the User Guide
   - Learn Tips & Tricks

2. **Contact Support:**
   - Send email to majumder15-4907@diu.edu.bd
   - Call +8801725691441
   - Visit the DIU website
   - Connect on Facebook

3. **Report Issues:**
   - Report bugs you encounter
   - Send feedback about the app
   - Report security concerns

4. **Join Community:**
   - Access DIU Facebook page
   - Learn about the DIU community

### How to Use:
- Tap on any option to view details or take action
- Email and phone options will open your default email/phone app
- Website and social media links open in your browser
- Fill out forms to submit bug reports or feedback

---

## About Screen

### What You Can See:
1. **App Information:**
   - App logo and branding
   - Current version number
   - Complete feature list

2. **Developer Information:**
   - Developer: Sagor Majumder
   - Department: CSE
   - Institution: Daffodil International University

3. **Project Details:**
   - Project type: Final Year Design Project
   - Degree: BSc in Computer Science & Engineering
   - Year: 2025

4. **Institution Details:**
   - About Daffodil International University
   - Link to university website

5. **Contact Information:**
   - Support email
   - Support phone number
   - University website

6. **Legal Information:**
   - Privacy Policy
   - Terms of Use
   - Open Source Licenses

### How to Use:
- Scroll through to read all information
- Tap on contact items to email, call, or visit website
- Tap on legal items to read full policies

---

## Common Questions

### Q: Will my notification settings be saved?
A: Currently, the settings show your preferences in the UI. Full backend integration will persist these across app sessions.

### Q: How do I contact support?
A: Go to Help & Support screen and tap on Email Support or Phone Support. This will open your default email app or phone dialer.

### Q: Where can I see who developed this app?
A: Check the About screen - it has complete developer and project information.

### Q: Can I change my language preferences?
A: Language preferences will be added in a future update. Currently, the app uses Hind Siliguri font for Bengali and English support.

### Q: What if I find a bug?
A: Go to Help & Support > Report Issues > Report a Bug. Describe the issue and submit.

### Q: How do I provide feedback?
A: Go to Help & Support > Report Issues > Send Feedback. Share your thoughts and submit.

---

## Tips & Tricks

💡 **Settings Screen:**
- Review your notification settings regularly
- Check the Privacy Policy to understand data usage
- Use Account Information to verify your profile is complete

💡 **Help & Support Screen:**
- Check FAQs first before contacting support
- Use Tips & Tricks to discover hidden features
- Save the support email and phone number for quick access

💡 **About Screen:**
- Scroll to see all features of the app
- Tap contact information to quickly reach out
- Review legal information to understand your rights

---

## Navigation Tips

1. **Back Navigation:**
   - Use the back arrow (←) in the top-left to return to previous screen
   - Use your device's back button

2. **Menu Access:**
   - The hamburger menu (☰) is always available in the top-right
   - Bottom navigation bar provides quick access to main sections

3. **External Links:**
   - Links with (↗) icon will open in external apps
   - You can always return to the app using your device's app switcher

---

## Troubleshooting

**Settings not saving?**
- Currently, settings are displayed in the UI. Backend persistence will be added in future updates.

**Can't open email/phone links?**
- Ensure you have an email app or phone app configured on your device
- Check app permissions if needed

**Dialog boxes not showing?**
- Try tapping the item again
- If issue persists, restart the app

**Need more help?**
- Go to Help & Support screen
- Contact support via email or phone
- Check the FAQs section

---

## For Developers

### File Locations:
```
lib/features/student/screens/
├── settings_screen.dart
├── help_support_screen.dart
└── about_screen.dart
```

### Integration Point:
```
lib/features/student/screens/widgets/
└── student_hamburger_menu.dart
```

### Navigation Code Example:
```dart
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => const SettingsScreen(),
  ),
);
```

---

## Version Information

- **Implementation Date:** 2025
- **Version:** 1.0.0
- **Platform:** Flutter
- **Compatibility:** Android, iOS, Web

---

**Need Help?**  
Contact: majumder15-4907@diu.edu.bd  
Phone: +8801725691441
Website: www.daffodilvarsity.edu.bd

**Developed by:**  
Sagor Majumder  
Department of CSE  
Daffodil International University
