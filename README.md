# Prova Finale di Reti Logiche (2018)
## Scelte progettuali

<p align="justify">Il seguente progetto è stato inizialmente pensato e ideato con due process distinti: uno per il registro degli stati, l’altro per la funzione vera e propria della FSM. Il progetto iniziale prevedeva il superamento dei principali testbench (non delay) solo in modalità comportamentale (behavioral). Successivamente il modulo è stato completamente rivisto, nella struttura (da due si è passato a un singolo clocked process per evitare inferred latches in sintesi, signals al posto di variabili per un migliore debugging) e nella logica (if statements e aritmetica non correttamente implementati).
La revisione del progetto supera tutti i testbench pubblici (delay e non). In più è sintetizzabile con successo, supera tutti i test in “post-synthesis functional” e “post-synthesis timing”, è implementabile e supera i test in “post-implementation functional” e “post-implementation timing”.
Il sorgente in VHDL è stato inoltre riformattato automaticamente tramite un tool per garantire una migliore leggibilità.</p>

<p align="center"><a rel="license" href="http://creativecommons.org/licenses/by-nc-nd/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-nc-nd/4.0/88x31.png" /></a></p>
