# KixFit - Release State v0.6 🏋️

## Pregled verzije
Ova verzija uvodi puni **Gym Tracking modul** inspiriran aplikacijama poput *Strong*, omogućujući korisnicima planiranje, izvođenje i praćenje treninga uz podršku Gemini AI generatora trening splita s personaliziranim ručnim fokusom.

---

## 💎 Ključne Nove Funkcionalnosti

### 1. 🏋️ Strong-Like Gym Tracker
*   **Aktivni trening**: Pokretanje treninga iz spremljenih predložaka (splita) ili "Praznog treninga" (Empty Workout).
*   **Praćenje serija i ponavljanja**: Bilježenje kilograma (KG) i ponavljanja (Reps) za svaku seriju s intuitivnim kvačicama za označavanje završenih serija.
*   **Dodavanje i uklanjanje**: Dinamičko dodavanje vježbi iz baze, dodavanje novih serija ili brisanje serija povlačenjem (Swipe-to-dismiss).
*   **Tajmer u realnom vremenu**: Aktivno praćenje trajanja treninga izravno u zaglavlju ekrana.

### 2. ⚡ AI Generator Treninga (Snažniji & Privlačniji)
*   **Ručni opis fokusa**: Korisnik može upisati vlastiti opis cilja (npr. *"kombinacija snage i hipertrofije, fokus na gornji dio tijela i ramena"*), što omogućuje potpunu fleksibilnost izvan standardnih kategorija.
*   **Pametna sinkronizacija s prehranom**: AI prilagođava volumen (broj serija i ponavljanja) ovisno o tome je li korisnik u kalorijskom deficitu (mršavljenje) ili suficitu (izgradnja mišića) prema profilu.
*   **Moderni vizuali**: UI je obogaćen premium ikonama i emotikonima (`🏋️`, `💪`, `🔥`, `🧘`, `⚡`) za privlačniji izgled.

### 3. 📊 Napredna Statistika Treninga
*   **Ukupni Volumen (Podignuta kilaža)**: Automatski izračun ukupnog volumena (KG × Reps) za svaku vježbu i cijeli trening.
*   **Potrošene kalorije (Calories Burned)**: Precizna procjena potrošnje kalorija na temelju trajanja treninga, tjelesne težine korisnika i intenziteta vježbi.
*   **Povijest treninga**: Pregled svih odrađenih treninga s datumom, trajanjem, volumenom i potrošenim kalorijama.

---

## 🛠️ Tehnički detalji
*   **Verzija**: 0.6
*   **Novi moduli**: `gym_tracking` (domain entities, state providers, UI screens).
*   **State Management**: `GymNotifier` i `ActiveWorkoutNotifier` pogonjeni Riverpod-om za reaktivno i stabilno praćenje stanja.
*   **Lokalna pohrana**: Integracija s `GymRepository` za spremanje predložaka i povijesti treninga.
*   **AI Integracija**: Gemini 2.5 Flash API s optimiziranim strukturiranim JSON promptom na hrvatskom jeziku.
