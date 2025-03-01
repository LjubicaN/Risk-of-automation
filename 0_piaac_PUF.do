clear
set more off

* Optional - may help if you are experiencing connectivity issues
	set timeout1 90
	set timeout2 360

* Set the path to your working directory
	loc pwd "C:\Users..."

* Define locals with country names (corresponding to available country files)	
	* these provide 4-dig ISCO information
	loc list1 bel /*cyp*/ cze dnk esp fra gbr ita jpn kor nld nor pol rus svk chl grc isr ltu nzl svn tur
	* these provide 2-dig ISCO information:
	loc list2 usa deu irl swe sgp
	* these do not provide ISCO information
	loc list_allmiss aut can est fin
	disp wordcount("`list1'")
	disp wordcount("`list2'")
	disp wordcount("`list_allmiss'")
	
* Keep relevant variables for country list 1 (these provide 4-dig ISCO information)
foreach n in `list1'{ 
	insheet using "https://webfs.oecd.org/piaac/puf-data/CSV/prg`n'p1.csv", clear
	
	keep cntryid* isco08_c isco08_l isco2c isco2l isic2c isic2l spfwt0 f_q06c earnhrbonusppp edwork d_q05a2 ///
	d_q10_c d_q10 ictwork_wle_ca icthome_wle_ca c_d05 edcat* age_r b_q01b vet gender_r c_q09_c edlevel3 ///
	f_q05a f_q05b g_q03g g_q03h f_q02b f_q03b f_q04a f_q04b f_q02d f_q02e f_q01b f_q02a d_q10* ageg5lfs
	
	foreach var of varlist _all{
		cap destring `var', replace force
	}	
	
	tempfile temp_`n'
	save `temp_`n''
}

* Keep relevant variables for country list 2 (these provide 2-dig ISCO information)
foreach n in `list2'{ 
	if "`n'" == "usa"{
	insheet using "https://webfs.oecd.org/piaac/puf-data/CSV/prg`n'p1_2012.csv", clear
	}
	else{
	insheet using "https://webfs.oecd.org/piaac/puf-data/CSV/prg`n'p1.csv", clear
	}
	keep cntryid* isco2c isco2l isic2c isic2l spfwt0 f_q06c earnhrbonusppp edwork d_q05a2 ///
	d_q10_c d_q10 ictwork_wle_ca icthome_wle_ca c_d05 edcat* age_r b_q01b vet gender_r c_q09_c edlevel3 ///
	f_q05a f_q05b g_q03g g_q03h f_q02b f_q03b f_q04a f_q04b f_q02d f_q02e f_q01b f_q02a d_q10* ageg5lfs
	
	foreach var of varlist _all{
		cap destring `var', replace force
	}	
	tempfile temp_`n'
	save `temp_`n''
}

* Keep relevant variables for country list allmiss (these do not provide ISCO information)
foreach n in `list_allmiss'{ 
	insheet using "https://webfs.oecd.org/piaac/puf-data/CSV/prg`n'p1.csv", clear
	
	keep cntryid* isic2c isic2l spfwt0 f_q06c earnhrbonusppp edwork d_q05a2 ///
	d_q10_c d_q10 ictwork_wle_ca icthome_wle_ca c_d05 edcat* age_r b_q01b vet gender_r c_q09_c edlevel3 ///
	f_q05a f_q05b g_q03g g_q03h f_q02b f_q03b f_q04a f_q04b f_q02d f_q02e f_q01b f_q02a d_q10* ageg5lfs
	
	foreach var of varlist _all{
		cap destring `var', replace force
	}	
	tempfile temp_`n'
	save `temp_`n''
}

foreach n in `list1'{ 
	append using `temp_`n''
}
foreach n in `list2'{
	append using `temp_`n''
}
foreach n in `list_allmiss'{ 
	disp "`n'"
	append using `temp_`n''
}

do "`pwd'/01_varlabels_piaac.do"
do "`pwd'/02_piaacvallab.do"
label val cntryid		   CNTRYID
label val isco08_c         isco08
label val isco08_l         isco08
label val isco2c           isco2c
label val isic2c           isicrev4
label val isic2l           isicrev4   
label val edwork           edwork
label val ictwork_wle_ca   ca
label val icthome_wle_ca   ca
label val c_d05            c_d05
label val edcat6           edcat6
label val edcat7           edcat7
label val edcat8           edcat8
label var edlevel3		   EDLEVEL3
label val b_q01b           major
label val vet              VET
label val gender_r         GENDER_R
label val f_q06c           F_Q06C 
label val f_q05a           F_Q05A 
label val f_q05b           F_Q05B 
label val g_q03g           G_Q03G 
label val g_q03h           G_Q03H 
label val f_q02b           F_Q02B 
label val f_q03b           F_Q03B 
label val f_q04a           F_Q04A 
label val f_q04b           F_Q04B 
label val f_q02d           F_Q02D 
label val f_q02e           F_Q02E 
label val f_q01b           F_Q01B 
label val f_q02a           F_Q02A 
label val ageg5lfs		   AGEG5LFS

// basic variables
	clonevar whours = d_q10_c if d_q10<.
// integer weight
	gen fweight = round(spfwt0, 1)

// PREPARE ANALYSIS OF AUTOMATABILITY 

// O*NET -> ISCO 2008 conversion 
	do "`pwd'/03_foclass.do"

// FO variables
	*** perception & manipulation
	clonevar dextrity_fo = f_q06c if f_q06c < .
	* missing: manual dextrity, awkward positions 
	* faulty: finger work is not same as finger dextriry

	*** creative intelligence
	clonevar psolve1_fo = f_q05a if f_q05a < .
	clonevar psolve2_fo = f_q05b if f_q05b < .
	clonevar math1_fo = g_q03g if g_q03g <.
	clonevar math2_fo = g_q03h if g_q03h <.
	* missing: originality, arts

	*** social intelligence
	clonevar teach_fo = f_q02b if f_q02b < .
	clonevar planothers_fo = f_q03b if f_q03b <.
	clonevar influence_fo = f_q04a if f_q04a < .
	clonevar negotiate_fo = f_q04b if f_q04b < .
	clonevar sell_fo = f_q02d if f_q02d < .
	clonevar advise_fo = f_q02e if f_q02e < .
	clonevar cooperate_fo = f_q01b if f_q01b < .
	clonevar communic_fo = f_q02a if f_q02a < .
	* missing: medical care, providing personal assistance/care
	
// Predict automatability
	* RISK OF AUTOMATION (FROM NEDELKOSKA AND QUINTINI 2018)
	gen pr_fo = 1/(1+exp(-(0.363 + 0.105*dextrity_fo + 0.0573*psolve1_fo - 0.0691*psolve2_fo ///
	- 0.0691*teach_fo - 0.308*planothers_fo - 0.235*influence_fo + 0.0463*negotiate_fo ///
	+ 0.160*sell_fo - 0.199*advise_fo + 0.214*communic_fo)))
	label var pr_fo "Risk of automation as estimated in Nedelkoska and Quintini (2018)"	
compress	
save "`pwd'/0_piaac_PUF.dta", replace

