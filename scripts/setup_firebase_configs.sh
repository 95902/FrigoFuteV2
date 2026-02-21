#!/bin/bash
# Firebase Configuration Setup Script
# Story 0.6: Replaces temporary google-services.json files with real ones
#
# Prerequisites:
# 1. Firebase projects created (dev, staging, prod)
# 2. Firebase CLI installed: npm install -g firebase-tools
# 3. Logged in to Firebase: firebase login

set -e

echo "🔥 Firebase Configuration Setup"
echo "================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo -e "${RED}❌ Error: Firebase CLI not installed${NC}"
    echo "Install with: npm install -g firebase-tools"
    exit 1
fi

echo -e "${GREEN}✅ Firebase CLI found${NC}"
echo ""

# Firebase project IDs (update these with your actual project IDs)
echo "📝 Enter your Firebase project IDs:"
read -p "Dev project ID (e.g., frigofute-dev): " DEV_PROJECT_ID
read -p "Staging project ID (e.g., frigofute-staging): " STAGING_PROJECT_ID
read -p "Prod project ID (e.g., frigofute-prod): " PROD_PROJECT_ID

echo ""
echo "Using project IDs:"
echo "  - Dev: $DEV_PROJECT_ID"
echo "  - Staging: $STAGING_PROJECT_ID"
echo "  - Prod: $PROD_PROJECT_ID"
echo ""

# Function to download Android config
download_android_config() {
    local project_id=$1
    local flavor=$2
    local output_path="android/app/src/$flavor/google-services.json"

    echo -e "${YELLOW}⏳ Downloading Android config for $flavor...${NC}"

    # Switch to project
    firebase use "$project_id" --add || {
        echo -e "${RED}❌ Failed to select project $project_id${NC}"
        echo "Make sure the project exists and you have access"
        return 1
    }

    # Download config
    firebase apps:sdkconfig ANDROID -o "$output_path" || {
        echo -e "${RED}❌ Failed to download config${NC}"
        echo "Make sure you have an Android app registered in the Firebase project"
        return 1
    }

    echo -e "${GREEN}✅ Downloaded: $output_path${NC}"
}

# Function to download iOS config
download_ios_config() {
    local project_id=$1
    local flavor=$2
    local output_path="ios/Runner/Firebase/$flavor/GoogleService-Info.plist"

    echo -e "${YELLOW}⏳ Downloading iOS config for $flavor...${NC}"

    # Create directory if it doesn't exist
    mkdir -p "$(dirname "$output_path")"

    # Switch to project
    firebase use "$project_id" --add || {
        echo -e "${RED}❌ Failed to select project $project_id${NC}"
        return 1
    }

    # Download config
    firebase apps:sdkconfig IOS -o "$output_path" || {
        echo -e "${RED}❌ Failed to download config${NC}"
        echo "Make sure you have an iOS app registered in the Firebase project"
        return 1
    }

    echo -e "${GREEN}✅ Downloaded: $output_path${NC}"
}

# Download all configs
echo ""
echo "📥 Downloading Firebase configurations..."
echo ""

# Android configs
download_android_config "$DEV_PROJECT_ID" "dev"
download_android_config "$STAGING_PROJECT_ID" "staging"
download_android_config "$PROD_PROJECT_ID" "prod"

echo ""

# iOS configs
download_ios_config "$DEV_PROJECT_ID" "dev"
download_ios_config "$STAGING_PROJECT_ID" "staging"
download_ios_config "$PROD_PROJECT_ID" "prod"

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Firebase configuration complete!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Next steps:"
echo "1. Verify the downloaded files are correct"
echo "2. Test builds with: flutter build apk --flavor dev"
echo "3. Commit the real google-services.json files (remove .gitignore entries if needed)"
echo ""
echo -e "${YELLOW}⚠️  Security Note:${NC}"
echo "  - Do NOT commit prod google-services.json to public repos"
echo "  - Use GitHub Secrets for CI/CD deployments"
echo "  - Keep staging configs in private repos only"
echo ""
