@echo off
REM Cleanup WordPress deployment
REM Author: Somil Rathore

echo ==========================================
echo Cleanup WordPress Deployment
echo ==========================================
echo.

echo WARNING: This will delete all WordPress data!
set /p CONFIRM="Are you sure you want to continue? (yes/no): "
if /i not "%CONFIRM%"=="yes" (
    echo Cleanup cancelled.
    exit /b 0
)
echo.

cd /d "%~dp0\.."

REM Delete WordPress application
echo [1/3] Deleting WordPress application...
helm list | findstr "my-release" >nul 2>nul
if %errorlevel% equ 0 (
    helm delete my-release
    echo SUCCESS: WordPress application deleted
) else (
    echo WARNING: WordPress application not found
)
echo.

REM Delete monitoring stack
echo [2/3] Deleting monitoring stack...
helm list | findstr "monitoring" >nul 2>nul
if %errorlevel% equ 0 (
    helm delete monitoring
    echo SUCCESS: Monitoring stack deleted
) else (
    echo WARNING: Monitoring stack not found
)
echo.

REM Wait for pods to terminate
echo Waiting for pods to terminate...
timeout /t 10 /nobreak >nul

REM Delete PVCs
echo [3/3] Deleting PersistentVolumeClaims...
kubectl delete pvc --all --timeout=60s
echo SUCCESS: PVCs deleted
echo.

REM Delete PVs if any remain
echo Checking for remaining PersistentVolumes...
kubectl get pv | findstr "my-release" >nul 2>nul
if %errorlevel% equ 0 (
    kubectl delete pv --all
    echo SUCCESS: PVs deleted
) else (
    echo INFO: No PVs to delete
)
echo.

REM Verify cleanup
echo Verifying cleanup...
echo.

echo Remaining pods:
kubectl get pods
echo.

echo Remaining services:
kubectl get svc
echo.

echo Remaining PVCs:
kubectl get pvc
echo.

echo ==========================================
echo Cleanup Complete!
echo ==========================================
echo.
echo Note: If using Minikube, you can delete the cluster with:
echo   minikube delete
echo.

pause
