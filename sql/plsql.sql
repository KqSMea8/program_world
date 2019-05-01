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

