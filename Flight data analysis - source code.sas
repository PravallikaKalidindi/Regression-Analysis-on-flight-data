
/*Import*/
PROC IMPORT OUT= WORK.FAA2 DATAFILE= "/folders/myfolders/FAA2.xls" 
            DBMS=xls REPLACE;
     SHEET="FAA2"; 
     GETNAMES=YES; 
RUN;

PROC IMPORT OUT= WORK.FAA1 DATAFILE= "/folders/myfolders/FAA1 (1).xls" 
            DBMS=xls REPLACE;
     SHEET="FAA1"; 
     GETNAMES=YES; 
RUN;

/*check for empty rows*/
options missing=' ';
data FAA2_spec;
 set FAA2;
 if missing(cats(of _all_)) ;
run;

options missing=' ';
data FAA1_spec;
 set FAA1;
 if missing(cats(of _all_)) ;
run;

/*remove empty rows*/
options missing='';
data FAA2;
   set FAA2;
   if missing(cats(of _all_)) then delete;
run;

options missing='';
data FAA1;
   set FAA1;
   if missing(cats(of _all_)) then delete;
run;

/*combining datasets*/
DATA Flight_Details;
SET FAA1 FAA2;
run;

proc sort data=Flight_Details  out=Flight_Details nodupkey ;
by aircraft	no_pasg	speed_ground speed_air height pitch	distance
;
run;

proc format;
 value $missfmt ' '='Missing' other='Not Missing';
 value  missfmt  . ='Missing' other='Not Missing';
run;
 
proc freq data=Flight_Details; 
format _CHAR_ $missfmt.; /* apply format for the duration of this PROC */
tables _CHAR_ / missing nocum nopercent;
format _NUMERIC_ missfmt.;
tables _NUMERIC_ / missing nocum nopercent;
run;

data Flight_Details;
set Flight_Details;
if Height<0 and height<>. then delete;
run;

data Flight_Details;
set Flight_Details;
if duration<40 and duration <>. then delete;
run;

PROC UNIVARIATE DATA=FLIGHT_DETAILS; 
VAR speed_ground; 
RUN;

DATA FLIGHT_DETAILS; 
SET FLIGHT_DETAILS; 
IF speed_ground<30 or speed_ground>140 THEN DELETE; 
RUN;

PROC UNIVARIATE DATA=FLIGHT_DETAILS; 
VAR speed_ground; 
RUN;


PROC UNIVARIATE DATA=FLIGHT_DETAILS; 
VAR speed_ground; 
RUN;

PROC UNIVARIATE DATA=FLIGHT_DETAILS; 
VAR height; 
RUN;

DATA FLIGHT_DETAILS; 
SET FLIGHT_DETAILS; 
IF height<6 THEN DELETE; 
RUN;

DATA FLIGHT_DETAILS; 
SET FLIGHT_DETAILS; 
IF distance>6000 THEN DELETE; 
RUN;

ODS SELECT PLOTS;
PROC UNIVARIATE DATA=Flight_Details PLOTS;
VAR DURATION NO_PASG SPEED_GROUND HEIGHT PITCH DISTANCE;
RUN;


proc plot data=flight_details;
plot distance*(no_pasg speed_ground speed_air height duration pitch);
run;

proc corr data=flight_details;
run;

data flight_details;
set flight_details;
if aircraft='boeing' then do; aircraft_boeing=1; aircraft_airbus=0;
end;
run;

data flight_details;
set flight_details;
if aircraft='airbus' then do; aircraft_boeing=0; aircraft_airbus=1;
end;
drop aircraft;
run;

proc reg data=flight_details;
model distance= aircraft_boeing aircraft_airbus no_pasg height duration pitch speed_ground;
output out=outp_reg r=res residual=output_residual;
run;

data flight_details;
set flight_details;
speed_ground_s = speed_ground*speed_ground*speed_ground*speed_ground;
sqrt_distance = sqrt(distance);
run;

proc reg data=flight_details;
model distance= aircraft_boeing aircraft_airbus height speed_ground_s;
output out=outp_reg r=res residual=output_residual;
run;

proc plot data=flight_details;
plot sqrt_distance*(speed_ground height);
run;


proc univariate data=outp_reg
normal plot;
var res;
run;


