const { createLogger } = require('../utils/logger');
const logger = createLogger('http');

const requestLogger = (req, res, next) => {
  const start = Date.now();

  res.on('finish', () => {
    const duration = Date.now() - start;
    const logMessage = `${req.method} ${req.path} [${res.statusCode}] ${duration}ms - IP: ${req.ip}`;
    logger.info(logMessage);
  });

  next();
};

module.exports = { requestLogger };
