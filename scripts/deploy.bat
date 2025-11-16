@echo off
REM Deploy WordPress application and monitoring stack
REM Author: Somil Rathore

echo ==========================================
echo Deploying WordPress on Kubernetes
echo ==========================================
echo.

cd /d "%~dp0\.."

REM Check prerequisites
echo Checking prerequisites...

where kubectl >nul 2>nul
if %errorlevel% neq 0 (
    echo ERROR: kubectl not found
    exit /b 1
)
echo OK: kubectl found

where helm >nul 2>nul
if %errorlevel% neq 0 (
    echo ERROR: helm not found
    exit /b 1
)
echo OK: helm found

kubectl cluster-info >nul 2>nul
if %errorlevel% neq 0 (
    echo ERROR: Cannot connect to Kubernetes cluster
    exit /b 1
)
echo OK: Kubernetes cluster accessible
echo.

REM Deploy WordPress application
echo [1/2] Deploying WordPress application...
helm install my-release .\helm-charts\wordpress-app
if %errorlevel% neq 0 (
    echo ERROR: Failed to deploy WordPress application
    exit /b 1
)
echo SUCCESS: WordPress application deployed
echo.

REM Wait for WordPress pods
echo Waiting for WordPress pods to be ready...
timeout /t 30 /nobreak >nul
kubectl wait --for=condition=ready pod -l component=mysql --timeout=300s
kubectl wait --for=condition=ready pod -l component=wordpress --timeout=300s
kubectl wait --for=condition=ready pod -l component=nginx --timeout=300s
echo SUCCESS: All WordPress pods are ready
echo.

REM Add Helm repositories
echo Adding Helm repositories...
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
echo SUCCESS: Helm repositories added
echo.

REM Update monitoring dependencies
echo Updating monitoring chart dependencies...
cd helm-charts\monitoring
helm dependency update
cd ..\..
echo SUCCESS: Dependencies updated
echo.

REM Deploy monitoring stack
echo [2/2] Deploying monitoring stack...
helm install monitoring .\helm-charts\monitoring
if %errorlevel% neq 0 (
    echo ERROR: Failed to deploy monitoring stack
    exit /b 1
)
echo SUCCESS: Monitoring stack deployed
echo.

REM Wait for monitoring pods
echo Waiting for monitoring pods to be ready...
timeout /t 30 /nobreak >nul
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=prometheus --timeout=300s
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=grafana --timeout=300s
echo SUCCESS: All monitoring pods are ready
echo.

REM Display status
echo ==========================================
echo Deployment Status
echo ==========================================
echo.

echo Pods:
kubectl get pods
echo.

echo Services:
kubectl get svc
echo.

echo PersistentVolumeClaims:
kubectl get pvc
echo.

REM Get Grafana password
for /f "delims=" %%i in ('kubectl get secret monitoring-grafana -o jsonpath^="{.data.admin-password}"') do set GRAFANA_PASSWORD_B64=%%i
REM Note: Base64 decode in Windows requires PowerShell or external tool
echo Grafana password (base64): %GRAFANA_PASSWORD_B64%
echo Decode with: [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('%GRAFANA_PASSWORD_B64%'))
echo.

echo ==========================================
echo Deployment Complete!
echo ==========================================
echo.
echo Access your applications:
echo.
echo WordPress:
echo   kubectl port-forward svc/nginx-service 8080:80
echo   http://localhost:8080
echo.
echo Grafana:
echo   kubectl port-forward svc/monitoring-grafana 3000:80
echo   http://localhost:3000
echo   Username: admin
echo   Password: See above (or check values.yaml)
echo.
echo Prometheus:
echo   kubectl port-forward svc/monitoring-prometheus-server 9090:80
echo   http://localhost:9090
echo.
echo Nginx Metrics:
echo   kubectl port-forward svc/nginx-service 9145:9145
echo   http://localhost:9145/metrics
echo.

pause
