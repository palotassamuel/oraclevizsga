CREATE OR REPLACE PROCEDURE add_people(p_first_name       VARCHAR2,
                                       p_last_name        VARCHAR2,
                                       p_team_id          NUMBER,
                                       p_birth_date       DATE,
                                       p_birth_place_city VARCHAR2,
                                       p_email            VARCHAR2,
                                       p_tel              VARCHAR2,
                                       p_team_role        VARCHAR2,
                                       p_playing_position VARCHAR2) IS
  PRAGMA AUTONOMOUS_TRANSACTION;
  e_empty_field EXCEPTION;
  l_player VARCHAR2(100) := 'JÁTÉKOS';
BEGIN
  BEGIN
    IF (upper(p_team_role) = l_player AND p_playing_position IS NULL) THEN
      dbms_output.put_line('HIBA: Kérem adja meg a játékos posztját!');
      RAISE e_empty_field;
    END IF;
    INSERT INTO people
      (people_id,
       first_name,
       last_name,
       team_id,
       birth_date,
       birth_place_city,
       email,
       tel,
       team_role)
    VALUES
      (people_seq.nextval,
       p_first_name,
       p_last_name,
       p_team_id,
       p_birth_date,
       p_birth_place_city,
       p_email,
       p_tel,
       p_team_role);
    IF (upper(p_team_role) = l_player) THEN
      INSERT INTO player_stat
        (stat_id, player_id, playing_position)
      VALUES
        (stat_seq.nextval, people_seq.currval, p_playing_position);
    END IF;
    COMMIT;
    dbms_output.put_line('Az új személy sikeresen hozáadódott a táblához.');
  EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line('HIBA: Nem megfelelőek a bevitt adatok!');
      ROLLBACK;
  END;
END add_people;
/
