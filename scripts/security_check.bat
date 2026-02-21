@echo off
REM Pre-Commit Security Check Script (Windows)
REM Story 0.10 Phase 9: CI/CD Security Checks
REM
REM Run this script before committing to catch security issues early:
REM   scripts\security_check.bat

setlocal enabledelayedexpansion

set WARNINGS=0
set ERRORS=0

echo.
echo ======================================
echo    SECURITY CHECK
echo ======================================
echo.

REM ========================================
REM 1. SECRETS DETECTION
REM ========================================

echo [INFO] Checking for hardcoded secrets...

REM Check for API keys
findstr /R /S /N "API_KEY.*=.*['\"]" lib\*.dart >nul 2>&1
if %ERRORLEVEL% EQU 0 (
  echo [ERROR] CRITICAL: Hardcoded API_KEY found
  set /a ERRORS+=1
) else (
  echo [OK] No hardcoded API keys
)

REM Check for Firebase credentials
findstr /R /S /N "google-services.json GoogleService-Info.plist" lib\*.dart >nul 2>&1
if %ERRORLEVEL% EQU 0 (
  echo [ERROR] CRITICAL: Firebase config referenced in code
  set /a ERRORS+=1
)

echo.

REM ========================================
REM 2. GIT CONFIGURATION
REM ========================================

echo [INFO] Checking .gitignore configuration...

findstr /C:".env" .gitignore >nul 2>&1
if %ERRORLEVEL% EQU 0 (
  echo [OK] .env files properly gitignored
) else (
  echo [ERROR] CRITICAL: .env files not in .gitignore
  echo    Add to .gitignore:
  echo    .env
  echo    .env.*
  echo    !.env.example
  set /a ERRORS+=1
)

REM Check if .env files are staged
git diff --cached --name-only | findstr /R "\.env$" >nul 2>&1
if %ERRORLEVEL% EQU 0 (
  echo [ERROR] CRITICAL: .env files staged for commit
  echo    Remove with: git reset HEAD .env*
  set /a ERRORS+=1
)

echo.

REM ========================================
REM 3. CODE ANALYSIS
REM ========================================

echo [INFO] Running static analysis...

flutter analyze --no-pub >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
  echo [ERROR] FAILED: flutter analyze found issues
  flutter analyze --no-pub
  set /a ERRORS+=1
) else (
  echo [OK] flutter analyze passed
)

echo.

REM ========================================
REM 4. DEPENDENCY AUDIT
REM ========================================

echo [INFO] Checking dependencies for vulnerabilities...

flutter pub audit 2>&1 | findstr /C:"vulnerability" >nul
if %ERRORLEVEL% EQU 0 (
  echo [WARN] WARNING: Dependencies have known vulnerabilities
  flutter pub audit
  set /a WARNINGS+=1
) else (
  echo [OK] No known vulnerabilities in dependencies
)

echo.

REM ========================================
REM 5. INSECURE CODE PATTERNS
REM ========================================

echo [INFO] Checking for insecure code patterns...

REM Check for HTTP (non-HTTPS)
findstr /R /S /N "http://" lib\*.dart | findstr /V "localhost 127.0.0.1 example.com //" >nul 2>&1
if %ERRORLEVEL% EQU 0 (
  echo [WARN] WARNING: Insecure HTTP connections found
  echo    Use HTTPS for all external API calls
  set /a WARNINGS+=1
) else (
  echo [OK] No insecure HTTP connections
)

echo.

REM ========================================
REM 6. SECURITY RULES VALIDATION
REM ========================================

echo [INFO] Validating Firestore security rules...

if exist firestore.rules (
  findstr /C:"match /{document=**}" firestore.rules >nul 2>&1
  if %ERRORLEVEL% EQU 0 (
    echo [OK] Firestore fail-secure rule present
  ) else (
    echo [WARN] WARNING: No catch-all rule in firestore.rules
    set /a WARNINGS+=1
  )
) else (
  echo [WARN] WARNING: firestore.rules not found
  set /a WARNINGS+=1
)

if exist storage.rules (
  findstr /C:"match /{allPaths=**}" storage.rules >nul 2>&1
  if %ERRORLEVEL% EQU 0 (
    echo [OK] Storage fail-secure rule present
  ) else (
    echo [WARN] WARNING: No catch-all rule in storage.rules
    set /a WARNINGS+=1
  )
) else (
  echo [WARN] WARNING: storage.rules not found
  set /a WARNINGS+=1
)

echo.

REM ========================================
REM 7. TESTS
REM ========================================

echo [INFO] Running tests...

flutter test --no-pub >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
  echo [ERROR] FAILED: Some tests failed
  set /a ERRORS+=1
) else (
  echo [OK] All tests passed
)

echo.

REM ========================================
REM SUMMARY
REM ========================================

echo ======================================
echo    SECURITY CHECK SUMMARY
echo ======================================
echo.

if %ERRORS% EQU 0 (
  if %WARNINGS% EQU 0 (
    echo [OK] ALL CHECKS PASSED
    echo.
    echo Your code is ready to commit!
    exit /b 0
  ) else (
    echo [WARN] %WARNINGS% WARNING(S)
    echo.
    echo Your code can be committed, but please review the warnings above.
    exit /b 0
  )
) else (
  echo [ERROR] %ERRORS% CRITICAL ERROR(S), %WARNINGS% WARNING(S)
  echo.
  echo Please fix the errors above before committing.
  echo.
  echo Common fixes:
  echo   - Remove hardcoded secrets - Use .env files
  echo   - Add .env to .gitignore
  echo   - Fix flutter analyze issues
  echo   - Use HTTPS instead of HTTP
  echo.
  exit /b 1
)
