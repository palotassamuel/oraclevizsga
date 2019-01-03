CREATE OR REPLACE PROCEDURE healthy_not_suspended_players(p_team IN VARCHAR2) IS
  CURSOR team_cur IS
    SELECT p.first_name, p.last_name
      FROM people p
      JOIN team t
        ON p.team_id = t.team_id
      JOIN player_stat ps
        ON p.people_id = ps.player_id
     WHERE upper(t.team_name) = upper(p_team)
       AND p.team_role = 'játékos'
       AND ps.suspension = 0
       AND ps.injury = 0;

  is_found_rec BOOLEAN := FALSE;

BEGIN
  dbms_output.put_line(upper(p_team) || ' bevethető játékosai: ');
  FOR i IN team_cur LOOP
    dbms_output.put_line(i.first_name || ' ' || i.last_name);
    is_found_rec := TRUE;
  END LOOP;

  IF NOT is_found_rec THEN
    dbms_output.put_line('Nincs ilyen nevű csapat a bajnokságban
     vagy nincs bevethető játékos a csapatban.');
  END IF;
END healthy_not_suspended_players;
/
