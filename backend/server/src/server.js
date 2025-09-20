import { createServer } from 'http';
import app from './app.js';
import { env } from './config/env.js';
import { seedDatabase } from './startup/seed.js';
import openapiSpec from './docs/openapi.js';

async function bootstrap() {
  const port = env.PORT;

  // Seed database with initial data
  await seedDatabase();

  const server = createServer(app);

  app.get('/docs', (_req, res) => {
    res.json(openapiSpec);
  });

  server.listen(port, () => {
    console.log(`Server listening on http://localhost:${port}`);
    console.log(`OpenAPI docs available at http://localhost:${port}/docs`);
  });
}

bootstrap().catch((err) => {
  console.error('Failed to bootstrap server', err);
  process.exit(1);
});


