@echo off
REM Epic 1 Readiness Verification Script (Windows)
REM FrigoFuteV2 - Preparation Checker
REM Date: 2026-02-15

setlocal enabledelayedexpansion

echo ===================================================
echo    Epic 1 Readiness Verification
echo    FrigoFuteV2 - User Authentication ^& Profiles
echo ===================================================
echo.

set PASSED=0
set FAILED=0
set WARNINGS=0

REM Function to increment counters
:check
set "name=%~1"
set "file=%~2"
echo Checking %name%...
if exist "%file%" (
    echo [PASS] %name%
    set /a PASSED+=1
) else (
    echo [FAIL] %name%
    set /a FAILED+=1
)
goto :eof

echo ===================================================
echo 1. FREEZED CODE GENERATION
echo ===================================================
echo.

REM Check if Freezed files exist
call :check "feature_config.freezed.dart" "lib\core\feature_flags\models\feature_config.freezed.dart"
call :check "subscription_status.freezed.dart" "lib\core\feature_flags\models\subscription_status.freezed.dart"
call :check "sync_queue_item.freezed.dart" "lib\core\data_sync\models\sync_queue_item.freezed.dart"
call :check "network_info.freezed.dart" "lib\core\network\models\network_info.freezed.dart"

echo.
echo Running Flutter analyze...
flutter analyze >nul 2>&1
if %errorlevel% equ 0 (
    echo [PASS] Flutter analyze - No issues found
    set /a PASSED+=1
) else (
    echo [WARN] Flutter analyze found issues
    echo   Run: flutter pub run build_runner build --delete-conflicting-outputs
    set /a WARNINGS+=1
)

echo.
echo ===================================================
echo 2. FIREBASE CONFIGURATION
echo ===================================================
echo.

call :check "firebase_options.dart" "lib\firebase_options.dart"
call :check "google-services.json" "android\app\google-services.json"
call :check "GoogleService-Info.plist" "ios\Runner\GoogleService-Info.plist"

REM Check Firebase CLI
where firebase >nul 2>&1
if %errorlevel% equ 0 (
    echo [PASS] Firebase CLI installed
    set /a PASSED+=1

    REM Check Firebase config
    if exist ".firebaserc" (
        findstr /C:"frigofute-dev" .firebaserc >nul 2>&1
        if %errorlevel% equ 0 (
            echo [PASS] Firebase aliases configured
            set /a PASSED+=1
        ) else (
            echo [WARN] Firebase aliases not configured
            echo   Run: firebase use --add
            set /a WARNINGS+=1
        )
    ) else (
        echo [WARN] Firebase not initialized
        echo   Run: firebase init
        set /a WARNINGS+=1
    )
) else (
    echo [WARN] Firebase CLI not installed
    echo   Install: npm install -g firebase-tools
    set /a WARNINGS+=1
)

echo.
echo ===================================================
echo 3. SECURITY RULES
echo ===================================================
echo.

call :check "firestore.rules" "firestore.rules"
call :check "storage.rules" "storage.rules"

REM Validate Firestore rules (basic)
if exist "firestore.rules" (
    findstr /C:"service cloud.firestore" firestore.rules >nul 2>&1
    if %errorlevel% equ 0 (
        echo [PASS] Firestore rules syntax valid
        set /a PASSED+=1
    ) else (
        echo [FAIL] Firestore rules syntax invalid
        set /a FAILED+=1
    )
)

REM Validate Storage rules (basic)
if exist "storage.rules" (
    findstr /C:"service firebase.storage" storage.rules >nul 2>&1
    if %errorlevel% equ 0 (
        echo [PASS] Storage rules syntax valid
        set /a PASSED+=1
    ) else (
        echo [FAIL] Storage rules syntax invalid
        set /a FAILED+=1
    )
)

echo.
echo ===================================================
echo 4. CI/CD WORKFLOWS
echo ===================================================
echo.

call :check "PR Checks workflow" ".github\workflows\pr_checks.yml"
call :check "Security Checks workflow" ".github\workflows\security_checks.yml"
call :check "Staging Deploy workflow" ".github\workflows\staging_deploy.yml"
call :check "Production Deploy workflow" ".github\workflows\production_deploy.yml"

REM Check if act is installed
where act >nul 2>&1
if %errorlevel% equ 0 (
    echo [PASS] act CLI installed
    set /a PASSED+=1
) else (
    echo [WARN] act CLI not installed
    echo   Install for local CI/CD testing
    set /a WARNINGS+=1
)

echo.
echo ===================================================
echo 5. SECURITY SCRIPTS
echo ===================================================
echo.

call :check "security_check.sh" "scripts\security_check.sh"
call :check "security_check.bat" "scripts\security_check.bat"
call :check "verify_epic1_readiness.sh" "scripts\verify_epic1_readiness.sh"
call :check "verify_epic1_readiness.bat" "scripts\verify_epic1_readiness.bat"

echo.
echo ===================================================
echo 6. TESTS ^& COVERAGE
echo ===================================================
echo.

echo Running all tests...
flutter test --no-pub >nul 2>&1
if %errorlevel% equ 0 (
    echo [PASS] All tests passing
    set /a PASSED+=1
) else (
    echo [FAIL] Some tests failing
    echo   Run: flutter test
    set /a FAILED+=1
)

if exist "coverage\lcov.info" (
    echo [PASS] Coverage data exists
    set /a PASSED+=1
) else (
    echo [WARN] No coverage data found
    echo   Run: flutter test --coverage
    set /a WARNINGS+=1
)

echo.
echo ===================================================
echo 7. DOCUMENTATION
echo ===================================================
echo.

call :check "Epic 0 Final Report" "docs\EPIC_0_FINAL_REPORT.md"
call :check "Story 0.10 Report" "docs\STORY_0.10_FINAL_REPORT.md"
call :check "Deployment Checklist" "docs\DEPLOYMENT_CHECKLIST.md"
call :check "Security Best Practices" "docs\SECURITY_BEST_PRACTICES.md"
call :check "Epic 1 Preparation Guide" "docs\EPIC_1_PREPARATION_GUIDE.md"

echo.
echo ===================================================
echo 8. SPRINT STATUS
echo ===================================================
echo.

if exist "_bmad-output\implementation-artifacts\sprint-status.yaml" (
    findstr /C:"epic-0: done" _bmad-output\implementation-artifacts\sprint-status.yaml >nul 2>&1
    if %errorlevel% equ 0 (
        echo [PASS] Epic 0 marked as DONE
        set /a PASSED+=1
    ) else (
        echo [WARN] Epic 0 not marked as done
        set /a WARNINGS+=1
    )

    findstr /C:"epic-1: in-progress" _bmad-output\implementation-artifacts\sprint-status.yaml >nul 2>&1
    if %errorlevel% equ 0 (
        echo [PASS] Epic 1 ready (in-progress)
        set /a PASSED+=1
    ) else (
        echo [WARN] Epic 1 not started
        set /a WARNINGS+=1
    )
) else (
    echo [FAIL] sprint-status.yaml not found
    set /a FAILED+=1
)

echo.
echo ===================================================
echo SUMMARY
echo ===================================================
echo.

set /a TOTAL=PASSED+FAILED
set /a PERCENTAGE=(PASSED*100)/TOTAL

echo [PASS] Passed:   %PASSED%
echo [FAIL] Failed:   %FAILED%
echo [WARN] Warnings: %WARNINGS%
echo.
echo Overall: %PERCENTAGE%%% (%PASSED%/%TOTAL% checks passed)
echo.

if %FAILED% equ 0 (
    if %WARNINGS% equ 0 (
        echo ===================================================
        echo    READY FOR EPIC 1!
        echo    All checks passed. You can start Epic 1.
        echo ===================================================
        exit /b 0
    ) else (
        echo ===================================================
        echo    MOSTLY READY FOR EPIC 1
        echo    All critical checks passed.
        echo    Review warnings before starting Epic 1.
        echo ===================================================
        exit /b 0
    )
) else (
    echo ===================================================
    echo    NOT READY FOR EPIC 1
    echo    Fix failed checks before starting Epic 1.
    echo    See docs\EPIC_1_PREPARATION_GUIDE.md for help.
    echo ===================================================
    exit /b 1
)
