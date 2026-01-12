# Authentication & Forms Guide

Your Flutter app now supports full authentication, form building, OTP verification, and data submission capabilities!

## 🔐 Authentication Features

### Login Action
```json
{
    "type": "login",
    "api": "https://yourapi.com/login",
    "method": "POST",
    "body": {
        "email": "user@example.com",
        "password": "password123"
    },
    "navigate_to": "https://yourapi.com/api/home-screen"
}
```

**Expected API Response:**
```json
{
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
        "id": 1,
        "name": "John Doe",
        "email": "user@example.com"
    }
}
```

The app will automatically:
- Extract and store the bearer token
- Save user data
- Add `Authorization: Bearer <token>` to all future API requests
- Navigate to the specified screen

### Logout Action
```json
{
    "type": "logout",
    "navigate_to": "https://yourapi.com/api/login-screen"
}
```

This will:
- Clear all stored tokens
- Clear user data
- Navigate to login/home screen

### Token Storage
The app supports these token key names from your API response:
- `token`
- `access_token`
- `bearer_token`
- `auth_token`

## 📝 Form Widget

### Complete Form Example
```json
{
    "type": "form",
    "fields": [
        {
            "type": "text",
            "key": "username",
            "label": "Username",
            "placeholder": "Enter username",
            "required": true
        },
        {
            "type": "email",
            "key": "email",
            "label": "Email Address",
            "placeholder": "you@example.com",
            "required": true
        },
        {
            "type": "password",
            "key": "password",
            "label": "Password",
            "placeholder": "Enter password",
            "required": true,
            "obscure": true
        },
        {
            "type": "number",
            "key": "age",
            "label": "Age",
            "placeholder": "Enter your age"
        },
        {
            "type": "textarea",
            "key": "bio",
            "label": "Bio",
            "placeholder": "Tell us about yourself"
        },
        {
            "type": "dropdown",
            "key": "country",
            "label": "Country",
            "required": true,
            "options": [
                {"label": "India", "value": "IN"},
                {"label": "USA", "value": "US"},
                {"label": "UK", "value": "GB"}
            ]
        },
        {
            "type": "checkbox",
            "key": "terms",
            "label": "I agree to terms and conditions"
        }
    ],
    "submit_label": "Register",
    "submit_action": {
        "type": "submit",
        "api": "https://yourapi.com/register",
        "method": "POST",
        "success_message": "Registration successful!",
        "navigate_to_api": "https://yourapi.com/api/home-screen"
    },
    "clear_on_success": true
}
```

### Field Types

#### Text Input
```json
{
    "type": "text",
    "key": "fieldName",
    "label": "Display Label",
    "placeholder": "Enter text...",
    "required": true
}
```

#### Email Input
```json
{
    "type": "email",
    "key": "email",
    "label": "Email",
    "placeholder": "you@example.com",
    "required": true
}
```

#### Password Input
```json
{
    "type": "password",
    "key": "password",
    "label": "Password",
    "placeholder": "Enter password",
    "required": true,
    "obscure": true
}
```

#### Number Input
```json
{
    "type": "number",
    "key": "age",
    "label": "Age",
    "placeholder": "Enter number"
}
```

#### Textarea
```json
{
    "type": "textarea",
    "key": "description",
    "label": "Description",
    "placeholder": "Enter description..."
}
```

#### Dropdown
```json
{
    "type": "dropdown",
    "key": "category",
    "label": "Select Category",
    "required": true,
    "options": [
        {"label": "Option 1", "value": "opt1"},
        {"label": "Option 2", "value": "opt2"}
    ]
}
```

#### Checkbox
```json
{
    "type": "checkbox",
    "key": "agree",
    "label": "I agree to terms"
}
```

## 🔘 Button Widget

### Button Example
```json
{
    "type": "button",
    "label": "Click Me",
    "style": "primary",
    "full_width": true,
    "action": {
        "type": "navigate",
        "api": "https://yourapi.com/api/next-screen"
    }
}
```

### Button Styles
- `primary` - Gradient blue/purple (default)
- `gradient` - Same as primary
- `secondary` - Gray
- `success` - Green
- `danger` - Red
- `warning` - Orange

## 🌐 API Call Actions

### Submit/Call API Action
```json
{
    "type": "submit",
    "api": "https://yourapi.com/api/endpoint",
    "method": "POST",
    "body": {
        "key": "value"
    },
    "include_auth": true,
    "success_message": "Success!",
    "error_message": "Failed!",
    "navigate_to_api": "https://yourapi.com/api/next-screen",
    "pop_on_success": false
}
```

### HTTP Methods Supported
- `GET` - Fetch data
- `POST` - Create data
- `PUT` - Update data (full replace)
- `PATCH` - Update data (partial)
- `DELETE` - Delete data

### Action Options
- `include_auth` - Include bearer token (default: true)
- `success_message` - Message to show on success
- `error_message` - Message to show on error
- `navigate_to_api` - Navigate to new screen after success
- `pop_on_success` - Close current screen on success
- `body` - Data to send with request

## 📱 Complete Login Flow Example

### 1. Login Screen (`login.json`)
```json
{
    "title": "Login",
    "display_title": false,
    "widgets": [
        {
            "type": "app_header",
            "app_name": "My App"
        },
        {
            "type": "form",
            "fields": [
                {
                    "type": "email",
                    "key": "email",
                    "label": "Email",
                    "required": true
                },
                {
                    "type": "password",
                    "key": "password",
                    "label": "Password",
                    "required": true
                }
            ],
            "submit_label": "Login",
            "submit_action": {
                "type": "login",
                "api": "https://yourapi.com/login",
                "method": "POST",
                "navigate_to": "https://yourapi.com/api/dashboard"
            }
        }
    ]
}
```

### 2. Dashboard Screen (Protected)
All API calls will automatically include `Authorization: Bearer <token>` header.

```json
{
    "type": "button",
    "label": "Logout",
    "style": "danger",
    "action": {
        "type": "logout",
        "navigate_to": "https://yourapi.com/api/login-screen"
    }
}
```

## 🔒 Backend API Requirements

### Login Endpoint
**Request:**
```
POST /api/login
Content-Type: application/json

{
    "email": "user@example.com",
    "password": "password123"
}
```

**Response:**
```json
{
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
        "id": 1,
        "name": "John Doe",
        "email": "user@example.com"
    }
}
```

### Protected Endpoints
All subsequent API calls will include:
```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

Your backend should verify this token and return appropriate data or 401 Unauthorized.

## 💡 Tips

1. **Form Validation**: All `required: true` fields are validated before submission
2. **Token Persistence**: Token is saved locally and survives app restarts
3. **Automatic Headers**: Bearer token is automatically added to all API calls
4. **Error Handling**: API errors are caught and displayed to users
5. **Loading States**: Forms show loading spinner during submission

## 🎨 Example: Registration Form
```json
{
    "type": "form",
    "fields": [
        {
            "type": "text",
            "key": "name",
            "label": "Full Name",
            "required": true
        },
        {
            "type": "email",
            "key": "email",
            "label": "Email",
            "required": true
        },
        {
            "type": "password",
            "key": "password",
            "label": "Password",
            "required": true
        },
        {
            "type": "password",
            "key": "password_confirmation",
            "label": "Confirm Password",
            "required": true
        },
        {
            "type": "dropdown",
            "key": "role",
            "label": "I am a",
            "options": [
                {"label": "Student", "value": "student"},
                {"label": "Teacher", "value": "teacher"},
                {"label": "Professional", "value": "professional"}
            ]
        },
        {
            "type": "checkbox",
            "key": "terms",
            "label": "I agree to Terms & Conditions"
        }
    ],
    "submit_label": "Create Account",
    "submit_action": {
        "type": "login",
        "api": "https://yourapi.com/register",
        "method": "POST",
        "navigate_to": "https://yourapi.com/api/home"
    }
}
```
## Passing Data Between Screens

When navigating between screens, you can pass form field values as query parameters using the `pass_data` parameter in navigate actions.

### Using pass_data Parameter

The `pass_data` parameter accepts an array of field keys from your FormDataManager. These values will be appended as query parameters to the navigation URL.

**Example: OTP Flow**

```json
{
    "type": "button",
    "button_text": "Send OTP",
    "click_action": {
        "type": "api_call",
        "api": "https://yourapi.com/api/send-otp",
        "method": "POST",
        "success_action": {
            "type": "navigate",
            "api": "https://yourapi.com/api/otp-verification-screen",
            "pass_data": ["phone"]
        }
    }
}
```

**Result**: If the user entered "1234567890" in the phone field, the navigation URL becomes:
```
https://yourapi.com/api/otp-verification-screen?phone=1234567890
```

### Complete OTP Authentication Flow Example

Here's a complete example showing how to pass data between screens in an OTP flow:

**Step 1: Phone Number Collection Screen**

```json
{
    "widgets": [
        {
            "type": "input",
            "id": "phone_input",
            "input_type": "phone",
            "key": "phone",
            "label": "Phone Number",
            "icon": "phone",
            "max_length": 10
        },
        {
            "type": "button",
            "button_text": "Send OTP",
            "click_action": {
                "type": "api_call",
                "api": "https://yourapi.com/api/send-otp",
                "method": "POST",
                "success_action": {
                    "type": "show_widget",
                    "widget_id": "otp_input"
                }
            }
        },
        {
            "type": "input",
            "id": "otp_input",
            "input_type": "number",
            "key": "otp",
            "label": "Enter OTP",
            "icon": "lock",
            "max_length": 6,
            "visibility": "hidden"
        },
        {
            "type": "button",
            "button_text": "Verify & Login",
            "click_action": {
                "type": "login",
                "api": "https://yourapi.com/api/login",
                "method": "POST",
                "navigate_to": "https://yourapi.com/api/home",
                "pass_data": ["phone", "otp"]
            },
            "visibility": "hidden",
            "id": "verify_button"
        }
    ]
}
```

**Step 2: Navigation to Next Screen with Data**

```json
{
    "type": "button",
    "button_text": "Continue to Profile",
    "click_action": {
        "type": "navigate",
        "api": "https://yourapi.com/api/profile-screen",
        "pass_data": ["phone", "user_id", "email"]
    }
}
```

**Result**: Creates URL like:
```
https://yourapi.com/api/profile-screen?phone=1234567890&user_id=123&email=user@example.com
```

### Multiple Field Passing

You can pass multiple fields at once:

```json
{
    "type": "navigate",
    "api": "https://yourapi.com/api/checkout",
    "pass_data": ["product_id", "quantity", "color", "size"]
}
```

This is useful for:
- Passing order details to checkout screens
- Sending search filters to results pages
- Carrying user selections across multi-step forms
- Maintaining context in wizard-style flows

### Resend OTP / Go Back with Data

When you need to navigate back to a previous screen with prefilled data (like resending OTP):

```json
{
    "type": "text_button",
    "text": "Resend OTP",
    "action": {
        "type": "navigate",
        "api": "https://yourapi.com/api/login-screen",
        "pass_data": ["phone"]
    }
}
```

This will:
1. Navigate back to the login screen
2. Pass the phone number as a query parameter
3. Your server can return the screen with the phone field prefilled
4. The user can request a new OTP without re-entering their phone number

### Important Notes

- Only fields that exist in FormDataManager will be passed
- Empty or null values are skipped
- Values are URL-encoded automatically
- Works with all navigate actions (button click_action, success_action, etc.)
- Use `success_action` instead of `navigate_to` in login actions for better control