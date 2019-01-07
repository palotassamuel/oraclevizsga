CREATE OR REPLACE PROCEDURE player_stat_injury_suspension(p_player_id  NUMBER,
                                                          p_suspension NUMBER,
                                                          p_injury     NUMBER) IS
  PRAGMA AUTONOMOUS_TRANSACTION;
  l_player_id NUMBER;
  e_wrong_data EXCEPTION;
BEGIN
  BEGIN
    IF (p_suspension < 0 OR p_suspension > 1 OR p_injury < 0 OR
       p_injury > 1 OR (p_suspension IS NULL AND p_injury IS NULL)) THEN
      RAISE e_wrong_data;
    END IF;
  
    SELECT ps.player_id
      INTO l_player_id
      FROM player_stat ps
     WHERE ps.player_id = p_player_id;
  
    IF (p_suspension IS NOT NULL) THEN
      UPDATE player_stat ps
         SET ps.suspension = p_suspension
       WHERE ps.player_id = l_player_id;
    END IF;
  
    IF (p_injury IS NOT NULL) THEN
      UPDATE player_stat ps
         SET ps.injury = p_injury
       WHERE ps.player_id = l_player_id;
    END IF;
    COMMIT;
    dbms_output.put_line('A módosítás sikeresen megtörtént.');
  EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line('HIBA: Nem megfelelőek a bevitt adatok!');
      ROLLBACK;
  END;
END player_stat_injury_suspension;
/
