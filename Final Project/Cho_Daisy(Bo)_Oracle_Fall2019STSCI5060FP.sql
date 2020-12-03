/* Fall 2019 STSCI 5060 Final Project */
/* Name: Daisy (Bo) Cho*/
/*NetID: bsc223*/
SET pagesize 1000
SET linesize 5000

ttitle '******** Step 1 ********' skip 2 
/* created new username in command prompt and granted privilege and created new connection*/

ttitle '******** Step 2 ********' skip 2 
/*imported State_t table and have 2 screenshots of column and data tab*/

ttitle '******** Step 3 ********' skip 2 
/*add 0 in front of single digit state code*/
UPDATE State_T
SET STCODE = '0' ||substr(stcode,1, 1)
Where stcode<=9;

Select * from state_t
where stcode<10;

ttitle '******** Step 4 ********' skip 2
/*describe school finance 2010 tabe and select first 10 of data*/
Describe School_Finance_2010_t
Select * from school_finance_2010_t
where rownum<=10;

ttitle '******** Step 5A ********' skip 2
/*modify idcensus type in school finance 2010*/
ALTER TABLE School_Finance_2010_t
MODIFY IDCENSUS VARCHAR2(15);

ttitle '******** Step 5b ********' skip 2 
/*modify name type in school finance 2010*/
ALTER TABLE School_Finance_2010_t
MODIFY NAME VARCHAR2(60);

ttitle '******** Step 6 ********' skip 2 
/*modify name and state name in school finance 2010*/
ALTER TABLE School_Finance_2010_t
Rename column NAME to SD_NAME;

ALTER TABLE School_Finance_2010_t
Rename column State to STCODE;

ttitle '******** Step 7A ********' skip 2
/*create fedrev table*/
Create table Fedrev_t as
Select idcensus, stcode, c14+ c15+ c16+ c17+ c18+ c19+ b11+ c20+ c25+ c36+
b10+ b12+ b13 as fed_rev
from School_Finance_2010_t;

ttitle '******** Step 7B ********' skip 2
/*create strev table*/
Create table Strev_t as
Select idcensus, stcode, c01 + c04 + c05 + c06 + c07 + c08 + c09 + c10 + c11 + c12 + c13 + c24 +
c35 + c38 + c39 as st_rev
from School_Finance_2010_t;

ttitle '******** Step 7C ********' skip 2
/*create locrev table*/
Create table Locrev_t as
Select idcensus, stcode, t02 + t06 + t09 + t15 + t40 + t99 + d11 + d23 + a07 + a08 +
a09 + a11 + a13 + a15 + a20 + a40 + u11 + u22 + u30 + u50 + u97 as loc_rev
from School_Finance_2010_t;

ttitle '******** Step 7D ********' skip 2
/*create school table*/
Create table School_t as
Select idcensus, stcode, sd_name
from School_Finance_2010_t;

ttitle '******** Step 8A ********' skip 2
/*add primary key to state table*/
ALTER TABLE State_t
ADD CONSTRAINT State_PK PRIMARY KEY (stcode);

ttitle '******** Step 8B ********' skip 2
/*add primary key to fedrev, strev, locrev table*/
ALTER TABLE Fedrev_t
ADD CONSTRAINT Fedrev_PK PRIMARY KEY (idcensus);

ALTER TABLE Strev_t
ADD CONSTRAINT Strev_PK PRIMARY KEY (idcensus);

ALTER TABLE Locrev_t
ADD CONSTRAINT Locrev_PK PRIMARY KEY (idcensus);

ALTER TABLE School_t
ADD CONSTRAINT School_PK PRIMARY KEY (idcensus);

ttitle '******** Step 8C ********' skip 2
/*add foreign key to fedrev, strev, locrev table*/
ALTER TABLE Fedrev_t 
add constraint Fedrev_FK foreign KEY (idcensus) 
references School_t (idcensus);

ALTER TABLE Strev_t 
add constraint Strev_FK foreign KEY (idcensus) 
references School_t (idcensus);

ALTER TABLE Locrev_t 
add constraint Locrev_FK foreign KEY (idcensus) 
references School_t (idcensus);

ttitle '******** Step 8D ********' skip 2
/*add foreign key to school table*/
ALTER TABLE School_t 
add constraint School_FK foreign KEY (stcode) 
references State_t (stcode);

ttitle '******** Step 10 ********' skip 2
/*select idcensus state code, revenue> 1000000 from fedrev, strev, locrev*/
SELECT idcensus, stcode, fed_rev AS fed_revenue
FROM Fedrev_t
WHERE fed_rev > 1000000;

SELECT idcensus, stcode, st_rev AS st_revenue
FROM strev_t
WHERE st_rev > 1000000;

SELECT idcensus, stcode, loc_rev AS loc_revenue
FROM locrev_t
WHERE loc_rev > 1000000;

ttitle '******** Step 11 ********' skip 2
/*create view with school district and state code and select max and min*/
CREATE VIEW sd#_v AS
SELECT count(distinct SD_Name) AS SD#, stcode
FROM School_t
GROUP BY STCODE;

ttitle '******** Step 11A ********' skip 2
Select max_SD#, s.stname, v.stcode
FROM State_t s, SD#_v v, (select max(SD#) as max_SD# from SD#_v)
WHERE s.stcode = v.stcode and SD# = max_SD#;

ttitle '******** Step 11B ********' skip 2 
Select min_SD#, s.stname, v.stcode
FROM State_t s, SD#_v v, (select min(SD#) as min_SD# from SD#_v)
WHERE s.stcode = v.stcode and SD# = min_SD#;

ttitle '******** Step 12A ********' skip 2
/*create view mfr, msr, mlr and show table*/
drop view mfr_v;
drop view msr_v;
drop view mlr_v;

CREATE VIEW mfr_v AS
SELECT stcode, max(fed_rev) AS MAX_FED_REV
FROM fedrev_t
GROUP BY STCODE;

CREATE VIEW msr_v AS
SELECT stcode, max(st_rev) AS MAX_ST_REV
FROM strev_t
GROUP BY STCODE;

CREATE VIEW mlr_v AS
SELECT stcode, max(loc_rev) AS MAX_LOC_REV
FROM locrev_t
GROUP BY STCODE;

ttitle '******** Step 12C ********' skip 2
select stcode, to_char(max_fed_rev, '999999999.9'), to_char(max_st_rev, '999999999.9'), to_char(max_loc_rev, '999999999.9') from mfslr_t;

ttitle '******** Step 13 ********' skip 2
/*select state name, state code and max fed revenue*/
SELECT state_t.stname AS state_name, mfslr_t.stcode AS state_code, mfslr_t.max_fed_rev
FROM mfslr_t
left  join state_t on mfslr_t.stcode = state_t.stcode
order by max_fed_rev desc;

ttitle '******** Step 14 ********' skip 2
/*create view total_rev_v*/
drop view total_rev_v;
CREATE VIEW Total_Rev_v AS
SELECT fedrev_t.idcensus, fedrev_t.stcode, fed_rev AS tfedrev, st_rev AS tstrev, loc_rev AS tlocrev
FROM fedrev_t, strev_t, locrev_t
Where fedrev_t.idcensus = strev_t.idcensus
AND strev_t.idcensus = locrev_t.idcensus;

ttitle '******** Step 15 ********' skip 2
/*create view total_rev_v*/
select * from
(select total_rev_v.stcode, stname, total_rev_v.idcensus, (tfedrev +tstrev+tlocrev) as total_revenue, sd_name
from total_rev_v, state_t, school_t
where state_t.stcode=total_rev_v.stcode
AND total_rev_v.stcode = school_t.stcode
order by total_revenue desc)
where rownum<=100;

ttitle '******** Step 16 ********' skip 2
/*slect state code, state name, and total exp*/
SELECT School_finance_2010_t.stcode,state_t.stname, School_Finance_2010_t.TOTALEXP
from School_Finance_2010_t, state_t
where School_Finance_2010_t.stcode = state_t.stcode
order by School_Finance_2010_t.TOTALEXP desc;

ttitle '******** Step 17 ********' skip 2
/*create sentence*/
SET HEADING OFF
Print 'The total amount that the United States spent on the public school systems in 2010 was $'; 
select to_char(sum(totalexp),'999999999.9')
FROM School_Finance_2010_t s;
SET HEADING ON

ttitle '******** Step 18A ********' skip 2
/*create view fed_contribution_v, st_contribution_v, loc_contribution_v*/
drop view fed_contribution_v;
CREATE VIEW fed_contribution_v AS
SELECT School_finance_2010_t.idcensus, School_Finance_2010_t.stcode, state_t.stname, 
School_finance_2010_t.sd_name,  Round((fed_rev/totalexp),4) AS fed_pcnt
FROM School_finance_2010_t,fedrev_t, state_t
where School_Finance_2010_t.stcode = fedrev_t.stcode
and fedrev_t.stcode = state_t.stcode
and totalexp^=0;
Select * from fed_contribution_v
where fed_pcnt > 1
ORDER BY fed_pcnt desc;

ttitle '******** Step 18B ********' skip 2
drop view st_contribution_v;
CREATE VIEW st_contribution_v AS
SELECT School_finance_2010_t.idcensus, School_Finance_2010_t.stcode, state_t.stname, 
School_finance_2010_t.sd_name, Round((st_rev/totalexp),4) AS st_pcnt
FROM School_finance_2010_t,strev_t, state_t
where School_Finance_2010_t.stcode = strev_t.stcode
and strev_t.stcode = state_t.stcode
and totalexp^=0;
Select * from st_contribution_v
where st_pcnt > 1
ORDER BY st_pcnt desc;

ttitle '******** Step 18C ********' skip 2
drop view loc_contribution_v;
create VIEW loc_contribution_v AS
SELECT School_finance_2010_t.idcensus, School_Finance_2010_t.stcode, state_t.stname, 
School_finance_2010_t.sd_name, Round((loc_rev/totalexp),4) AS loc_pcnt
FROM School_finance_2010_t,locrev_t, state_t
where School_Finance_2010_t.stcode = locrev_t.stcode
and locrev_t.stcode = state_t.stcode
and totalexp^=0;
Select * from loc_contribution_v
where loc_pcnt > 1
ORDER BY loc_pcnt DESC;

ttitle '******** Step 19 ********' skip 2
/*create view fsl_contribution_v*/
drop view fsl_contribution_v;
CREATE VIEW fsl_contribution_v AS
SELECT f.idcensus, f.stcode, f.sd_name, (fed_pcnt+st_pcnt+loc_pcnt) AS fsl_pcnt
FROM fed_contribution_v f, st_contribution_v s, loc_contribution_v l
where f.stcode = s.stcode
and l.stcode = s.stcode;

ttitle '******** Step 19A ********' skip 2
/*select when fsl_pcnt>3 in fsl_contribution_v*/
Select * from fsl_contribution_v
where fsl_pcnt>3
order by fsl_pcnt desc;

ttitle '******** Step 19B ********' skip 2
/*select when fsl_pcnt<=3 in fsl_contribution_v*/
Select * from fsl_contribution_v
where fsl_pcnt<= 0.3
order by fsl_pcnt desc;

ttitle '******** Step 25 ********' skip 2
/*alter 2015 table to change column names and select top 5 lost and gained revenue and 5 that haven't changed*/
ALTER TABLE School_Finance_2015_t
Rename column NAME to SD_NAME;

ALTER TABLE School_Finance_2015_t
Rename column State to STCODE;

ttitle '******** Step 25A ********' skip 2

select * from
(SELECT e.stcode, s.stname, e.idcensus, e.sd_name, Round((e.totalrev - l.totalrev),1) AS revdif, Round(100*Round((e.totalrev - l.totalrev),1)/nullif(e.totalrev,0),1) AS change_percentage
FROM School_Finance_2010_t e, School_Finance_2015_t l, state_t s
Where e.stcode=l.stcode
AND l.stcode= s.stcode
ORDER BY revdif ASC)
where rownum<=5;

ttitle '******** Step 25B ********' skip 2
SELECT * from
(SELECT e.stcode, s.stname, e.idcensus, e.sd_name, Round((e.totalrev - l.totalrev),1) AS revdif, Round(100*Round((e.totalrev - l.totalrev),1)/nullif(e.totalrev,0),1) AS change_percentage
FROM School_Finance_2010_t e, School_Finance_2015_t l, state_t s
Where e.stcode=l.stcode
AND l.stcode= s.stcode
ORDER BY revdif desc)
where rownum<=5;

ttitle '******** Step 25C ********' skip 2
SELECT * from
(SELECT e.stcode, s.stname, e.idcensus, e.sd_name, Round((e.totalrev - l.totalrev),1) AS revdif, Round(100*Round((e.totalrev - l.totalrev),1)/nullif(e.totalrev,0),1) AS change_percentage
FROM School_Finance_2010_t e, School_Finance_2015_t l, state_t s
Where e.stcode=l.stcode
AND l.stcode= s.stcode
AND (e.totalrev - l.totalrev) = 0)
where rownum<=5;