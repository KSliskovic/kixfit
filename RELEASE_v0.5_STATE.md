# KixFit - Release State v0.5 🚀

## Pregled verzije
Ova verzija pretvara KixFit u sveobuhvatan sustav za upravljanje prehranom, uvodeći medicinski precizno praćenje i pametno istraživanje lokalne gastronomske ponude.

---

## 💎 Ključne Nove Funkcionalnosti

### 1. 🔍 AI Restaurant Finder (Next-Gen)
KixFit više nije samo za praćenje onoga što jedeš kod kuće. Sada ti pomaže pronaći zdrave opcije vani!
*   **AI Pretraga**: Unesi grad i odaberi kategoriju (npr. Bez glutena, High Protein, Fit hrana).
*   **Lokalni vodič**: AI pronalazi stvarne restorane, daje opise na hrvatskom i ocjenjuje njihovu "fit" razinu.
*   **Direktni linkovi**: Jednim klikom otvori web stranicu ili navigaciju do restorana putem Google Mapsa.
*   **Premium UI**: Novi modul s glassmorphism dizajnom i brzim filtrima.

### 2. 📊 10-točkovni Nutritivni Profil
Proširili smo AI analizu na ukupno 10 parametara za potpunu kontrolu zdravlja:
*   **Novi parametri**: Šećeri, Vlakna, Natrij, Zasićene masti, Kolesterol i Trans-masti.
*   **Interaktivni Dashboard**: Dugim pritiskom (Long-press) na kalorije otvara se detaljni prozor s vizualnim indikatorima.
*   **Pametni Savjeti**: Aplikacija ti sada daje savjete poput "Pazi na sol!" ili "Odličan unos vlakana!" u realnom vremenu.
*   **Minus za kalorije**: Ako premašiš dnevni limit, kalorije odlaze u minus (crvena boja) kako bi odmah vidio prekoračenje.

### 🎯 Dinamički Ciljevi (Personalizacija)
Nutritivni ciljevi se više ne pogađaju od oka. KixFit ih sada računa znanstveno prema tvom profilu:
*   **Sugar Limit**: Max 10% kalorija.
*   **Fiber Target**: 14g na svakih 1000 kcal.
*   **Saturated Fat**: Max 10% kalorija.
*   **Sodium/Cholesterol**: Prema standardima WHO-a.

---

## 🛠️ Tehnički detalji
*   **Verzija**: 0.5
*   **Branch Status**: feature/detailed-macros & feature/restaurant-finder spojeni u `master`.
*   **Model**: Gemini 2.5 Flash (nadograđen prompt za 10 parametara).
*   **Framework**: Flutter / Riverpod (migrirano na Notifier pattern za stabilnost).
*   **Dependencies**: Dodan `url_launcher` za vanjsku navigaciju.

---
*KixFit - Pametnije jelo, lakši život.*
