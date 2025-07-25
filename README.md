# r.autopres

## Apraksts

r.autopres ir R pakotne ar PowerPoint prezentāciju automatizācijas rīkiem. Pakotnes galvenais mērķis ir spēt atjaunot iegultos datus PowerPoint prezentāciju grafikos.

-   `replace_chart_data()` aizvieto esošos datus PowerPoint prezentācijas grafikā ar R datu tabulu.
-   `format_chart_data()` sagatavo R datu tabulas izmantošanai `replace_chart_data()`, ļaujot norādīt, kuras kolonnas ir kategorijas (x-ass; atbalsta vairāklīmeņu kategorijas), kuras kolonnas ir sērijas (y-ass) un datumu ass formātu.
-   `autoppt_format` ir `Rmarkdown` dokumentu formāts, kas ļauj strukturēt PowerPoint prezentācijas ar `Rmarkdown` palīdzību. Dokumentā printētās datu tabulas tiek ieliktas norādītās šablona prezentācijas iepriekš formatētos grafikos. Katrs dokumenta "chunk" atbilst vienam prezentācijas slaidam.

## Instalācija

PowerPoint prezentāciju grafiku datu aizvietošana balstās uz Python, tāpēc nepieciešams instalēt Python, `pandas` un `python-pptx` Python pakotnes un `reticulate` R pakotni. Lai RStudio atrastu Python instanci, `Tools > Global Options > Python` jāiestata `Python interpreter`.

``` r
#install.packages("remotes")
remotes::install_github("ajnikitins/r.autopres")
```

## Pateicības

-   Artūrs Jānis Ņikitins (pakotnes autors)
-   Latvijas Bankas kolēģiem
