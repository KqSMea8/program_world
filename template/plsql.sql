



--https://github.com/LucaCanali/Oracle_DBA_scripts

DECLARE
张三 CONSTANT varchar2(50) NOT NULL:= '张三丰';--定义用户中文名
v_name VARCHAR2(30) := 'jack';--定义用户名称
age CONSTANT NUMBER NOT NULL:= 26;--定义用户年龄
BEGIN
  IF age<18 THEN
    dbms_output.put_line('未成年');
   ELSIF  age>60 THEN
    dbms_output.put_line('老年');
   ELSE
    dbms_output.put_line('中青年');
    --Statements2
    --dbms_output.put_line(张三); --程序包.方法

   END IF;
  --dbms_output.put_line(age); --程序包.方法
  --INSERT INTO club_user VALUES(v_name,v_age);
  --EXCEPTION
  --WHEN OTHERS THEN
END;
DECLARE
 score NUMBER(4,2) := 0.05555555555;
BEGIN
   IF score > 100 OR score < 0 THEN
     dbms_output.put_line('��������');
     ELSIF score >= 90 THEN
       dbms_output.put_line('����');
     ELSIF score >=80 THEN
       dbms_output.put_line('����');
     ELSIF score >=70 THEN
       dbms_output.put_line('�е�');
     ELSIF score >=60 THEN
       dbms_output.put_line('����');
     ELSE
       dbms_output.put_line('������'||score);
     END IF;
END;
/*
You can embed the SELECT directly inside the FOR loop. That's easiest, but that also means
you cannot reuse the SELECT in another FOR loop, if you have that need.
*/

BEGIN
   FOR rec IN (SELECT * FROM employees)
   LOOP
      DBMS_OUTPUT.put_line (rec.last_name);
   END LOOP;
END;
/

/*
You can also declare the cursor explicitly and then reference that in the FOR loop. You can
then use that same cursor in another context, such as another FOR loop.
*/

DECLARE
   CURSOR emps_cur
   IS
      SELECT * FROM employees;
BEGIN
   FOR rec IN emps_cur
   LOOP
      DBMS_OUTPUT.put_line (rec.last_name);
   END LOOP;

   FOR rec IN emps_cur
   LOOP
      DBMS_OUTPUT.put_line (rec.salary);
   END LOOP;
END;
/

--
--  dump_optimizer_trace.sql
--
--  DESCRIPTION
--    dump Optimizer trace for a given sql_id & print out the trace file name
--
--  Created by Greg Rahn on 2011-08-19.
--  Copyright (c) 2011 Greg Rahn. All rights reserved.
--

set verify off linesize 132

begin
    dbms_sqldiag.dump_trace(
        p_sql_id=>'&&sql_id',
        p_child_number=>&&child_number,
        p_component=>'Compiler',
        p_file_id=>'&&trace_file_identifier');
end;
/

select value ||'/'||(select instance_name from v$instance) ||'_ora_'||
(select spid||case when traceid is not null then '_'||traceid else null end
from v$process
where addr = (select paddr from v$session where sid = (select sid from v$mystat where rownum = 1))
) || '.trc' tracefile
from v$parameter where name = 'user_dump_dest'
/

undef sql_id
undef child_number
undef trace_file_identifier



@@stats_config

@@logsetup unlock_stats

prompt
prompt ==============================
prompt == UNLOCK TABLE STATS
prompt ==============================
prompt


set echo on

declare
	type v_tabtyp_i is table of varchar2(100) index by pls_integer;
   v_tables v_tabtyp_i;
begin

@@table_list

	for t in v_tables.first .. v_tables.last
	loop
		dbms_output.put_line('##############################################################################');
		dbms_output.put_line('### Table: ' || v_tables(t));
		dbms_stats.unlock_table_stats('&&v_owner',v_tables(t));
	end loop;

end;
/

spool off

set echo off


/*
You can add a parameter list to a cursor, just like you can a function.
You can only have IN parameters. Well, that makes sense, right?
*/

DECLARE
   CURSOR emps_cur (department_id_in IN INTEGER)
   IS
      SELECT * FROM employees
       WHERE department_id = department_id_in;
BEGIN
   FOR rec IN emps_cur (1700)
   LOOP
      DBMS_OUTPUT.put_line (rec.last_name);
   END LOOP;

   FOR rec IN emps_cur (50)
   LOOP
      DBMS_OUTPUT.put_line (rec.salary);
   END LOOP;
END;
/

/*
You can declare a cursor at the package level and then reference that cursor in multiple
program units. Remember, though, that if you explicitly open a packaged cursor (as in
OPEN emus_pkg.emps_cur), it will stay open until you close it explicitly (or disconnect).
*/

CREATE OR REPLACE PACKAGE emps_pkg
IS
   CURSOR emps_cur
   IS
      SELECT * FROM employees;
END;
/

BEGIN
   FOR rec IN emps_pkg.emps_cur
   LOOP
      DBMS_OUTPUT.put_line (rec.last_name);
   END LOOP;
END;
/

/*
You can even hide the SELECT inside the package body in case you don't want developers to know the details of the query.
*/

CREATE OR REPLACE PACKAGE emps_pkg
IS
   CURSOR emps_cur
      RETURN employees%ROWTYPE;
END;
/

CREATE OR REPLACE PACKAGE BODY emps_pkg
IS
   CURSOR emps_cur RETURN employees%ROWTYPE
   IS
      SELECT * FROM employees;
END;
/

BEGIN
   FOR rec IN emps_pkg.emps_cur
   LOOP
      DBMS_OUTPUT.put_line (rec.last_name);
   END LOOP;
END;
/

FORALL
BULK COLLECT
Function result cache
UDF pragma (12.1)
Compiler optimization

-- email validation

declare
  l_validation boolean;
begin
  debug_pkg.debug_on;
  l_validation := validation_util_pkg.is_valid_email ('someone@somewhere.net');
  debug_pkg.print('validation result (should be true)', l_validation);
  l_validation := validation_util_pkg.is_valid_email ('someone');
  debug_pkg.print('validation result (should be false)', l_validation);
  l_validation := validation_util_pkg.is_valid_email ('someone@');
  debug_pkg.print('validation result (should be false)', l_validation);
  l_validation := validation_util_pkg.is_valid_email ('someone@sdfsdf');
  debug_pkg.print('validation result (should be false)', l_validation);
  l_validation := validation_util_pkg.is_valid_email ('someone@sfdsf.safdsfsf');
  debug_pkg.print('validation result (should be false)', l_validation);
  l_validation := validation_util_pkg.is_valid_email ('someone@dsfsfd.sdf;sdfsfs');
  debug_pkg.print('validation result (should be false)', l_validation);
end;



-- email list validation


declare
  l_validation boolean;
begin
  debug_pkg.debug_on;
  l_validation := validation_util_pkg.is_valid_email_list ('someone@somewhere.net');
  debug_pkg.print('validation result (should be true)', l_validation);
  l_validation := validation_util_pkg.is_valid_email_list ('user1@somewhere.net;user2@somewhere.net');
  debug_pkg.print('validation result (should be true)', l_validation);
  l_validation := validation_util_pkg.is_valid_email_list ('sdfsff dsfsfsdfs ; sdfsf @');
  debug_pkg.print('validation result (should be false)', l_validation);
  l_validation := validation_util_pkg.is_valid_email_list ('user1@somewhere.net;user2@somewhere.net;sdfsff');
  debug_pkg.print('validation result (should be false)', l_validation);
end;

-- see http://technology.amis.nl/2012/04/11/generating-a-pdf-document-with-some-plsql-as_pdf_mini-as_pdf3/

begin
  as_pdf3.init;
  as_pdf3.write( 'Minimal usage' );
  as_pdf3.save_pdf;
end;
--
begin
  as_pdf3.init;
  as_pdf3.write( 'Some text with a newline-character included at this "
" place.' );
  as_pdf3.write( 'Normally text written with as_pdf3.write() is appended after the previous text. But the text wraps automaticly to a new line.' );
  as_pdf3.write( 'But you can place your text at any place', -1, 700 );
  as_pdf3.write( 'you want', 100, 650 );
  as_pdf3.write( 'You can even align it, left, right, or centered', p_y => 600, p_alignment => 'right' );
  as_pdf3.save_pdf;
end;
--
begin
  as_pdf3.init;
  as_pdf3.write( 'The 14 standard PDF-fonts and the WINDOWS-1252 encoding.' );
  as_pdf3.set_font( 'helvetica' );
  as_pdf3.write( 'helvetica, normal: ' || 'The quick brown fox jumps over the lazy dog. 1234567890', -1, 700 );
  as_pdf3.set_font( 'helvetica', 'I' );
  as_pdf3.write( 'helvetica, italic: ' || 'The quick brown fox jumps over the lazy dog. 1234567890', -1, -1 );
  as_pdf3.set_font( 'helvetica', 'b' );
  as_pdf3.write( 'helvetica, bold: ' || 'The quick brown fox jumps over the lazy dog. 1234567890', -1, -1 );
  as_pdf3.set_font( 'helvetica', 'BI' );
  as_pdf3.write( 'helvetica, bold italic: ' || 'The quick brown fox jumps over the lazy dog. 1234567890', -1, -1 );
  as_pdf3.set_font( 'times' );
  as_pdf3.write( 'times, normal: ' || 'The quick brown fox jumps over the lazy dog. 1234567890', -1, 625 );
  as_pdf3.set_font( 'times', 'I' );
  as_pdf3.write( 'times, italic: ' || 'The quick brown fox jumps over the lazy dog. 1234567890', -1, -1 );
  as_pdf3.set_font( 'times', 'b' );
  as_pdf3.write( 'times, bold: ' || 'The quick brown fox jumps over the lazy dog. 1234567890', -1, -1 );
  as_pdf3.set_font( 'times', 'BI' );
  as_pdf3.write( 'times, bold italic: ' || 'The quick brown fox jumps over the lazy dog. 1234567890', -1, -1 );
  as_pdf3.set_font( 'courier' );
  as_pdf3.write( 'courier, normal: ' || 'The quick brown fox jumps over the lazy dog. 1234567890', -1, 550 );
  as_pdf3.set_font( 'courier', 'I' );
  as_pdf3.write( 'courier, italic: ' || 'The quick brown fox jumps over the lazy dog. 1234567890', -1, -1 );
  as_pdf3.set_font( 'courier', 'b' );
  as_pdf3.write( 'courier, bold: ' || 'The quick brown fox jumps over the lazy dog. 1234567890', -1, -1 );
  as_pdf3.set_font( 'courier', 'BI' );
  as_pdf3.write( 'courier, bold italic: ' || 'The quick brown fox jumps over the lazy dog. 1234567890', -1, -1 );
--
  as_pdf3.set_font( 'courier' );
  as_pdf3.write( 'symbol:', -1, 475 );
  as_pdf3.set_font( 'symbol' );
  as_pdf3.write( 'The quick brown fox jumps over the lazy dog. 1234567890', -1, -1 );
  as_pdf3.set_font( 'courier' );
  as_pdf3.write( 'zapfdingbats:', -1, -1 );
  as_pdf3.set_font( 'zapfdingbats' );
  as_pdf3.write( 'The quick brown fox jumps over the lazy dog. 1234567890', -1, -1 );
--
  as_pdf3.set_font( 'times', 'N', 20 );
  as_pdf3.write( 'times, normal with fontsize 20pt', -1, 400 );
  as_pdf3.set_font( 'times', 'N', 6 );
  as_pdf3.write( 'times, normal with fontsize 5pt', -1, -1 );
  as_pdf3.save_pdf;
end;
--
declare
  x pls_integer;
begin
  as_pdf3.init;
  as_pdf3.write( 'But others fonts and encodings are possible using TrueType fontfiles.' );
  x := as_pdf3.load_ttf_font( 'MY_FONTS', 'refsan.ttf', 'CID', p_compress => false );
  as_pdf3.set_font( x, 12  );
  as_pdf3.write( 'The Windows MSReference SansSerif font contains a lot of encodings, for instance', -1, 700 );
  as_pdf3.set_font( x, 15  );
  as_pdf3.write( 'Albanian: Kush mund të lexoni këtë diçka si kjo', -1, -1 );
  as_pdf3.write( 'Croatic: Tko može citati to nešto poput ovoga', -1, -1 );
  as_pdf3.write( 'Russian: ??? ????? ????????? ??? ???-?? ????? ?????', -1, -1);
  as_pdf3.write( 'Greek: ????? µp??e? ?a d?aß?se? a?t? t? ??t? sa? a?t?', -1, -1 );
--
  as_pdf3.set_font( 'helvetica', 12  );
  as_pdf3.write( 'Or by using a  TrueType collection file (ttc).', -1, 600 );
  as_pdf3.load_ttc_fonts( 'MY_FONTS',  'cambria.ttc', p_embed => true, p_compress => false );
  as_pdf3.set_font( 'cambria', 15 );   -- font family
  as_pdf3.write( 'Anton, testing 1,2,3 with Cambria', -1, -1 );
  as_pdf3.set_font( 'CambriaMT', 15 );  -- fontname
  as_pdf3.write( 'Anton, testing 1,2,3 with CambriaMath', -1, -1 );
  as_pdf3.save_pdf;
end;
--
begin
  as_pdf3.init;
  for i in 1 .. 10
  loop
    as_pdf3.horizontal_line( 30, 700 - i * 15, 100, i );
  end loop;
  for i in 1 .. 10
  loop
    as_pdf3.vertical_line( 150 + i * 15, 700, 100, i );
  end loop;
  for i in 0 .. 255
  loop
    as_pdf3.horizontal_line( 330, 700 - i, 100, 2, p_line_color =>  to_char( i, 'fm0x' ) || to_char( i, 'fm0x' ) || to_char( i, 'fm0x' ) );
  end loop;
  as_pdf3.save_pdf;
end;
--
declare
  t_logo varchar2(32767) :=
'/9j/4AAQSkZJRgABAQEAYABgAAD/2wBDAAgGBgcGBQgHBwcJCQgKDBQNDAsLDBkS' ||
'Ew8UHRofHh0aHBwgJC4nICIsIxwcKDcpLDAxNDQ0Hyc5PTgyPC4zNDL/2wBDAQkJ' ||
'CQwLDBgNDRgyIRwhMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIy' ||
'MjIyMjIyMjIyMjIyMjL/wAARCABqAJYDASIAAhEBAxEB/8QAHwAAAQUBAQEBAQEA' ||
'AAAAAAAAAAECAwQFBgcICQoL/8QAtRAAAgEDAwIEAwUFBAQAAAF9AQIDAAQRBRIh' ||
'MUEGE1FhByJxFDKBkaEII0KxwRVS0fAkM2JyggkKFhcYGRolJicoKSo0NTY3ODk6' ||
'Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqDhIWGh4iJipKTlJWWl5iZ' ||
'mqKjpKWmp6ipqrKztLW2t7i5usLDxMXGx8jJytLT1NXW19jZ2uHi4+Tl5ufo6erx' ||
'8vP09fb3+Pn6/8QAHwEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoL/8QAtREA' ||
'AgECBAQDBAcFBAQAAQJ3AAECAxEEBSExBhJBUQdhcRMiMoEIFEKRobHBCSMzUvAV' ||
'YnLRChYkNOEl8RcYGRomJygpKjU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hp' ||
'anN0dXZ3eHl6goOEhYaHiImKkpOUlZaXmJmaoqOkpaanqKmqsrO0tba3uLm6wsPE' ||
'xcbHyMnK0tPU1dbX2Nna4uPk5ebn6Onq8vP09fb3+Pn6/9oADAMBAAIRAxEAPwD3' ||
'+iiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAoorifiX4pk' ||
'8PaCILR9t9eExxsOqL/E315AHuaUmkrs1oUZVqipw3ZU8X/FCz0KeSw02Jb2+Thy' ||
'WxHGfQkdT7D8686ufih4suGJW/jgXssUC8fnk1ydvbz3lzHb28bzTyttRF5LMa7H' ||
'Uvh+3hvRI9T1+7kUPIsf2ezUMykgnlmIHbtXI5znqtj66ng8DhFGFRJyffVv5Fnw' ||
'r8QfEEvinTodR1N5rSaYRyIyIAd3A5A9SK7X4qeINV0Gz019LvGtmlkcOVVTkADH' ||
'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';
begin
  as_pdf3.init;
  as_pdf3.put_image( to_blob( utl_encode.base64_decode( utl_raw.cast_to_raw( t_logo ) ) )
                   , 0
                   , as_pdf3.get( as_pdf3.C_GET_PAGE_HEIGHT ) - 260
                   , as_pdf3.get( as_pdf3.C_GET_PAGE_WIDTH )
                   );
  as_pdf3.write( 'jpg, gif and png images are supported.' );
  as_pdf3.write( 'And because PDF 1.3 (thats the format I use) doesn''t support alpha channels, neither does AS_PDF.', -1, -1 );
  as_pdf3.save_pdf;
end;
--
declare
  t_rc sys_refcursor;
  t_query varchar2(1000);
begin
  as_pdf3.init;
  as_pdf3.load_ttf_font( 'MY_FONTS', 'COLONNA.TTF', 'CID' );
  as_pdf3.set_page_proc( q'~
    begin
      as_pdf3.set_font( 'helvetica', 8 );
      as_pdf3.put_txt( 10, 15, 'Page #PAGE_NR# of "PAGE_COUNT#' );
      as_pdf3.set_font( 'helvetica', 12 );
      as_pdf3.put_txt( 350, 15, 'This is a footer text' );
      as_pdf3.set_font( 'helvetica', 'B', 15 );
      as_pdf3.put_txt( 200, 780, 'This is a header text' );
      as_pdf3.put_image( 'MY_DIR', 'amis.jpg', 500, 15 );
   end;~' );
  as_pdf3.set_page_proc( q'~
    begin
      as_pdf3.set_font( 'Colonna MT', 'N', 50 );
      as_pdf3.put_txt( 150, 200, 'Watermark Watermark Watermark', 60 );
   end;~' );
  t_query := 'select rownum, sysdate + level, ''example'' || level from dual connect by level <= 50';
  as_pdf3.query2table( t_query );
  open t_rc for t_query;
  as_pdf3.refcursor2table( t_rc );
  as_pdf3.save_pdf;
end;


create table tq84_for_all (
  col_1 number       primary key,
  col_2 varchar2(10)
);

create or replace package tq84_for_all_pkg as

  procedure run_without;
  procedure run_with;

end tq84_for_all_pkg;
/

create or replace package body tq84_for_all_pkg as

  procedure run_without is -- {
    t0 number;
    t1 number;
  begin

    t0 := dbms_utility.get_time;

    for i in 1 .. 100000 loop

      insert into tq84_for_all values(i, 'foo ' || i);

    end loop;

    t1 := dbms_utility.get_time;

    dbms_output.put_line('Without: ' || ((t1-t0) / 100) || ' seconds');

  end run_without; -- }

  procedure run_with is -- {
     type vals_t is table of tq84_for_all%rowtype index by pls_integer;
     vals vals_t;

    t0 number;
    t1 number;

  begin

    t0 := dbms_utility.get_time;

    for i in 1 .. 100000 loop

       vals(i).col_1 :=  i + 100000;
       vals(i).col_2 := 'foo ' || i;

    end loop;

    forall i in 1 .. 10000 insert into tq84_for_all values vals(i); -- (vals(i).col_1, vals(i).col_2);

    t1 := dbms_utility.get_time;
    dbms_output.put_line('With   : ' || ((t1-t0) / 100) || ' seconds');

  end run_with; -- }

end tq84_for_all_pkg;
/
show errors;

exec tq84_for_all_pkg.run_without
exec tq84_for_all_pkg.run_with

drop table tq84_for_all purge;
drop package tq84_for_all_pkg;
declare
  ts timestamp;
begin
  ts := systimestamp;
  as_pdf3.init;
  as_pdf3.set_font( as_pdf3.load_ttf_font( as_pdf3.file2blob( 'MY_FONTS', 'arial.ttf' ), 'CID' ), 15 );
  as_pdf3.write( 'Anton, testing 1,2,3!' );
  as_pdf3.save_pdf;
  dbms_output.put_line( systimestamp - ts );
end;


- Tables {

create table tq84_a (
       id    number primary key,
       txt   varchar2(10)
);

create table tq84_b (
       id    number primary key,
       id_a  references tq84_a,
       txt   varchar2(10)
);

create table tq84_c (
       id    number primary key,
       id_b  references tq84_b,
       txt   varchar2(10)
);

-- }

-- Inserts {

insert into tq84_a values (   1, 'one');

       insert into tq84_b values (  11,  1, 'A');

              insert into tq84_c values (111, 11, '(');
              insert into tq84_c values (112, 11, ')');

       insert into tq84_b values (  12,  1, 'B');

              insert into tq84_c values (121, 12, '!');
              insert into tq84_c values (122, 12, '?');
              insert into tq84_c values (123, 12, '.');
              insert into tq84_c values (124, 12, ',');

       insert into tq84_b values (  13,  1, 'C');

insert into tq84_a values (   2, 'two');


insert into tq84_a values (   3, 'two');

       insert into tq84_b values (  31,  3, 'Y');
       insert into tq84_b values (  32,  3, 'Z');

-- }

-- Types {

create type tq84_c_o as object (
       id   number,
       txt  varchar2(10)
);
/

create type tq84_c_t as table of tq84_c_o;
/

create type tq84_b_o as object (
       id   number,
       txt  varchar2(10),
       c    tq84_c_t
);
/

create type tq84_b_t as table of tq84_b_o;
/

create type tq84_a_o as object (
       id   number,
       txt  varchar2(10),
       b    tq84_b_t
);
/

create type tq84_a_t as table of tq84_a_o;
/

-- }

declare

  complete_tree tq84_a_t;

begin

  select tq84_a_o (
    a.id,
    a.txt,
    -----
      cast ( collect (tq84_b_o ( b.id, b.txt, null ) ) as tq84_b_t )
  ) bulk collect into complete_tree
  from
        tq84_a a                   join
        tq84_b b on a.id = b.id_a
  group by
        a.id,
        a.txt;

  dbms_output.new_line;
  for a in 1 .. complete_tree.count loop

      dbms_output.put_line('Id: ' || complete_tree(a).id || ', txt: ' || complete_tree(a).txt);

      for b in 1 .. complete_tree(a).b.count loop

          dbms_output.put_line('   Id: ' || complete_tree(a).b(b).id || ', txt: ' || complete_tree(a).b(b).txt);

          -- ? if complete_tree(a).b(b).c is not null then
          -- ?    for c in 1 .. complete_tree(a).b(b).c.count loop
          -- ?
          -- ?        dbms_output.put_line('      Id: ' || complete_tree(a).b(b).c(c).id || ', txt: ' || complete_tree(a).b(b).c(c).txt);
          -- ?
          -- ?    end loop;
          -- ?    dbms_output.new_line;
          -- ? end if;

      end loop;
      dbms_output.new_line;

  end loop;


--
--  select tq84_outer (o.i,
--                     o.j,
--                     cast(collect(  tq84_inner(i.n, i.t)  order by i.n) as tq84_inner_t)
--                    )
--    bulk collect into t
--    from tq84_o    o    join
--         tq84_i    i    on o.i = i.i
--   group by o.i, o.j;
--
--   --
--
---- does not work  select tq84_outer__ (o.i, -- {
---- does not work                     o.j,
---- does not work                     cast(collect(  tq84_inner__(i.n, i.t)  order by i.n) as tq84_inner_t__)
---- does not work                    )
---- does not work    bulk collect into t
---- does not work    from tq84_o    o    join
---- does not work         tq84_i    i    on o.i = i.i
---- does not work   group by o.i, o.j; -- }
--
--   --
--
--   dbms_output.put_line('Cnt: ' || t.count);
--
--   dbms_output.put_line('Cnt (2): ' || t(2).inner_.count);
--
--   dbms_output.put_line(t(3).inner_(2).t);
--
--   ----------------------------------------------------
--
--   for r in (
--       select i, j from table(t)
--   ) loop -- {
--
--     dbms_output.put_line('i: ' || r.i || ', j: ' || r.j);
--
--   end loop; -- }
--
--   ----------------------------------------------------
--
--   dbms_output.new_line;
--
--   ----------------------------------------------------
--
--   for r in (
--       select
--         outer_.i,
--         outer_.j,
--         inner_.n,
--         inner_.t
--       from
--         table(t)             outer_,
--         table(outer_.inner_) inner_
--   ) loop -- {
--
--     dbms_output.put_line('i: ' || r.i || ', j: ' || r.j || ', n: ' || r.n || ', t: ' || r.t);
--
--   end loop; -- }
--
--   ----------------------------------------------------
--
end;
/

drop type  tq84_a_t force;
drop type  tq84_a_o force;
drop type  tq84_b_t force;
drop type  tq84_b_o force;
drop type  tq84_c_t force;
drop type  tq84_c_o force;

drop table tq84_c purge;
drop table tq84_b purge;
drop table tq84_a purge;

-- explain.sql
-- prints execution plan for a give sql_id
-- detailed execution plan, taken from memory/library cache
-- Usage @explain <sql_id>
-- by Luca

--select * from table(dbms_xplan.display_cursor('&1'));
--select * from table(dbms_xplan.display_cursor('&1',0,'ALLSTATS LAST'));
--select * from table(dbms_xplan.display_cursor('&1',0,'TYPICAL OUTLINE'));
--for explain plan use:
--select * from table(dbms_xplan.display('PLAN_TABLE',null,'ADVANCED OUTLINE ALLSTATS LAST +PEEKED_BINDS',null));
select * from table(dbms_xplan.display_cursor('&1',null,'ADVANCED OUTLINE ALLSTATS LAST +PEEKED_BINDS'));


connect scott/tiger

SELECT deptno, job, APPROX_SUM(sal) sum_sal,
       APPROX_SUM(sal,'MAX_ERROR') sum_sal_err
FROM   emp
GROUP BY deptno, job
HAVING APPROX_RANK(partition by deptno ORDER BY APPROX_SUM(sal) desc) <= 2;


--    oracle数据库在执行sql语句时，oracle的优化器会根据一定的规则确定sql语句的执行路径，以确保sql语句能以最优性能执行.在oracle数据库系统中为了执行sql语句，oracle可能需要实现多个步骤，这些步骤中的每一步可能是从数据库中物理检索数据行，或者用某种方法准备数据行，让编写sql语句的用户使用，oracle用来执行语句的这些步骤的组合被称为执行计划。
--  当执行一个sql语句时oracle经过了4个步骤:
--  ①.解析sql语句:主要在共享池中查询相同的sql语句，检查安全性和sql语法与语义。
--  ②.创建执行计划及执行:包括创建sql语句的执行计划及对表数据的实际获取。
--  ③.显示结果集:对字段数据执行所有必要的排序，转换和重新格式化。
--  ④.转换字段数据:对已通过内置函数进行转换的字段进行重新格式化处理和转换.
--
--1-2.查看执行计划
--    查看sql语句的执行计划，比如一些第三方工具  需要先执行utlxplan.sql脚本创建explain_plan表。

SQL> conn system/123456 as sysdba
-- 如果下面语句没有执行成功，可以找到这个文件，单独执行这个文件里的建表语句
SQL> @/rdbms/admin/utlxplan.sql
SQL> grant all on sys.plan_table to public;
  在创建表后，在SQL*Plus中就可以使用set autotrace语句来显示执行计划及统计信息。常用的语句与作用如下：
set autotrace on explain:执行sql，且仅显示执行计划
set autotrace on statistics:执行sql 且仅显示执行统计信息
set autotrace on :执行sql，且显示执行计划与统计信息，无执行结果
set autotrace traceonly:仅显示执行计划与统计信息，无执行结果
set autotrace off:关闭跟踪显示计划与统计
--  比如要执行SQL且显示执行计划，可以使用如下的语句：
SQL> set autotrace on explain
SQL> col ename format a20;
SQL> select empno，ename from emp where empno=7369;
--上面不一定可以执行成功，使用这个：explain plan for sql语句
SQL> explain plan for
  2  select * from cfreportdata where outitemcode='CR04_00160' and quarter='1' and month='2015';
Explained

SQL> select * from table(dbms_xplan.display);
PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------
Plan hash value: 3825643284
--------------------------------------------------------------------------------
| Id  | Operation                   | Name            | Rows  | Bytes | Cost (%C
--------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |                 |     1 |   115 |     3
|   1 |  TABLE ACCESS BY INDEX ROWID| CFREPORTDATA    |     1 |   115 |     3
|*  2 |   INDEX RANGE SCAN          | PK_CFREPORTDATA |     1 |       |     2
--------------------------------------------------------------------------------
Predicate Information (identified by operation id):
---------------------------------------------------
   2 - access("OUTITEMCODE"='CR04_00160' AND "MONTH"='2015' AND "QUARTER"='1')
       filter("MONTH"='2015' AND "QUARTER"='1')
15 rows selected

--    1.全表扫描(full table scans):这种方式会读取表中的每一条记录，顺序地读取每一个数据块直到结尾标志，对于一个大的数据表来说，使用全表扫描会降低性能，但有些时候，比如查询的结果占全表的数据量的比例比较高时，全表扫描相对于索引选择又是一种较好的办法。
--    2.通过ROWID值获取(table access by rowid)：行的rowid指出了该行所在的数据文件，数据块及行在该块中的位置，所以通过rowid来存取数据可以快速定位到目标数据上，是oracle存取单行数据的最快方法。
--    3.索引扫描(index scan)：先通过索引找到对象的rowid值，然后通过rowid值直接从表中找到具体的数据，能大大提高查找的效率。

--2.连接查询的表顺序
--    默认情况下，优化器会使用all_rows优化方式，也就是基于成本的优化器CBO生成执行计划，CBO方式会根据统计信息来产生执行计划.
--    统计信息给出表的大小，多少行，每行的长度等信息，这些统计信息起初在库内是没有的，是做analyee后才发现的，很多时候过期统计信息会令优化器做出一个错误的执行计划，因此应及时更新这些信息。
--    在CBO模式下，当对多个表进行连接查询时，oracle分析器会按照从右到左的顺序处理from子句中的表名。例如：

select a.empno，a.ename，c.deptno，c.dname，a.log_action from emp_log a,emp b,dept c


--    在执行时，oracle会先查询dept表，根据dept表查询的行作为数据源串行连接emp表继续执行，因此dept表又称为基础表或驱动表。由于连接的顺序对于查询的效率有非常大的影响。因此在处理多表连接时，必须选择记录条数较少的表作为基础表，oracle会使用排序与合并的方式进行连接。比如先扫描dept表，然后对dept表进行排序，再扫描emp表，最后将所有检索出来的记录与第一个表中的记录进行合并。
--    如果有3个以上的表连接查询，就需要选择交叉表作为基础表。交叉表是指那个被其他表所引用的表，由于emp_log是dept与emp表中的交叉表，既包含dept的内容又包含emp的内容。
select a.empno，a.ename，c.deptno，c.dname，a.log_action from emp b,dept c,emp_log a;

--3.指定where条件顺序
--    在查询表时，where子句中条件的顺序往往影响了执行的性能。默认情况下，oracle采用自下而上的顺序解析where子句，因此在处理多表查询时，表之间的连接必须写在其他的where条件之前，但是过滤数据记录的条件则必须写在where子句的尾部，以便在过滤了数据之后再进行连接处理，这样可以提升sql语句的性能。
--
SELECT a.empno, a.ename, c.deptno, c.dname, a.log_action, b.sal
  FROM emp b, dept c, emp_log a
 WHERE a.deptno = b.deptno AND a.empno=b.empno AND c.deptno IN (20, 30)
--    从SQL执行计划中可以看到const成本值为10。如果使用如下不好的查询方式，const成本值为32
 SELECT a.empno, a.ename, c.deptno, c.dname, a.log_action, a.mgr
  FROM emp b, dept c, emp_log a
 WHERE c.deptno IN (20, 30) AND  a.deptno = b.deptno


--4.避免使用*符号
 SELECT * FROM emp
    Oracle在遇到*符号时，会去查询数据字典表中获取所有的列信息，然后依次转换成所有的列名，这将耗费较长的执行时间，因此尽量避免使用*符号获取所有的列信息


使用decode函数

    比如统计emp表中部门编号为20和部门编号为30的员工的人数和薪资汇总，如果不使用decode那么就必须用两条sql语句


select count(*)，SUM(sal) from emp where deptno=20;

union

select count(*)，SUM(sal) from emp where deptno=30;


  通过Union将两条SQL语句进行合并，实际上通过执行计划可以看到，SQL优化器对emp进行了两次全表扫描
通过decode语句，可以再一个sql查询中获取到相同的结果，并且将两行结果显示为单行。
SELECT COUNT (DECODE (deptno, 20, 'X', NULL)) dept20_count,
       COUNT (DECODE (deptno, 30, 'X', NULL)) dept30_count,
       SUM (DECODE (deptno, 20, sal, NULL)) dept20_sal,
       SUM (DECODE (deptno, 30, sal, NULL)) dept30_sal
  FROM emp;
    通过灵活的运用decode函数，可以得到很多意想不到的结果，比如在group by 或order by子句中使用decode函数，或者在decode块中嵌套另一个decode块。
关于decode函数详解：http://blog.csdn.net/ochangwen/article/details/52733273

--6.使用where而非having
--    where子句和having子句都可以过滤数据，但是where子句不能使用聚集函数，如count max min avg sum等函数。因此通常将Having子句与Group By子句一起使用
--    注意：当利用Group By进行分组时，可以没有Having子句。但Having出现时，一定会有Group By
--  需要了解的是，WHERE语句是在GROUP BY语句之前筛选出记录，而HAVING是在各种记录都筛选之后再进行过滤。也就是说HAVING子句是在从数据库中提取数据之后进行筛选的，因此在编写SQL语句时，尽量在筛选之前将数据使用WHERE子句进行过滤，因此执行的顺序应该总是这样。
--  ①.使用WHERE子句查询符合条件的数据
--  ②.使用GROUP BY子句对数据进行分组。
--  ③.在GROUP BY分组的基础上运行聚合函数计算每一组的值
--  ④.用HAVING子句去掉不符合条件的组。

--例子：查询部门20和30的员工薪资总数大于1000的员工信息

select empno,deptno，sum(sal)
from emp group by empno，deptno
having sum(sal) > 1000 and deptno in (20，30);
    在having子句中，过滤出部门编号为20或30的记录，实际上这将导致查询取出所有部门的员工记录，在进行分组计算，最后才根据分组的结果过滤出部门 20和30的记录。这非常低效，好的算法是先使用where子句取出部门编号为20和30的记录，再进行过滤。修改如下：
select empno，deptno，sum(sal)
from emp where deptno in （20,30）
group by empno，deptno having sum (sal) > 1000;
7.使用UNION而非OR
  如果要进行OR运算的两个列都是索引列，可以考虑使用union来提升性能。
  例子：比如emp表中，empno和ename都创建了索引列，当需要在empno和ename之间进行OR操作查询时，可以考虑将这两个查询更改为union来提升性能。

select empno，ename，job，sal from emp where empno > 7500 OR ename LIKE 'S%';
使用UNION
select empno，ename，job，sal from emp where empno > 7500
UNION
select empno，ename，job，sal from emp where ename LIKE 'S%';
--    但这种方式要确保两个列都是索引列。否则还不如OR语句。
--    如果坚持使用OR语句，①.需要记住尽量将返回记录最少的索引列写在最前面，这样能获得较好的性能，例如empno > 7500 返回的记录要少于对ename的查询，因此在OR语句中将其放到前面能获得较好的性能。②.另外一个建议是在要对单个字段值进行OR计算的时候，可以考虑使用IN来代替
select empno，ename，job，sal from emp where deptno=20 OR deptno=30;
--上面的SQL如果修改为使用In，性能更好

--8.使用exists而非IN
--    比如查询位于芝加哥的所有员工列表可以考虑使用IN

SELECT *
  FROM emp
 WHERE deptno IN (SELECT deptno
                    FROM dept
                   WHERE loc = 'CHICAGO');
替换成exists可以获取更好的查询性能
SELECT a.*
  FROM emp a
 WHERE NOT EXISTS (SELECT 1
                     FROM dept b
                    WHERE a.deptno = b.deptno AND loc = 'CHICAGO');
--    同样的替换页发生在not in 和not exists之间，not in 子句将执行一个内部的排序和合并，实际上它对子查询中的表执行了一次全表扫描，因此效率低，在需要使用NOT IN的场合，英爱总是考虑把它更改成外连接或NOT EXISTS
SELECT *
  FROM emp
 WHERE deptno NOT IN (SELECT deptno
                    FROM dept
                   WHERE loc = 'CHICAGO');
--为了提高较好的性能，可以使用连接查询，这是最有效率的的一种办法
SELECT a.*
  FROM emp a, dept b
 WHERE a.deptno = b.deptno AND b.loc <> 'CHICAGO';
--也可以考虑使用NOT EXIST
select a.* from emp a
          where NOT EXISTS (
			select 1 from dept b where a.deptno =b.deptno and loc='CHICAGO');
--9.避免低效的PL/SQL流程控制语句
--    PLSQL在处理逻辑表达式值的时候，使用的是短路径的计算方式。
DECLARE
   v_sal   NUMBER        := &sal;                 --使用绑定变量输入薪资值
   v_job   VARCHAR2 (20) := &job;                 --使用绑定变量输入job值
BEGIN
   IF (v_sal > 5000) OR (v_job = '销售')          --判断执行条件
   THEN
      DBMS_OUTPUT.put_line ('符合匹配的OR条件');
   END IF;
END;
--    首先对第一个条件进行判断，如果v_sal大于5000，就不会再对v_job条件进行判断，灵活的运用这种短路计算方式可以提升性能。应该总是将开销较低的判断语句放在前面，这样当前面的判断失败时，就不会再执行后面的具有较高开销的语句，能提升PL/SQL应用程序的性能.
--    举个例子，对于and逻辑运算符来说，只有左右两边的运算为真，结果才为真。如果前面的结果第一个运算时false值，就不会进行第二个运算、
DECLARE
   v_sal   NUMBER        := &sal;                 --使用绑定变量输入薪资值
   v_job   VARCHAR2 (20) := &job;                 --使用绑定变量输入job值
BEGIN
   IF (Check_Sal(v_sal) > 5000) AND (v_job = '销售')          --判断执行条件
   THEN
      DBMS_OUTPUT.put_line ('符合匹配的AND条件');
   END IF;
END;
    这段代码有一个性能隐患，check_sal涉及一些业务逻辑的检查，如果让check_sal函数的调用放在前面，这个函数总是被调用，因此处于性能方面的考虑，应该总是将v_job的判断放到and语句的前面.
DECLARE
   v_sal   NUMBER        := &sal;                     --使用绑定变量输入薪资值
   v_job   VARCHAR2 (20) := &job;                     --使用绑定变量输入job值
BEGIN
   IF (v_job = '销售') AND (Check_Sal(v_sal) > 5000)  --判断执行条件
   THEN
      DBMS_OUTPUT.put_line ('符合匹配的AND条件');
   END IF;
END;





今天在加班中，本身五一准备钓鱼去的， 我仿佛听到鲤鱼妹妹欢乐的笑声。

    加班归加班，但是活并不多，我负责后期数据库调优，数据关联的。 其他公司抽取数据进度不行，听到的回答只是，现在再抽，没有报错，目前抽了多少不知道，速度不知道。 什么时候抽完不知道，方案B没有，二线没有。这够无语的。  后期他们一张560G的大表， 抽取进度 206M/分钟。 而且还是我帮他们评估出来的。 肯定不行，于是换方案。够喜剧性的，这个公司领导陆续施压，把另外2个人0点叫起来，高铁过来，到现场已是凌晨2点， 把单独抽取大表。 我当天是正常下班的， 看着群里他们大领导挨个拉进来，一级级施压，估计这情节放在韩国够拍成电视剧20集。我们领导让我帮他们建大表索引，我也答应了。我建索引最快的一个是308S， 索引20G。 这个下次说吧。建主键，报错，重复数据。  原因是大表重抽，他们通道里面的数据无法清理，造成数据量重复。于是主键建不了。 涉及到560G大表重复数据删除，我当时用了20分钟不到，甚至真正delete的时候 用了118S，各位想想看能有什么办法搞定？？  如果你不会，看了今天的文章你应该有所感悟了。好了废话不说，上干货。

有个存储过程从周五晚上跑了到了周一还没有跑完，存储过程代码如下：



 TMP_NBR_NO_XXXX共有400w行数据，180MB。For in 后面的查询

select nli.*, .......
   and ns2l.nbr_level_id between 201 and 208 order by nl2i.priority;

上面SQL查询返回43行数据。

   嵌套循环就是一个loop循环，loop套loop相当于笛卡尔积。该PLSQL代码中有loop套loop的情况，这就导致UPDATE TMP_NBR_NO_XXXX要执行400w*43次，TMP_NBR_NO_XXXX.no列没有索引，TMP_NBR_NO_XXXX每次更新都要进行全表扫描。这就是为什么存储过程从周五跑到周一还没跑完的原因。

    有读者可能会问，为什么不用MERGE进行改写呢？在PLSQL代码中是用regexp_like关联的.无法走hash连接，也无法走排序合并连接，两表只能走嵌套循环并且被驱动表无法走索引。如果强行使用MERGE进行改写，因为该SQL执行时间很长，会导致UNDO不释放，因此，没有采用MERGE INTO对代码进行改写。

    有读者可能也会问，为什么不对TMP_NBR_NO_XXXX.no建立索引呢？因为关联更新可以采用ROWID批量更新，所以没有采用建立索引方法优化。

    下面采用ROWID批量更新方法改写上面PLSQL，为了方便读者阅读PLSQL代码，先创建一个临时表用于存储43记录：

create table TMP_DATE_TEST as 

  select  nli.expression, nl.nbr_level_id, priority   from tmp_xxx_item

  ...... and ns2l.nbr_level_id between 201 and 208; 

 创建另外一个临时表，用于存储要被更新的表的ROWID以及no字段：

create table TMP_NBR_NO_XXXX_TEXT as 

select rowid rid, nbn.no from TMP_NBR_NO_XXXX nbn 

 Where nbn.level_id=1 and length(nbn.no)= 8;   


改写后的PLSQL能在4小时左右跑完。有没有什么办法进一步优化呢？单个进程能在4小时左右跑完，如果开启8个并行进程，那应该能在30分钟左右跑完。但是PLSQL怎么开启并行呢？正常情况下PLSQL是无法开启并行的，如果直接在多个窗口中执行同一个PLSQL代码，会遇到锁争用，如果能解决锁争用，在多个窗口中执行同一个PLSQL代码，这样就变相实现了PLSQL开并行功能。可以利用ROWID切片变相实现并行：

select DBMS_ROWID.ROWID_CREATE(1,c.oid,e.RELATIVE_FNO,e.BLOCK_ID,0) minrid,

       DBMS_ROWID.ROWID_CREATE(1,c.oid,e.RELATIVE_FNO,e.BLOCK_ID+e.BLOCKS-1,     10000) maxrid from dba_extents e,

(select max(data_object_id)oid from dba_objects where object_name= 

'TMP_NBR_NO_XXXX_TEXT' and owner='RESXX2')and data_object_id is not null) c

 where e.segment_name='TMP_NBR_NO_XXXX_TEXT'and e.owner = 'RESXX2';

 但是这时发现，切割出来的数据分布严重不均衡，这是因为创建表空间的时候没有指定uniform size 的Extent所导致的。

于是新建一个表空间，指定采用uniform size方式管理Extent：

create tablespace TBS_BSS_FIXED datafile '/oradata/bs_bss_fixed_500.dbf' 

       size 500M extent management local uniform size 128k;

重建一个表用来存储要被更新的ROWID：

create table RID_TABLE

( rowno  NUMBER,  minrid VARCHAR2(18),  maxrid VARCHAR2(18)) ;  

将ROWID插入到新表中：

这样RID_TABLE中每行指定的数据都很均衡，大概4035条数据。最终更改的PLSQL代码：


然后在8个窗口中同时运行上面PLSQL代码：

Begin  pro_phone_grade(0); end; ..... Begin pro_phone_grade(7); end;

    最终能在29分左右跑完所有存储过程。本案例技巧就在于ROWID切片实现并行，并且考虑到了数据分布对并行的影响，其次还使用了ROWID关联更新技巧。




首页 > 数据库 > Oracle > 正文
利用pl/sql执行计划评估SQL语句的性能简析
2012-04-12 10:54:12             收藏   我要投稿

一段SQL代码写好以后，可以通过查看SQL的执行计划，初步预测该SQL在运行时的性能好坏，尤其是在发现某个SQL语句的效率较差时，我们可以通过查看执行计划，分析出该SQL代码的问题所在。


那么，作为开发人员，怎么样比较简单的利用执行计划评估SQL语句的性能呢？总结如下步骤供大家参考：


1、 打开熟悉的查看工具：PL/SQL Developer。

  在PL/SQL Developer中写好一段SQL代码后，按F5，PL/SQL Developer会自动打开执行计划窗口，显示该SQL的执行计划。


2、 查看总COST，获得资源耗费的总体印象

  一般而言，执行计划第一行所对应的COST(即成本耗费)值，反应了运行这段SQL的总体估计成本，单看这个总成本没有实际意义，但可以拿它与相同逻辑不同执行计划的SQL的总体COST进行比较，通常COST低的执行计划要好一些。  www.2cto.com


3、 按照从左至右，从上至下的方法，了解执行计划的执行步骤

执行计划按照层次逐步缩进，从左至右看，缩进最多的那一步，最先执行，如果缩进量相同，则按照从上而下的方法判断执行顺序，可粗略认为上面的步骤优先执行。每一个执行步骤都有对应的COST,可从单步COST的高低，以及单步的估计结果集（对应ROWS/基数），来分析表的访问方式，连接顺序以及连接方式是否合理。


4、 分析表的访问方式

  表的访问方式主要是两种：全表扫描（TABLE ACCESS FULL）和索引扫描(INDEX SCAN)，如果表上存在选择性很好的索引，却走了全表扫描，而且是大表的全表扫描，就说明表的访问方式可能存在问题；若大表上没有合适的索引而走了全表扫描，就需要分析能否建立索引，或者是否能选择更合适的表连接方式和连接顺序以提高效率。


5、 分析表的连接方式和连接顺序

  表的连接顺序：就是以哪张表作为驱动表来连接其他表的先后访问顺序。

表的连接方式：简单来讲，就是两个表获得满足条件的数据时的连接过程。主要有三种表连接方式，嵌套循环（NESTED LOOPS）、哈希连接（HASH JOIN）和排序-合并连接（SORT MERGE JOIN）。我们常见得是嵌套循环和哈希连接。

嵌套循环：最适用也是最简单的连接方式。类似于用两层循环处理两个游标，外层游标称作驱动表，Oracle检索驱动表的数据，一条一条的代入内层游标，查找满足WHERE条件的所有数据，因此内层游标表中可用索引的选择性越好，嵌套循环连接的性能就越高。

哈希连接：先将驱动表的数据按照条件字段以散列的方式放入内存，然后在内存中匹配满足条件的行。哈希连接需要有合适的内存，而且必须在CBO优化模式下，连接两表的WHERE条件有等号的情况下才可以使用。哈希连接在表的数据量较大，表中没有合适的索引可用时比嵌套循环的效率要高。


6、 请核心技术组协助分析  www.2cto.com

以上步骤可以协助我们初步分析SQL性能问题，如果遇到连接表太多，执行计划过于复杂，可联系核心技术组共同讨论，一起寻找更合适的SQL写法或更恰当的索引建立方法



总结两点：

1、这里看到的执行计划，只是SQL运行前可能的执行方式，实际运行时可能因为软硬件环境的不同，而有所改变，而且cost高的执行计划，不一定在实际运行起来，速度就一定差，我们平时需要结合执行计划，和实际测试的运行时间，来确定一个执行计划的好坏。

2、对于表的连接顺序，多数情况下使用的是嵌套循环，尤其是在索引可用性好的情况下，使用嵌套循环式最好的，但当ORACLE发现需要访问的数据表较大，索引的成本较高或者没有合适的索引可用时，会考虑使用哈希连接，以提高效率。排序合并连接的性能最差，但在存在排序需求，或者存在非等值连接无法使用哈希连接的情况下，排序合并的效率，也可能比哈希连接或嵌套循环要好。





--1.联合数组：

DECLARE

  TYPE ind_tab_type IS TABLE OF VARCHAR2(2000)
                    INDEX BY BINARY_INTEGER;
  ind_tab           ind_tab_type;

BEGIN

  ind_tab(1) := 'lubinsu';--这里的下标可以随意指定，可以通过循环来获取
  ind_tab(2) := 'luzhou';
  --dbms_output.put_line(ind_tab(0));
  --dbms_output.put_line(ind_tab(1));
  FOR i IN ind_tab.first..ind_tab.last LOOP
    dbms_output.put_line('ind_tab(' || i || '):' || ind_tab(i));
  END LOOP;

END;




--2.嵌套表的初始化1

--嵌套表的下标默认为1开始，也可以自己指定任意值  www.2cto.com

DECLARE

  TYPE nest_tab_type IS TABLE OF VARCHAR2(2000) NOT NULL; --如果设置not null条件那么在初始化的时候不可以设置null

  nest_tab nest_tab_type := nest_tab_type('lubinsu', 'luzhou'); --初始化的时候只要在集合变量之后使用空的构造函数或者直接赋值即可

BEGIN

  FOR i IN nest_tab.first .. nest_tab.last LOOP

    dbms_output.put_line('nest_tab(' || i || ') value is ' || nest_tab(i));

  END LOOP;

END;





--3.嵌套表和的初始化2

DECLARE

  TYPE nest_tab_type IS TABLE OF VARCHAR2(2000) NOT NULL; --如果设置not null条件那么在初始化的时候不可以设置null

  nest_tab nest_tab_type := nest_tab_type(); --初始化的时候只要在集合变量之后使用空的构造函数或者直接赋值即可

BEGIN

  nest_tab.extend;

  nest_tab(1) := 'lubinsu';

  nest_tab.extend;

  nest_tab(2) := 'luzhou';

  FOR i IN nest_tab.first .. nest_tab.last LOOP

    dbms_output.put_line('nest_tab(' || i || '):' || nest_tab(i));

  END LOOP;

END;



--如果设置not null条件那么在初始化的时候不可以设置null,如：nest_tab(1) := null;否则出错提示；

ORA-06550: line 7, column 18:

PLS-00382: expression is of wrong type

ORA-06550: line 7, column 3:

PLSQL: Statement ignored

--赋值的时候必须使用extend来扩展集合的容量否则会如下错误

ERROR at line 1:

ora-06533: subscript beyond count

ora-06512: at line 6





--4.变长数组类似于PLSQL表，每个元素都被分配了一个连续的下标，从1开始

--4.变长数组的初始化(与嵌套表的初始化方式一样)

DECLARE

  TYPE varray_tab_type IS VARRAY(10) OF VARCHAR2(2000);

  varray_tab varray_tab_type :=  varray_tab_type('lubinsu', 'luzhou'); --初始化的时候只要在集合变量之后使用空的构造函数或者直接赋值即可

BEGIN

  varray_tab.extend;

  varray_tab(3) := 'zengq';

  varray_tab.extend;

  varray_tab(4) := 'buwei';

  FOR i IN varray_tab.first .. varray_tab.last LOOP

    dbms_output.put_line('varray_tab(' || i || '):' || varray_tab(i));

  END LOOP;

END;





--5.集合与集合之间的赋值必须是相同的TYPE

DECLARE

  TYPE type1 IS TABLE OF NUMBER(2);

  TYPE type2 IS TABLE OF NUMBER(2);

  type1_tab  type1 := type1(1, 2, 3);

  type1_tab2 type1 := type1(4, 5, 6);

  type2_tab  type2 := type2(3, 2, 1);

BEGIN

  type1_tab2 := type1_tab;

  --type1_tab2 := type2_tab; 不可用

  FOR i IN type1_tab2.first .. type1_tab2.last LOOP

    dbms_output.put_line('type1_tab2(' || i || '):' || type1_tab2(i));

  END LOOP;

END;



--type1_tab2 := type2_tab;报错

ORA-06550: line 10, column 17:

PLS-00382: expression is of wrong type

ORA-06550: line 10, column 3:

PLSQL: Statement ignored



RESULT:

type1_tab2(1):1

type1_tab2(2):2

type1_tab2(3):3





--6.使用null值为集合赋值

DECLARE

  TYPE type1 IS TABLE OF NUMBER(2);

  type1_tab  type1 := type1();--已经初始化，不为空，虽然没有赋值

  type1_tab2 type1;--未初始化，为空

BEGIN

  IF type1_tab IS NOT NULL THEN

    dbms_output.put_line('type1_tab is not null');

  END IF;



  --type1_tab := NULL;

  --或者

  type1_tab := type1_tab2;



  IF type1_tab IS NULL THEN

    dbms_output.put_line('type1_tab is null');

  END IF;

END;





--7.超出变长数组长度的值将会被丢弃

--8.记录类型的嵌套表的初始化，赋值以及元素的引用

DECLARE

  TYPE object_rec IS RECORD(

    object_id   all_objects_loc.object_id%TYPE,

    object_name all_objects_loc.object_name%TYPE,

    object_type all_objects_loc.object_type%TYPE);



  TYPE object_tab_type IS TABLE OF object_rec;



  object_tab object_tab_type;



  TYPE obj_cur_type IS REF CURSOR; --声明游标变量类型

  obj_cur obj_cur_type;

BEGIN

  OPEN obj_cur FOR

    SELECT a.object_id, a.object_name, a.object_type

    FROM   all_objects_loc a

    WHERE  rownum <= 10;



  FETCH obj_cur BULK COLLECT

    INTO object_tab;

  CLOSE obj_cur;

  FOR i IN 1 .. object_tab.count LOOP

    dbms_output.put_line('object_tab(' || i || '):' || object_tab(i)

                         .object_id || ',' || object_tab(i).object_name || ',' || object_tab(i)

                         .object_type);

  END LOOP;

END;
