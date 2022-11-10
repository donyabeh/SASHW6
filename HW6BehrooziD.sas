/*********************************************/
/* STAT 330, Fall 2022						 */
/* Homework #6A								 */
/* Donya Behroozi and Grace Trenholme		 */
/*********************************************/

*1;
filename MEPSfile "/home/u62368731/my_shared_file_links/ulund/STAT 330/Data/Homework/H224.DAT"; 
 
data meps2020; 
  infile MEPSfile; 
  input dupersID $ 11-20 age20x 182-183 sex 192 oftsmk53 635-636 totexp20 2703-2709; 
run; 
 
 
data mepsUse; 
  set meps2020; 
   
  * Restrict to adults with known smoking status; 
  if age20x >= 18 and oftsmk53 >= 1; 
   
  currSmoke = 0; 
  if oftsmk53 in (1,2) then currSmoke = 1; 
   
  if      18 <= age20x <= 34 then ageGrp = 1; 
  else if 35 <= age20x <= 64 then ageGrp = 2; 
  else if       age20x >= 65 then ageGrp = 3; 
   
  if          totexp20  =    0 then expGrp = 1; 
  else if 0 < totexp20 <= 1000 then expGrp = 2; 
  else if     totexp20 >  1000 then expGrp = 3; 
run;

data meps;
	set mepsUse;
	if totexp20 <= 224 then expQuartile = 1;
	else if totexp20 > 224 and totexp20 <= 1546 then expQuartile = 2;
	else if totexp20 > 1546 and totexp20 <= 5740.5 then expQuartile = 3;
	else if totexp20 > 5740.5 then expQuartile = 4;
run;

*1a;
proc freq data = meps;
	tables currSmoke * expQuartile;
run;
*Of the non-current smokers in the data, 50.7% have expenditure totals above the median value of $1546.00 (in the third and fourth quartiles). Of the current smokers
in the data, 45.38% have expenditure totals above the median value of $1546.00 (above the third and fourth quartiles).

*1b; *discuss with grace: wanted 1 age group to be the controlled group;
proc freq data = meps;
	tables ageGrp*currSmoke*expQuartile; 
run;
*For younger Americans, 12.14% of current smokers are in the high-expenditure quartile, while 11.84% of non-smokers are;
*For middle-aged Americans, 24.55% of current smokers are in the high-expenditure quartile, while 21.96% of non-smokers are;
*For older Americans, 37.98% of current smokers are in the high-expenditure quartile, while 42.78% of non-smokers are;

*1c;
proc means data = meps median;
	class sex;
	var totexp20;
run;
*Females have the higher median expenditure value of $2027.00 compared to the males with $1028.00;

proc means data = meps median;
	var totexp20;
	class ageGrp;
run;
*The older age group has a higher expenditure value of $4243.00 compared to the middle-aged group with $1293.00, and the 
younger age group with $425.50 as their expenditure values;

proc means data = meps median;
	var totexp20;
	class currSmoke;
run;
*The non-smokers have a higher expenditure group of $1578.00, compared to the smokers group with $1212.00 as their expenditure value.;

proc means data = meps mean;
	var totexp20;
	class currSmoke;
run;	
*With the mean expenditure value, the smokers have a higher expenditure of 7414.30, compared to the non-smokers
with 7244.33 as their expenditure value;

*1d;
proc means data = meps n mean median stddev nonobs;
	class sex ageGrp currSmoke;
	var totexp20;
	output out = mepsStats (drop = _type_ _freq_) n = median = mean = stddev = / autoname;
run;
	
	
proc format;
	value gender 1 = 'Male'
				 2 = 'Female';
	value age 1 = '18-34'
	          2 = '35-64'
	          3 = '65+';
	value smoker 0 = 'Non-Smoker'
		         1 = 'Smoker';
		         
proc sort data = mepsStats;
	where sex is not missing and ageGrp is not missing and currSmoke is not missing;
	by sex ageGrp currSmoke;
run;

		         
options nocenter;
proc print data = mepsStats label noobs;
	title1 "Total Medical Expenditures by Sex, Age, and Smoking Status"; 
    title2 height=0.10 "US Adults, Medical Expenditure Panel Survey, 2018";
    label sex = 'Sex'
	      ageGrp = 'Age'
	      currSmoke = 'Current Smoker'
		  totexp20_n = 'N'
		  totexp20_median = 'Median'
		  totexp20_mean = 'Mean'
		  totexp20_stddev = 'SD';
	format sex gender. ageGrp age. currSmoke smoker.
	totexp20_n comma. totexp20_median totexp20_mean totexp20_stddev dollar15.;
run;

*1e;
options nocenter;
proc print data = mepsStats label noobs;
	title1 "Total Medical Expenditures by Sex, Age, and Smoking Status"; 
    title2 height=0.10 "US Adults, Medical Expenditure Panel Survey, 2018";
    label sex = 'Sex'
	      ageGrp = 'Age'
	      currSmoke = 'Current Smoker'
		  totexp20_n = 'N'
		  totexp20_median = 'Median'
		  totexp20_mean = 'Mean'
		  totexp20_stddev = 'SD';
	format sex gender. ageGrp age. currSmoke smoker.
	totexp20_n comma. totexp20_median totexp20_mean totexp20_stddev dollar15.;
	id sex ageGrp; *ID turns the columns blue (like a variable);
	by sex ageGrp; *splits columns by sex, then age group;
run;
*The group that pays the highest medical expenditures is the female, aged 65+ non-smoker group. Across all of the sex and age groups, 
non-smokers pay higher medical expenditures than the smokers, other than the middle-aged female group;


/*********************************************/
/* STAT 330, Fall 2022						 */
/* Homework #6B 							 */
/* Donya Behroozi and Grace Trenholme		 */
/*********************************************/

*1a;
filename rsltFile '/home/u62368731/sasuser.v94/Homework/Cert Test Results - All.csv';
data all_test;
	infile rsltFile dlm = ',' dsd firstobs = 2;
	input id $ cert_score;
run;
 
filename stu1File '/home/u62368731/sasuser.v94/Homework/Cert Test Students - Los Angeles.csv';
data LA_test;
	infile stu1File dlm = ',' dsd firstobs = 2;
	input id $ last :$12. first $ age;
run;

filename stu2File '/home/u62368731/sasuser.v94/Homework/Cert Test Students - San Antonio.csv';
data SA_test;
	infile stu2File dlm = ',' dsd firstobs = 2;
	input id $ last $ first $ age;
run;

*1b;
proc sort data = SA_test;
	by id;
run;

proc sort data = LA_test;
	by id;
run;

data all;
	merge all_test LA_test (in = inLA) SA_test (in = inSA);
	by id;
	if inSA = 1 then site = 'San Antonio';
	else if inLA = 1 then site = 'Los Angeles';
run;

*1c;
ods noptitle;
proc means data = all maxdec = 2;
	var cert_score;
	class site;
	output out = sum_all (drop = _type_ _freq_) n = N mean = Mean stddev = SD min = Min max = Max;
run;

data sum_all;
	set sum_all;
	if site = ' ' then site = 'Overall';
	
options nocenter;
proc print data = sum_all (rename = (site = Site)) noobs;
	title1 'Results of SAS Certification Exam, 2021';
	title2 height=0.10 'Los Angeles and San Antonio Sites';
	format SD 6.2;
run;

*1d; *discuss with grace;
options missing = '';
ods csv file = '/home/u62368731/sasuser.v94/Output Files/SASCertExam.csv';
proc print data = all;
run;
ods csv close;

*2a;
libname save '/home/u62368731/my_shared_file_links/ulund/STAT 330/Data/Homework';
data cannabis;
	length county $25;
	set save.cannabisretailersfinal;
	if county = ' ' then county_missing = 1;
	else county_missing = 0;
run;

*2b;
proc freq data = cannabis;	
	tables county_missing;
	tables type*county_missing;
run;
*314 of all observations are missing a county. There are 3 observations with Cannabis - 
Retailer License type that are missing a county, accounting for 0.55% of total licenses;


*2c;
data retailers_missing;
	set cannabis;
	where county_missing = 1 and type = 'Cannabis - Retailer License';
run;
*cities seaside, desert hot springs, blythe;

data retailers;
	set cannabis;
	if type = 'Cannabis - Retailer License'; 
	if license = 'C10-0000070-LIC' then county = 'Riverside';
	if license = 'C10-0000396-LIC' then county  = 'Riverside';
	if license = 'C10-0000425-LIC' then county = 'Monterey';
	keep county use;
run;

proc freq data = retailers;
	tables county;
run;
*There are no more missing values;

*2d;
proc freq data = retailers;
	tables county / missing out = retailers_freq (keep = county count);
run;

*2e; 
filename popFile "/home/u62368731/sasuser.v94/Homework/County Population Estimates 2021.csv"; 
 
data countyPops; 
  infile popFile firstobs=4 dlm=',' dsd; 
  input sumLev region div stCode cntyCode stName :$20. cntyName :$25. popln; 
run; 

*2f; *discuss with grace; *need to take out county in substring;
data calpops;
	set countypops;
	if stName = 'California';
	county = substr(cntyname, 1, length(cntyname)-7);
	keep popln county;
	if cntyname = 'California' then delete;
run;

*2g;
libname cali '/home/u62368731/my_shared_file_links/ulund/STAT 330/Data/Homework';
data capops;
	length county $20;
	set cali.capops;
run;

libname ret '/home/u62368731/my_shared_file_links/ulund/STAT 330/Data/Homework';
data numRetailers;
	length county $20;
	set ret.numretailers;
run;


data all_canna;
	merge capops numRetailers;
	by county;
	if count = '.' then count = 0;
	perCapita = round(count/popln*100000, 0.1);
run;

*2h;
proc sort data = all_canna;
	by descending perCapita;
run;

ods html path = '/home/u62368731/sasuser.v94/Output Files' body = 'all_canna.html';
options nocenter;
proc print data = all_canna label;
	var county perCapita count popln;
	sum popln count;
	title1 height = 14pt 'Number of Cannabis Retailer Licenses: California, as of 8/8/2019';
	title2 height = 11pt 'By County';
	label county = 'County'
	      perCapita = '# per 100,000'
	      count = '# Retailers'
	      popln = 'Popln';
	format popln comma10.;
run;
ods html close;
	
