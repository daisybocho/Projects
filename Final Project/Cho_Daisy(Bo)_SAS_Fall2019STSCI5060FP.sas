/* Fall 2019 STSCI 5060 Final Project */
/* Name: Daisy (Bo) Cho*/
/*NetID: bsc223*/

options pagesize=1000 linesize=5000

title '******** Step 4 ********';
/*connect to oracly using libname with new username and get 2010 data from final and connect to myoracle*/
LIBNAME myoracle ORACLE USER=Cho_Daisy_STSCI5060FP PW = "62368102Dc";

PROC SQL;
create table myoracle.School_Finance_2010_t as
select * from Final.School_Finance_2010;
quit;

title '******** Step 12B ********';
/*connect to myoracle and create mfslr table*/
LIBNAME myoracle ORACLE USER=Cho_Daisy_STSCI5060FP PW = "62368102Dc";

data myoracle.mfslr_t;
 merge myoracle.mfr_v myoracle.msr_v myoracle.mlr_v;
 run;

title '******** Step 20 ********';
/*create total_rev table from view*/
proc SQL;
create table myoracle.Total_Rev as
select * from myoracle.total_rev_v;
quit;

title '******** Step 21 ********';
/*run correlation of tfedrev tstrev tlocrev*/
proc corr data= myoracle.Total_Rev
plots(maxpoints=NONE)=matrix(histogram);
var tfedrev tstrev tlocrev;
run;

title '******** Step 22 ********';
/*run regression of tfedrev tstrev tlocrev*/
proc reg data= myoracle.Total_Rev;
model tfedrev = tstrev tlocrev;
run;

title '******** Step 23 ********';
/*run correlation and regression of tfedrev tstrev tlocrev using view*/
proc corr data= myoracle.Total_Rev_v
plots(maxpoints=NONE)=matrix(histogram);
var tfedrev tstrev tlocrev;
run;

proc reg data= myoracle.Total_Rev_v;
model tfedrev = tstrev tlocrev;
run;

title '******** Step 24 ********';
PROC SQL;
create table myoracle.School_Finance_2015_t as
select * from Final.School_Finance_2015;
quit;
