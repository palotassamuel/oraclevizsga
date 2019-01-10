CREATE OR REPLACE PACKAGE pkg_add_new_match IS

  gc_wrong_data        CONSTANT VARCHAR2(30) := 'Hibás adat!';
  gc_my_exception_code CONSTANT NUMBER := -20000;

  PROCEDURE match_start(p_home_team_id NUMBER, p_away_team_id NUMBER);
  PROCEDURE goal(p_team_id        NUMBER,
                 p_goal_scorer_id NUMBER,
                 p_assist_id      NUMBER);
  PROCEDURE fault(p_team_id        NUMBER,
                  p_yellow_card_id NUMBER,
                  p_red_card_id    NUMBER);
  PROCEDURE suspension_injury(p_team_id      NUMBER,
                              p_suspended_id NUMBER,
                              p_injured_id   NUMBER);
  PROCEDURE match_end;

END pkg_add_new_match;
/
CREATE OR REPLACE PACKAGE BODY pkg_add_new_match IS

  gv_match_id     NUMBER;
  gv_home_team_id NUMBER;
  gv_away_team_id NUMBER;
  gv_home_goals   NUMBER := 0;
  gv_away_goals   NUMBER := 0;

  PROCEDURE match_start(p_home_team_id NUMBER, p_away_team_id NUMBER) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    e_equivalent_team_ids EXCEPTION;
    lc_equivalent_team_ids CONSTANT VARCHAR2(30) := 'A csapat id-k megegyeznek!';
    lc_my_exception_code   CONSTANT NUMBER := -20001;
    l_players_who_played player_id_list := player_id_list();
  BEGIN
    BEGIN
      IF (p_home_team_id = p_away_team_id) THEN
        RAISE e_equivalent_team_ids;
      END IF;
    
      INSERT INTO match
        (match_id, home_team_id, away_team_id)
      VALUES
        (match_seq.nextval, p_home_team_id, p_away_team_id);
    
      SELECT ps.player_id
        BULK COLLECT
        INTO l_players_who_played
        FROM player_stat ps
        JOIN people p
          ON ps.player_id = p.people_id
       WHERE (p.team_id = p_home_team_id OR p.team_id = p_away_team_id)
         AND ps.suspension = 0
         AND ps.injury = 0;
    
      FOR i IN l_players_who_played.first .. l_players_who_played.last LOOP
        UPDATE player_stat ps
           SET ps.played_matches = ps.played_matches + 1
         WHERE ps.player_id = l_players_who_played(i);
      END LOOP;
    
      gv_match_id     := match_seq.currval;
      gv_home_team_id := p_home_team_id;
      gv_away_team_id := p_away_team_id;
      COMMIT;
    EXCEPTION
      WHEN e_equivalent_team_ids THEN
        raise_application_error(lc_my_exception_code,
                                lc_equivalent_team_ids);
      WHEN OTHERS THEN
        raise_application_error(gc_my_exception_code, gc_wrong_data);
        ROLLBACK;
    END;
  END match_start;

  PROCEDURE goal(p_team_id        NUMBER,
                 p_goal_scorer_id NUMBER,
                 p_assist_id      NUMBER) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    e_wrong_team_id EXCEPTION;
    l_goal_scorers player_id_list;
    l_assists      player_id_list;
    l_check_ids    NUMBER;
  BEGIN
    BEGIN
      IF (p_team_id = gv_home_team_id OR p_team_id = gv_away_team_id) THEN
        SELECT ps.player_id
          INTO l_check_ids
          FROM player_stat ps
          JOIN people p
            ON ps.player_id = p.people_id
         WHERE ps.player_id = p_goal_scorer_id
           AND p.team_id = p_team_id;
      
        SELECT ps.player_id
          INTO l_check_ids
          FROM player_stat ps
          JOIN people p
            ON ps.player_id = p.people_id
         WHERE ps.player_id = p_assist_id
           AND p.team_id = p_team_id;
      
        SELECT m.goal_scorers
          INTO l_goal_scorers
          FROM match m
         WHERE match_id = gv_match_id;
      
        IF (l_goal_scorers IS NULL) THEN
          l_goal_scorers := player_id_list();
        END IF;
        l_goal_scorers.extend(1);
        l_goal_scorers(l_goal_scorers.count) := p_goal_scorer_id;
      
        UPDATE match m
           SET m.goal_scorers = l_goal_scorers
         WHERE match_id = gv_match_id;
      
        UPDATE player_stat ps
           SET ps.goals = ps.goals + 1
         WHERE ps.player_id = p_goal_scorer_id;
      
        SELECT m.assists
          INTO l_assists
          FROM match m
         WHERE match_id = gv_match_id;
      
        IF (l_assists IS NULL) THEN
          l_assists := player_id_list();
        END IF;
        l_assists.extend(1);
        l_assists(l_assists.count) := p_assist_id;
      
        UPDATE match m
           SET m.assists = l_assists
         WHERE match_id = gv_match_id;
      
        UPDATE player_stat ps
           SET ps.assists = ps.assists + 1
         WHERE ps.player_id = p_assist_id;
      
        IF (p_team_id = gv_home_team_id) THEN
          gv_home_goals := gv_home_goals + 1;
        ELSE
          gv_away_goals := gv_away_goals + 1;
        END IF;
        COMMIT;
      ELSE
        RAISE e_wrong_team_id;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        raise_application_error(gc_my_exception_code, gc_wrong_data);
        ROLLBACK;
    END;
  END goal;

  PROCEDURE fault(p_team_id        NUMBER,
                  p_yellow_card_id NUMBER,
                  p_red_card_id    NUMBER) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    l_yellow_cards player_id_list;
    l_red_cards    player_id_list;
    l_check_ids    NUMBER;
  BEGIN
    BEGIN
      IF (p_team_id = gv_home_team_id OR p_team_id = gv_away_team_id) THEN
        IF (p_yellow_card_id IS NOT NULL) THEN
          SELECT ps.player_id
            INTO l_check_ids
            FROM player_stat ps
            JOIN people p
              ON ps.player_id = p.people_id
           WHERE ps.player_id = p_yellow_card_id
             AND (p.team_id = gv_home_team_id OR
                 p.team_id = gv_away_team_id);
        
          SELECT m.yellow_cards
            INTO l_yellow_cards
            FROM match m
           WHERE match_id = gv_match_id;
        
          IF (l_yellow_cards IS NULL) THEN
            l_yellow_cards := player_id_list();
          END IF;
          l_yellow_cards.extend(1);
          l_yellow_cards(l_yellow_cards.count) := p_yellow_card_id;
        
          UPDATE match m
             SET m.yellow_cards = l_yellow_cards
           WHERE match_id = gv_match_id;
        
          UPDATE player_stat ps
             SET ps.yellow_cards = ps.yellow_cards + 1
           WHERE ps.player_id = p_yellow_card_id;
        
        END IF;
      
        IF (p_red_card_id IS NOT NULL) THEN
          SELECT ps.player_id
            INTO l_check_ids
            FROM player_stat ps
            JOIN people p
              ON ps.player_id = p.people_id
           WHERE ps.player_id = p_red_card_id
             AND (p.team_id = gv_home_team_id OR
                 p.team_id = gv_away_team_id);
        
          SELECT m.red_cards
            INTO l_red_cards
            FROM match m
           WHERE match_id = gv_match_id;
        
          IF (l_red_cards IS NULL) THEN
            l_red_cards := player_id_list();
          END IF;
          l_red_cards.extend(1);
          l_red_cards(l_red_cards.count) := p_red_card_id;
        
          UPDATE match m
             SET m.red_cards = l_red_cards
           WHERE match_id = gv_match_id;
        
          UPDATE player_stat ps
             SET ps.red_cards = ps.red_cards + 1
           WHERE ps.player_id = p_red_card_id;
        END IF;
      
        COMMIT;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        raise_application_error(gc_my_exception_code, gc_wrong_data);
        ROLLBACK;
    END;
  END fault;

  PROCEDURE suspension_injury(p_team_id      NUMBER,
                              p_suspended_id NUMBER,
                              p_injured_id   NUMBER) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    l_suspended player_id_list;
    l_injured   player_id_list;
    l_check_ids NUMBER;
  BEGIN
    BEGIN
      IF (p_team_id = gv_home_team_id OR p_team_id = gv_away_team_id) THEN
        IF (p_suspended_id IS NOT NULL) THEN
          SELECT ps.player_id
            INTO l_check_ids
            FROM player_stat ps
            JOIN people p
              ON ps.player_id = p.people_id
           WHERE ps.player_id = p_suspended_id
             AND (p.team_id = gv_home_team_id OR
                 p.team_id = gv_away_team_id);
        
          SELECT m.suspended
            INTO l_suspended
            FROM match m
           WHERE match_id = gv_match_id;
        
          IF (l_suspended IS NULL) THEN
            l_suspended := player_id_list();
          END IF;
          l_suspended.extend(1);
          l_suspended(l_suspended.count) := p_suspended_id;
        
          UPDATE match m
             SET m.suspended = l_suspended
           WHERE match_id = gv_match_id;
        
          UPDATE player_stat ps
             SET ps.suspension = 1
           WHERE ps.player_id = p_suspended_id;
        
        END IF;
      
        IF (p_injured_id IS NOT NULL) THEN
          SELECT ps.player_id
            INTO l_check_ids
            FROM player_stat ps
            JOIN people p
              ON ps.player_id = p.people_id
           WHERE ps.player_id = p_injured_id
             AND (p.team_id = gv_home_team_id OR
                 p.team_id = gv_away_team_id);
        
          SELECT m.injured
            INTO l_injured
            FROM match m
           WHERE match_id = gv_match_id;
        
          IF (l_injured IS NULL) THEN
            l_injured := player_id_list();
          END IF;
          l_injured.extend(1);
          l_injured(l_injured.count) := p_injured_id;
        
          UPDATE match m
             SET m.injured = l_injured
           WHERE match_id = gv_match_id;
        
          UPDATE player_stat ps
             SET ps.injury = 1
           WHERE ps.player_id = p_injured_id;
        END IF;
      
        COMMIT;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        raise_application_error(gc_my_exception_code, gc_wrong_data);
        ROLLBACK;
    END;
  END suspension_injury;

  PROCEDURE match_end IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    IF (gv_away_goals = gv_home_goals) THEN
      UPDATE championship ch
         SET ch.played_matches = ch.played_matches + 1,
             ch.drawn          = ch.drawn + 1,
             ch.points         = ch.points + 1
       WHERE ch.team_id = gv_home_team_id
          OR ch.team_id = gv_away_team_id;
    ELSIF (gv_home_goals > gv_away_goals) THEN
      UPDATE championship ch
         SET ch.played_matches = ch.played_matches + 1,
             ch.won            = ch.won + 1,
             ch.points         = ch.points + 3
       WHERE ch.team_id = gv_home_team_id;
      UPDATE championship ch
         SET ch.played_matches = ch.played_matches + 1,
             ch.lost           = ch.lost + 1
       WHERE ch.team_id = gv_away_team_id;
    ELSE
      UPDATE championship ch
         SET ch.played_matches = ch.played_matches + 1,
             ch.lost           = ch.lost + 1
       WHERE ch.team_id = gv_home_team_id;
      UPDATE championship ch
         SET ch.played_matches = ch.played_matches + 1,
             ch.won            = ch.won + 1,
             ch.points         = ch.points + 3
       WHERE ch.team_id = gv_away_team_id;
    END IF;
  
    UPDATE match m
       SET m.home_goals = gv_home_goals, m.away_goals = gv_away_goals
     WHERE m.match_id = gv_match_id;
  
    COMMIT;
  END match_end;
END pkg_add_new_match;
/
