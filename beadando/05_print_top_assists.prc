CREATE OR REPLACE PROCEDURE top_assists(list_length IN VARCHAR2) IS
  CURSOR assists_cur IS
    SELECT p.first_name, p.last_name, ps.assists
      FROM people p
      JOIN player_stat ps
        ON p.people_id = ps.player_id
     ORDER BY ps.assists DESC;

  v_row assists_cur%ROWTYPE;

BEGIN
  BEGIN
    OPEN assists_cur;
  
    dbms_output.put_line('Legtöbb gólpasszt szerző játékosok listája(top ' ||
                         list_length || '):');
  
    LOOP
      FETCH assists_cur
        INTO v_row;
      EXIT WHEN assists_cur%NOTFOUND;
      EXIT WHEN assists_cur%ROWCOUNT > list_length;
      dbms_output.put_line(chr(9) || v_row.assists || chr(9) || chr(9) ||
                           v_row.first_name || ' ' || v_row.last_name);
    END LOOP;
  
    CLOSE assists_cur;
  EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line('HIBA: Nem megfelelő formátumú a megadott lista hossza!');
  END;
END top_assists;
/
