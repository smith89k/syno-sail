# SynoSail - Synology Laravel Docker Configuration

SynoSail is a drop-in package designed for Laravel developers who want to deploy their applications on a **Synology NAS** using third-party Docker GUI managers like **Dockhand**, **Dockge**, **Arcane**, or **Portainer**.

## Why this package?

Deploying Laravel often involves building images and managing complex configurations. This package scaffolds a complete `docker-compose.yml` Stack designed *specifically* for Synology's strict folder permissions (tested on Synology NAS DS723+ running DSM 7.4) and GUI Docker managers.

It includes an **`init` service** that automatically copies pre-compiled assets, Nginx configs, and PHP configs into persistent, permission-safe `data` folders on your Synology NAS upon startup.

---

## Step 1: Installation & Building (On Your Local Machine / CI)

First, install this package in your Laravel project via Composer:

```bash
composer require --dev smith89k/syno-sail
```

Next, publish the Docker configuration files to your project root.

**For a first-time installation**, run:
```bash
php artisan syno-sail:install
```

**If you are updating the package** and want to pull the latest versions of the stubs (Note: this will overwrite any custom changes you made to these files), run:
```bash
php artisan syno-sail:install --force
```

This command will copy the following into your project root:
- `Dockerfile` (Used to build your image)
- `docker-compose.yml` (The stack you will deploy on Synology)
- `docker/` (Contains Nginx, PHP configs, and backup scripts)
- `.env.docker.example` (Template for your production environment)
- `.dockerignore`
- `.github/` (Contains a ready-to-use GitHub Actions workflow to build and push to GHCR)

**Build & Push Your Image**
Because we included a GitHub Actions workflow, your image will automatically build and push to GitHub Container Registry (GHCR) when you push to the `main` branch. 
Make sure you add a `GHCR_PAT` repository secret containing a Personal Access Token with `write:packages` permissions.

Alternatively, you can build locally:

```bash
docker build -t your-registry/your-app:latest -f Dockerfile .
docker push your-registry/your-app:latest
```

---

## Step 2: Preparing Dockhand (On Synology DS723+ / DSM 7.4)

Now that your image is on the registry, follow these strict steps on your Synology NAS to deploy it.

1. **Create the Stack (Do not deploy yet!)**
   Open Dockhand (or Dockge/Arcane), and create a new Stack/Project. 
   Copy the contents of your `docker-compose.yml` into the editor.
   Copy the contents of `.env.docker.example` into the `.env` editor, and fill out your variables (e.g., `APP_KEY`, database credentials, and your registry image url).
   **Save the stack, but do NOT start it.**

2. **Set Synology Folder Permissions (Crucial)**
   Because Synology is strict about file creation permissions for Docker volumes, you must manually create the `data` folder first:
   - Open **File Station** in Synology DSM.
   - Navigate to the folder where your stack was saved (e.g., `/volume1/docker/dockhand/stacks/<your-environment-or-user>/<your-project-name>/`).
   - Create a new folder inside it named `data`.
   - Right-click the `data` folder -> **Properties** -> **Permission** tab.
   - Give **Everyone** `Read & Write` permissions, and ensure you check "Apply to this folder, sub-folders and files".

3. **Deploy the Stack**
   Go back to your Docker manager and click **Start/Deploy**. 

### What the Services Do:
- **`init`**: This is a temporary container that runs before everything else. Because you mapped `./data`, it takes the Nginx configs, PHP configs, and compiled Vite/public assets from inside your built image, and copies them to your physical Synology `data` folder.
- **`db`**: MariaDB instance for your application.
- **`app`**: The main PHP-FPM Laravel application.
- **`nginx`**: The web server, exposing the port specified by `APP_PORT` (default `8082`) to route traffic to your app.

### Why `security_opt: seccomp=unconfined`?
You may notice the `security_opt: ["seccomp=unconfined"]` flag used in the services. Synology's DSM often runs on older Linux kernels with an outdated default seccomp profile in Docker. Newer Docker images (like Alpine or Debian bases) use new system calls (such as `clone3`) that are blocked by Synology's default profile, causing containers to instantly crash or fail to start. Setting `seccomp=unconfined` bypasses this outdated filter and allows the containers to run normally on Synology NAS without breaking.

---

## Step 3: Setting up Backups via DSM Task Scheduler

We've provided a `backup.sh` script (located in the published `docker/scripts/` folder) to safely dump your database and compress your storage folder, keeping a 7-day retention.

**Note on Backup Location**: To prevent backups from being deleted if you remove or recreate your stack in Dockhand/Dockge, the script automatically saves backups outside the stack folder in `/volume1/docker/backups/<your-project-name>`. You can override this by defining `BACKUP_DIR` in your `.env` file.

To run this automatically every night:
1. Open **Control Panel** in Synology DSM.
2. Go to **Task Scheduler** -> **Create** -> **Scheduled Task** -> **User-defined script**.
3. **General**: Name it "Laravel Backup", user `root`.
4. **Schedule**: Set it to run daily at 2:00 AM.
5. **Task Settings**: In the "Run command" box, execute the script. Make sure to pass the `DEPLOY_PATH` of your stack:
```bash
cd /volume1/docker/dockhand/stacks/<your-environment-or-user>/<your-project-name>
DEPLOY_PATH=$(pwd) sh ./data/scripts/backup.sh
```

## License
The MIT License (MIT).
