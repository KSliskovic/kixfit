# KixFit - Release State v0.8 🏋️‍♂️✨

## Pregled verzije
Ova verzija pretvara KixFit u sveobuhvatan fitness ekosustav spajanjem naprednog praćenja prehrane s moćnim modulom za trening snage u stilu poznate aplikacije **Strong**, uključujući prilagodbu spola i AI inteligenciju.

---

## 💎 Ključne Nove Funkcionalnosti

### 1. 🦾 Strong-Style Gym Tracker
Uveden je potpuno novi modul za bilježenje treninga i praćenje fizičkog napretka:
*   **Aktivni Trening**: Ekran s tekućim vremenom, mogućnošću dodavanja vježbi u hodu, bilježenjem kilograma i ponavljanja (serija), te kvačicama za dovršene setove.
*   **Pametna štoperica i pauza**: Tajmer je integriran u pozadinski provider. Kada stisnete pauzu i izađete iz ekrana, tajmer ostaje zamrznut i nastavlja točno tamo gdje ste stali kada se vratite ili kliknete Nastavi.
*   **Automatsko spašavanje**: Čak i ako korisnik zaboravi kliknuti kvačicu za završetak, aplikacija osigurava da se trening ispravno spremi u povijest.
*   **Metrike Napretka**: Prati se ukupni volumen podignutih kilograma, potrošnja kalorija i trajanje svakog treninga.

### 2. 📂 Kategorizacija Programa (Osobni vs AI Splits)
Kako bi se spriječilo gomilanje i miješanje različitih splitova:
*   **Odvojeni Tabovi**: Dashboard sada ima vizualno atraktivan tab selektor za "Osobne programe" i "AI Programi".
*   **Fiksirana veličina boksova**: Prazna stanja (empty states) su fiksirana na istu visinu kako bi prebacivanje između tabova bilo glatko, bez skakanja layouta.
*   **Dinamički akcijski gumbi**: Gumb plus (`+`) za ručno kreiranje prikazuje se samo na osobnim programima, dok se gumb zvjezdice (`auto_awesome`) za generiranje novih AI splitova prikazuje samo na AI tabu.

### 3. 🧹 Upravljanje Vlastitim Vježbama
*   **Brisanje custom vježbi**: Vlastite kreirane vježbe se više neće gomilati. Dodana je ikona kante za smeće u biblioteci vježbi i u prozoru za odabir (picker) koja omogućuje trajno brisanje custom vježbi uz potvrdu.
*   **Filtri pri odabiru**: Prilikom odabira vježbi u trening dodani su brzi filtri za mišićne skupine i opremu (Dumbbell, Barbell, itd.).

### 4. 👩‍❤️‍👨 Prilagodba Pitanja Prema Spolu
Aplikacija je u potpunosti jezično prilagođena spolu korisnika na hrvatskom jeziku (npr. "Što si danas pojela?" za ženski spol i "Što si danas pojeo?" za muški).

---

## 🛠️ Tehnički detalji i Build
*   **Verzija**: 0.8
*   **APK datoteka**: `KixFit_v0.8.apk` (~22MB, optimizirana za arm64-v8a arhitekturu).
*   **Sustav**: Flutter / Riverpod
*   **Baza**: Cloud Firestore (zasebne sub-kolekcije za custom_exercises, workout_templates i workout_sessions).
