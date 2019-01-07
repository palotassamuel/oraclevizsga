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
