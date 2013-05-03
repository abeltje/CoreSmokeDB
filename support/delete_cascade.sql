begin;

    alter table config
drop constraint config_report_id_fkey;
    alter table config
add foreign key (report_id)
     references report(id) on delete cascade;

    alter table result
drop constraint result_config_id_fkey;
    alter table result
add foreign key (config_id)
     references config(id) on delete cascade;

    alter table failures_for_env
drop constraint failures_for_env_failure_id_fkey;
    alter table failures_for_env
add foreign key (failure_id)
     references failure(id) on delete cascade;

    alter table failures_for_env
drop constraint failures_for_env_result_id_fkey;
    alter table failures_for_env
add foreign key (result_id)
     references result(id) on delete cascade;

commit;
