# Public Pool Web Application

A modern web application built with Ruby on Rails 8.0 and Bootstrap 5, featuring real-time updates with Hotwire and a responsive design.

![screenshot of the application](/umbrel-os/images/1.png)


## Requirements

- Ruby 3.x (see `.ruby-version` file for exact version)
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
   The application will be available at http://localhost:3000

## Key Features

- Modern Rails 8.0 architecture
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

## Deployment

This application is configured for deployment using Kamal and Docker:

1. Build the Docker image:
   ```bash
   docker build -t public-pool-web .
   ```

2. Deploy using Kamal:
   ```bash
   kamal deploy
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
    -t martinbarilik/public-pool-web:0.0.1 \
    -t martinbarilik/public-pool-web:latest .
   ```

Note: Replace `<container-id>` with your actual Docker container ID. You can find it using `docker ps`.