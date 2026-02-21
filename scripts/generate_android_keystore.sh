#!/bin/bash
# Android Keystore Generation Script
# Story 0.6: Generate production signing key for Play Store

set -e

echo "🔐 Android Keystore Generator"
echo "=============================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check if keytool is available
if ! command -v keytool &> /dev/null; then
    echo -e "${RED}❌ Error: keytool not found${NC}"
    echo "keytool should be included with Java JDK"
    echo "Install Java JDK: https://www.oracle.com/java/technologies/downloads/"
    exit 1
fi

echo -e "${GREEN}✅ keytool found${NC}"
echo ""

# Output paths
KEYSTORE_DIR="android/app"
KEYSTORE_FILE="upload-keystore.jks"
KEYSTORE_PATH="$KEYSTORE_DIR/$KEYSTORE_FILE"

# Get keystore information
echo "📝 Enter keystore information:"
echo ""
read -p "Key Alias (e.g., upload): " KEY_ALIAS
read -sp "Key Password: " KEY_PASSWORD
echo ""
read -sp "Store Password: " STORE_PASSWORD
echo ""
echo ""
read -p "Your Name: " DNAME_CN
read -p "Organization (e.g., FrigoFute): " DNAME_O
read -p "City: " DNAME_L
read -p "State/Province: " DNAME_ST
read -p "Country Code (e.g., FR): " DNAME_C

echo ""
echo -e "${YELLOW}⏳ Generating keystore...${NC}"
echo ""

# Generate keystore
keytool -genkey -v \
  -keystore "$KEYSTORE_PATH" \
  -alias "$KEY_ALIAS" \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -storepass "$STORE_PASSWORD" \
  -keypass "$KEY_PASSWORD" \
  -dname "CN=$DNAME_CN, O=$DNAME_O, L=$DNAME_L, ST=$DNAME_ST, C=$DNAME_C"

echo ""
echo -e "${GREEN}✅ Keystore generated successfully!${NC}"
echo ""
echo "📁 Keystore location: $KEYSTORE_PATH"
echo ""

# Create key.properties file
KEY_PROPERTIES_PATH="android/key.properties"
cat > "$KEY_PROPERTIES_PATH" <<EOF
storePassword=$STORE_PASSWORD
keyPassword=$KEY_PASSWORD
keyAlias=$KEY_ALIAS
storeFile=$KEYSTORE_FILE
EOF

echo -e "${GREEN}✅ key.properties created${NC}"
echo ""

# Verify keystore
echo "🔍 Verifying keystore..."
keytool -list -v -keystore "$KEYSTORE_PATH" -storepass "$STORE_PASSWORD" | head -n 20

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Keystore setup complete!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Next steps:"
echo ""
echo "1. ⚠️  BACKUP YOUR KEYSTORE SECURELY!"
echo "   - Store in password manager"
echo "   - Keep offline backup"
echo "   - NEVER commit to git"
echo ""
echo "2. Add to .gitignore:"
echo "   android/app/upload-keystore.jks"
echo "   android/key.properties"
echo ""
echo "3. For GitHub Actions CI/CD:"
echo "   # Convert keystore to base64"
echo "   base64 android/app/upload-keystore.jks > keystore.txt"
echo ""
echo "   # Add as GitHub Secret: ANDROID_KEYSTORE_FILE"
echo "   # Add other secrets:"
echo "   #   - ANDROID_KEY_ALIAS=$KEY_ALIAS"
echo "   #   - ANDROID_KEY_PASSWORD=<your_key_password>"
echo "   #   - ANDROID_KEYSTORE_PASSWORD=<your_store_password>"
echo ""
echo "4. Update android/app/build.gradle.kts:"
echo "   See: docs/CI_CD_DOCUMENTATION.md"
echo ""
echo -e "${RED}⚠️  SECURITY WARNING:${NC}"
echo "If you lose this keystore, you CANNOT update your app on Play Store!"
echo "You will have to publish a new app with a different package name."
echo ""
