drop database if exists cardstore;
create database cardstore;
use cardstore;

CREATE TABLE `Utenti` (
  `username` varchar(20) PRIMARY KEY,
  `nome` varchar(20),
  `cognome` varchar(20),
  `email` varchar(30) NOT NULL,
  `telefono` int,
  `credito` float default 0,
  `paese` varchar(20)
);

CREATE TABLE `Copie` (
  `codice` int PRIMARY KEY auto_increment,
  `prezzo` float NOT NULL,
  `data_inizio_vendita` date,
  `carta` varchar(5),
  `grado` int,
  `venditore` varchar(20),
  `stato` varchar(20) default 'In vendita',
  `lingua` varchar(20)
);

CREATE TABLE `Carte` (
  `nome` varchar(20),
  `id` varchar(5) PRIMARY KEY,
  `rarità` int,
  `numero` int,
  `espansione` varchar(2),
  `illustratore` varchar(20)
);

CREATE TABLE `Espansioni` (
  `nome` varchar(20),
  `anno` year,
  `sigla` varchar(2) PRIMARY KEY
);

CREATE TABLE `Illustratori` (
  `nome` varchar(20),
  `cognome` varchar(20),
  `firma` varchar(20) PRIMARY KEY,
  `paese` varchar(20)
);

CREATE TABLE `Giudici` (
  `matricola` int PRIMARY KEY AUTO_INCREMENT,
  `nome` varchar(20) NOT NULL,
  `cognome` varchar(20) NOT NULL,
  `email` varchar(50),
  `prezzo` float
);

CREATE TABLE `Gradazioni` (
  `matricola_giudice` int,
  `copia_valutata` int,
  `valutazione` int NOT NULL,
  PRIMARY KEY (`matricola_giudice`, `copia_valutata`)
);

CREATE TABLE `Ordini` (
  `codice` int PRIMARY KEY AUTO_INCREMENT,
  `utente` varchar(20),
  `data_emissione` date NOT NULL,
  `data_consegna` date,
  `status` varchar(20),
  `presa_a_carico` varchar(20),
  `notificato` int default 0,
  `importo` int default 0
);

CREATE TABLE `Dettagli_ordini` (
  `prodotto` int,
  `codice_ordine` int,
  PRIMARY KEY (`prodotto`, `codice_ordine`)
);

CREATE TABLE `Società_di_trasporto` (
  `nome` varchar(20) PRIMARY KEY,
  `email` varchar(50),
  `telefono` int,
  `paese_sede` varchar(20),
  `città_sede` varchar(20),
  `via` varchar(20),
  `numero` int,
  `prezzo_servizio` float
);

ALTER TABLE `Copie` ADD FOREIGN KEY (`carta`) REFERENCES `Carte` (`id`);

ALTER TABLE `Copie` ADD FOREIGN KEY (`venditore`) REFERENCES `Utenti` (`username`);

ALTER TABLE `Carte` ADD FOREIGN KEY (`espansione`) REFERENCES `Espansioni` (`sigla`);

ALTER TABLE `Carte` ADD FOREIGN KEY (`illustratore`) REFERENCES `Illustratori` (`firma`);

ALTER TABLE `Gradazioni` ADD FOREIGN KEY (`copia_valutata`) REFERENCES `Copie` (`codice`);

ALTER TABLE `Gradazioni` ADD FOREIGN KEY (`matricola_giudice`) REFERENCES `Giudici` (`matricola`);

ALTER TABLE `Ordini` ADD FOREIGN KEY (`utente`) REFERENCES `Utenti` (`username`) ON DELETE SET NULL;

ALTER TABLE `Ordini` ADD FOREIGN KEY (`presa_a_carico`) REFERENCES `Società_di_trasporto` (`nome`);

ALTER TABLE `Dettagli_ordini` ADD FOREIGN KEY (`prodotto`) REFERENCES `Copie` (`codice`);

ALTER TABLE `Dettagli_ordini` ADD FOREIGN KEY (`codice_ordine`) REFERENCES `Ordini` (`codice`);

