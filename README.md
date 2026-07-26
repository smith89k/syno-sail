# SynoSail - Synology Laravel Docker Configuration

SynoSail is a drop-in package designed for Laravel developers who want to deploy their applications on a **Synology NAS** using third-party Docker GUI managers like **Dockhand**, **Dockge**, or **Portainer**.

## Why this package?

Deploying Laravel often involves building images and managing complex configurations. This package scaffolds a complete `docker-compose.yml` Stack designed *specifically* for Synology's strict folder permissions and GUI Docker managers.

It includes an **`init` service** that automatically copies pre-compiled assets, Nginx configs, and PHP configs into persistent, permission-safe `data` folders on your Synology NAS upon startup.

---

## Step 1: Installation & Building (On Your Local Machine / CI)

First, install this package in your Laravel project via Composer:

```bash
composer require --dev smith89k/syno-sail
```

Next, publish the Docker configuration files to your project root:

```bash
php artisan syno-sail:install
```

This command will copy the following into your project root:
- `Dockerfile` (Used to build your image)
- `docker-compose.yml` (The stack you will deploy on Synology)
- `docker/` (Contains Nginx, PHP configs, and backup scripts)
- `.env.docker.example` (Template for your production environment)
- `.dockerignore`

**Build & Push Your Image**
You should build your image (either locally or using GitHub Actions) and push it to a container registry (like GHCR or Docker Hub).

```bash
docker build -t your-registry/your-app:latest -f Dockerfile .
docker push your-registry/your-app:latest
```

---

## Step 2: Preparing Dockhand / Dockge (On Synology)

Now that your image is on the registry, follow these strict steps on your Synology NAS to deploy it.

1. **Create the Stack (Do not deploy yet!)**
   Open Dockhand or Dockge, and create a new Stack/Project. 
   Copy the contents of your `docker-compose.yml` into the editor.
   Copy the contents of `.env.docker.example` into the `.env` editor, and fill out your variables (e.g., `APP_KEY`, database credentials, and your registry image url).
   **Save the stack, but do NOT start it.**

2. **Set Synology Folder Permissions (Crucial)**
   Because Synology is strict about file creation permissions for Docker volumes, you must manually create the `data` folder first:
   - Open **File Station** in Synology DSM.
   - Navigate to the folder where your Dockhand/Dockge stack was saved (e.g., `/volume1/docker/dockge/stacks/my-app/`).
   - Create a new folder inside it named `data`.
   - Right-click the `data` folder -> **Properties** -> **Permission** tab.
   - Give **Everyone** `Read & Write` permissions, and ensure you check "Apply to this folder, sub-folders and files".

3. **Deploy the Stack**
   Go back to Dockhand/Dockge and click **Start/Deploy**. 

### What the Services Do:
- **`init`**: This is a temporary container that runs before everything else. Because you mapped `./data`, it takes the Nginx configs, PHP configs, and compiled Vite/public assets from inside your built image, and copies them to your physical Synology `data` folder.
- **`db`**: MariaDB instance for your application.
- **`app`**: The main PHP-FPM Laravel application.
- **`nginx`**: The web server, exposing port `8082` (by default) to route traffic to your app.

---

## Step 3: Setting up Backups via DSM Task Scheduler

We've provided a `backup.sh` script (located in the published `docker/scripts/` folder) to safely dump your database and compress your storage folder, keeping a 7-day retention.

To run this automatically every night:
1. Open **Control Panel** in Synology DSM.
2. Go to **Task Scheduler** -> **Create** -> **Scheduled Task** -> **User-defined script**.
3. **General**: Name it "Laravel Backup", user `root`.
4. **Schedule**: Set it to run daily at 2:00 AM.
5. **Task Settings**: In the "Run command" box, execute the script. Make sure to pass the `DEPLOY_PATH` of your stack:
```bash
cd /volume1/docker/dockge/stacks/my-app
DEPLOY_PATH=$(pwd) sh ./docker/scripts/backup.sh >> ./backup.log 2>&1
```

## License
The MIT License (MIT).
