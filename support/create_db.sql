drop table if exists reports; --         cascade;
drop table if exists config;  --         cascade;
drop table if exists result;  --         cascade;
drop table if exists smoke_config; --    cascade;

CREATE TABLE reports 
           ( id              serial not null PRIMARY KEY
           , sconfig_id      int REFERENCES smoke_config (id)

           , duration        int                      -- 35464
           , config_count    int                      -- 32
-- id
           , smoke_date      timestamp with time zone -- 2011-04-14 21:20:43Z
           , perl_id         varchar                  -- "5.14.0"
           , git_id          varchar                  -- "b4ffc3db31e268adb50c44bab9b628dc619f1e83"
           , git_description varchar                  -- 5.13.11-1423-ga4f23763
           , applied_patches varchar                  -- -
--node
           , hostname        varchar                  -- "smokebox"
           , architecture    varchar                  -- "ia64"
           , osname          varchar                  -- "HP-UX"
           , osversion       varchar                  -- "B.11.31/64"
           , cpu_count       varchar                  -- "1 [2 cores]"
           , cpu_description varchar                  -- "Itanium 2 9100/1710"
           , cc              varchar                  -- "cc"
           , ccversion       varchar                  -- "B3910B"
           , username        varchar                  -- "tux"
-- build
           , TEST_JOBS       varchar                -- NULL
           , LC_ALL          varchar                -- "en_US.utf8"
           , LANG            varchar                -- NULL
           , manifest_msgs   bytea                  -- "..."
           , compiler_msgs   bytea                  -- "..."
           , skipped_tests   varchar                -- "..."
           , harness_only    varchar                -- "1"
           , summary         varchar                -- "FAIL(F)"
           ) ;

CREATE TABLE config
           ( id        serial not null PRIMARY KEY
           , report_id int    not null REFERENCES reports (id)
--config
           , arguments varchar                -- "-Duse64bitall -DDEBUGGING"
           , parallel  varchar                -- "1"
           , debugging varchar                -- "1"
           ) ;

CREATE TABLE result
           ( id         serial  not null  PRIMARY KEY
           , config_id  int     not null  REFERENCES config (id)
-- result
           , io_env     varchar                -- "perlio"
           , output     varchar                -- "..."
           , summary    varchar                -- "F"
           , statistics varchar                -- "Files=1802, Tests=349808, .."
           ) ;

CREATE TABLE smoke_config
           ( id      serial  not null        primary key
           , config  varchar
           ) ;
