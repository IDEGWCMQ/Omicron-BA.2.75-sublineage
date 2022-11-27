use Data

gen CaseControl=1 if result==1 & seqPos==1 & StudyPeriod==1
replace CaseControl=0 if result==0 & seqNeg~=. & StudyPeriod==1
label define CaseControl 1"Positive test" 0"Negative test"
label value CaseControl CaseControl

gen InfType1=0 if TestDate1<td(19dec2021) & StudyPeriod==0
replace InfType1=1 if TestDate1>=td(19dec2021) & StudyPeriod==0
label define InfType1 0"Pre-Omicron" 1"Omicron"
label values InfType1 InfType1

gen InfType2=0 if TestDate2<td(19dec2021) & StudyPeriod==0
replace InfType2=1 if TestDate2>=td(19dec2021) & StudyPeriod==0
label define InfType2 0"Pre-Omicron" 1"Omicron"
label values InfType2 InfType2

gen PriorInfType=1 if InfType1==0 & InfType2==0
replace PriorInfType=2 if InfType1==1 & InfType2==1
replace PriorInfType=3 if InfType1==1 & InfType2==0
replace PriorInfType=0 if PriorInfType==.
label define PriorInfType 0"No prior infection" 1"Pre-Omicron" 2"Omicron" 3"Pre-Omicron & Omicron"
label values PriorInfType PriorInfType

gen VaccineDose=4 if Dose4<TestDate & Dose4~=.
replace VaccineDose=3 if Dose3<TestDate & Dose3~=. & VaccineDose==.
replace VaccineDose=2 if Dose2<TestDate & Dose2~=. & VaccineDose==.
replace VaccineDose=1 if Dose1<TestDate & Dose1~=. & VaccineDose==.
replace VaccineDose=0 if VaccineDose==.
label define VaccineDose 0"Unvaccinated" 1"1 dose" 2"2 doses" 3"3 doses" 4"4 doses"
label values VaccineDose VaccineDose

recast int Sex Age Nationality ComorbCount Assay reasonfortesting VaccineDose WeekNumber
calipmatch in 1/489462, gen(match_id) casevar(CaseControl) maxmatches(5) calipermatch(Sex Age Nationality ComorbCount Assay reasonfortesting VaccineDose WeekNumber) caliperwidth(2 8 200 4 2 9 5 6) exactmatch(Sex Age Nationality ComorbCount Assay reasonfortesting VaccineDose WeekNumber) 

drop if match_id==.

gen Exposure=1 if PriorInfType>=1
replace Exposure=0 if PriorInfType==0
label define Exposure 0"No prior infection" 1"Prior infection"
label values Exposure Exposure

gen ExposurePreOm=1 if PriorInfType==1
replace ExposurePreOm=0 if PriorInfType==0
label define ExposurePreOm 0"No prior infection" 1"Pre-Omicron"
label values ExposurePreOm ExposurePreOm

gen ExposureOm=1 if PriorInfType==2
replace ExposureOm=0 if PriorInfType==0
label define ExposureOm 0"No prior infection" 1"Omicron"
label values ExposureOm ExposurePreOm

gen ExposureBA4BA5=1 if PriorInfType==2 & TestDate2>=td(08jun2022) & TestDate2<=td(09sep2022)
replace ExposureBA4BA5=0 if PriorInfType==0
label define ExposureBA4BA5 0"No prior infection" 1"BA4BA5"
label values ExposureBA4BA5 ExposureBA4BA5

gen ExposureBA1BA2=1 if PriorInfType==2 & TestDate2>=td(19dec2021) & TestDate2<=td(07jun2022)
replace ExposureBA1BA2=0 if PriorInfType==0
label define ExposureBA1BA2 0"No prior infection" 1"BA1BA2"
label values ExposureBA1BA2 ExposureBA1BA2

gen ExposureMix=1 if PriorInfType==3
replace ExposureMix=0 if PriorInfType==0
label define ExposureMix 0"No prior infection" 1"Pre-Omicron & Omicron"
label values ExposureMix ExposureMix

gen ExposureMixBA1BA2=1 if PriorInfType==3 & TestDate2>=td(19dec2021) & TestDate2<=td(07jun2022)
replace ExposureMixBA1BA2=0 if PriorInfType==0
label define ExposureMixBA1BA2 0"No prior infection" 1"Pre-Omicron & BA1BA2 Omicron"
label values ExposureMixBA1BA2 ExposureMixBA1BA2

gen ExposureMixBA4BA5=1 if PriorInfType==3 & TestDate2>=td(08jun2022) & TestDate2<=td(09sep2022)
replace ExposureMixBA4BA5=0 if PriorInfType==0
label define ExposureMixBA4BA5 0"No prior infection" 1"Pre-Omicron & Omicron BA4BA5"
label values ExposureMixBA4BA5 ExposureMixBA4BA5

cc CaseControl Exposure
clogit CaseControl i.Exposure, group(match_id) or
di 1-OR
cc CaseControl ExposurePreOm
clogit CaseControl i.ExposurePreOm, group(match_id) or
di 1-OR
cc CaseControl ExposureOm
clogit CaseControl i.ExposureOm, group(match_id) or
di 1-OR
cc CaseControl ExposureMix
clogit CaseControl i.ExposureMix, group(match_id) or
di 1-OR
cc CaseControl ExposureBA4BA5
clogit CaseControl i.ExposureBA4BA5, group(match_id) or
di 1-OR
cc CaseControl ExposureBA1BA2
clogit CaseControl i.ExposureBA1BA2, group(match_id) or
di 1-OR
cc CaseControl ExposureMixBA4BA5
clogit CaseControl i.ExposureMixBA4BA5, group(match_id) or
di 1-OR
cc CaseControl ExposureMixBA1BA2
clogit CaseControl i.ExposureMixBA1BA2, group(match_id) or
di 1-OR

gen check00=TestDate-TestDate2 if Exposure~=. & TestDate2~=.
bys CaseControl: summ check00, detail

gen check1=TestDate-TestDate1 if ExposurePreOm~=. & TestDate1~=.
bys CaseControl: summ check1, detail

gen check2=TestDate-TestDate2 if ExposureOm~=. & TestDate2~=.
bys CaseControl: summ check2, detail

gen check3=TestDate-TestDate2 if ExposureMix~=. & TestDate2~=.
bys CaseControl: summ check3, detail

gen check4=TestDate-TestDate2 if ExposureBA4BA5~=. & TestDate2>=td(08jun2022) & TestDate2<=td(09sep2022)
bys CaseControl: summ check4, detail

gen check5=TestDate-TestDate2 if ExposureBA1BA2~=. & TestDate2>=td(19dec2021) & TestDate2<=td(07jun2022)
bys CaseControl: summ check5, detail

gen check6=TestDate-TestDate2 if ExposureMixBA4BA5~=. & TestDate2>=td(08jun2022) & TestDate2<=td(09sep2022)
bys CaseControl: summ check6, detail

gen check7=TestDate-TestDate2 if ExposureMixBA1BA2~=. & TestDate2>=td(19dec2021) & TestDate2<=td(07jun2022)
bys CaseControl: summ check7, detail

gen TimePrior=1 if check00<=240 & check00~=.
replace TimePrior=2 if check00>240 & check00<=480
replace TimePrior=3 if check00>480 & check00~=.
label define TimePrior 1"<=8 months" 2"9-16 months" 3">16 months"
label values TimePrior TimePrior

gen WaningPrior1=1 if PriorInfType>=1 & TimePrior==1 & PriorInfType~=.
replace WaningPrior1=0 if PriorInfType==0
gen WaningPrior2=1 if PriorInfType>=1 & TimePrior==2 & PriorInfType~=.
replace WaningPrior2=0 if PriorInfType==0
gen WaningPrior3=1 if PriorInfType>=1 & TimePrior==3 & PriorInfType~=.
replace WaningPrior3=0 if PriorInfType==0

label define WaningPrior1 0"No prior infection" 1"<=8 months"
label define WaningPrior2 0"No prior infection" 1"9-16 months"
label define WaningPrior3 0"No prior infection" 1">16 months"

label values WaningPrior1 WaningPrior1
label values WaningPrior2 WaningPrior2
label values WaningPrior3 WaningPrior3

cc CaseControl WaningPrior1
clogit CaseControl i.WaningPrior1, group(match_id) or
cc CaseControl WaningPrior2
clogit CaseControl i.WaningPrior2, group(match_id) or
cc CaseControl WaningPrior3
clogit CaseControl i.WaningPrior3, group(match_id) or

bys CaseControl TimePrior: summ check00, detail

gen TimePreOm=1 if check1<=480 & check1~=.
replace TimePreOm=2 if check1>480 & check1<=720
replace TimePreOm=3 if check1>720 & check1~=.
label define TimePreOm 1"<=16 months" 2"17-24 months" 3">24 months"
label values TimePreOm TimePreOm
 
gen WaningPreOm1=1 if PriorInfType==1 & TimePreOm==1
replace WaningPreOm1=0 if PriorInfType==0
gen WaningPreOm2=1 if PriorInfType==1 & TimePreOm==2
replace WaningPreOm2=0 if PriorInfType==0
gen WaningPreOm3=1 if PriorInfType==1 & TimePreOm==3
replace WaningPreOm3=0 if PriorInfType==0

label define WaningPreOm1 0"No prior infection" 1"<=16 months"
label define WaningPreOm2 0"No prior infection" 1"17-24 months"
label define WaningPreOm3 0"No prior infection" 1">24 months"

label values WaningPreOm1 WaningPreOm1
label values WaningPreOm2 WaningPreOm2
label values WaningPreOm3 WaningPreOm3

cc CaseControl WaningPreOm1
clogit CaseControl i.WaningPreOm1, group(match_id) or
cc CaseControl WaningPreOm2
clogit CaseControl i.WaningPreOm2, group(match_id) or
cc CaseControl WaningPreOm3
clogit CaseControl i.WaningPreOm3, group(match_id) or

bys CaseControl TimePreOm: summ check1, detail

gen TimeOm=1 if check2<=180 & check2~=.
replace TimeOm=2 if check2>180 & check2~=.
label define TimeOm 1"<=6 months" 2">6 months"
label values TimeOm TimeOm
 
gen WaningOm1=1 if PriorInfType==2 & TimeOm==1 
replace WaningOm1=0 if PriorInfType==0
gen WaningOm2=1 if PriorInfType==2 & TimeOm==2
replace WaningOm2=0 if PriorInfType==0
gen WaningOm3=1 if PriorInfType==2 & TimeOm==3 
replace WaningOm3=0 if PriorInfType==0

label define WaningOm1 0"No prior infection" 1"<=6 months"
label define WaningOm2 0"No prior infection" 1">6 months"

label values WaningOm1 WaningOm1
label values WaningOm2 WaningOm2

cc CaseControl WaningOm1
clogit CaseControl i.WaningOm1, group(match_id) or
cc CaseControl WaningOm2
clogit CaseControl i.WaningOm2, group(match_id) or

bys CaseControl TimeOm: summ check2, detail

gen TimeMix=1 if check3<=180 & check3~=.
replace TimeMix=2 if check3>180 & check3~=.
label define TimeMix 1"<=6 months" 2">6 months"
label values TimeMix TimeMix
 
gen WaningMix1=1 if PriorInfType==3 & TimeMix==1
replace WaningMix1=0 if PriorInfType==0
gen WaningMix2=1 if PriorInfType==3 & TimeMix==2
replace WaningMix2=0 if PriorInfType==0
gen WaningMix3=1 if PriorInfType==3 & TimeMix==3
replace WaningMix3=0 if PriorInfType==0

label define WaningMix1 0"No prior infection" 1"<=6 months"
label define WaningMix2 0"No prior infection" 1">6 months"

label values WaningMix1 WaningMix1
label values WaningMix2 WaningMix2

cc CaseControl WaningMix1
clogit CaseControl i.WaningMix1, group(match_id) or
cc CaseControl WaningMix2
clogit CaseControl i.WaningMix2, group(match_id) or

bys CaseControl TimeMix: summ check3, detail

joinby hcno using Testing, unmatched(master)
drop id if TestingDate>TestDate & TestingDate~=.
gen newid=_N

by id: gen seq=seq()
keep if seq==1

gen Testers=0 if newid<=2
replace Testers=1 if newid>2 & newid<=6
replace Testers=2 if newid>=7
label define Testers 0"Low testers" 1"Intermediate testers" 2"High testers"
label values Testers Testers


clogit CaseControl i.Exposure i.Testers, group(match_id) or
di 1-OR
clogit CaseControl i.ExposurePreOm i.Testers, group(match_id) or
di 1-OR
clogit CaseControl i.ExposureOm i.Testers, group(match_id) or
di 1-OR
clogit CaseControl i.ExposureMix i.Testers, group(match_id) or
di 1-OR
clogit CaseControl i.ExposureBA4BA5 i.Testers, group(match_id) or
di 1-OR
clogit CaseControl i.ExposureBA1BA2 i.Testers, group(match_id) or
di 1-OR
clogit CaseControl i.ExposureMixBA4BA5 i.Testers, group(match_id) or
di 1-OR
clogit CaseControl i.ExposureMixBA1BA2 i.Testers, group(match_id) or
di 1-OR
