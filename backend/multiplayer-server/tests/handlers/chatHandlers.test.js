jest.mock('../../src/utils/database', () => ({
  query: jest.fn()
}));

jest.mock('../../src/utils/encryption', () => ({
  encrypt: jest.fn((value) => `encrypted:${value}`)
}));

jest.mock('../../src/utils/logger', () => ({
  createLogger: jest.fn(() => ({
    info: jest.fn(),
    error: jest.fn()
  }))
}));

const { query } = require('../../src/utils/database');
const encryptionService = require('../../src/utils/encryption');
const registerChatHandlers = require('../../src/handlers/chatHandlers');

describe('chatHandlers', () => {
  let io;
  let emit;
  let socket;
  let handlers;

  beforeEach(() => {
    emit = jest.fn();
    handlers = {};
    io = {
      to: jest.fn(() => ({ emit }))
    };
    socket = {
      userId: 'user-123',
      on: jest.fn((event, handler) => {
        handlers[event] = handler;
      })
    };

    jest.clearAllMocks();
    registerChatHandlers(io, socket);
  });

  test('stores direct profanity as filtered content and broadcasts once', async () => {
    query
      .mockResolvedValueOnce({ rows: [{ id: 'lp-1' }] })
      .mockResolvedValueOnce({ rows: [{ display_name: 'Alice', avatar_url: 'avatar.png' }] })
      .mockResolvedValueOnce({ rows: [{ id: 'msg-1', timestamp: new Date('2026-03-13T00:00:00.000Z') }] });

    const callback = jest.fn();
    await handlers['chat-message']({
      lobbyId: 'lobby-1',
      message: 'This is fucking rude'
    }, callback);

    expect(encryptionService.encrypt).toHaveBeenCalledWith('This is fucking rude');
    expect(query).toHaveBeenNthCalledWith(
      3,
      expect.stringContaining('INSERT INTO chat_messages'),
      expect.arrayContaining([
        'lobby-1',
        'user-123',
        'encrypted:This is fucking rude',
        expect.stringContaining('*'),
        true,
        'Profanity detected'
      ])
    );
    expect(emit).toHaveBeenCalledTimes(1);
    expect(callback).toHaveBeenCalledWith({
      success: true,
      moderation: {
        action: 'filtered',
        flagged: true
      }
    });
  });

  test('flags leetspeak profanity bypass attempts for moderation review', async () => {
    query
      .mockResolvedValueOnce({ rows: [{ id: 'lp-1' }] })
      .mockResolvedValueOnce({ rows: [{ display_name: 'Alice', avatar_url: 'avatar.png' }] })
      .mockResolvedValueOnce({ rows: [{ id: 'msg-2', timestamp: new Date('2026-03-13T00:00:00.000Z') }] });

    const callback = jest.fn();
    await handlers['chat-message']({
      lobbyId: 'lobby-1',
      message: 'you are f.u.c.k'
    }, callback);

    expect(query).toHaveBeenNthCalledWith(
      3,
      expect.stringContaining('INSERT INTO chat_messages'),
      [
        'lobby-1',
        'user-123',
        'encrypted:you are f.u.c.k',
        '[message removed pending moderation]',
        true,
        'Profanity bypass attempt detected'
      ]
    );
    expect(callback).toHaveBeenCalledWith({
      success: true,
      moderation: {
        action: 'review',
        flagged: true
      }
    });
  });

  test('returns normalized chat history payload for lobby members', async () => {
    query
      .mockResolvedValueOnce({ rows: [{ id: 'lp-1' }] })
      .mockResolvedValueOnce({
        rows: [
          {
            id: 'msg-2',
            filtered_message: 'Second',
            timestamp: new Date('2026-03-13T00:00:02.000Z'),
            user_id: 'user-456',
            display_name: 'Bob',
          },
          {
            id: 'msg-1',
            filtered_message: 'First',
            timestamp: new Date('2026-03-13T00:00:01.000Z'),
            user_id: 'user-123',
            display_name: 'Alice',
          },
        ],
      });

    const callback = jest.fn();
    await handlers['get-chat-history']({
      lobbyId: 'lobby-1',
      limit: 20,
    }, callback);

    expect(callback).toHaveBeenCalledWith({
      success: true,
      messages: [
        {
          id: 'msg-1',
          senderId: 'user-123',
          senderName: 'Alice',
          userId: 'user-123',
          displayName: 'Alice',
          message: 'First',
          timestamp: '2026-03-13T00:00:01.000Z',
        },
        {
          id: 'msg-2',
          senderId: 'user-456',
          senderName: 'Bob',
          userId: 'user-456',
          displayName: 'Bob',
          message: 'Second',
          timestamp: '2026-03-13T00:00:02.000Z',
        },
      ],
    });
  });
});
