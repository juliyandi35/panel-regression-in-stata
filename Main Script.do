* Sebelum run script ini, sesuaikan dulu cd dengan alamat folder yang ada di perangkat
cd "D:/Kerjaan/Research Consultant/Project Panel Regression in STATA"

*-----------------------------------------------*
* 1. Import data dari Excel
*-----------------------------------------------*
import excel using "Tabel Perhitungan Data Sekunder Skripsi Terbaru 1.xlsx", sheet("Tabel Perhitungan (2)") firstrow clear

*-----------------------------------------------*
* 2. Deskriptif Statistik
*-----------------------------------------------*
summarize TobinsQ GreenhouseGasEmission EnvironmentalPerformance FinancialFlexibility FirmSize Leverage, detail

*-----------------------------------------------*
* 3. Transformasi log (jika perlu)
*-----------------------------------------------*
gen log_TQ = log(TobinsQ)
gen log_GGE = log(GreenhouseGasEmission)
gen log_EP = log(EnvironmentalPerformance)
gen log_FF = log(FinancialFlexibility)
gen log_FS = log(FirmSize)
gen log_L = log(Leverage)

*-----------------------------------------------*
* 5. Set data sebagai panel
*-----------------------------------------------*
xtset ID Tahun

*-----------------------------------------------*
* 6. Pooled OLS (CEM - Common Effect Model)
*-----------------------------------------------*
regress log_TQ log_GGE log_EP log_FF log_FS log_L
estimates store cem

* Simpan residual untuk diagnostik
predict resid_pooled, residuals

*-----------------------------------------------*
* 7. Diagnostik Model
*-----------------------------------------------*

*-----------------------------------------------*
* A. Normalitas residual (dari pooled OLS)
*-----------------------------------------------*
swilk resid_pooled
sktest resid_pooled

*-----------------------------------------------*
* B. Heteroskedastisitas (Breusch-Pagan dari pooled OLS)
*-----------------------------------------------*
estat hettest

*-----------------------------------------------*
* C. Multikolinearitas (dari pooled OLS)
*-----------------------------------------------*
vif

*-----------------------------------------------*
* D. Autokorelasi — Gunakan model panel: Uji Wooldridge
*-----------------------------------------------*
* Catatan: Durbin-Watson tidak dapat digunakan di data panel
* Gantilah dengan uji Wooldridge: 
* ssc install xtserial, replace 
 
xtserial log_TQ log_GGE log_EP log_FF log_FS log_L

*-----------------------------------------------*
* 8. Fixed Effect Model (FEM)
*-----------------------------------------------*
xtreg log_TQ log_GGE log_EP log_FF log_FS log_L, fe
estimates store fem

*-----------------------------------------------*
* 9. Random Effect Model (REM)
*-----------------------------------------------*
xtreg log_TQ log_GGE log_EP log_FF log_FS log_L, re
estimates store rem

*-----------------------------------------------*
* 10. Uji Chow: Pooled OLS vs FEM
*-----------------------------------------------*
* Chow test ≈ test untuk fixed effect signifikan cukup dengan melihat nilai F test that all u_i =0 pada model fem, jika < 0,05 maka pilih FEM

*-----------------------------------------------*
* 11. Uji Hausman: FEM vs REM
*-----------------------------------------------*
hausman fem rem

*-----------------------------------------------*
* 12. Uji Breusch-Pagan LM test: CEM vs REM
*-----------------------------------------------*
xtreg log_TQ log_GGE log_EP log_FF log_FS log_L, re
xttest0

save "Final Dataset.dta", replace

