CREATE OR REPLACE PROCEDURE team_players(p_team IN VARCHAR2) IS
  CURSOR team_cur IS
    SELECT p.first_name, p.last_name
      FROM people p
      JOIN team t
        ON p.team_id = t.team_id
     WHERE upper(t.team_name) = upper(p_team)
       AND p.team_role = 'játékos';

  is_found_rec BOOLEAN := FALSE;

BEGIN
  FOR i IN team_cur LOOP
    dbms_output.put_line(i.first_name || ' ' || i.last_name);
    is_found_rec := TRUE;
  END LOOP;

  IF NOT is_found_rec THEN
    dbms_output.put_line('Nincs ilyen nevű csapat a bajnokságban.');
  END IF;

END team_players;
/
