const app = require('./app');
const config = require('./config/env');

// Start server
const PORT = config.port;

const server = app.listen(PORT, () => {
  console.log(`
🚀 JanMitra Server is running!
📡 Port: ${PORT}
🌍 Environment: ${config.nodeEnv}
📚 API Documentation: http://localhost:${PORT}/api/docs
❤️  Health Check: http://localhost:${PORT}/api/health
  `);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM received. Shutting down gracefully...');
  server.close(() => {
    console.log('Process terminated');
    process.exit(0);
  });
});

process.on('SIGINT', () => {
  console.log('SIGINT received. Shutting down gracefully...');
  server.close(() => {
    console.log('Process terminated');
    process.exit(0);
  });
});

// Handle uncaught exceptions
process.on('uncaughtException', (err) => {
  console.error('Uncaught Exception:', err);
  process.exit(1);
});

// Handle unhandled promise rejections
process.on('unhandledRejection', (err) => {
  console.error('Unhandled Rejection:', err);
  process.exit(1);
});

module.exports = server;
