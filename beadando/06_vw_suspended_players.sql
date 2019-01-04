CREATE OR REPLACE VIEW vw_suspended_players
AS
SELECT p.first_name,p.last_name
  FROM people p 
  JOIN player_stat ps
    ON p.people_id=ps.stat_id
 WHERE ps.suspension=1;
