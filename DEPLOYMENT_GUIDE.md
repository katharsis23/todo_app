# 🚀 Deployment Guide for Flutter App on Vercel

## 📋 Prerequisites
- GitHub repository with your Flutter project
- Vercel account (free tier available)
- Flutter project configured for web

## 🔧 Step 1: Vercel Setup

### 1. Create Vercel Account
1. Go to [vercel.com](https://vercel.com)
2. Sign up with your GitHub account
3. Install Vercel CLI: `npm i -g vercel`

### 2. Create New Project
1. Click "Add New..." → "Project"
2. Import your GitHub repository
3. Configure project settings:
   - **Framework Preset**: Other
   - **Root Directory**: `./`
   - **Build Command**: `cd todo_app && flutter build web --release --base-href="/"`
   - **Output Directory**: `todo_app/build/web`
   - **Install Command**: `cd todo_app && flutter pub get`

## 🔐 Step 2: Get Vercel Credentials

### 1. Get Vercel Token
```bash
vercel login
vercel tokens create
```
Copy the generated token.

### 2. Get Project Details
```bash
vercel link
```
This will create `.vercel` directory with:
- `orgId` in `project.json`
- `projectId` in `project.json`

## 🔑 Step 3: Configure GitHub Secrets

In your GitHub repository:
1. Go to Settings → Secrets and variables → Actions
2. Add these secrets:

| Secret Name | Value |
|-------------|-------|
| `VERCEL_TOKEN` | Your Vercel token |
| `ORG_ID` | Your Vercel organization ID |
| `PROJECT_ID` | Your Vercel project ID |

## 🚀 Step 4: Deploy

### Automatic Deployment
- Push to `main` branch → Automatic deployment to production
- Push to `dev` branch → Runs tests but doesn't deploy

### Manual Deployment
```bash
# From project root
vercel --prod
```

## 📁 Project Structure
```
todo_app/
├── .github/workflows/CI-CD.yml  # CI/CD pipeline
├── vercel.json                  # Vercel configuration
├── todo_app/
│   ├── build/web/              # Generated web build
│   ├── lib/                    # Flutter source code
│   └── pubspec.yaml            # Flutter dependencies
└── DEPLOYMENT_GUIDE.md         # This file
```

## 🔧 Configuration Details

### vercel.json
- Configures build settings for Flutter web
- Routes all requests to Flutter build directory
- Sets up proper build commands

### CI/CD Pipeline
- **Build & Test**: Runs on every push/PR
- **Deploy**: Only on main branch pushes
- **Flutter Version**: 3.35.6 (matches your project)

## 🐛 Troubleshooting

### Common Issues
1. **Build fails**: Check Flutter version compatibility
2. **Routing issues**: Ensure `--base-href="/"` is set
3. **Missing assets**: Verify assets are in `pubspec.yaml`

### Debug Commands
```bash
# Local build test
cd todo_app && flutter build web --release --base-href="/"

# Check Vercel logs
vercel logs

# Preview deployment
vercel
```

## 📊 Benefits of Vercel
- ✅ Free tier with generous limits
- ✅ Automatic HTTPS
- ✅ Global CDN
- ✅ Instant rollbacks
- ✅ Preview deployments for PRs
- ✅ Custom domains support

## 🔄 Alternative: Netlify

If you prefer Netlify, create `netlify.toml`:
```toml
[build]
  base = "todo_app/"
  command = "flutter build web --release --base-href=/"
  publish = "build/web"

[[redirects]]
  from = "/*"
  to = "/index.html"
  status = 200
```

## 📞 Support
- Vercel docs: [vercel.com/docs](https://vercel.com/docs)
- Flutter web: [flutter.dev/web](https://flutter.dev/web)
- Issues: Check GitHub Actions logs first
