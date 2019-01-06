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
