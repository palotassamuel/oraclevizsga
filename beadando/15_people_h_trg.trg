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
