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
