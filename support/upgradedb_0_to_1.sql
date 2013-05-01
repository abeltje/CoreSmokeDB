begin;
    create table tsgateway_config
               ( id serial not null primary key
               , name varchar not null unique
               , value varchar
               );
    insert into tsgateway_config
              ( name
              , value )
         values (
                'dbversion'
              , '1'
              );

    alter table report
         add column smoke_branch varchar default 'blead';

commit;
