#!/bin/bash

# Pre-Commit Security Check Script
# Story 0.10 Phase 9: CI/CD Security Checks
#
# Run this script before committing to catch security issues early:
#   ./scripts/security_check.sh
#
# Or add to git pre-commit hook:
#   ln -s ../../scripts/security_check.sh .git/hooks/pre-commit

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
WARNINGS=0
ERRORS=0

echo ""
echo "======================================"
echo "   SECURITY CHECK"
echo "======================================"
echo ""

# ========================================
# 1. SECRETS DETECTION
# ========================================

echo -e "${BLUE}🔍 Checking for hardcoded secrets...${NC}"

# Check for API keys
if grep -rn "API_KEY\s*=\s*['\"][^'\"]*['\"]" lib/ --include="*.dart" --exclude-dir={test,integration_test} 2>/dev/null; then
  echo -e "${RED}❌ CRITICAL: Hardcoded API_KEY found${NC}"
  ((ERRORS++))
else
  echo -e "${GREEN}✅ No hardcoded API keys${NC}"
fi

# Check for secrets
SECRET_PATTERNS=("SECRET" "password\s*=" "token\s*=" "private.*key")
for pattern in "${SECRET_PATTERNS[@]}"; do
  if grep -rn -i "$pattern\s*=\s*['\"][^'\"]*['\"]" lib/ --include="*.dart" --exclude-dir={test,integration_test} 2>/dev/null; then
    echo -e "${YELLOW}⚠️  WARNING: Potential secret found matching '$pattern'${NC}"
    ((WARNINGS++))
  fi
done

# Check for Firebase credentials
if grep -rn "google-services.json\|GoogleService-Info.plist" lib/ --include="*.dart" 2>/dev/null; then
  echo -e "${RED}❌ CRITICAL: Firebase config referenced in code${NC}"
  ((ERRORS++))
fi

echo ""

# ========================================
# 2. GIT CONFIGURATION
# ========================================

echo -e "${BLUE}🔍 Checking .gitignore configuration...${NC}"

# Check if .env files are gitignored
if grep -q "^\.env$\|^\.env\..*$\|^\*\.env$" .gitignore 2>/dev/null; then
  echo -e "${GREEN}✅ .env files properly gitignored${NC}"
else
  echo -e "${RED}❌ CRITICAL: .env files not in .gitignore${NC}"
  echo "   Add to .gitignore:"
  echo "   .env"
  echo "   .env.*"
  echo "   !.env.example"
  ((ERRORS++))
fi

# Check if .env files are staged
if git diff --cached --name-only | grep -E "\.env$|\.env\.(dev|staging|prod)$" 2>/dev/null; then
  echo -e "${RED}❌ CRITICAL: .env files staged for commit${NC}"
  echo "   Remove with: git reset HEAD .env*"
  ((ERRORS++))
fi

echo ""

# ========================================
# 3. CODE ANALYSIS
# ========================================

echo -e "${BLUE}🔍 Running static analysis...${NC}"

if flutter analyze --no-pub 2>&1 | grep -E "error|warning" >/dev/null; then
  echo -e "${RED}❌ FAILED: flutter analyze found issues${NC}"
  flutter analyze --no-pub
  ((ERRORS++))
else
  echo -e "${GREEN}✅ flutter analyze passed${NC}"
fi

echo ""

# ========================================
# 4. DEPENDENCY AUDIT
# ========================================

echo -e "${BLUE}🔍 Checking dependencies for vulnerabilities...${NC}"

if flutter pub audit 2>&1 | grep -E "vulnerability|vulnerabilities" >/dev/null; then
  echo -e "${YELLOW}⚠️  WARNING: Dependencies have known vulnerabilities${NC}"
  flutter pub audit
  ((WARNINGS++))
else
  echo -e "${GREEN}✅ No known vulnerabilities in dependencies${NC}"
fi

echo ""

# ========================================
# 5. INSECURE CODE PATTERNS
# ========================================

echo -e "${BLUE}🔍 Checking for insecure code patterns...${NC}"

# Check for HTTP (non-HTTPS)
HTTP_COUNT=$(grep -rn "http://" lib/ --include="*.dart" 2>/dev/null | grep -v "localhost\|127.0.0.1\|example.com\|//" | wc -l)
if [ "$HTTP_COUNT" -gt 0 ]; then
  echo -e "${YELLOW}⚠️  WARNING: Found $HTTP_COUNT insecure HTTP connections${NC}"
  echo "   Use HTTPS for all external API calls"
  ((WARNINGS++))
else
  echo -e "${GREEN}✅ No insecure HTTP connections${NC}"
fi

# Check for debug print statements
PRINT_COUNT=$(grep -rn "print(" lib/ --include="*.dart" 2>/dev/null | wc -l)
if [ "$PRINT_COUNT" -gt 10 ]; then
  echo -e "${YELLOW}⚠️  WARNING: Found $PRINT_COUNT print() statements${NC}"
  echo "   Consider using logger or conditional debug flags"
  ((WARNINGS++))
fi

echo ""

# ========================================
# 6. SECURITY RULES VALIDATION
# ========================================

echo -e "${BLUE}🔍 Validating Firestore security rules...${NC}"

if [ -f "firestore.rules" ]; then
  # Check for fail-secure deny-all
  if grep -q "match /{document=\*\*}" firestore.rules; then
    if grep -A 1 "match /{document=\*\*}" firestore.rules | grep -q "allow.*false"; then
      echo -e "${GREEN}✅ Firestore fail-secure rule present${NC}"
    else
      echo -e "${YELLOW}⚠️  WARNING: No fail-secure deny-all in firestore.rules${NC}"
      ((WARNINGS++))
    fi
  else
    echo -e "${YELLOW}⚠️  WARNING: No catch-all rule in firestore.rules${NC}"
    ((WARNINGS++))
  fi
else
  echo -e "${YELLOW}⚠️  WARNING: firestore.rules not found${NC}"
  ((WARNINGS++))
fi

if [ -f "storage.rules" ]; then
  # Check for fail-secure deny-all
  if grep -q "match /{allPaths=\*\*}" storage.rules; then
    if grep -A 1 "match /{allPaths=\*\*}" storage.rules | grep -q "allow.*false"; then
      echo -e "${GREEN}✅ Storage fail-secure rule present${NC}"
    else
      echo -e "${YELLOW}⚠️  WARNING: No fail-secure deny-all in storage.rules${NC}"
      ((WARNINGS++))
    fi
  fi
else
  echo -e "${YELLOW}⚠️  WARNING: storage.rules not found${NC}"
  ((WARNINGS++))
fi

echo ""

# ========================================
# 7. TESTS
# ========================================

echo -e "${BLUE}🔍 Running tests...${NC}"

if flutter test --no-pub 2>&1 | grep -E "Failed|Some tests failed" >/dev/null; then
  echo -e "${RED}❌ FAILED: Some tests failed${NC}"
  ((ERRORS++))
else
  echo -e "${GREEN}✅ All tests passed${NC}"
fi

echo ""

# ========================================
# 8. CODE COVERAGE
# ========================================

echo -e "${BLUE}🔍 Checking code coverage...${NC}"

# Run tests with coverage
flutter test --coverage --no-pub >/dev/null 2>&1

# Calculate coverage (requires lcov)
if command -v lcov &> /dev/null; then
  COVERAGE=$(lcov --summary coverage/lcov.info 2>&1 | grep "lines" | awk '{print $2}' | sed 's/%//')

  if [ -z "$COVERAGE" ]; then
    echo -e "${YELLOW}⚠️  WARNING: Could not calculate coverage${NC}"
    ((WARNINGS++))
  elif (( $(echo "$COVERAGE < 75" | bc -l) )); then
    echo -e "${YELLOW}⚠️  WARNING: Coverage $COVERAGE% is below 75% threshold${NC}"
    ((WARNINGS++))
  else
    echo -e "${GREEN}✅ Coverage: $COVERAGE% (≥75%)${NC}"
  fi
else
  echo -e "${YELLOW}⚠️  WARNING: lcov not installed (cannot check coverage)${NC}"
  echo "   Install: sudo apt-get install lcov (Linux)"
  echo "   Install: brew install lcov (macOS)"
  ((WARNINGS++))
fi

echo ""

# ========================================
# SUMMARY
# ========================================

echo "======================================"
echo "   SECURITY CHECK SUMMARY"
echo "======================================"
echo ""

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
  echo -e "${GREEN}✅ ALL CHECKS PASSED${NC}"
  echo ""
  echo "Your code is ready to commit!"
  exit 0
elif [ $ERRORS -eq 0 ]; then
  echo -e "${YELLOW}⚠️  $WARNINGS WARNING(S)${NC}"
  echo ""
  echo "Your code can be committed, but please review the warnings above."
  exit 0
else
  echo -e "${RED}❌ $ERRORS CRITICAL ERROR(S), $WARNINGS WARNING(S)${NC}"
  echo ""
  echo "Please fix the errors above before committing."
  echo ""
  echo "Common fixes:"
  echo "  • Remove hardcoded secrets → Use .env files"
  echo "  • Add .env to .gitignore"
  echo "  • Fix flutter analyze issues"
  echo "  • Use HTTPS instead of HTTP"
  echo ""
  exit 1
fi
