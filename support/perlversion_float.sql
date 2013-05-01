begin;

drop function if exists perlversion_float(varchar);
create function perlversion_float(varchar) returns float
AS $$
    declare
        vparts varchar array [3];
        rf     float;
    begin
        select regexp_matches($1, E'\(\\d\+\)\\.\(\\d\+\)\\.\(\\d\+\)') into vparts;

        select cast(vparts[1] as float) into rf;
        select rf + (cast(lpad(vparts[2], 3, '0') as float)/1000) into rf;
        select rf + (cast(lpad(vparts[3], 3, '0') as float)/1000000) into rf;

        return rf;
    end;
$$ language plpgsql;

commit;
