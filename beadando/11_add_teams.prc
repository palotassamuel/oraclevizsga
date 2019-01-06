CREATE OR REPLACE PROCEDURE add_team(p_team_name IN VARCHAR2,
                                     p_city      IN VARCHAR2,
                                     p_email     IN VARCHAR2,
                                     p_tel       IN VARCHAR2) IS

  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
  BEGIN
    INSERT INTO team
      (team_id, team_name, city, email, tel)
    VALUES
      (team_seq.nextval, upper(p_team_name), p_city, p_email, p_tel);
    INSERT INTO championship
      (championship_id, team_id)
    VALUES
      (championship_seq.nextval, team_seq.currval);
    COMMIT;
    dbms_output.put_line('Az új csapat sikeresen hozáadódott a táblához.');
  
  EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line('HIBA: Nem megfelelőek a bevitt adatok!');
  END;
END add_team;
/
