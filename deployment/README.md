# Deployment Instructions

This directory contains scripts to deploy the Plagiatanet application to your VPS (IP: 178.172.139.125).

## Prerequisites

1.  **SSH Access**: Ensure you can connect to the server.
    ```bash
    ssh root@178.172.139.125
    # Password: Obtain from secure password manager or project administrator
    ```
    *Recommended: Set up SSH keys to avoid typing the password repeatedly.*

2.  **Local Tools**: You need `npm`, `rsync` (optional but recommended), and `ssh` installed locally.

## Initial Server Setup (Run Once)

1.  Copy the setup script to the server:
    ```bash
    scp deployment/setup_remote.sh deployment/nginx.conf root@178.172.139.125:/root/
    ```

2.  Connect to the server and run the setup:
    ```bash
    ssh root@178.172.139.125
    chmod +x setup_remote.sh
    ./setup_remote.sh
    ```
    This will install Nginx, Node.js, PostgreSQL, PM2, and configure the firewall.

## Database Configuration

1.  Log in to PostgreSQL on the server:
    ```bash
    su - postgres
    psql
    ```
2.  Create a database and user:
    ```sql
    CREATE DATABASE plagiatanet;
    CREATE USER plagiatanet_user WITH ENCRYPTED PASSWORD 'your_secure_password';
    GRANT ALL PRIVILEGES ON DATABASE plagiatanet TO plagiatanet_user;
    \q
    ```
3.  Exit postgres user: `exit`

## Backend Configuration

1.  Create a `.env` file on the server in `/var/www/plagiatanet/backend/.env`.
    You can create it locally and copy it, or edit it on the server:
    ```bash
    nano /var/www/plagiatanet/backend/.env
    ```
    **Required Content:**
    ```env
    PORT=3000
    DATABASE_URL=postgres://plagiatanet_user:your_secure_password@localhost:5432/plagiatanet
    CLIENT_BOT_TOKEN=your_client_bot_token
    ENGINE_BOT_TOKEN=your_engine_bot_token
    ENGINE_CHAT_ID=your_engine_chat_id
    ADMIN_USER_ID=your_admin_user_id
    RECAPTCHA_API_KEY=your_recaptcha_key
    RECAPTCHA_PROJECT_ID=your_project_id
    RECAPTCHA_SITE_KEY=your_site_key
    WEBHOOK_URL=http://178.172.139.125
    ```

## Frontend Configuration

1.  Create or update `web/.env.production` locally:
    ```env
    VITE_ORDER_API_BASE_URL=
    # Leave empty to use relative path (recommended for same-server deployment)
    ```

## Deployment

1.  Make the deploy script executable:
    ```bash
    chmod +x deployment/deploy.sh
    ```

2.  Run the deployment script from the `deployment` directory:
    ```bash
    ./deploy.sh
    ```

This script will:
*   Build the frontend locally.
*   Upload the frontend build to the server.
*   Upload the backend code to the server.
*   Install backend dependencies on the server.
*   Restart the PM2 process.
*   Reload Nginx.

## Troubleshooting

*   **Logs**: Check backend logs with `pm2 logs`. Check Nginx logs at `/var/log/nginx/error.log`.
*   **Permissions**: Ensure `/var/www/plagiatanet` is owned by `root` (or the user running the app).
*   **Firewall**: Ensure UFW allows ports 80 (HTTP) and 443 (HTTPS).

