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
