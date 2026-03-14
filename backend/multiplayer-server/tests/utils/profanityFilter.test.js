/**
 * Tests for Profanity Filter Service
 */

const { 
  ProfanityFilterService, 
  FilterConfig, 
  STRICTNESS_LEVELS 
} = require('../../src/utils/profanityFilter');

describe('ProfanityFilterService', () => {
  let service;

  beforeEach(() => {
    // Create a fresh instance for each test
    service = new ProfanityFilterService();
  });

  describe('Basic filtering', () => {
    test('should filter profanity in messages', () => {
      const result = service.filterMessage('This is a fucking test');
      expect(result.hasProfanity).toBe(true);
      expect(result.filtered).not.toContain('fucking');
      expect(result.filtered).toContain('*');
    });

    test('should not filter clean messages', () => {
      const result = service.filterMessage('This is a clean test');
      expect(result.hasProfanity).toBe(false);
      expect(result.filtered).toBe('This is a clean test');
    });

    test('should handle empty messages', () => {
      const result = service.filterMessage('');
      expect(result.hasProfanity).toBe(false);
      expect(result.filtered).toBe('');
      expect(result.originalLength).toBe(0);
    });

    test('should handle null/undefined messages', () => {
      const result1 = service.filterMessage(null);
      expect(result1.hasProfanity).toBe(false);
      
      const result2 = service.filterMessage(undefined);
      expect(result2.hasProfanity).toBe(false);
    });

    test('should flag leetspeak bypass attempts for moderation review', () => {
      const result = service.filterMessage('you are f.u.c.k');
      expect(result.hasProfanity).toBe(false);
      expect(result.hasBypassAttempt).toBe(true);
      expect(result.requiresReview).toBe(true);
      expect(result.filtered).toBe('[message removed pending moderation]');
      expect(result.flaggedReason).toBe('Profanity bypass attempt detected');
    });
  });

  describe('isProfane method', () => {
    test('should detect profanity', () => {
      expect(service.isProfane('This is fucking bad')).toBe(true);
    });

    test('should return false for clean messages', () => {
      expect(service.isProfane('This is good')).toBe(false);
    });

    test('should handle empty messages', () => {
      expect(service.isProfane('')).toBe(false);
      expect(service.isProfane(null)).toBe(false);
    });
  });

  describe('clean method', () => {
    test('should clean profanity', () => {
      const cleaned = service.clean('This is fucking bad');
      expect(cleaned).not.toContain('fucking');
      expect(cleaned).toContain('*');
    });

    test('should return original for clean messages', () => {
      const cleaned = service.clean('This is good');
      expect(cleaned).toBe('This is good');
    });
  });

  describe('Custom word management', () => {
    test('should add custom words to default filter', () => {
      service.addWords('customword');
      const result = service.filterMessage('This has customword in it');
      expect(result.hasProfanity).toBe(true);
      expect(result.filtered).toContain('*');
    });

    test('should remove words from default filter', () => {
      // First check that a word is filtered
      const before = service.filterMessage('This is damn annoying');
      
      // Remove the word
      service.removeWords('damn');
      
      // Check that it's no longer filtered
      const after = service.filterMessage('This is damn annoying');
      expect(after.filtered).toBe('This is damn annoying');
    });
  });

  describe('Strictness levels', () => {
    test('should support strict mode', () => {
      service.setConfiguration('strict-lobby', { 
        strictness: STRICTNESS_LEVELS.STRICT 
      });
      
      const result = service.filterMessage('You are stupid', 'strict-lobby');
      expect(result.hasProfanity).toBe(true);
      expect(result.strictness).toBe(STRICTNESS_LEVELS.STRICT);
    });

    test('should support moderate mode (default)', () => {
      service.setConfiguration('moderate-lobby', { 
        strictness: STRICTNESS_LEVELS.MODERATE 
      });
      
      const result = service.filterMessage('This is a test', 'moderate-lobby');
      expect(result.strictness).toBe(STRICTNESS_LEVELS.MODERATE);
    });

    test('should support relaxed mode', () => {
      service.setConfiguration('relaxed-lobby', { 
        strictness: STRICTNESS_LEVELS.RELAXED 
      });
      
      // Words that might be filtered in strict mode should pass in relaxed
      const result = service.filterMessage('What the hell', 'relaxed-lobby');
      expect(result.hasProfanity).toBe(false);
      expect(result.strictness).toBe(STRICTNESS_LEVELS.RELAXED);
    });
  });

  describe('Context-specific configurations', () => {
    test('should set configuration for a specific context', () => {
      const config = service.setConfiguration('lobby-123', {
        strictness: STRICTNESS_LEVELS.STRICT,
        customWords: ['noob']
      });
      
      expect(config).toBeInstanceOf(FilterConfig);
      expect(config.strictness).toBe(STRICTNESS_LEVELS.STRICT);
      expect(config.customWords).toContain('noob');
    });

    test('should get configuration for a context', () => {
      service.setConfiguration('lobby-123', {
        strictness: STRICTNESS_LEVELS.RELAXED
      });
      
      const config = service.getConfiguration('lobby-123');
      expect(config.strictness).toBe(STRICTNESS_LEVELS.RELAXED);
    });

    test('should return default config for unknown context', () => {
      const config = service.getConfiguration('unknown-lobby');
      expect(config.strictness).toBe(STRICTNESS_LEVELS.MODERATE);
    });

    test('should remove configuration for a context', () => {
      service.setConfiguration('lobby-123', {
        strictness: STRICTNESS_LEVELS.STRICT
      });
      
      service.removeConfiguration('lobby-123');
      
      const config = service.getConfiguration('lobby-123');
      expect(config.strictness).toBe(STRICTNESS_LEVELS.MODERATE); // Should return default
    });
  });

  describe('Context-specific word management', () => {
    test('should add words to specific context', () => {
      service.addWordsToContext('lobby-123', 'gameword1', 'gameword2');
      
      const result = service.filterMessage('This has gameword1', 'lobby-123');
      expect(result.hasProfanity).toBe(true);
      
      // Should not affect other contexts
      const result2 = service.filterMessage('This has gameword1', 'lobby-456');
      expect(result2.hasProfanity).toBe(false);
    });

    test('should remove words from specific context', () => {
      service.removeWordsFromContext('lobby-123', 'hell');
      
      const result = service.filterMessage('What the hell', 'lobby-123');
      expect(result.filtered).toBe('What the hell');
    });
  });

  describe('Multiple context filtering', () => {
    test('should maintain separate filters for different contexts', () => {
      // Set up two different lobbies with different configs
      service.setConfiguration('family-lobby', {
        strictness: STRICTNESS_LEVELS.STRICT,
        customWords: ['noob']
      });
      
      service.setConfiguration('casual-lobby', {
        strictness: STRICTNESS_LEVELS.RELAXED
      });
      
      // Test family lobby
      const familyResult = service.filterMessage('You are a noob', 'family-lobby');
      expect(familyResult.hasProfanity).toBe(true);
      
      // Test casual lobby
      const casualResult = service.filterMessage('You are a noob', 'casual-lobby');
      expect(casualResult.hasProfanity).toBe(false);
    });
  });

  describe('Dynamic updates', () => {
    test('should update default configuration', () => {
      service.updateDefaultConfiguration({
        strictness: STRICTNESS_LEVELS.STRICT
      });
      
      const result = service.filterMessage('You are stupid');
      expect(result.hasProfanity).toBe(true);
    });

    test('should reflect changes after adding words to context', () => {
      service.setConfiguration('lobby-123', {
        strictness: STRICTNESS_LEVELS.MODERATE
      });
      
      // Initially should not filter
      let result = service.filterMessage('This is gameterms', 'lobby-123');
      expect(result.hasProfanity).toBe(false);
      
      // Add the word
      service.addWordsToContext('lobby-123', 'gameterms');
      
      // Now should filter
      result = service.filterMessage('This is gameterms', 'lobby-123');
      expect(result.hasProfanity).toBe(true);
    });
  });

  describe('Cache management', () => {
    test('should clear cache', () => {
      service.setConfiguration('lobby-1', { strictness: STRICTNESS_LEVELS.STRICT });
      service.setConfiguration('lobby-2', { strictness: STRICTNESS_LEVELS.RELAXED });
      
      // Trigger filter creation
      service.filterMessage('test', 'lobby-1');
      service.filterMessage('test', 'lobby-2');
      
      // Clear cache
      service.clearCache();
      
      // Should still work after clearing cache
      const result = service.filterMessage('test', 'lobby-1');
      expect(result).toBeDefined();
    });
  });

  describe('FilterConfig class', () => {
    test('should create config with defaults', () => {
      const config = new FilterConfig();
      expect(config.strictness).toBe(STRICTNESS_LEVELS.MODERATE);
      expect(config.customWords).toEqual([]);
      expect(config.allowedWords).toEqual([]);
    });

    test('should create config with custom options', () => {
      const config = new FilterConfig({
        strictness: STRICTNESS_LEVELS.STRICT,
        customWords: ['word1', 'word2'],
        allowedWords: ['allowed1']
      });
      
      expect(config.strictness).toBe(STRICTNESS_LEVELS.STRICT);
      expect(config.customWords).toEqual(['word1', 'word2']);
      expect(config.allowedWords).toEqual(['allowed1']);
    });
  });

  describe('getStrictnessLevels', () => {
    test('should return all strictness levels', () => {
      const levels = service.getStrictnessLevels();
      expect(levels).toHaveProperty('STRICT');
      expect(levels).toHaveProperty('MODERATE');
      expect(levels).toHaveProperty('RELAXED');
    });
  });
});
