# Eclettica - Archiviazione Disegni

Applicazione desktop e mobile sviluppata in Flutter per l'elaborazione batch, il raddrizzamento automatico dell'orientamento e l'archiviazione organizzata di disegni e fotografie tecniche per calzature.

Il sistema sfrutta modelli Vision AI per rilevare l'angolo di rotazione (0°, 90°, 180°, 270°) e trascrivere le sigle del modello (es. `MARV 366/1`, `marq 63`), catalogando automaticamente i file in cartelle suddivise per autore e stagione.

---

## Funzionalità Principali

- **Riconoscimento e Trascrizione AI**: Analisi automatica delle immagini con rilevamento di orientamento e sigle modello.
- **Raddrizzamento Fisico dell'Immagine**: Rotazione a livello di file immagine prima del salvataggio.
- **Catalogazione per Autore e Stagione**:
  - Mappatura personalizzabile delle sigle autore (es. `MAR` → `MARIANNA`).
  - Smistamento automatico in `[DESTINAZIONE]/[AUTORE]/[STAGIONE]/[CODICE_NORMALIZZATO].jpg`.
  - Instradamento automatico dei file non codificati o senza corrispondenza nella cartella `sconosciuti/`.
- **Elaborazione Concorrente**: Gestione parallela delle richieste con ridimensionamento preventivo per ottimizzare tempi di risposta e consumi di rete.
- **Report di Archiviazione**: Generazione automatica di un report CSV con riepilogo dettagliato di tutte le operazioni eseguite.
- **Modalità Sviluppatore Protetta**: Vista di ispezione avanzata protetta da PIN per visualizzazione anteprime, rotazione manuale e modifica dei codici.

---

## Requisiti

- **Flutter SDK**: 3.24 o superiore
- **Piattaforma target principale**: macOS (supporto desktop) / iOS / Android / Windows
- **Google Gemini API Key**: Necessaria per il servizio di visione e analisi delle immagini

---

## Installazione e Avvio

1. Clona il repository:
   ```bash
   git clone https://github.com/joshuagottardo/eclettica-archiviazione-disegno.git
   cd eclettica-archiviazione-disegno
   ```

2. Installa le dipendenze:
   ```bash
   flutter pub get
   ```

3. Avvia l'applicazione su macOS:
   ```bash
   flutter run -d macos
   ```

---

## Configurazione

All'avvio dell'applicazione, apri la sezione **Impostazioni**:
1. Inserisci la tua **Chiave API Google Gemini**.
2. Seleziona la **Cartella di Destinazione** per l'archivio.
3. Configura le corrispondenze nella sezione **Autori** (es. `MAR` → `MARIANNA`).

Tutte le impostazioni vengono salvate localmente e mantenute tra i riavvii dell'app.
