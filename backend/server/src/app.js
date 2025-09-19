import express from 'express';
import cors from 'cors';
import authRouter from './routes/auth.routes.js';
import ticketsRouter from './routes/tickets.routes.js';
import adminRouter from './routes/admin.routes.js';

const app = express();

app.use(cors());
app.use(express.json({ limit: '10mb' }));

app.get('/health', (_req, res) => res.json({ status: 'ok' }));

app.use('/auth', authRouter);
app.use('/tickets', ticketsRouter);
app.use('/admin', adminRouter);

// Global error handler
// eslint-disable-next-line no-unused-vars
app.use((err, _req, res, _next) => {
  const status = err.status || 500;
  const message = status === 500 ? 'Internal Server Error' : err.message || 'Error';
  res.status(status).json({ error: message });
});

export default app;


