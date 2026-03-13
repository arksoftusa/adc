# Environment Bootstrap Guide

Follow these exact steps to start the application locally from scratch. 
Never attempt to guess the start commands.

```bash
# 1. Install dependencies
npm install

# 2. Setup the environment configuration
cp .env.example .env

# 3. Start backing services (e.g. database, redis)
docker-compose up -d db redis

# 4. Run database migrations
npm run db:migrate

# 5. Start the local development server
npm run dev
```
