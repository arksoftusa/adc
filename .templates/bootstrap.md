# Environment Bootstrap Guide

Follow these exact steps to start the application locally from scratch.
Never attempt to guess the start commands.

## Local Development Setup

```bash
# 3. Install dependencies
npm install

# 4. Setup the environment configuration
cp .env.example .env
# (Edit .env with project-specific values for the target application)

# 5. Start backing services (e.g. database, redis)
docker-compose up -d db redis

# 6. Run database migrations
npm run db:migrate

# 7. Start the local development server
npm run dev
```

## Verify Connectivity

Once running, verify the local services required by the project are reachable:

```bash
# Check the application health endpoint
curl http://localhost:8000/health
```
