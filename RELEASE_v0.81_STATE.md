# KixFit - Release State v0.81 🚀🛠️

## Pregled verzije
Ova verzija (v0.81) donosi ispravke korisničkog sučelja (UI) i poboljšanja u modulima za teretanu te generiranje AI treninga kako bi se osiguralo glađe i intuitivnije korisničko iskustvo.

---

## 💎 Ključne Nove Funkcionalnosti i Ispravci

### 1. ⚙️ Cijeli brojevi (KG) za težine u serijama
*   **Bez nepotrebnih decimala**: Težine u aktivnom treningu (`ActiveWorkoutScreen`) i predlošcima (`TemplateFormScreen`) sada se prikazuju kao cijeli brojevi (npr. `75` umjesto `75.0`).
*   **Podrška za decimalne vrijednosti**: Korisnik i dalje može unijeti decimalne brojeve (npr. `75.5`), a aplikacija će ih ispravno spremiti i prikazati samo ako imaju decimalni dio.
*   **Fiksirana pozicija kursora**: Unosi se više ne resetiraju pri svakom koraku unosa, čime je tipkanje znatno ugodnije.

### 2. 📱 Prilagodba tipkovnice u AI Generatoru
*   **Skrolajući prozor (Bottom Sheet)**: Cijeli panel za AI generiranje treninga je omotan u `SingleChildScrollView`.
*   **Dinamički odmaci**: Korištenjem `MediaQuery.of(context).viewInsets.bottom` panel se automatski pomiče prema gore kada se pojavi tipkovnica. Polja za ručni unos (poput fokusa treninga) više nisu prekrivena tipkovnicom.

### 3. 📐 Riješeno prelamanje stupca "SERIJA"
*   **Optimalna širina**: Širina stupca za brojanje serija povećana je s `40` na `50` u tablicama treninga i predložaka. Riječ "SERIJA" sada stane u jedan redak bez prelamanja slova "A".

---

## 🛠️ Tehnički detalji i Build
*   **Verzija**: 0.81
*   **APK datoteka**: `KixFit_v0.81.apk` (~22.4MB)
*   **Status grane**: Sve promjene su uspješno spajane na `master` granu i sinkronizirane s remote repozitorijem.
