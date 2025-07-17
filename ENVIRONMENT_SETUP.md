# 🔒 Environment Configuration Guide

## Security Notice
**NEVER commit real API keys to version control!**

## Setup Instructions

### 1. Copy Environment Template
```bash
cp .env.example .env
```

### 2. Configure Your API Keys

Edit the `.env` file with your actual credentials:

#### Binance API Setup
1. Go to [Binance API Management](https://www.binance.com/en/support/faq/360002502072)
2. Create new API Key named "InvictusTrader"
3. Enable permissions: "Spot & Margin Trading" + "Futures"
4. Copy both API Key and Secret Key to `.env`

#### Groq AI Setup
1. Go to [Groq Console](https://console.groq.com/keys)
2. Create account or sign in
3. Generate new API Key
4. Copy immediately (won't be shown again)
5. Paste into `.env` file

### 3. Example Configuration

```bash
# Real values - KEEP PRIVATE!
BINANCE_API_KEY=your_actual_binance_api_key
BINANCE_SECRET_KEY=your_actual_binance_secret_key
GROQ_API_KEY=gsk_your_actual_groq_api_key
```

## Security Best Practices

- ✅ `.env` is in `.gitignore` 
- ✅ Never commit real API keys
- ✅ Use TestNet for development
- ✅ Rotate keys regularly
- ✅ Limit API permissions

## Troubleshooting

### Git Push Blocked?
If you accidentally commit secrets:
```bash
git rm --cached .env
git commit --amend --no-edit
git push origin main
```

### API Connection Issues?
1. Verify keys are correct
2. Check API permissions
3. Test with API config screen
4. Check network connectivity

## Support
For configuration help, see the in-app API Configuration screen with step-by-step guides.
