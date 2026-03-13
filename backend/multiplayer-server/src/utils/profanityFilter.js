/**
 * Profanity Filter Service
 * Uses bad-words library for content moderation in chat messages
 * Supports multiple configurations and strictness levels
 */

const Filter = require('bad-words');

/**
 * Strictness levels for profanity filtering
 */
const STRICTNESS_LEVELS = {
  STRICT: 'strict',       // Family-friendly, filters all profanity
  MODERATE: 'moderate',   // Default, filters common profanity
  RELAXED: 'relaxed'      // Minimal filtering, only severe profanity
};

/**
 * Configuration class for profanity filters
 */
class FilterConfig {
  constructor(options = {}) {
    this.strictness = options.strictness || STRICTNESS_LEVELS.MODERATE;
    this.customWords = options.customWords || [];
    this.allowedWords = options.allowedWords || [];
  }
}

class ProfanityFilterService {
  constructor() {
    // Store multiple filter instances by configuration key
    this.filters = new Map();
    
    // Store configurations by lobby/context
    this.configurations = new Map();
    
    // Default configuration
    this.defaultConfig = new FilterConfig({ strictness: STRICTNESS_LEVELS.MODERATE });
    
    // Create default filter instance
    this.defaultFilter = this._createFilter(this.defaultConfig);
  }

  /**
   * [2026-03-13 Security] Normalize text so leetspeak and punctuation-heavy
   * bypass attempts can be reviewed by the same moderation pipeline.
   * @param {string} message - Original message
   * @returns {string} - Normalized message for detection
   */
  _normalizeForDetection(message) {
    if (!message || typeof message !== 'string') {
      return '';
    }

    const leetspeakMap = {
      '@': 'a',
      '4': 'a',
      '3': 'e',
      '1': 'i',
      '!': 'i',
      '|': 'i',
      '0': 'o',
      '$': 's',
      '5': 's',
      '7': 't',
      '+': 't',
      '8': 'b'
    };

    const normalized = message
      .normalize('NFKD')
      .replace(/[\u0300-\u036f]/g, '')
      .toLowerCase();

    const translatedCharacters = [];
    for (const character of normalized) {
      translatedCharacters.push(leetspeakMap[character] || character);
    }
    const translated = translatedCharacters.join('');

    return translated
      .replace(/[^a-z\s]/g, ' ')
      .replace(/\s+/g, ' ')
      .trim();
  }

  /**
   * Create a new Filter instance with the given configuration
   * @private
   * @param {FilterConfig} config - Configuration for the filter
   * @returns {Filter} - Configured Filter instance
   */
  _createFilter(config) {
    const filter = new Filter();
    
    // Apply strictness-based word adjustments
    if (config.strictness === STRICTNESS_LEVELS.RELAXED) {
      // For relaxed mode, remove some words that might be acceptable in casual conversation
      // Note: This is a simplified example. In production, you'd have a curated list
      const commonFalsePositives = ['hell', 'damn', 'crap'];
      filter.removeWords(...commonFalsePositives);
    } else if (config.strictness === STRICTNESS_LEVELS.STRICT) {
      // For strict mode, add more words that might be borderline
      const additionalStrictWords = ['stupid', 'idiot', 'dumb'];
      filter.addWords(...additionalStrictWords);
    }
    
    // Add custom words specific to this configuration
    if (config.customWords && config.customWords.length > 0) {
      filter.addWords(...config.customWords);
    }
    
    // Remove allowed words (for handling false positives)
    if (config.allowedWords && config.allowedWords.length > 0) {
      filter.removeWords(...config.allowedWords);
    }
    
    return filter;
  }

  /**
   * Get a configuration key for caching filter instances
   * @private
   * @param {FilterConfig} config - Configuration object
   * @returns {string} - Unique key for this configuration
   */
  _getConfigKey(config) {
    return JSON.stringify({
      strictness: config.strictness,
      customWords: config.customWords.sort(),
      allowedWords: config.allowedWords.sort()
    });
  }

  /**
   * Get or create a filter instance for the given configuration
   * @private
   * @param {FilterConfig} config - Configuration for the filter
   * @returns {Filter} - Filter instance
   */
  _getFilter(config) {
    const key = this._getConfigKey(config);
    
    if (!this.filters.has(key)) {
      this.filters.set(key, this._createFilter(config));
    }
    
    return this.filters.get(key);
  }

  /**
   * Set configuration for a specific context (lobby, user, etc.)
   * @param {string} contextId - Identifier for the context (e.g., lobby ID)
   * @param {object} options - Configuration options
   * @returns {FilterConfig} - The created configuration
   */
  setConfiguration(contextId, options) {
    const config = new FilterConfig(options);
    this.configurations.set(contextId, config);
    return config;
  }

  /**
   * Get configuration for a specific context
   * @param {string} contextId - Identifier for the context
   * @returns {FilterConfig} - Configuration for the context
   */
  getConfiguration(contextId) {
    return this.configurations.get(contextId) || this.defaultConfig;
  }

  /**
   * Remove configuration for a specific context
   * @param {string} contextId - Identifier for the context
   */
  removeConfiguration(contextId) {
    this.configurations.delete(contextId);
  }

  /**
   * Update the default configuration
   * @param {object} options - Configuration options
   */
  updateDefaultConfiguration(options) {
    this.defaultConfig = new FilterConfig(options);
    this.defaultFilter = this._createFilter(this.defaultConfig);
  }

  /**
   * Add custom words to a specific configuration
   * @param {string} contextId - Identifier for the context
   * @param {...string} words - Words to add
   */
  addWordsToContext(contextId, ...words) {
    // Get existing config or create a new one based on defaults
    let config = this.configurations.get(contextId);
    if (!config) {
      // Create a new config for this context based on defaults
      config = new FilterConfig({
        strictness: this.defaultConfig.strictness,
        customWords: [...this.defaultConfig.customWords],
        allowedWords: [...this.defaultConfig.allowedWords]
      });
    }
    
    config.customWords = [...new Set([...config.customWords, ...words])];
    
    // Clear cached filter to force recreation with new words
    const key = this._getConfigKey(config);
    this.filters.delete(key);
    
    this.configurations.set(contextId, config);
  }

  /**
   * Remove words from a specific configuration (for handling false positives)
   * @param {string} contextId - Identifier for the context
   * @param {...string} words - Words to remove
   */
  removeWordsFromContext(contextId, ...words) {
    // Get existing config or create a new one based on defaults
    let config = this.configurations.get(contextId);
    if (!config) {
      // Create a new config for this context based on defaults
      config = new FilterConfig({
        strictness: this.defaultConfig.strictness,
        customWords: [...this.defaultConfig.customWords],
        allowedWords: [...this.defaultConfig.allowedWords]
      });
    }
    
    config.allowedWords = [...new Set([...config.allowedWords, ...words])];
    
    // Clear cached filter to force recreation with new words
    const key = this._getConfigKey(config);
    this.filters.delete(key);
    
    this.configurations.set(contextId, config);
  }

  /**
   * Filter a message with optional context-specific configuration
   * @param {string} message - The message to filter
   * @param {string} contextId - Optional context identifier (e.g., lobby ID)
   * @returns {object} - Object with filtered message and metadata
   */
  filterMessage(message, contextId = null) {
    if (!message || typeof message !== 'string') {
      return {
        filtered: '',
        hasProfanity: false,
        hasBypassAttempt: false,
        requiresReview: false,
        flaggedReason: null,
        moderationAction: 'allow',
        originalLength: 0,
      };
    }

    const config = contextId ? this.getConfiguration(contextId) : this.defaultConfig;
    const filter = contextId ? this._getFilter(config) : this.defaultFilter;
    
    const lowerTrimmedMessage = message.toLowerCase().trim();
    const normalizedMessage = this._normalizeForDetection(message);
    const hasProfanity = filter.isProfane(message);
    const hasBypassAttempt = !hasProfanity &&
      normalizedMessage.length > 0 &&
      normalizedMessage !== lowerTrimmedMessage &&
      filter.isProfane(normalizedMessage);
    const requiresReview = hasProfanity || hasBypassAttempt;
    const flaggedReason = hasBypassAttempt
      ? 'Profanity bypass attempt detected'
      : (hasProfanity ? 'Profanity detected' : null);
    const moderationAction = hasBypassAttempt ? 'review' : (hasProfanity ? 'filtered' : 'allow');

    return {
      filtered: hasBypassAttempt ? '[message removed pending moderation]' : (hasProfanity ? filter.clean(message) : message),
      hasProfanity,
      hasBypassAttempt,
      requiresReview,
      flaggedReason,
      moderationAction,
      originalLength: message.length,
      strictness: config.strictness
    };
  }

  /**
   * Check if a message contains profanity without filtering
   * @param {string} message - The message to check
   * @param {string} contextId - Optional context identifier
   * @returns {boolean} - True if message contains profanity
   */
  isProfane(message, contextId = null) {
    if (!message || typeof message !== 'string') {
      return false;
    }
    
    const config = contextId ? this.getConfiguration(contextId) : this.defaultConfig;
    const filter = contextId ? this._getFilter(config) : this.defaultFilter;
    
    return filter.isProfane(message);
  }

  /**
   * Clean a message (replace profanity with asterisks)
   * @param {string} message - The message to clean
   * @param {string} contextId - Optional context identifier
   * @returns {string} - Cleaned message
   */
  clean(message, contextId = null) {
    if (!message || typeof message !== 'string') {
      return '';
    }
    
    const config = contextId ? this.getConfiguration(contextId) : this.defaultConfig;
    const filter = contextId ? this._getFilter(config) : this.defaultFilter;
    
    return filter.clean(message);
  }

  /**
   * Add custom words to the default filter
   * @param {...string} words - Words to add to the filter
   */
  addWords(...words) {
    this.defaultConfig.customWords = [...new Set([...this.defaultConfig.customWords, ...words])];
    this.defaultFilter = this._createFilter(this.defaultConfig);
    
    // Clear the default filter cache
    const key = this._getConfigKey(this.defaultConfig);
    this.filters.delete(key);
  }

  /**
   * Remove words from the default filter (for false positives)
   * @param {...string} words - Words to remove from the filter
   */
  removeWords(...words) {
    this.defaultConfig.allowedWords = [...new Set([...this.defaultConfig.allowedWords, ...words])];
    this.defaultFilter = this._createFilter(this.defaultConfig);
    
    // Clear the default filter cache
    const key = this._getConfigKey(this.defaultConfig);
    this.filters.delete(key);
  }

  /**
   * Get available strictness levels
   * @returns {object} - Object containing strictness level constants
   */
  getStrictnessLevels() {
    return { ...STRICTNESS_LEVELS };
  }

  /**
   * Clear all cached filters (useful for testing or memory management)
   */
  clearCache() {
    this.filters.clear();
    this.defaultFilter = this._createFilter(this.defaultConfig);
  }
}

// Export a singleton instance and the class for testing
const instance = new ProfanityFilterService();
module.exports = instance;
module.exports.ProfanityFilterService = ProfanityFilterService;
module.exports.FilterConfig = FilterConfig;
module.exports.STRICTNESS_LEVELS = STRICTNESS_LEVELS;
