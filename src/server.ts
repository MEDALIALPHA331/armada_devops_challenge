import http from 'node:http';

function rootRequestHandler(req: http.IncomingMessage, res: http.ServerResponse) {
  res.setHeader('Content-Type', 'application/json');
  res.end(JSON.stringify({ content: 'Hello Armada' }));
}

const server = http.createServer(rootRequestHandler);

server.listen(8000, () => {
  console.log('Server is running on port 8000');
});

//Graceful shutdown
function gracefulShutdown() {
  console.log('Received kill signal, shutting down gracefully');
  server.close(() => {
    console.log('Closed out remaining connections');
    process.exit(0);
  });

  setTimeout(() => {
    console.error('Could not close connections in time, forcefully shutting down');
    process.exit(1);
  }, 10000);
}

process.on('SIGTERM', gracefulShutdown);
process.on('SIGINT', gracefulShutdown);
