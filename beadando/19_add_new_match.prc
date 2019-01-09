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
          JOIN people p
            ON ps.player_id = p.people_id
         WHERE ps.player_id = p_goal_scorers(i)
           AND (p.team_id = p_home_team_id OR p.team_id = p_away_team_id);
      
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
          JOIN people p
            ON ps.player_id = p.people_id
         WHERE ps.player_id = p_assists(i)
           AND (p.team_id = p_home_team_id OR p.team_id = p_away_team_id);
      
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
          JOIN people p
            ON ps.player_id = p.people_id
         WHERE ps.player_id = p_yellow_cards(i)
           AND (p.team_id = p_home_team_id OR p.team_id = p_away_team_id);
      
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
          JOIN people p
            ON ps.player_id = p.people_id
         WHERE ps.player_id = p_red_cards(i)
           AND (p.team_id = p_home_team_id OR p.team_id = p_away_team_id);
      
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
          JOIN people p
            ON ps.player_id = p.people_id
         WHERE ps.player_id = p_suspended(i)
           AND (p.team_id = p_home_team_id OR p.team_id = p_away_team_id);
      
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
          JOIN people p
            ON ps.player_id = p.people_id
         WHERE ps.player_id = p_injured(i)
           AND (p.team_id = p_home_team_id OR p.team_id = p_away_team_id);
      
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
