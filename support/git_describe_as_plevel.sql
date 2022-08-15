begin;

CREATE OR REPLACE FUNCTION public.git_describe_as_plevel(character varying)
 RETURNS character varying
 LANGUAGE plpgsql
 IMMUTABLE
AS $function$
    declare
        vparts varchar array [5];
        plevel varchar;
        clean  varchar;
    begin
        select regexp_replace($1, E'^v', '') into clean;
        select regexp_replace(clean, E'-g\.\+$', '') into clean;

        select regexp_split_to_array(clean, E'[\.\-]') into vparts;

        select vparts[1] || '.' into plevel;
        select plevel || lpad(vparts[2], 3, '0') into plevel;
        select plevel || lpad(vparts[3], 3, '0') into plevel;
        if array_length(vparts, 1) = 3 then
            select array_append(vparts, '0') into vparts;
        end if;
        if regexp_matches(vparts[4], 'RC') = array['RC'] then
            select plevel || vparts[4] into plevel;
        else
            select plevel || 'zzz' into plevel;
        end if;
        select plevel || lpad(vparts[array_upper(vparts, 1)], 3, '0') into plevel;

        return plevel;
    end;
$function$ ;

drop index if exists report_plevel_idx;
create index report_plevel_idx
          on report (git_describe_as_plevel(git_describe))
             ;

update tsgateway_config
   set value = '3'
 where name = 'dbversion'
       ;

commit;
