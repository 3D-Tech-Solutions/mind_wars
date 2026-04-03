const { Pool } = require('pg');
const { createLogger } = require('./logger');
const logger = createLogger('database');

const pool = new Pool({
  host: process.env.POSTGRES_HOST || 'localhost',
  port: process.env.POSTGRES_PORT || 5432,
  database: process.env.POSTGRES_DB || 'mindwars',
  user: process.env.POSTGRES_USER || 'mindwars',
  password: process.env.POSTGRES_PASSWORD,
  max: 20,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 10000,
});

const initDatabase = async () => {
  try {
    await pool.query('SELECT NOW()');
    logger.info('Database connection established');
  } catch (error) {
    logger.error('Database connection failed', error);
    throw error;
  }
};

const query = async (text, params) => {
  const start = Date.now();
  try {
    const result = await pool.query(text, params);
    const duration = Date.now() - start;
    logger.debug({ text, duration: `${duration}ms`, rows: result.rowCount });
    return result;
  } catch (error) {
    logger.error({ text, error: error.message });
    throw error;
  }
};

module.exports = { pool, query, initDatabase };
