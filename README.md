# Sendmail.jl

[![Julia](https://img.shields.io/badge/Julia-1.6+-9558B2?logo=julia)](https://julialang.org)

Simple and reliable email sending for Julia using SMTP with SSL/TLS support.

## Features

- ✅ Simple API for sending emails
- ✅ SSL/TLS support with automatic certificate detection
- ✅ CC and BCC recipients
- ✅ Priority levels (High, Normal, Low)
- ✅ Multiple recipients support
- ✅ HTML email support
- ✅ Configurable via TOML file

## Installation

```julia
using Pkg
Pkg.add(url="https://github.com/yourusername/Sendmail.jl")
```

Or clone the repository:
```bash
git clone https://github.com/yourusername/Sendmail.jl.git
```

## Quick Start

### 1. Create `config.toml`

```toml
[smtp]
server = "smtp.gmail.com"
port = 587
use_ssl = true

[credentials]
email = "your.email@gmail.com"
password = "your_password"
app_password = "your_app_password"

[sender]
display_name = "Your Name"
display_email = "your.email@gmail.com"
```

**Security Note:** Use environment variable for app password:
```bash
export EMAIL_APP_PASSWORD="your_app_password"
```

### 2. Send an Email

```julia
using Sendmail

# Configure (auto-loads on first use)
Sendmail.configure("config.toml")

# Send email
Sendmail.send_email(
    "recipient@example.com",
    "Hello from Julia!",
    "<h1>Hello!</h1><p>This is a test email.</p>"
)
```

## Usage Examples

### Basic Email
```julia
Sendmail.send_email(
    "recipient@example.com",
    "Subject",
    "<h1>Hello!</h1><p>Message body</p>"
)
```

### Email with CC and BCC
```julia
Sendmail.send_email(
    "recipient@example.com",
    "Subject",
    "<p>Message</p>",
    cc="cc@example.com",
    bcc="bcc@example.com"
)
```

### High Priority Email
```julia
Sendmail.send_email(
    "recipient@example.com",
    "Urgent!",
    "<p>Urgent message</p>",
    priority=1  # 1=High, 3=Normal, 5=Low
)
```

### Multiple Recipients
```julia
Sendmail.send_email(
    ["user1@example.com", "user2@example.com"],
    "Subject",
    "<p>Message to multiple recipients</p>"
)
```

### Multiple CC Recipients
```julia
Sendmail.send_email(
    "recipient@example.com",
    "Subject",
    "<p>Message</p>",
    cc=["cc1@example.com", "cc2@example.com"]
)
```

## API Reference

### `configure(config_file="config.toml")`
Load configuration from TOML file. Called automatically on first `send_email` if not called explicitly.

**Parameters:**
- `config_file`: Path to configuration file (default: "config.toml")

**Returns:** Configuration object

### `send_email(recipient, subject, body; priority=3, cc=nothing, bcc=nothing, use_display_name=true)`
Send an email via SMTP.

**Parameters:**
- `recipient`: Email address (String) or list of addresses (Vector{String})
- `subject`: Email subject (String)
- `body`: Email body in HTML format (String)
- `priority`: Priority level - 1 (High), 3 (Normal), 5 (Low) (default: 3)
- `cc`: CC recipient(s) - single email or list (default: nothing)
- `bcc`: BCC recipient(s) - single email or list (default: nothing)
- `use_display_name`: Use display name from config (default: true)

**Returns:** `true` if successful, `false` otherwise

## Gmail Setup

For Gmail, you need to use an **App Password**:

1. Enable 2-Factor Authentication on your Google account
2. Go to [Google App Passwords](https://myaccount.google.com/apppasswords)
3. Generate an app password for "Mail"
4. Use this password in your `config.toml` or environment variable

## Configuration File

```toml
[smtp]
server = "smtp.gmail.com"     # SMTP server address
port = 587                     # SMTP port (587 for TLS, 465 for SSL)
use_ssl = true                 # Enable SSL/TLS

[credentials]
email = "your@email.com"       # Your email address
password = "password"          # Your password (not recommended)
app_password = "app_password"  # App password (recommended)

[sender]
display_name = "Your Name"     # Display name in emails
display_email = "your@email.com"
```

## Common SMTP Settings

| Provider | Server | Port | SSL |
|----------|--------|------|-----|
| Gmail | smtp.gmail.com | 587 | true |
| Outlook | smtp-mail.outlook.com | 587 | true |
| Yahoo | smtp.mail.yahoo.com | 587 | true |
| Office 365 | smtp.office365.com | 587 | true |

## Testing

```julia
using Pkg
Pkg.test("Sendmail")
```

## Troubleshooting

### SSL Certificate Errors

If you encounter SSL certificate errors, install CA certificates:

**Ubuntu/Debian:**
```bash
sudo apt-get install ca-certificates
```

**Fedora/RHEL:**
```bash
sudo yum install ca-certificates
```

### Authentication Failed

- Ensure you're using an App Password, not your regular password
- Check if 2FA is enabled on your account
- Verify SMTP server and port settings

## License

MIT License

## Author

Jaewoo Joung (jaewoo.joung@gmail.com)

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
