@echo off
REM Build all Docker images for WordPress on Kubernetes
REM Author: Somil Rathore

echo ==========================================
echo Building Docker Images for WordPress K8s
echo ==========================================
echo.

cd /d "%~dp0\.."

echo [1/3] Building Nginx (OpenResty) image...
docker build -t wordpress-nginx:latest .\docker\nginx
if %errorlevel% neq 0 (
    echo ERROR: Failed to build Nginx image
    exit /b 1
)
echo SUCCESS: Nginx image built
echo.

echo [2/3] Building WordPress image...
docker build -t wordpress-custom:latest .\docker\wordpress
if %errorlevel% neq 0 (
    echo ERROR: Failed to build WordPress image
    exit /b 1
)
echo SUCCESS: WordPress image built
echo.

echo [3/3] Building MySQL image...
docker build -t mysql-custom:latest .\docker\mysql
if %errorlevel% neq 0 (
    echo ERROR: Failed to build MySQL image
    exit /b 1
)
echo SUCCESS: MySQL image built
echo.

echo Built images:
docker images | findstr "wordpress-nginx wordpress-custom mysql-custom"
echo.

REM Check if Minikube is available
where minikube >nul 2>nul
if %errorlevel% equ 0 (
    set /p LOAD_MINIKUBE="Load images to Minikube? (y/n): "
    if /i "%LOAD_MINIKUBE%"=="y" (
        echo Loading images to Minikube...
        minikube image load wordpress-nginx:latest
        minikube image load wordpress-custom:latest
        minikube image load mysql-custom:latest
        echo Images loaded to Minikube
    )
)

echo.
echo ==========================================
echo All images built successfully!
echo ==========================================
pause
