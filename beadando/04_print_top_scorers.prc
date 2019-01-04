CREATE OR REPLACE PROCEDURE top_scorers(list_length IN VARCHAR2) IS
  CURSOR scorers_cur IS
    SELECT p.first_name, p.last_name, ps.goals
      FROM people p
      JOIN player_stat ps
        ON p.people_id = ps.player_id
     ORDER BY ps.goals DESC;

  v_row scorers_cur%ROWTYPE;

BEGIN
  BEGIN
    OPEN scorers_cur;
  
    dbms_output.put_line('Legtöbb gólt szerző játékosok listája(top ' ||
                         list_length || '):');
  
    LOOP
      FETCH scorers_cur
        INTO v_row;
      EXIT WHEN scorers_cur%NOTFOUND;
      EXIT WHEN scorers_cur%ROWCOUNT > list_length;
      dbms_output.put_line(chr(9) || v_row.goals || chr(9) || chr(9) ||
                           v_row.first_name || ' ' || v_row.last_name);
    END LOOP;
  
    CLOSE scorers_cur;
  EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line('HIBA: Nem megfelelő formátumú a megadott lista hossza!');
  END;
END top_scorers;
/
