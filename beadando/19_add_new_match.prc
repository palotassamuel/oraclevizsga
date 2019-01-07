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
BEGIN
  BEGIN
    IF (p_home_team_id = p_away_team_id) THEN
      dbms_output.put_line('HIBA: A két csapat nem lehet azonos!');
      RAISE e_equivalent_team_ids;
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
  
    IF (p_goal_scorers IS NOT NULL AND p_goal_scorers.count <> 0) THEN
      FOR i IN p_goal_scorers.first .. p_goal_scorers.last LOOP
        UPDATE player_stat ps
           SET ps.goals = ps.goals + 1
         WHERE ps.player_id = p_goal_scorers(i);
      END LOOP;
    END IF;
    IF (p_assists IS NOT NULL AND p_assists.count <> 0) THEN
      FOR i IN p_assists.first .. p_assists.last LOOP
        UPDATE player_stat ps
           SET ps.assists = ps.assists + 1
         WHERE ps.player_id = p_assists(i);
      END LOOP;
    END IF;
    IF (p_yellow_cards IS NOT NULL AND p_yellow_cards.count <> 0) THEN
      FOR i IN p_yellow_cards.first .. p_yellow_cards.last LOOP
        UPDATE player_stat ps
           SET ps.yellow_cards = ps.yellow_cards + 1
         WHERE ps.player_id = p_yellow_cards(i);
      END LOOP;
    END IF;
    IF (p_red_cards IS NOT NULL AND p_red_cards.count <> 0) THEN
      FOR i IN p_red_cards.first .. p_red_cards.last LOOP
        UPDATE player_stat ps
           SET ps.red_cards = ps.red_cards + 1
         WHERE ps.player_id = p_red_cards(i);
      END LOOP;
    END IF;
    IF (p_suspended IS NOT NULL AND p_suspended.count <> 0) THEN
      FOR i IN p_suspended.first .. p_suspended.last LOOP
        UPDATE player_stat ps
           SET ps.suspension = 1
         WHERE ps.player_id = p_suspended(i);
      END LOOP;
    END IF;
    IF (p_injured IS NOT NULL AND p_injured.count <> 0) THEN
      FOR i IN p_injured.first .. p_injured.last LOOP
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
