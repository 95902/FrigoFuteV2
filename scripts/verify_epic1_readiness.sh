#!/bin/bash

# Epic 1 Readiness Verification Script
# FrigoFuteV2 - Preparation Checker
# Date: 2026-02-15

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔═══════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   Epic 1 Readiness Verification                  ║${NC}"
echo -e "${BLUE}║   FrigoFuteV2 - User Authentication & Profiles   ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════╝${NC}"
echo ""

# Counter for passed/failed checks
PASSED=0
FAILED=0
WARNINGS=0

# Function to check status
check() {
    local name="$1"
    local command="$2"

    echo -n "Checking $name... "

    if eval "$command" &>/dev/null; then
        echo -e "${GREEN}✅ PASS${NC}"
        ((PASSED++))
        return 0
    else
        echo -e "${RED}❌ FAIL${NC}"
        ((FAILED++))
        return 1
    fi
}

# Function for warnings
warn() {
    local name="$1"
    local message="$2"

    echo -e "${YELLOW}⚠️  WARNING: $name${NC}"
    echo -e "   $message"
    ((WARNINGS++))
}

# Function for info
info() {
    local message="$1"
    echo -e "${BLUE}ℹ️  $message${NC}"
}

echo "═══════════════════════════════════════════════════"
echo "1️⃣  FREEZED CODE GENERATION"
echo "═══════════════════════════════════════════════════"
echo ""

# Check if Freezed files exist
check "Freezed files exist" "[ -f 'lib/core/feature_flags/models/feature_config.freezed.dart' ] && \
    [ -f 'lib/core/feature_flags/models/subscription_status.freezed.dart' ] && \
    [ -f 'lib/core/data_sync/models/sync_queue_item.freezed.dart' ] && \
    [ -f 'lib/core/network/models/network_info.freezed.dart' ]"

# Check Flutter analyzer
echo -n "Running Flutter analyze... "
ANALYZE_OUTPUT=$(flutter analyze 2>&1 || true)
if echo "$ANALYZE_OUTPUT" | grep -q "No issues found"; then
    echo -e "${GREEN}✅ PASS${NC}"
    ((PASSED++))
elif echo "$ANALYZE_OUTPUT" | grep -q "The file is being used by another program"; then
    echo -e "${YELLOW}⚠️  WARNING - Flutter SDK locked${NC}"
    warn "Flutter SDK Lock" "Close all IDEs and run: flutter pub run build_runner build --delete-conflicting-outputs"
else
    echo -e "${RED}❌ FAIL${NC}"
    echo "   $ANALYZE_OUTPUT" | head -20
    ((FAILED++))
fi

echo ""
echo "═══════════════════════════════════════════════════"
echo "2️⃣  FIREBASE CONFIGURATION"
echo "═══════════════════════════════════════════════════"
echo ""

# Check Firebase files
check "firebase_options.dart exists" "[ -f 'lib/firebase_options.dart' ]"
check "google-services.json exists" "[ -f 'android/app/google-services.json' ]"
check "GoogleService-Info.plist exists" "[ -f 'ios/Runner/GoogleService-Info.plist' ]"

# Check if Firebase CLI is installed
if command -v firebase &>/dev/null; then
    echo -e "${GREEN}✅ Firebase CLI installed${NC}"
    ((PASSED++))

    # Check Firebase projects
    echo -n "Checking Firebase project aliases... "
    if [ -f '.firebaserc' ]; then
        if grep -q "frigofute-dev" .firebaserc && \
           grep -q "frigofute-staging" .firebaserc && \
           grep -q "frigofute-prod" .firebaserc; then
            echo -e "${GREEN}✅ PASS${NC}"
            ((PASSED++))
        else
            echo -e "${YELLOW}⚠️  WARNING${NC}"
            warn "Firebase Aliases" "Run: firebase use --add for each environment (dev, staging, prod)"
        fi
    else
        echo -e "${YELLOW}⚠️  NOT CONFIGURED${NC}"
        warn "Firebase Config" "Run: firebase init to configure projects"
    fi
else
    echo -e "${YELLOW}⚠️  Firebase CLI not installed${NC}"
    warn "Firebase CLI" "Install with: npm install -g firebase-tools"
fi

echo ""
echo "═══════════════════════════════════════════════════"
echo "3️⃣  SECURITY RULES"
echo "═══════════════════════════════════════════════════"
echo ""

# Check security rules files
check "firestore.rules exists" "[ -f 'firestore.rules' ]"
check "storage.rules exists" "[ -f 'storage.rules' ]"

# Validate rules syntax (basic check)
if [ -f 'firestore.rules' ]; then
    echo -n "Validating Firestore rules syntax... "
    if grep -q "service cloud.firestore" firestore.rules && \
       grep -q "match /users/{userId}" firestore.rules; then
        echo -e "${GREEN}✅ PASS${NC}"
        ((PASSED++))
    else
        echo -e "${RED}❌ FAIL${NC}"
        ((FAILED++))
    fi
fi

if [ -f 'storage.rules' ]; then
    echo -n "Validating Storage rules syntax... "
    if grep -q "service firebase.storage" storage.rules && \
       grep -q "match /users/{userId}" storage.rules; then
        echo -e "${GREEN}✅ PASS${NC}"
        ((PASSED++))
    else
        echo -e "${RED}❌ FAIL${NC}"
        ((FAILED++))
    fi
fi

echo ""
echo "═══════════════════════════════════════════════════"
echo "4️⃣  CI/CD WORKFLOWS"
echo "═══════════════════════════════════════════════════"
echo ""

# Check GitHub workflows
check "PR Checks workflow exists" "[ -f '.github/workflows/pr_checks.yml' ]"
check "Security Checks workflow exists" "[ -f '.github/workflows/security_checks.yml' ]"
check "Staging Deploy workflow exists" "[ -f '.github/workflows/staging_deploy.yml' ]"
check "Production Deploy workflow exists" "[ -f '.github/workflows/production_deploy.yml' ]"

# Check if act is installed (for local testing)
if command -v act &>/dev/null; then
    echo -e "${GREEN}✅ act CLI installed (local testing available)${NC}"
    ((PASSED++))
else
    echo -e "${YELLOW}⚠️  act CLI not installed${NC}"
    warn "act CLI" "Install for local CI/CD testing: https://github.com/nektos/act"
fi

echo ""
echo "═══════════════════════════════════════════════════"
echo "5️⃣  SECURITY SCRIPTS"
echo "═══════════════════════════════════════════════════"
echo ""

# Check security scripts
check "security_check.sh exists" "[ -f 'scripts/security_check.sh' ]"
check "security_check.bat exists" "[ -f 'scripts/security_check.bat' ]"
check "security_check.sh is executable" "[ -x 'scripts/security_check.sh' ]"

echo ""
echo "═══════════════════════════════════════════════════"
echo "6️⃣  TESTS & COVERAGE"
echo "═══════════════════════════════════════════════════"
echo ""

# Run tests
echo "Running all tests..."
if flutter test --no-pub &>/dev/null; then
    echo -e "${GREEN}✅ All tests passing${NC}"
    ((PASSED++))
else
    echo -e "${RED}❌ Some tests failing${NC}"
    ((FAILED++))
fi

# Check coverage
if [ -f 'coverage/lcov.info' ]; then
    echo -n "Checking code coverage... "
    # Extract coverage percentage (this is a simplified check)
    LINES_FOUND=$(grep -c "LF:" coverage/lcov.info || echo "0")
    LINES_HIT=$(grep -c "LH:" coverage/lcov.info || echo "0")

    if [ "$LINES_FOUND" -gt 0 ]; then
        COVERAGE=$((LINES_HIT * 100 / LINES_FOUND))

        if [ "$COVERAGE" -ge 75 ]; then
            echo -e "${GREEN}✅ $COVERAGE% (threshold: 75%)${NC}"
            ((PASSED++))
        else
            echo -e "${YELLOW}⚠️  $COVERAGE% (below 75% threshold)${NC}"
            warn "Code Coverage" "Coverage is below 75% threshold. Run: flutter test --coverage"
        fi
    else
        echo -e "${YELLOW}⚠️  Unable to calculate coverage${NC}"
        warn "Coverage Calculation" "Run: flutter test --coverage"
    fi
else
    echo -e "${YELLOW}⚠️  No coverage data found${NC}"
    warn "Coverage Missing" "Generate coverage with: flutter test --coverage"
fi

echo ""
echo "═══════════════════════════════════════════════════"
echo "7️⃣  DOCUMENTATION"
echo "═══════════════════════════════════════════════════"
echo ""

# Check documentation
check "Epic 0 Final Report exists" "[ -f 'docs/EPIC_0_FINAL_REPORT.md' ]"
check "Story 0.10 Report exists" "[ -f 'docs/STORY_0.10_FINAL_REPORT.md' ]"
check "Deployment Checklist exists" "[ -f 'docs/DEPLOYMENT_CHECKLIST.md' ]"
check "Security Best Practices exists" "[ -f 'docs/SECURITY_BEST_PRACTICES.md' ]"
check "Epic 1 Preparation Guide exists" "[ -f 'docs/EPIC_1_PREPARATION_GUIDE.md' ]"

echo ""
echo "═══════════════════════════════════════════════════"
echo "8️⃣  SPRINT STATUS"
echo "═══════════════════════════════════════════════════"
echo ""

# Check sprint status
if [ -f '_bmad-output/implementation-artifacts/sprint-status.yaml' ]; then
    echo -n "Checking Epic 0 status... "
    if grep -q "epic-0: done" _bmad-output/implementation-artifacts/sprint-status.yaml; then
        echo -e "${GREEN}✅ Epic 0 marked as DONE${NC}"
        ((PASSED++))
    else
        echo -e "${YELLOW}⚠️  Epic 0 not marked as done${NC}"
        warn "Sprint Status" "Epic 0 should be marked as 'done' in sprint-status.yaml"
    fi

    echo -n "Checking Epic 1 status... "
    if grep -q "epic-1: in-progress" _bmad-output/implementation-artifacts/sprint-status.yaml; then
        echo -e "${GREEN}✅ Epic 1 ready (in-progress)${NC}"
        ((PASSED++))
    else
        echo -e "${YELLOW}⚠️  Epic 1 not started${NC}"
        warn "Epic 1 Status" "Epic 1 should be in 'in-progress' status"
    fi
else
    echo -e "${RED}❌ sprint-status.yaml not found${NC}"
    ((FAILED++))
fi

echo ""
echo "═══════════════════════════════════════════════════"
echo "📊 SUMMARY"
echo "═══════════════════════════════════════════════════"
echo ""

TOTAL=$((PASSED + FAILED))
PERCENTAGE=$((PASSED * 100 / TOTAL))

echo -e "${GREEN}✅ Passed:    $PASSED${NC}"
echo -e "${RED}❌ Failed:    $FAILED${NC}"
echo -e "${YELLOW}⚠️  Warnings:  $WARNINGS${NC}"
echo ""
echo -e "Overall: $PERCENTAGE% ($PASSED/$TOTAL checks passed)"
echo ""

if [ "$FAILED" -eq 0 ] && [ "$WARNINGS" -eq 0 ]; then
    echo -e "${GREEN}╔═══════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║   🎉 READY FOR EPIC 1!                           ║${NC}"
    echo -e "${GREEN}║   All checks passed. You can start Epic 1.       ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════╝${NC}"
    exit 0
elif [ "$FAILED" -eq 0 ]; then
    echo -e "${YELLOW}╔═══════════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║   ⚠️  MOSTLY READY FOR EPIC 1                    ║${NC}"
    echo -e "${YELLOW}║   All critical checks passed.                     ║${NC}"
    echo -e "${YELLOW}║   Review warnings before starting Epic 1.         ║${NC}"
    echo -e "${YELLOW}╚═══════════════════════════════════════════════════╝${NC}"
    exit 0
else
    echo -e "${RED}╔═══════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║   ❌ NOT READY FOR EPIC 1                         ║${NC}"
    echo -e "${RED}║   Fix failed checks before starting Epic 1.       ║${NC}"
    echo -e "${RED}║   See docs/EPIC_1_PREPARATION_GUIDE.md for help.  ║${NC}"
    echo -e "${RED}╚═══════════════════════════════════════════════════╝${NC}"
    exit 1
fi
