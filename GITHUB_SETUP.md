# GitHub Repository Setup Guide

**For:** Somil Rathore  
**Project:** WordPress on Kubernetes - Syfe Internship Task

---

## Step 1: Create GitHub Repository

### On GitHub.com

1. **Login to GitHub**
   - Go to https://github.com
   - Sign in with your account

2. **Create New Repository**
   - Click the "+" icon in top right
   - Select "New repository"

3. **Repository Settings**
   - **Name:** `wordpress-kubernetes-syfe`
   - **Description:** `Production-grade WordPress on Kubernetes with Prometheus/Grafana monitoring - Syfe Internship Task`
   - **Visibility:** Public ✓
   - **Initialize:** Do NOT check any boxes (we have existing code)
   - Click "Create repository"

---

## Step 2: Prepare Local Repository

### Navigate to Project Directory

```bash
cd "C:\Signet\RnD\Extra work - not project"
```

### Initialize Git Repository

```bash
# Initialize git
git init

# Verify .gitignore exists
cat .gitignore

# Add all files
git add .

# Check what will be committed
git status

# Make initial commit
git commit -m "Initial commit: Production-grade WordPress on Kubernetes with monitoring

- Custom Docker images (Nginx/OpenResty, WordPress, MySQL)
- OpenResty compiled with Lua support
- PersistentVolumes with ReadWriteMany access mode
- Helm charts for easy deployment
- Prometheus/Grafana monitoring stack
- Pod CPU utilization monitoring
- Nginx request count and 5xx error tracking
- Comprehensive documentation
- Automation scripts for build, deploy, and cleanup
- Testing scripts

Task completed for Syfe company first-round internship selection."
```

---

## Step 3: Push to GitHub

### Add Remote Repository

```bash
# Add GitHub remote (replace YOUR_USERNAME with your GitHub username)
git remote add origin https://github.com/YOUR_USERNAME/wordpress-kubernetes-syfe.git

# Verify remote
git remote -v
```

### Push Code

```bash
# Push to main branch
git branch -M main
git push -u origin main
```

---

## Step 4: Enhance Repository

### Add Repository Topics

On GitHub repository page:
1. Click "⚙️ Settings" or the gear icon near "About"
2. Add topics:
   - `kubernetes`
   - `docker`
   - `wordpress`
   - `prometheus`
   - `grafana`
   - `helm`
   - `openresty`
   - `nginx`
   - `monitoring`
   - `devops`
   - `lua`

### Update Repository Description

In "About" section:
- **Description:** `Production-grade WordPress on Kubernetes with Prometheus/Grafana monitoring - Syfe Internship Task`
- **Website:** (leave blank or add your portfolio)
- **Topics:** (added above)

---

## Step 5: Create GitHub Release (Optional)

### Tag the Release

```bash
# Create annotated tag
git tag -a v1.0.0 -m "Version 1.0.0 - Complete WordPress on Kubernetes solution

Features:
- Custom Docker images with OpenResty, WordPress, MySQL
- Kubernetes deployment with PersistentVolumes
- Helm charts for easy deployment
- Prometheus/Grafana monitoring
- Comprehensive documentation
- Automation scripts"

# Push tag
git push origin v1.0.0
```

### Create Release on GitHub

1. Go to repository page
2. Click "Releases" (right sidebar)
3. Click "Create a new release"
4. Select tag: `v1.0.0`
5. Release title: `v1.0.0 - Production-Grade WordPress on Kubernetes`
6. Description:
   ```markdown
   ## WordPress on Kubernetes - Syfe Internship Task
   
   Complete production-grade WordPress deployment on Kubernetes with comprehensive monitoring.
   
   ### Features
   - ✅ Custom Docker images (Nginx/OpenResty with Lua, WordPress, MySQL)
   - ✅ OpenResty compiled with specified configure options
   - ✅ PersistentVolumes with ReadWriteMany access mode
   - ✅ Helm charts for easy deployment and cleanup
   - ✅ Prometheus/Grafana monitoring stack
   - ✅ Pod CPU utilization monitoring
   - ✅ Nginx request count and 5xx error tracking
   - ✅ Comprehensive documentation
   - ✅ Automation scripts
   
   ### Quick Start
   See [QUICK_START.md](./QUICK_START.md) for 5-minute setup.
   
   ### Documentation
   - [README.md](./README.md) - Project overview
   - [DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md) - Detailed deployment
   - [METRICS_DOCUMENTATION.md](./METRICS_DOCUMENTATION.md) - All metrics
   
   ### Author
   Somil Rathore - IIIT Bhopal
   ```
7. Click "Publish release"

---

## Step 6: Verify Repository

### Check Repository Contents

Visit your repository URL:
`https://github.com/YOUR_USERNAME/wordpress-kubernetes-syfe`

Verify:
- [ ] README.md displays correctly
- [ ] All files are present
- [ ] .gitignore is working (no sensitive files)
- [ ] Topics are added
- [ ] Description is set

### Test Clone

```bash
# In a different directory
cd /tmp
git clone https://github.com/YOUR_USERNAME/wordpress-kubernetes-syfe.git
cd wordpress-kubernetes-syfe
ls -la
```

---

## Step 7: Share with Syfe

### Prepare Submission

**Email Template:**

```
Subject: First Round Task Submission - Somil Rathore

Dear Syfe Team,

I have completed the first-round task for the internship position. Please find my submission below:

GitHub Repository: https://github.com/YOUR_USERNAME/wordpress-kubernetes-syfe

Project Summary:
- Production-grade WordPress deployment on Kubernetes
- Custom Docker images with OpenResty (Lua support), WordPress, and MySQL
- PersistentVolumes with ReadWriteMany access mode
- Helm charts for easy deployment (helm install/delete)
- Prometheus/Grafana monitoring stack
- Pod CPU utilization monitoring
- Nginx request count and 5xx error tracking
- Comprehensive documentation with deployment guides

Key Highlights:
✅ All task requirements completed
✅ OpenResty compiled with specified configure options
✅ Lua scripts for metrics collection
✅ Production-ready with health checks and resource limits
✅ Comprehensive documentation and automation scripts
✅ Clean code following best practices

Documentation:
- README.md - Quick overview and setup
- QUICK_START.md - 5-minute deployment guide
- DEPLOYMENT_GUIDE.md - Detailed step-by-step instructions
- METRICS_DOCUMENTATION.md - Complete metrics reference
- TROUBLESHOOTING.md - Common issues and solutions

The project is ready for deployment and testing. Please let me know if you need any clarification or have questions.

Thank you for this opportunity!

Best regards,
Somil Rathore
Final Year Student
Indian Institute of Information Technology, Bhopal
```

---

## Step 8: Keep Repository Updated

### If You Make Changes

```bash
# Make changes to files
# ...

# Stage changes
git add .

# Commit with descriptive message
git commit -m "Description of changes"

# Push to GitHub
git push origin main
```

### Update README Badges (Optional)

Add badges to README.md:

```markdown
![Kubernetes](https://img.shields.io/badge/kubernetes-%23326ce5.svg?style=for-the-badge&logo=kubernetes&logoColor=white)
![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white)
![WordPress](https://img.shields.io/badge/WordPress-%23117AC9.svg?style=for-the-badge&logo=WordPress&logoColor=white)
![Prometheus](https://img.shields.io/badge/Prometheus-E6522C?style=for-the-badge&logo=Prometheus&logoColor=white)
![Grafana](https://img.shields.io/badge/grafana-%23F46800.svg?style=for-the-badge&logo=grafana&logoColor=white)
![Nginx](https://img.shields.io/badge/nginx-%23009639.svg?style=for-the-badge&logo=nginx&logoColor=white)
```

---

## Repository Structure Verification

Ensure your repository has this structure:

```
wordpress-kubernetes-syfe/
├── .gitignore
├── README.md
├── QUICK_START.md
├── DEPLOYMENT_GUIDE.md
├── METRICS_DOCUMENTATION.md
├── TROUBLESHOOTING.md
├── PROJECT_SUMMARY.md
├── TASK_CHECKLIST.md
├── PRESENTATION_NOTES.md
├── INDEX.md
├── GITHUB_SETUP.md
│
├── docker/
│   ├── nginx/
│   │   ├── Dockerfile
│   │   ├── nginx.conf
│   │   ├── wordpress.conf
│   │   └── lua/
│   │       ├── metrics.lua
│   │       └── request_logger.lua
│   ├── wordpress/
│   │   ├── Dockerfile
│   │   └── wp-config-docker.php
│   └── mysql/
│       ├── Dockerfile
│       ├── my.cnf
│       └── init-wordpress.sql
│
├── helm-charts/
│   ├── wordpress-app/
│   │   ├── Chart.yaml
│   │   ├── values.yaml
│   │   └── templates/
│   │       ├── _helpers.tpl
│   │       ├── pv.yaml
│   │       ├── pvc.yaml
│   │       ├── mysql-deployment.yaml
│   │       ├── wordpress-deployment.yaml
│   │       ├── nginx-deployment.yaml
│   │       ├── services.yaml
│   │       └── servicemonitor.yaml
│   └── monitoring/
│       ├── Chart.yaml
│       └── values.yaml
│
└── scripts/
    ├── build-images.sh
    ├── build-images.bat
    ├── deploy.sh
    ├── deploy.bat
    ├── cleanup.sh
    ├── cleanup.bat
    └── test-deployment.sh
```

---

## Common Git Commands

### Check Status
```bash
git status
```

### View Changes
```bash
git diff
```

### View Commit History
```bash
git log --oneline
```

### Undo Changes (Before Commit)
```bash
git checkout -- <file>
```

### Undo Last Commit (Keep Changes)
```bash
git reset --soft HEAD~1
```

---

## Troubleshooting Git Issues

### Issue: Large Files

If you accidentally added large files:

```bash
# Remove from staging
git rm --cached <large-file>

# Add to .gitignore
echo "<large-file>" >> .gitignore

# Commit
git commit -m "Remove large file"
```

### Issue: Wrong Commit Message

```bash
# Change last commit message
git commit --amend -m "New commit message"

# Force push (if already pushed)
git push --force origin main
```

### Issue: Merge Conflicts

```bash
# Pull latest changes
git pull origin main

# Resolve conflicts in files
# Then:
git add .
git commit -m "Resolve merge conflicts"
git push origin main
```

---

## Final Checklist

Before sharing with Syfe:

- [ ] Repository is public
- [ ] README.md displays correctly
- [ ] All documentation files are present
- [ ] No sensitive data (passwords, keys)
- [ ] .gitignore is working
- [ ] Repository description is set
- [ ] Topics are added
- [ ] Code is clean and organized
- [ ] All scripts are executable
- [ ] Documentation is comprehensive
- [ ] GitHub URL is ready to share

---

## GitHub Repository URL Format

Your final URL will be:
```
https://github.com/YOUR_USERNAME/wordpress-kubernetes-syfe
```

Replace `YOUR_USERNAME` with your actual GitHub username.

---

**Good luck with your submission! 🚀**

---

**Note:** Make sure to replace `YOUR_USERNAME` with your actual GitHub username throughout this guide.
