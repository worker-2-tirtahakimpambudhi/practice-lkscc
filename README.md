# LKS DIY Cloud Computing 2024 - 2025

This repository contains practical exercises for the LKS Cloud Computing 2025 competition, including Kubernetes implementation, Laravel deployment, and various supporting scripts.

## 📁 Directory Structure

```
H:.
├───lksdiycc2024           # Source code for the LKS DIY Cloud Computing 2024 competition with upgrade Laravel 11
├───practice2025           # Practice exercises based on the LKS 2025 cloud computing
│   ├───eks                # Experimenting with Amazon EKS
│   └───minikube           # Local Kubernetes with Minikube
│       └───bitnami        # Deployment with image from bitnami provider
│           └───wordpress  # Deploying WordPress 
│               ├───mysql  # MySQL database for WordPress
│               └───wp     # WordPress configuration
│
├───questions              # Collection of LKS practice questions
└───script                 # Scripts used in practical exercises
```

## 🚀 Setting Up and Deploying Laravel

1. Ensure all Laravel-related scripts in the `script/` directory have been converted using `dos2unix` to avoid execution issues in UNIX/Linux environments:
   ```sh
   dos2unix script/*.sh
   ```
2. Run `sudo bash script/setup_laravel.sh or sudo bash script/setup_laravelV2.sh` to start the necessary services.
3. Ensure the `.env` file is correctly configured.
4. Run the database migration:
   ```sh
   php artisan migrate
   ```
5. The application is now ready to use!

## 🔄 Converting Script Format with dos2unix

When running shell scripts on UNIX/Linux systems, files created on Windows may cause errors due to different line endings. To resolve this, use `dos2unix`:

### Installing dos2unix

- **Ubuntu/Debian**:
  ```sh
  sudo apt install dos2unix
  ```
- **CentOS/RHEL**:
  ```sh
  sudo yum install dos2unix
  ```
- **MacOS (via Homebrew)**:
  ```sh
  brew install dos2unix
  ```

### Converting Files
To convert a single file:
```sh
 dos2unix script.sh
```
To convert all `.sh` files in a directory:
```sh
 dos2unix script/*.sh
```

## ⚠️ Warning
**Ensure you convert all shell scripts using `dos2unix` before running them in a UNIX/Linux environment!**

---

Happy learning and good luck with LKS Cloud Computing 2025! 🚀

