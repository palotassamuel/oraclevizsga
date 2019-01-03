CREATE OR REPLACE PROCEDURE players_in_the_same_position(p_position IN VARCHAR2) IS
  CURSOR position_cur IS
    SELECT p.first_name, p.last_name
      FROM people p
      JOIN player_stat ps
        ON p.people_id = ps.player_id
     WHERE upper(ps.playing_position) = upper(p_position);

  is_found_rec BOOLEAN := FALSE;
BEGIN
  dbms_output.put_line(upper(p_position) ||
                       ' poszton szereplő játékosok: ');
  FOR i IN position_cur LOOP
    dbms_output.put_line(i.first_name || ' ' || i.last_name);
    is_found_rec := TRUE;
  END LOOP;

  IF NOT is_found_rec THEN
    dbms_output.put_line('Nincs ilyen nevű poszt.');
  END IF;

END players_in_the_same_position;
/
