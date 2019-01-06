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
  red_cars         NUMBER,
  suspension       NUMBER(1),
  injury           NUMBER(1),
  mod_user         VARCHAR2(300),
  mod_time         TIMESTAMP(6),
  dml_flag         VARCHAR2(1)     
) TABLESPACE users;

CREATE TABLE match_h(
  match_id         NUMBER          NOT NULL,
  home_team_id     NUMBER          NOT NULL,
  away_team_id     NUMBER          NOT NULL,
  home_goals       NUMBER          DEFAULT 0 NOT NULL,
  away_goals       NUMBER          DEFAULT 0 NOT NULL,
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
