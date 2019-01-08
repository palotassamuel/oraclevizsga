PROMPT Creating user FOOTBALL_MANAGER...

----------------------------------
-- 1. Create user, add grants   --
----------------------------------
declare
  cursor cur is
    select 'alter system kill session ''' || sid || ',' || serial# || '''' as command
      from v$session
     where username = 'FOOTBALL_MANAGER';
begin
  for c in cur loop
    EXECUTE IMMEDIATE c.command;
  end loop;
end;
/

DECLARE
  v_count NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_count FROM dba_users t WHERE t.username='FOOTBALL_MANAGER';
  IF v_count = 1 THEN 
    EXECUTE IMMEDIATE 'DROP USER football_manager CASCADE';
  END IF;
END;
/
CREATE USER football_manager 
  IDENTIFIED BY "12345678" 
  DEFAULT TABLESPACE users
  QUOTA UNLIMITED ON users
;

GRANT CREATE TRIGGER to football_manager;
GRANT CREATE SESSION TO football_manager;
GRANT CREATE TABLE TO football_manager;
GRANT CREATE VIEW TO football_manager;
GRANT CREATE SEQUENCE TO football_manager;
GRANT CREATE PROCEDURE TO football_manager;
GRANT CREATE TYPE TO football_manager;
GRANT CREATE JOB TO dog_manager;

ALTER SESSION SET CURRENT_SCHEMA=football_manager;

PROMPT Done.

----------------------------------
-- 2. Create tables             --
----------------------------------
PROMPT Creating table TEAM...

CREATE TABLE team(
  team_id       NUMBER          NOT NULL,
  team_name     VARCHAR2(100)   NOT NULL UNIQUE,
  city          VARCHAR2(100)   NOT NULL,
  email         VARCHAR2(100),
  tel           VARCHAR2(100)     
) TABLESPACE users;

ALTER TABLE team
  ADD CONSTRAINT team_pk PRIMARY KEY (team_id);

COMMENT ON TABLE team IS 'Bajnokságban szereplő csapatok';

PROMPT Done.

PROMPT Creating table PEOPLE...

CREATE TABLE people(
  people_id        NUMBER          NOT NULL,
  first_name       VARCHAR2(40)    NOT NULL,
  last_name        VARCHAR2(40)    NOT NULL,
  team_id          NUMBER          NOT NULL,
  birth_date       DATE,
  birth_place_city VARCHAR2(100),
  email            VARCHAR2(100),
  tel              VARCHAR2(100),
  team_role        VARCHAR2(100)   NOT NULL                   
) TABLESPACE users;

ALTER TABLE people
  ADD CONSTRAINT people_pk PRIMARY KEY (people_id);
  
ALTER TABLE people
  ADD CONSTRAINT people_fk FOREIGN KEY (team_id) REFERENCES team(team_id);

COMMENT ON TABLE people IS 'Emberek';
COMMENT ON COLUMN people.team_role IS 'A csapatban betöltött feladatkör';

PROMPT Done.

PROMPT Creating table PLAYER_STAT...

CREATE TABLE player_stat(
  stat_id          NUMBER          NOT NULL,
  player_id        NUMBER          NOT NULL,
  playing_position VARCHAR2(100)   NOT NULL,
  played_matches   NUMBER          DEFAULT 0 NOT NULL,
  goals            NUMBER          DEFAULT 0 NOT NULL,
  assists          NUMBER          DEFAULT 0 NOT NULL,
  yellow_cards     NUMBER          DEFAULT 0 NOT NULL,
  red_cards        NUMBER          DEFAULT 0 NOT NULL,
  suspension       NUMBER(1)       DEFAULT 0 NOT NULL,
  injury           NUMBER(1)       DEFAULT 0 NOT NULL       
) TABLESPACE users;

ALTER TABLE player_stat
  ADD CONSTRAINT player_stat_pk PRIMARY KEY (stat_id);

ALTER TABLE player_stat
  ADD CONSTRAINT player_stat_fk FOREIGN KEY (player_id) REFERENCES people(people_id);

COMMENT ON TABLE player_stat IS 'Játékosok statisztikái';
COMMENT ON COLUMN player_stat.playing_position IS 'A játékos posztja a pályán';
COMMENT ON COLUMN player_stat.suspension IS 'Eltiltás';

PROMPT Done.

PROMPT Creating table CHAMPIONSHIP...

CREATE TABLE championship(
  championship_id  NUMBER          NOT NULL,
  team_id          NUMBER          NOT NULL,
  played_matches   NUMBER          DEFAULT 0 NOT NULL,
  won              NUMBER          DEFAULT 0 NOT NULL,
  drawn            NUMBER          DEFAULT 0 NOT NULL,
  lost             NUMBER          DEFAULT 0 NOT NULL,
  points           NUMBER          DEFAULT 0 NOT NULL     
) TABLESPACE users;

ALTER TABLE championship
  ADD CONSTRAINT championship_pk PRIMARY KEY (championship_id);

ALTER TABLE championship
  ADD CONSTRAINT championship_team_fk FOREIGN KEY (team_id) REFERENCES team(team_id);

COMMENT ON TABLE championship IS 'Bajnokság állása';

PROMPT Done.

PROMPT Creating table MATCH...

CREATE OR REPLACE TYPE player_id_list AS TABLE OF NUMBER;
/

CREATE TABLE match(
  match_id         NUMBER          NOT NULL,
  home_team_id     NUMBER          NOT NULL,
  away_team_id     NUMBER          NOT NULL,
  home_goals       NUMBER          NOT NULL,
  away_goals       NUMBER          NOT NULL,
  goal_scorers     player_id_list,
  assists          player_id_list,
  yellow_cards     player_id_list,
  red_cards        player_id_list,
  suspended        player_id_list,
  injured          player_id_list    
) NESTED TABLE goal_scorers STORE AS goal_scorers_table,
  NESTED TABLE assists      STORE AS assists_table,
  NESTED TABLE yellow_cards STORE AS yellow_cards_table,
  NESTED TABLE red_cards    STORE AS red_cards_table,
  NESTED TABLE suspended    STORE AS suspended_table,
  NESTED TABLE injured      STORE AS injured_table,
  TABLESPACE users;

ALTER TABLE match
  ADD CONSTRAINT match_pk PRIMARY KEY (match_id);
  
ALTER TABLE match
  ADD CONSTRAINT match_home_team_fk FOREIGN KEY (home_team_id) REFERENCES team(team_id);
  
ALTER TABLE match
  ADD CONSTRAINT match_away_team_fk FOREIGN KEY (away_team_id) REFERENCES team(team_id);
  
COMMENT ON TABLE match IS 'Lejátszott mérkőzések';

PROMPT Done.

PROMPT Loading tables...

prompt Loading TEAM...

INSERT INTO team(team_id, team_name, city, email, tel)
VALUES (1, 'PVSK', 'Pécs', 'pvsk@email.hu', '060111222');
INSERT INTO team(team_id, team_name, city, email, tel)
VALUES (2, 'SZEGED FC', 'Szeged', 'szfc@email.hu', '060111333');
INSERT INTO team(team_id, team_name, city, email, tel)
VALUES (3, 'FTC', 'Budapest', 'ftc@email.hu', '060111111');
INSERT INTO team(team_id, team_name, city, email, tel)
VALUES (4, 'HONVÉD', 'Budapest', 'honved@email.hu', '060000222');

prompt Loading PEOPLE...

INSERT INTO people(people_id, first_name, last_name, team_id, birth_date, birth_place_city, email, tel, team_role)
VALUES (1, 'László', 'Tóth', 1, to_date('23-10-1986', 'dd-mm-yyyy'), 'Veszprém', 'laszlo.toth@tot.hu', '0678123456','játékos');
INSERT INTO people(people_id, first_name, last_name, team_id, birth_date, birth_place_city, email, tel, team_role)
VALUES (2, 'Marcell', 'Nagy', 1, to_date('23-10-1990', 'dd-mm-yyyy'), 'Kaposvár', 'laszlo.nagy@email.hu', '067812355','játékos');
INSERT INTO people(people_id, first_name, last_name, team_id, birth_date, birth_place_city, email, tel, team_role)
VALUES (3, 'Imre', 'Tóth', 1, to_date('23-10-1985', 'dd-mm-yyyy'), 'Budapest', 'imre.toth@tot.hu', '0678123412','játékos');
INSERT INTO people(people_id, first_name, last_name, team_id, birth_date, birth_place_city, email, tel, team_role)
VALUES (4, 'Gábor', 'Kis', 1, to_date('23-10-1990', 'dd-mm-yyyy'), 'Budapest', 'laszlo.kis@tot.hu', '0678123444','játékos');
INSERT INTO people(people_id, first_name, last_name, team_id, birth_date, birth_place_city, email, tel, team_role)
VALUES (5, 'József', 'Miklós', 1, to_date('23-10-1998', 'dd-mm-yyyy'), 'Veszprém', 'jozsef.miklos@email.hu', '067812123','játékos');
INSERT INTO people(people_id, first_name, last_name, team_id, birth_date, birth_place_city, email, tel, team_role)
VALUES (6, 'György', 'Szabó', 2, to_date('23-10-1991', 'dd-mm-yyyy'), 'Pécs', 'gyorgy.szabo@email.hu', '067812111','játékos');
INSERT INTO people(people_id, first_name, last_name, team_id, birth_date, birth_place_city, email, tel, team_role)
VALUES (7, 'Csaba', 'Pécsi', 2, to_date('23-10-1988', 'dd-mm-yyyy'), 'Pécs', 'csaba.pécsi@email.hu', '067812000','játékos');
INSERT INTO people(people_id, first_name, last_name, team_id, birth_date, birth_place_city, email, tel, team_role)
VALUES (8, 'Gyula', 'Marosi', 2, to_date('23-10-1995', 'dd-mm-yyyy'), 'Pécs', 'gyula.marosi@email.hu', '067812321','játékos');
INSERT INTO people(people_id, first_name, last_name, team_id, birth_date, birth_place_city, email, tel, team_role)
VALUES (9, 'Gergely', 'Jónás', 2, to_date('23-10-1988', 'dd-mm-yyyy'), 'Szeged', 'gergely.jónás@email.hu', '067000321','játékos');
INSERT INTO people(people_id, first_name, last_name, team_id, birth_date, birth_place_city, email, tel, team_role)
VALUES (10, 'Mihály', 'Vas', 2, to_date('23-10-1979', 'dd-mm-yyyy'), 'Mohács', 'mihaly.vas@email.hu', '067000000','játékos');
INSERT INTO people(people_id, first_name, last_name, team_id, birth_date, birth_place_city, email, tel, team_role)
VALUES (11, 'András', 'Kovács', 3, to_date('23-10-1986', 'dd-mm-yyyy'), 'Pécs', 'andras.kovacs@email.hu', '067888999','játékos');
INSERT INTO people(people_id, first_name, last_name, team_id, birth_date, birth_place_city, email, tel, team_role)
VALUES (12, 'Zoltán', 'Balog', 3, to_date('23-10-1996', 'dd-mm-yyyy'), 'Zalaegerszeg', 'zoltan.balog@email.hu', '067888888','játékos');
INSERT INTO people(people_id, first_name, last_name, team_id, birth_date, birth_place_city, email, tel, team_role)
VALUES (13, 'Károly', 'Horváth', 3, to_date('23-10-1984', 'dd-mm-yyyy'), 'Pécs', 'karoly.horvath@email.hu', '067999999','játékos');
INSERT INTO people(people_id, first_name, last_name, team_id, birth_date, birth_place_city, email, tel, team_role)
VALUES (14, 'András', 'Németh', 3, to_date('23-10-1989', 'dd-mm-yyyy'), 'Baja', 'andras.nemeth@email.hu', '067888777','játékos');
INSERT INTO people(people_id, first_name, last_name, team_id, birth_date, birth_place_city, email, tel, team_role)
VALUES (15, 'Tamás', 'Lengyel', 3, to_date('23-10-1989', 'dd-mm-yyyy'), 'Pécs', 'tamas.lengyel@email.hu', '067112233','játékos');
INSERT INTO people(people_id, first_name, last_name, team_id, birth_date, birth_place_city, email, tel, team_role)
VALUES (16, 'Dénes', 'Kistamás', 4, to_date('23-10-1987', 'dd-mm-yyyy'), 'Baja', 'denes.kistamas@email.hu', '067333444','játékos');
INSERT INTO people(people_id, first_name, last_name, team_id, birth_date, birth_place_city, email, tel, team_role)
VALUES (17, 'Márton', 'Nagypál', 4, to_date('23-10-1991', 'dd-mm-yyyy'), 'Zalaegerszeg', 'marton.nagypal@email.hu', '067444444','játékos');
INSERT INTO people(people_id, first_name, last_name, team_id, birth_date, birth_place_city, email, tel, team_role)
VALUES (18, 'József', 'Kispál', 4, to_date('23-10-1983', 'dd-mm-yyyy'), 'Pécs', 'jozsef.kispal@email.hu', '067555999','játékos');
INSERT INTO people(people_id, first_name, last_name, team_id, birth_date, birth_place_city, email, tel, team_role)
VALUES (19, 'Szablocs', 'Kóródi', 4, to_date('23-10-1987', 'dd-mm-yyyy'), 'Debrecen', 'szabolcs.korodi@email.hu', '067555777','játékos');
INSERT INTO people(people_id, first_name, last_name, team_id, birth_date, birth_place_city, email, tel, team_role)
VALUES (20, 'Krisztián', 'Molnár', 4, to_date('23-10-1999', 'dd-mm-yyyy'), 'Miskolc', 'krisztian.molnar@email.hu', '067666666','játékos');
INSERT INTO people(people_id, first_name, last_name, team_id, birth_date, birth_place_city, email, tel, team_role)
VALUES (21, 'Dobos', 'József', 1, to_date('23-10-1959', 'dd-mm-yyyy'), 'Miskolc', 'dobos.jozsef@email.hu', '06711221122','edző');
INSERT INTO people(people_id, first_name, last_name, team_id, birth_date, birth_place_city, email, tel, team_role)
VALUES (22, 'Berta', 'Pál', 1, to_date('23-10-1949', 'dd-mm-yyyy'), 'Miskolc', 'berta.pal@email.hu', '067987987','elnök');

prompt Loading PLAYER_STAT...

INSERT INTO player_stat(stat_id, player_id, playing_position)
VALUES(1, 1 ,'kapus');
INSERT INTO player_stat(stat_id, player_id, playing_position)
VALUES(2, 2 ,'hátvéd');
INSERT INTO player_stat(stat_id, player_id, playing_position)
VALUES(3, 3 ,'középpályás');
INSERT INTO player_stat(stat_id, player_id, playing_position)
VALUES(4, 4 ,'csatár');
INSERT INTO player_stat(stat_id, player_id, playing_position)
VALUES(5, 5 ,'csatár');
INSERT INTO player_stat(stat_id, player_id, playing_position)
VALUES(6, 6 ,'kapus');
INSERT INTO player_stat(stat_id, player_id, playing_position)
VALUES(7, 7 ,'hátvéd');
INSERT INTO player_stat(stat_id, player_id, playing_position)
VALUES(8, 8 ,'középpályás');
INSERT INTO player_stat(stat_id, player_id, playing_position)
VALUES(9, 9 ,'csatár');
INSERT INTO player_stat(stat_id, player_id, playing_position)
VALUES(10, 10 ,'csatár');
INSERT INTO player_stat(stat_id, player_id, playing_position)
VALUES(11, 11 ,'kapus');
INSERT INTO player_stat(stat_id, player_id, playing_position)
VALUES(12, 12 ,'hátvéd');
INSERT INTO player_stat(stat_id, player_id, playing_position)
VALUES(13, 13 ,'középpályás');
INSERT INTO player_stat(stat_id, player_id, playing_position)
VALUES(14, 14 ,'csatár');
INSERT INTO player_stat(stat_id, player_id, playing_position)
VALUES(15, 15 ,'csatár');
INSERT INTO player_stat(stat_id, player_id, playing_position)
VALUES(16, 16 ,'kapus');
INSERT INTO player_stat(stat_id, player_id, playing_position)
VALUES(17, 17 ,'hátvéd');
INSERT INTO player_stat(stat_id, player_id, playing_position)
VALUES(18, 18 ,'középpályás');
INSERT INTO player_stat(stat_id, player_id, playing_position)
VALUES(19, 19 ,'csatár');
INSERT INTO player_stat(stat_id, player_id, playing_position)
VALUES(20, 20 ,'csatár');

prompt Loading CHAMPIONSHIP...

INSERT INTO championship(championship_id,team_id)
VALUES(1,1);
INSERT INTO championship(championship_id,team_id)
VALUES(2,2);
INSERT INTO championship(championship_id,team_id)
VALUES(3,3);
INSERT INTO championship(championship_id,team_id)
VALUES(4,4);

PROMPT Done.

prompt Procedures, Views, Sequences, Triggers...

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

CREATE OR REPLACE VIEW vw_suspended_players
AS
SELECT p.first_name,p.last_name
  FROM people p 
  JOIN player_stat ps
    ON p.people_id=ps.stat_id
 WHERE ps.suspension=1;
/

CREATE OR REPLACE VIEW vw_injured_players
AS
SELECT p.first_name,p.last_name
  FROM people p 
  JOIN player_stat ps
    ON p.people_id=ps.stat_id
 WHERE ps.injury=1;
/

CREATE OR REPLACE VIEW vw_championship
AS
SELECT t.team_name, ch.points, ch.played_matches
  FROM championship ch
  JOIN team t
    ON ch.team_id=t.team_id
 ORDER BY ch.points DESC, ch.played_matches DESC;
/

CREATE OR REPLACE PROCEDURE teams_from_same_city(p_city IN VARCHAR2) IS
  CURSOR city_cur IS
    SELECT t.team_name FROM team t WHERE upper(t.city) = upper(p_city);

  is_found_rec BOOLEAN := FALSE;

BEGIN
  dbms_output.put_line(upper(p_city) ||
                       ' város a következő csapatok székhelye: ');

  FOR i IN city_cur LOOP
    dbms_output.put_line(chr(9) || i.team_name);
    is_found_rec := TRUE;
  END LOOP;

  IF NOT is_found_rec THEN
    dbms_output.put_line('Ebben a városban nem található csapat.');
  END IF;

END teams_from_same_city;
/

CREATE SEQUENCE team_seq START WITH 10;
CREATE SEQUENCE championship_seq START WITH 10;
CREATE SEQUENCE people_seq START WITH 25;
CREATE SEQUENCE stat_seq START WITH 25;
CREATE SEQUENCE match_seq START WITH 1;


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
      ROLLBACK;
  END;
END add_team;
/

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

CREATE TABLE team_h(
  team_id       NUMBER,
  team_name     VARCHAR2(100),
  city          VARCHAR2(100),
  email         VARCHAR2(100),
  tel           VARCHAR2(100),  
  mod_user      VARCHAR2(300),
  mod_time      TIMESTAMP(6),
  dml_flag      VARCHAR2(1)
)TABLESPACE users;

CREATE TABLE people_h(
  people_id        NUMBER,
  first_name       VARCHAR2(40),
  last_name        VARCHAR2(40),
  team_id          NUMBER,
  birth_date       DATE,
  birth_place_city VARCHAR2(100),
  email            VARCHAR2(100),
  tel              VARCHAR2(100),
  team_role        VARCHAR2(100),
  mod_user         VARCHAR2(300),
  mod_time         TIMESTAMP(6),
  dml_flag         VARCHAR2(1)                
) TABLESPACE users;

CREATE TABLE player_stat_h(
  stat_id          NUMBER,
  player_id        NUMBER,
  playing_position VARCHAR2(100),
  played_matches   NUMBER,
  goals            NUMBER,
  assists          NUMBER,
  yellow_cards     NUMBER,
  red_cards        NUMBER,
  suspension       NUMBER(1),
  injury           NUMBER(1),
  mod_user         VARCHAR2(300),
  mod_time         TIMESTAMP(6),
  dml_flag         VARCHAR2(1)     
) TABLESPACE users;

CREATE TABLE match_h(
  match_id         NUMBER,
  home_team_id     NUMBER,
  away_team_id     NUMBER,
  home_goals       NUMBER,
  away_goals       NUMBER,
  goal_scorers     player_id_list,
  assists          player_id_list,
  yellow_cards     player_id_list,
  red_cards        player_id_list,
  suspended        player_id_list,
  injured          player_id_list, 
  mod_user         VARCHAR2(300),
  mod_time         TIMESTAMP(6),
  dml_flag         VARCHAR2(1) 
) NESTED TABLE goal_scorers STORE AS goal_scorers_table_h,
  NESTED TABLE assists      STORE AS assists_table_h,
  NESTED TABLE yellow_cards STORE AS yellow_cards_table_h,
  NESTED TABLE red_cards    STORE AS red_cards_table_h,
  NESTED TABLE suspended    STORE AS suspended_table_h,
  NESTED TABLE injured      STORE AS injured_table_h,
  TABLESPACE users;
  
CREATE TABLE championship_h(
  championship_id  NUMBER,
  team_id          NUMBER,
  played_matches   NUMBER,
  won              NUMBER,
  drawn            NUMBER,
  lost             NUMBER,
  points           NUMBER,
  mod_user         VARCHAR2(300),
  mod_time         TIMESTAMP(6),
  dml_flag         VARCHAR2(1)    
) TABLESPACE users;


CREATE OR REPLACE TRIGGER team_h_trg
  AFTER INSERT OR UPDATE OR DELETE ON team
  FOR EACH ROW
BEGIN
  IF deleting THEN
    INSERT INTO team_h
      (team_id, team_name, city, email, tel, mod_user, mod_time, dml_flag)
    VALUES
      (:old.team_id,
       :old.team_name,
       :old.city,
       :old.email,
       :old.tel,
       sys_context('USERENV', 'OS_USER'),
       SYSDATE,
       'D');
  ELSIF inserting THEN
    INSERT INTO team_h
      (team_id, team_name, city, email, tel, mod_user, mod_time, dml_flag)
    VALUES
      (:new.team_id,
       :new.team_name,
       :new.city,
       :new.email,
       :new.tel,
       sys_context('USERENV', 'OS_USER'),
       SYSDATE,
       'I');
  ELSE
    INSERT INTO team_h
      (team_id, team_name, city, email, tel, mod_user, mod_time, dml_flag)
    VALUES
      (:new.team_id,
       :new.team_name,
       :new.city,
       :new.email,
       :new.tel,
       sys_context('USERENV', 'OS_USER'),
       SYSDATE,
       'U');
  END IF;
END team_h_trg;
/

CREATE OR REPLACE TRIGGER people_h_trg
  AFTER INSERT OR UPDATE OR DELETE ON people
  FOR EACH ROW
BEGIN
  IF deleting THEN
    INSERT INTO people_h
      (people_id,
       first_name,
       last_name,
       team_id,
       birth_date,
       birth_place_city,
       email,
       tel,
       team_role,
       mod_user,
       mod_time,
       dml_flag)
    VALUES
      (:old.people_id,
       :old.first_name,
       :old.last_name,
       :old.team_id,
       :old.birth_date,
       :old.birth_place_city,
       :old.email,
       :old.tel,
       :old.team_role,
       sys_context('USERENV', 'OS_USER'),
       SYSDATE,
       'D');
  ELSIF inserting THEN
    INSERT INTO people_h
      (people_id,
       first_name,
       last_name,
       team_id,
       birth_date,
       birth_place_city,
       email,
       tel,
       team_role,
       mod_user,
       mod_time,
       dml_flag)
    VALUES
      (:new.people_id,
       :new.first_name,
       :new.last_name,
       :new.team_id,
       :new.birth_date,
       :new.birth_place_city,
       :new.email,
       :new.tel,
       :new.team_role,
       sys_context('USERENV', 'OS_USER'),
       SYSDATE,
       'I');
  ELSE
    INSERT INTO people_h
      (people_id,
       first_name,
       last_name,
       team_id,
       birth_date,
       birth_place_city,
       email,
       tel,
       team_role,
       mod_user,
       mod_time,
       dml_flag)
    VALUES
      (:new.people_id,
       :new.first_name,
       :new.last_name,
       :new.team_id,
       :new.birth_date,
       :new.birth_place_city,
       :new.email,
       :new.tel,
       :new.team_role,
       sys_context('USERENV', 'OS_USER'),
       SYSDATE,
       'U');
  END IF;
END people_h_trg;
/

CREATE OR REPLACE TRIGGER player_stat_h_trg
  AFTER INSERT OR UPDATE OR DELETE ON player_stat
  FOR EACH ROW
BEGIN
  IF deleting THEN
    INSERT INTO player_stat_h
      (stat_id,
       player_id,
       playing_position,
       played_matches,
       goals,
       assists,
       yellow_cards,
       red_cards,
       suspension,
       injury,
       mod_user,
       mod_time,
       dml_flag)
    VALUES
      (:old.stat_id,
       :old.player_id,
       :old.playing_position,
       :old.played_matches,
       :old.goals,
       :old.assists,
       :old.yellow_cards,
       :old.red_cards,
       :old.suspension,
       :old.injury,
       sys_context('USERENV', 'OS_USER'),
       SYSDATE,
       'D');
  ELSIF inserting THEN
    INSERT INTO player_stat_h
      (stat_id,
       player_id,
       playing_position,
       played_matches,
       goals,
       assists,
       yellow_cards,
       red_cards,
       suspension,
       injury,
       mod_user,
       mod_time,
       dml_flag)
    VALUES
      (:new.stat_id,
       :new.player_id,
       :new.playing_position,
       :new.played_matches,
       :new.goals,
       :new.assists,
       :new.yellow_cards,
       :new.red_cards,
       :new.suspension,
       :new.injury,
       sys_context('USERENV', 'OS_USER'),
       SYSDATE,
       'I');
  ELSE
    INSERT INTO player_stat_h
      (stat_id,
       player_id,
       playing_position,
       played_matches,
       goals,
       assists,
       yellow_cards,
       red_cards,
       suspension,
       injury,
       mod_user,
       mod_time,
       dml_flag)
    VALUES
      (:new.stat_id,
       :new.player_id,
       :new.playing_position,
       :new.played_matches,
       :new.goals,
       :new.assists,
       :new.yellow_cards,
       :new.red_cards,
       :new.suspension,
       :new.injury,
       sys_context('USERENV', 'OS_USER'),
       SYSDATE,
       'U');
  END IF;
END player_stat_h_trg;
/

CREATE OR REPLACE TRIGGER match_h_trg
  AFTER INSERT OR UPDATE OR DELETE ON match
  FOR EACH ROW
BEGIN
  IF deleting THEN
    INSERT INTO match_h
      (match_id,
       home_team_id,
       away_team_id,
       home_goals,
       away_goals,
       goal_scorers,
       assists,
       yellow_cards,
       red_cards,
       suspended,
       injured,
       mod_user,
       mod_time,
       dml_flag)
    VALUES
      (:old.match_id,
       :old.home_team_id,
       :old.away_team_id,
       :old.home_goals,
       :old.away_goals,
       :old.goal_scorers,
       :old.assists,
       :old.yellow_cards,
       :old.red_cards,
       :old.suspended,
       :old.injured,
       sys_context('USERENV', 'OS_USER'),
       SYSDATE,
       'D');
  ELSIF inserting THEN
    INSERT INTO match_h
      (match_id,
       home_team_id,
       away_team_id,
       home_goals,
       away_goals,
       goal_scorers,
       assists,
       yellow_cards,
       red_cards,
       suspended,
       injured,
       mod_user,
       mod_time,
       dml_flag)
    VALUES
      (:new.match_id,
       :new.home_team_id,
       :new.away_team_id,
       :new.home_goals,
       :new.away_goals,
       :new.goal_scorers,
       :new.assists,
       :new.yellow_cards,
       :new.red_cards,
       :new.suspended,
       :new.injured,
       sys_context('USERENV', 'OS_USER'),
       SYSDATE,
       'I');
  ELSE
    INSERT INTO match_h
      (match_id,
       home_team_id,
       away_team_id,
       home_goals,
       away_goals,
       goal_scorers,
       assists,
       yellow_cards,
       red_cards,
       suspended,
       injured,
       mod_user,
       mod_time,
       dml_flag)
    VALUES
      (:new.match_id,
       :new.home_team_id,
       :new.away_team_id,
       :new.home_goals,
       :new.away_goals,
       :new.goal_scorers,
       :new.assists,
       :new.yellow_cards,
       :new.red_cards,
       :new.suspended,
       :new.injured,
       sys_context('USERENV', 'OS_USER'),
       SYSDATE,
       'U');
  END IF;
END match_h_trg;
/

CREATE OR REPLACE TRIGGER championship_h_trg
  AFTER INSERT OR UPDATE OR DELETE ON championship
  FOR EACH ROW
BEGIN
  IF deleting THEN
    INSERT INTO championship_h
      (championship_id,
       team_id,
       played_matches,
       won,
       drawn,
       lost,
       points,
       mod_user,
       mod_time,
       dml_flag)
    VALUES
      (:old.championship_id,
       :old.team_id,
       :old.played_matches,
       :old.won,
       :old.drawn,
       :old.lost,
       :old.points,
       sys_context('USERENV', 'OS_USER'),
       SYSDATE,
       'D');
  ELSIF inserting THEN
    INSERT INTO championship_h
      (championship_id,
       team_id,
       played_matches,
       won,
       drawn,
       lost,
       points,
       mod_user,
       mod_time,
       dml_flag)
    VALUES
      (:new.championship_id,
       :new.team_id,
       :new.played_matches,
       :new.won,
       :new.drawn,
       :new.lost,
       :new.points,
       sys_context('USERENV', 'OS_USER'),
       SYSDATE,
       'I');
  ELSE
    INSERT INTO championship_h
      (championship_id,
       team_id,
       played_matches,
       won,
       drawn,
       lost,
       points,
       mod_user,
       mod_time,
       dml_flag)
    VALUES
      (:new.championship_id,
       :new.team_id,
       :new.played_matches,
       :new.won,
       :new.drawn,
       :new.lost,
       :new.points,
       sys_context('USERENV', 'OS_USER'),
       SYSDATE,
       'U');
  END IF;
END championship_h_trg;
/

CREATE OR REPLACE PROCEDURE add_new_match(p_home_team_id NUMBER,
                                          p_away_team_id NUMBER,
                                          p_home_goals   NUMBER,
                                          p_away_goals   NUMBER,
                                          p_goal_scorers player_id_list,
                                          p_assists      player_id_list,
                                          p_yellow_cards player_id_list,
                                          p_red_cards    player_id_list,
                                          p_suspended    player_id_list,
                                          p_injured      player_id_list) IS
  PRAGMA AUTONOMOUS_TRANSACTION;
  e_equivalent_team_ids EXCEPTION;
  e_wrong_data          EXCEPTION;
  l_check_ids NUMBER;
BEGIN
  BEGIN
    IF (p_home_team_id = p_away_team_id) THEN
      dbms_output.put_line('HIBA: A két csapat nem lehet azonos!');
      RAISE e_equivalent_team_ids;
    END IF;
    IF (p_home_goals < 0 OR p_away_goals < 0) THEN
      dbms_output.put_line('HIBA: A gólok száma nem lehet kisebb mint 0!');
      RAISE e_wrong_data;
    END IF;
    INSERT INTO match
      (match_id,
       home_team_id,
       away_team_id,
       home_goals,
       away_goals,
       goal_scorers,
       assists,
       yellow_cards,
       red_cards,
       suspended,
       injured)
    VALUES
      (match_seq.nextval,
       p_home_team_id,
       p_away_team_id,
       p_home_goals,
       p_away_goals,
       p_goal_scorers,
       p_assists,
       p_yellow_cards,
       p_red_cards,
       p_suspended,
       p_injured);
  
    IF (p_away_goals = p_home_goals) THEN
      UPDATE championship ch
         SET ch.played_matches = ch.played_matches + 1,
             ch.drawn          = ch.drawn + 1,
             ch.points         = ch.points + 1
       WHERE ch.team_id = p_home_team_id
          OR ch.team_id = p_away_team_id;
    ELSIF (p_home_goals > p_away_goals) THEN
      UPDATE championship ch
         SET ch.played_matches = ch.played_matches + 1,
             ch.won            = ch.won + 1,
             ch.points         = ch.points + 3
       WHERE ch.team_id = p_home_team_id;
      UPDATE championship ch
         SET ch.played_matches = ch.played_matches + 1,
             ch.lost           = ch.lost + 1
       WHERE ch.team_id = p_away_team_id;
    ELSE
      UPDATE championship ch
         SET ch.played_matches = ch.played_matches + 1,
             ch.lost           = ch.lost + 1
       WHERE ch.team_id = p_home_team_id;
      UPDATE championship ch
         SET ch.played_matches = ch.played_matches + 1,
             ch.won            = ch.won + 1,
             ch.points         = ch.points + 3
       WHERE ch.team_id = p_away_team_id;
    END IF;
  
    IF (p_goal_scorers IS NOT NULL AND p_goal_scorers.count <> 0) THEN
      FOR i IN p_goal_scorers.first .. p_goal_scorers.last LOOP
        SELECT ps.player_id
          INTO l_check_ids
          FROM player_stat ps
         WHERE ps.player_id = p_goal_scorers(i);
      
        UPDATE player_stat ps
           SET ps.goals = ps.goals + 1
         WHERE ps.player_id = p_goal_scorers(i);
      END LOOP;
    END IF;
    IF (p_assists IS NOT NULL AND p_assists.count <> 0) THEN
      FOR i IN p_assists.first .. p_assists.last LOOP
        SELECT ps.player_id
          INTO l_check_ids
          FROM player_stat ps
         WHERE ps.player_id = p_assists(i);
      
        UPDATE player_stat ps
           SET ps.assists = ps.assists + 1
         WHERE ps.player_id = p_assists(i);
      END LOOP;
    END IF;
    IF (p_yellow_cards IS NOT NULL AND p_yellow_cards.count <> 0) THEN
      FOR i IN p_yellow_cards.first .. p_yellow_cards.last LOOP
        SELECT ps.player_id
          INTO l_check_ids
          FROM player_stat ps
         WHERE ps.player_id = p_yellow_cards(i);
      
        UPDATE player_stat ps
           SET ps.yellow_cards = ps.yellow_cards + 1
         WHERE ps.player_id = p_yellow_cards(i);
      END LOOP;
    END IF;
    IF (p_red_cards IS NOT NULL AND p_red_cards.count <> 0) THEN
      FOR i IN p_red_cards.first .. p_red_cards.last LOOP
        SELECT ps.player_id
          INTO l_check_ids
          FROM player_stat ps
         WHERE ps.player_id = p_red_cards(i);
      
        UPDATE player_stat ps
           SET ps.red_cards = ps.red_cards + 1
         WHERE ps.player_id = p_red_cards(i);
      END LOOP;
    END IF;
    IF (p_suspended IS NOT NULL AND p_suspended.count <> 0) THEN
      FOR i IN p_suspended.first .. p_suspended.last LOOP
        SELECT ps.player_id
          INTO l_check_ids
          FROM player_stat ps
         WHERE ps.player_id = p_suspended(i);
      
        UPDATE player_stat ps
           SET ps.suspension = 1
         WHERE ps.player_id = p_suspended(i);
      END LOOP;
    END IF;
    IF (p_injured IS NOT NULL AND p_injured.count <> 0) THEN
      FOR i IN p_injured.first .. p_injured.last LOOP
        SELECT ps.player_id
          INTO l_check_ids
          FROM player_stat ps
         WHERE ps.player_id = p_injured(i);
      
        UPDATE player_stat ps
           SET ps.injury = 1
         WHERE ps.player_id = p_injured(i);
      END LOOP;
    END IF;
    COMMIT;
    dbms_output.put_line('Az új mérkőzés sikeresen hozáadódott a táblához.');
  EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line('HIBA: Nem megfelelőek a bevitt adatok!');
      ROLLBACK;
  END;
END add_new_match;
/

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

prompt Done.
