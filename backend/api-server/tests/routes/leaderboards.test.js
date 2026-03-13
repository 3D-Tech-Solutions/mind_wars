const {
  WEEKLY_LEADERBOARD_ORDER_BY,
  ALL_TIME_LEADERBOARD_ORDER_BY
} = require('../../src/routes/leaderboards');

describe('leaderboard ordering constants', () => {
  test('weekly leaderboard breaks ties by average completion time before stable fallbacks', () => {
    expect(WEEKLY_LEADERBOARD_ORDER_BY).toContain('SUM(gr.score) DESC');
    expect(WEEKLY_LEADERBOARD_ORDER_BY).toContain('AVG(COALESCE(gr.time_taken, 2147483647)) ASC');
    expect(WEEKLY_LEADERBOARD_ORDER_BY).toContain('COUNT(gr.id) DESC');
  });

  test('all-time leaderboard breaks ties by average completion time and then wins', () => {
    expect(ALL_TIME_LEADERBOARD_ORDER_BY).toContain('u.total_score DESC');
    expect(ALL_TIME_LEADERBOARD_ORDER_BY).toContain('AVG(COALESCE(gr.time_taken, 2147483647)) ASC');
    expect(ALL_TIME_LEADERBOARD_ORDER_BY).toContain('u.games_won DESC');
  });
});
