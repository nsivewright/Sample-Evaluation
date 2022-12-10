* import_malawi_ifc_live2.do
*
* 	Imports and aggregates "Macadamia Malawi v2" (ID: malawi_ifc_live2) data.
*
*	Inputs: .csv file(s) exported by the SurveyCTO Sync
*	Outputs: "C:/Users/NathanSivewright/C4ED/P1836_Malawi_agribusiness_WB - Documents/Working_files/02_Analysis/04_Raw_Data/SurveyCTO Sync/Stata/Macadamia Malawi v2.dta"
*
*	Output by the SurveyCTO Sync September 9, 2019 10:51 AM.

* initialize Stata
clear all
set more off
set mem 100m

* initialize workflow-specific parameters
*	Set overwrite_old_data to 1 if you use the review and correction
*	workflow and allow un-approving of submissions. If you do this,
*	incoming data will overwrite old data, so you won't want to make
*	changes to data in your local .dta file (such changes can be
*	overwritten with each new import).
local overwrite_old_data 0

* initialize form-specific parameters
local csvfile "C:\Users\/`c(username)'\C4ED\C4ED Global - Documents\10_Knowledge Management\02_KM_All\05_GitFlow\exported\Macadamia Malawi v2.csv"
local dtafile "C:\Users\/`c(username)'\C4ED\C4ED Global - Documents\10_Knowledge Management\02_KM_All\05_GitFlow\exported\Macadamia Malawi v2.dta"
local corrfile "C:\Users\/`c(username)'\C4ED\C4ED Global - Documents\10_Knowledge Management\02_KM_All\05_GitFlow\exported\Macadamia Malawi v2_corrections.csv"
local note_fields1 "note_intro consent_note headlessthan20 noadults set_up_timeuse set_up_enterprise notelistent notea4_1 notea4_2 notea4_3 notea4_4 notea4_5 notea4_6 notea4_7 notea4_8 set_up_household set_up_agri"
local note_fields2 "trees_check set_up_crops agri_inputs set_up_nutrition penandpencil loan_entry set_up_income set_up_extension set_up_shocks set_up_sc note_privacy note_gender"
local text_fields1 "deviceid imei text district district_name ta ta_name village village_name farmer farmer_name treatment_group replacement_group z1_text z10 z10_other timestamp_visit where_district z99 z6 z7 z8 z9"
local text_fields2 "z97_name timestamp_consent_end sign timestamp_int_start a0_3 a0_3_other timestamp_hhmember_start roster1_count"
local text_fields3 "name15 name16 name17 name18 name19 name20 name21 sum_food_adult_man sum_food_adult_woman sum_food_boy sum_food_girl sum_food_baby sum_spouse sum_adult resp_sex ben_sex head_name head_id head_sex"
local text_fields4 "head_age head_marital head_count roster2_count roster3_count timestamp_hhmember_end any_enterprise a4_numifmiss a4_rep_count timestamp_enterprise_end b12 b12_other b14 b14_other timestamp_asset_end"
local text_fields5 "cult_area c1_7 c1_7_other sumtrees04 total_trees c1_7c c1_8x c1_8x_other crop1_count fert_any pest_any ofert_any c1_23 c1_23_other c1_23b c1_23b_other c1_24 c1_24_other c1_25 c1_26_other c1_26 c2_1"
local text_fields6 "c2_1_other c2_4 c2_4_other c2_5 c2_5_other c2_6a c2_7b c2_8 c2_8_other c2_12 c2_12_other c2_13 c2_13_other timestamp_agri_end d5 timestamp_nutrition_end e7 e8 e8_other e12_rep_count e17 e17_other e18"
local text_fields7 "e18_other e21 e21_other e22 e22_other timestamp_finance_end f1_17_other timestamp_income_end g1_12_other h1 timestamp_extension_end h1_2 h1_5 h1_5_other h2_2 h2_5 h2_5_other h3_2 h3_5 h3_5_other h4_2"
local text_fields8 "h4_5 h4_5_other h5_2 h5_5 h5_5_other h6_2 h6_5 h6_5_other h7_2 h7_5 h7_5_other h8_2 h8_5 h8_5_other h9_2 h9_5 h9_5_other h10_2 h10_5 h10_5_other h11_2 h11_5 h11_5_other h12_2 h12_5 h12_5_other h13_2"
local text_fields9 "h13_5 h13_5_other h14_2 h14_5 h14_5_other h15_2 h15_5 h15_5_other h16_2 h16_5 h16_5_other i1 i1_other timestamp_shocks_end i2 i2_other i3 i3_other i5 i5_other timestamp_social_end j2_13_other any_j5"
local text_fields10 "j5_11_other j6 j6_other timestamp_gender_end timestamp_int_end should_replace comment instanceid"
local date_fields1 "today"
local datetime_fields1 "submissiondate start end time_start"

disp
disp "Starting import of: `csvfile'"
disp

* import data from primary .csv file
insheet using "`csvfile'", names clear

* drop extra table-list columns
cap drop reserved_name_for_field_*
cap drop generated_table_list_lab*

* continue only if there's at least one row of data to import
if _N>0 {
	* drop note fields (since they don't contain any real data)
	
	
	* format date and date/time fields
	forvalues i = 1/100 {
		if "`datetime_fields`i''" ~= "" {
			foreach dtvarlist in `datetime_fields`i'' {
				cap unab dtvarlist : `dtvarlist'
				if _rc==0 {
					foreach dtvar in `dtvarlist' {
						tempvar tempdtvar
						rename `dtvar' `tempdtvar'
						gen double `dtvar'=.
						cap replace `dtvar'=clock(`tempdtvar',"DMYhms",2025)
						* automatically try without seconds, just in case
						cap replace `dtvar'=clock(`tempdtvar',"DMYhm",2025) if `dtvar'==. & `tempdtvar'~=""
						format %tc `dtvar'
						drop `tempdtvar'
					}
				}
			}
		}
		if "`date_fields`i''" ~= "" {
			foreach dtvarlist in `date_fields`i'' {
				cap unab dtvarlist : `dtvarlist'
				if _rc==0 {
					foreach dtvar in `dtvarlist' {
						tempvar tempdtvar
						rename `dtvar' `tempdtvar'
						gen double `dtvar'=.
						cap replace `dtvar'=date(`tempdtvar',"DMY",2025)
						format %td `dtvar'
						drop `tempdtvar'
					}
				}
			}
		}
	}

	* ensure that text fields are always imported as strings (with "" for missing values)
	* (note that we treat "calculate" fields as text; you can destring later if you wish)
	tempvar ismissingvar
	quietly: gen `ismissingvar'=.
	forvalues i = 1/100 {
		if "`text_fields`i''" ~= "" {
			foreach svarlist in `text_fields`i'' {
				cap unab svarlist : `svarlist'
				if _rc==0 {
					foreach stringvar in `svarlist' {
						quietly: replace `ismissingvar'=.
						quietly: cap replace `ismissingvar'=1 if `stringvar'==.
						cap tostring `stringvar', format(%100.0g) replace
						cap replace `stringvar'="" if `ismissingvar'==1
					}
				}
			}
		}
	}
	quietly: drop `ismissingvar'


	* consolidate unique ID into "key" variable
	replace key=instanceid if key==""
	drop instanceid


	* label variables
	label variable key "Unique submission ID"
	cap label variable submissiondate "Date/time submitted"
	cap label variable formdef_version "Form version used on device"
	cap label variable review_status "Review status"
	cap label variable review_comments "Comments made during review"
	cap label variable review_corrections "Corrections made during review"


	label variable district "District"
	note district: "District"

	label variable ta "Traditional Authority"
	note ta: "Traditional Authority"

	label variable village "Village"
	note village: "Village"

	label variable farmer "Beneficiary"
	note farmer: "Beneficiary"

	label variable z2 "Supervisor ID"
	note z2: "Supervisor ID"
	label define z2 1 "Supervisor 1" 2 "Supervisor 2" 3 "Supervisor 3" 4 "Supervisor 4" 5 "Supervisor 5" 6 "Supervisor 6"
	label values z2 z2

	label variable z1 "Enumerator ID"
	note z1: "Enumerator ID"
	label define z1 1 "Enumerator 1" 2 "Enumerator 2" 3 "Enumerator 3" 4 "Enumerator 4" 5 "Enumerator 5" 6 "Enumerator 6" 7 "Enumerator 7" 8 "Enumerator 9" 9 "Enumerator 9" 10 "Enumerator 10" 11 "Enumerator 11" 12 "Enumerator 12" 13 "Enumerator 13" 14 "Enumerator 14" 15 "Enumerator 15" 16 "Enumerator 16" 17 "Enumerator 17" 18 "Enumerator 18" 19 "Enumerator 19" 20 "Enumerator 20" 21 "Enumerator 21" 22 "Enumerator 22" 23 "Enumerator 23" 24 "Enumerator 24" 25 "Enumerator 25" 26 "Enumerator 26" 27 "Enumerator 27" 28 "Enumerator 28" 29 "Enumerator 29" 30 "Enumerator 30"
	label values z1 z1


	label variable consent "Consent"
	note consent: "Consent"
	label define consent 0 "No" 1 "Yes"
	label values consent consent

	label variable c1_1 "C1_1. Do you own any arable land?"
	note c1_1: "C1_1. Do you own any arable land?"
	label define c1_1 0 "No" 1 "Yes"
	label values c1_1 c1_1

	label variable c1_2 "C1_2. What is the total size of your arable land, in acres?"
	note c1_2: "C1_2. What is the total size of your arable land, in acres?"

	label variable e14 "E14. Over the last 12 months, did anyone in your household apply for a loan from"
	note e14: "E14. Over the last 12 months, did anyone in your household apply for a loan from a financial institution?"
	label define e14 0 "No" 1 "Yes"
	label values e14 e14



	* append old, previously-imported data (if any)
	cap confirm file "`dtafile'"
	if _rc == 0 {
		* mark all new data before merging with old data
		gen new_data_row=1
		
		* pull in old data
		append using "`dtafile'"
		
		* drop duplicates in favor of old, previously-imported data if overwrite_old_data is 0
		* (alternatively drop in favor of new data if overwrite_old_data is 1)
		sort key
		by key: gen num_for_key = _N
		drop if num_for_key > 1 & ((`overwrite_old_data' == 0 & new_data_row == 1) | (`overwrite_old_data' == 1 & new_data_row ~= 1))
		drop num_for_key

		* drop new-data flag
		drop new_data_row
	}
	
	* save data to Stata format
	save "`dtafile'", replace

	* show codebook and notes
	codebook
	notes list
}

disp
disp "Finished import of: `csvfile'"
disp

* apply corrections (if any)
capture confirm file "`corrfile'"
if _rc==0 {
	disp
	disp "Starting application of corrections in: `corrfile'"
	disp

	* save primary data in memory
	preserve

	* load corrections
	insheet using "`corrfile'", names clear
	
	if _N>0 {
		* number all rows (with +1 offset so that it matches row numbers in Excel)
		gen rownum=_n+1
		
		* drop notes field (for information only)
		drop notes
		
		* make sure that all values are in string format to start
		gen origvalue=value
		tostring value, format(%100.0g) replace
		cap replace value="" if origvalue==.
		drop origvalue
		replace value=trim(value)
		
		* correct field names to match Stata field names (lowercase, drop -'s and .'s)
		replace fieldname=lower(subinstr(subinstr(fieldname,"-","",.),".","",.))
		
		* format date and date/time fields (taking account of possible wildcards for repeat groups)
		forvalues i = 1/100 {
			if "`datetime_fields`i''" ~= "" {
				foreach dtvar in `datetime_fields`i'' {
					* skip fields that aren't yet in the data
					cap unab dtvarignore : `dtvar'
					if _rc==0 {
						gen origvalue=value
						replace value=string(clock(value,"DMYhms",2025),"%25.0g") if strmatch(fieldname,"`dtvar'")
						* allow for cases where seconds haven't been specified
						replace value=string(clock(origvalue,"DMYhm",2025),"%25.0g") if strmatch(fieldname,"`dtvar'") & value=="." & origvalue~="."
						drop origvalue
					}
				}
			}
			if "`date_fields`i''" ~= "" {
				foreach dtvar in `date_fields`i'' {
					* skip fields that aren't yet in the data
					cap unab dtvarignore : `dtvar'
					if _rc==0 {
						replace value=string(clock(value,"DMY",2025),"%25.0g") if strmatch(fieldname,"`dtvar'")
					}
				}
			}
		}

		* write out a temp file with the commands necessary to apply each correction
		tempfile tempdo
		file open dofile using "`tempdo'", write replace
		local N = _N
		forvalues i = 1/`N' {
			local fieldnameval=fieldname[`i']
			local valueval=value[`i']
			local keyval=key[`i']
			local rownumval=rownum[`i']
			file write dofile `"cap replace `fieldnameval'="`valueval'" if key=="`keyval'""' _n
			file write dofile `"if _rc ~= 0 {"' _n
			if "`valueval'" == "" {
				file write dofile _tab `"cap replace `fieldnameval'=. if key=="`keyval'""' _n
			}
			else {
				file write dofile _tab `"cap replace `fieldnameval'=`valueval' if key=="`keyval'""' _n
			}
			file write dofile _tab `"if _rc ~= 0 {"' _n
			file write dofile _tab _tab `"disp"' _n
			file write dofile _tab _tab `"disp "CAN'T APPLY CORRECTION IN ROW #`rownumval'""' _n
			file write dofile _tab _tab `"disp"' _n
			file write dofile _tab `"}"' _n
			file write dofile `"}"' _n
		}
		file close dofile
	
		* restore primary data
		restore
		
		* execute the .do file to actually apply all corrections
		do "`tempdo'"

		* re-save data
		save "`dtafile'", replace
	}
	else {
		* restore primary data		
		restore
	}

	disp
	disp "Finished applying corrections in: `corrfile'"
	disp
}


