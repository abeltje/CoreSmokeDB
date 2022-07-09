begin;

drop function if exists git_describe_as_plevel(varchar);
create function git_describe_as_plevel(varchar) returns varchar
AS $$
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
        if array_length(vparts, 1) = 4 then
            -- Also set the RC-bit
            select plevel || '000' || lpad(vparts[4], 3, '0') into plevel;
        else
            if array_length(vparts, 1) < 4 then
                select plevel || '000000' into plevel;
            end if;
        end if;
        if array_length(vparts, 1) = 5 then -- must be an RC
            select plevel|| lpad(vparts[4], 3, '0')  || lpad(vparts[5], 3, '0') into plevel;
        end if;

        return plevel;
    end;
$$ language plpgsql;

commit;
