# Report Analisi CRM Sales Pipeline

## Contesto

Questo progetto analizza i dati di un CRM commerciale di un'azienda che vende prodotti tecnologici (serie GTX, MG, GTK). I dati coprono le opportunità commerciali gestite dal team vendite, con informazioni su clienti, prodotti, venditori e stato delle trattative.

Il dataset include circa 8.800 opportunità, 85 aziende clienti, 7 prodotti e 35 sales agent distribuiti su 3 uffici regionali (Central, East, West).

Lo scopo dell'analisi è rispondere a domande di business concrete: quanto vale la pipeline? Chi vende meglio? Quali prodotti convertono di più? Dove si bloccano i deal?


## Domande di business

Le domande a cui ho cercato di rispondere sono:

1. Qual è il valore totale della pipeline e quante opportunità abbiamo?
2. Qual è il nostro win rate complessivo?
3. Quali venditori e team performano meglio?
4. Quali prodotti generano più valore e hanno win rate migliore?
5. Chi sono i nostri clienti principali?
6. Quanto tempo ci vuole mediamente per chiudere un deal?
7. Ci sono deal bloccati da troppo tempo?
8. Quali settori o tipi di azienda convertono meglio?


## Metodologia

Ho usato SQL (MySQL) per tutte le analisi. Ho strutturato le query in sezioni logiche, partendo da controlli di qualità sui dati e poi passando ad analisi sempre più specifiche.

Ho utilizzato:
- Aggregazioni (COUNT, SUM, AVG)
- JOIN tra le tabelle per incrociare dati venditori, clienti e prodotti
- CASE WHEN per calcolare metriche condizionali come il win rate
- CTE (WITH) dove serviva isolare calcoli intermedi
- Funzioni data per analisi temporali e calcolo giorni apertura deal

Dove i campi erano nulli (es. deal ancora aperti senza close_date), ho gestito i casi con filtri appropriati.


## Risultati principali

### 1. Overview pipeline

La pipeline contiene poco meno di 9.000 opportunità. Il valore totale dei deal vinti è nell'ordine di diversi milioni di dollari. Il valore medio per deal vinto si aggira intorno ai 2.000-3.000 dollari, ma c'è molta variabilità in base al prodotto.

### 2. Win rate

Il win rate complessivo (deal vinti su deal chiusi) è intorno al 63-65%. È un buon risultato, ma significa che perdiamo comunque circa un terzo delle opportunità che portiamo avanti. Capire perché le perdiamo potrebbe essere un passo successivo.

### 3. Performance venditori

C'è una variabilità significativa tra i venditori. I top performer generano valore 3-4 volte superiore rispetto ai venditori nella fascia bassa. Alcuni venditori hanno win rate sopra il 70%, altri sotto il 55%.

L'ufficio West sembra performare leggermente meglio in termini di win rate, ma il volume maggiore viene dall'ufficio Central. Questo potrebbe dipendere da come sono distribuiti i territori o i clienti.

### 4. Prodotti

I prodotti della serie GTX (in particolare GTX Plus Pro e GTXPro) generano la maggior parte del valore, ma hanno anche prezzi di listino più alti. La serie MG ha volumi elevati ma valori unitari bassi.

Il prodotto GTK 500 ha un prezzo molto alto (circa 27.000) ma compare raramente nei dati, probabilmente è un prodotto enterprise venduto a pochi clienti selezionati.

### 5. Top clienti

I primi 5-10 clienti pesano in modo significativo sul valore totale vinto. Questo è tipico nel B2B ma rappresenta anche un rischio: perdere uno di questi clienti avrebbe un impatto importante.

Tra i settori, retail e technology sembrano i più rappresentati nel portafoglio clienti.

### 6. Tempi di chiusura

Il tempo medio per chiudere un deal (da engage a close) è di circa 100-130 giorni. I deal persi tendono ad avere tempi simili o leggermente più lunghi rispetto ai deal vinti, il che suggerisce che non vengono abbandonati velocemente.

### 7. Deal bloccati

Ci sono diverse opportunità in stato Prospecting o Engaging aperte da oltre 90 giorni. Queste andrebbero riviste: potrebbero essere deal "zombie" da chiudere come persi o opportunità che richiedono un'azione commerciale specifica.

### 8. Segmentazioni

I clienti del settore retail generano molto valore, seguiti da technology. Le aziende di dimensioni medie (500-2000 dipendenti) sembrano avere un buon equilibrio tra volume deal e valore medio.


## Limitazioni

Alcune cose che non posso sapere con questi dati:

- Non ho informazioni sul motivo delle perdite (lost reason)
- Non so se ci sono stati sconti rispetto al prezzo di listino
- Non ho dati sui costi o margini, quindi parlo solo di revenue
- I dati coprono un periodo specifico (2016-2017), non so se i pattern sono stabili nel tempo
- Non ho informazioni sulle attività commerciali (email, call, meeting) che potrebbero spiegare le performance


## Prossimi passi

Se questo fosse un progetto reale in azienda, suggerirei:

1. Aggiungere un campo lost_reason nel CRM per capire perché perdiamo i deal. Senza questo dato posso solo dire "abbiamo perso", non "perché abbiamo perso"
2. Impostare un report settimanale sui deal bloccati da più di 60 giorni, da mandare ai manager
3. Approfondire i top 10 clienti: capire se ci sono pattern comuni, se possiamo replicare il successo su clienti simili
4. Parlare con il team vendite per validare i numeri. I dati dicono una cosa, ma magari ci sono contesti che non conosco
