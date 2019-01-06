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
