CREATE OR REPLACE VIEW vw_championship
AS
SELECT t.team_name, ch.points, ch.played_matches
  FROM championship ch
  JOIN team t
    ON ch.team_id=t.team_id
 ORDER BY ch.points DESC, ch.played_matches DESC;
