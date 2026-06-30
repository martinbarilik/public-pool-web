# Public Pool's Web

A modern web application built with Ruby on Rails 8.1.3 and Bootstrap 5, featuring real-time updates with Hotwire and a responsive design.

![screenshot of the application](https://getumbrel.github.io/umbrel-apps-gallery/public-pool-web/3.jpg)

<div style="display: flex; gap: 20px; align-items: center;">
   <div style="background: white; padding: 10px; border-radius: 5px;">
   <img src="https://p.kagi.com/proxy/S9-Transparent-Dark_1200x630.png?c=XXO6cLpMCEjQi_t7yL_7GZidgNrn8ZVfiaDUPNHwKMUUwwBUU5LxJ2omkQFFKjUzy3nHq1rG1NCPnmZ1m53TWpxKuRBw08VskjBiXhQek5dNyWNNIOXhWEh7-kz8EuzX" alt="Start9 Logo" height="80" style="margin-right: 20px;">
   </div>
   <div style="background: white; padding: 10px; border-radius: 5px;">
   <img src="https://camo.githubusercontent.com/40fc559585a384cee34b0e5688256ed6057b78186e9d7f44976e7dface90f5a0/68747470733a2f2f617070732e756d6272656c2e636f6d2f62616467652d6c696768742e737667" alt="Umbrel Logo" height="80">
   </div>
</div>

## Requirements

- Ruby 4.0.5 (see `.mise.toml` file for exact version)
- Node.js (see `.node-version` file for exact version)
- PostgreSQL
- Yarn package manager

## Development Setup

1. **Clone the repository**

   ```bash
   git clone <repository-url>
   cd public-pool-web
   ```

2. **Install dependencies**

   ```bash
   bundle install
   yarn install
   ```

3. **Environment configuration**

   ```bash
   cp .env.example .env.development
   # Edit .env.development with your local settings
   ```

4. **Database setup**

   ```bash
   bin/rails db:prepare
   ```

5. **Start the development server**
   ```bash
   bin/dev
   ```
   **Note1:** The application will be available at http://localhost:3000<br>
   **Note2:** If you change the host and port of your pool, you need to restart the application in umbrel os. Otherwise, sidekiq will not see them.

## Key Features

- Modern Rails 8.1 architecture
- Real-time updates using Hotwire (Turbo and Stimulus)
- Bootstrap 5 for responsive UI
- PostgreSQL database
- Background job processing with Sidekiq
- Caching with Solid Cache
- WebSocket support with Solid Cable

## Testing

Run the test suite with:

```bash
   bin/rails test
```

# Run this as postgres user if you get PG::InsufficientPrivilege error

```
ALTER USER myuser WITH SUPERUSER;
```

## Deployment

This application is set to be deployed manually on Umbrel OS (see `umbrel-os` directory). To deploy:

1. Clone the repository

   ```bash
   git clone https://github.com/martinbarilik/public-pool-web
   cd public-pool-web
   ```

2. rsync the application to the Umbrel OS server:

   ```bash
   rsync -av --exclude=".gitkeep" <path-to-your-cloned-repo-on-local-machine>/umbrel-apps/public-pool-web umbrel@umbrel.local:/home/umbrel/umbrel/app-stores/getumbrel-umbrel-apps-github-53f74447/
   ```

3. Install the app on your umbrelOS device via terminal or app store

   ```bash
   umbreld client apps.install.mutate --appId public-pool-web
   ```

4. Uninstall the app

   ```bash
   umbreld client apps.uninstall.mutate --appId public-pool-web
   ```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details

## Docker Development

### Additional Requirements

- Docker Engine
- Docker Buildx (for multi-platform builds)

### Useful Commands

1. Run locally from docker-compose.yml

   ```bash
   debian@debian:~$ cd umbrel-os
   debian@debian:~$ source exports.sh && docker compose up
   ```

2. **Access PostgreSQL Database**

   ```bash
   debian@debian:~$ docker exec -it <container-id> psql -U <user> -d <dbname>
   ```

3. **Access Rails Console**

   ```bash
   debian@debian:~$ docker exec -it <container-id> ./bin/rails c
   ```

4. **Build and Push Multi-Platform Image**

   ```bash
   # Login to Docker Hub
   debian@debian:~$ docker login

   # Set up buildx for multi-platform builds
   debian@debian:~$ docker buildx create --use

   # Build and push for multiple architectures
   debian@debian:~$ docker buildx build --push \
    --platform linux/arm64,linux/amd64 \
    -t martinbarilik/public-pool-web:0.2.0 \
    -t martinbarilik/public-pool-web:latest .
   ```

Note: Replace `<container-id>` with your actual Docker container ID. You can find it using `docker ps`.

### Donate

![Donate](public/donate.png)
