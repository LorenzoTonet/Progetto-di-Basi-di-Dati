use cardstore;
-- RICERCA IN BASE AL NOME
DELIMITER §§
CREATE PROCEDURE ricerca_carta_per_nome(IN
nome_carta varchar(20))
BEGIN
	SELECT * FROM copie INNER JOIN carte on copie.carta = carte.id WHERE copie.nome = nome_carta AND copie.stato = 'Disponibile';
END §§
DELIMITER ;

-- Mostra un'intera espansione
DELIMITER §§
CREATE PROCEDURE mostra_espansione(IN
nome_espansione varchar(20))
BEGIN
	SELECT * FROM carte INNER JOIN espansione on carte.espansione = espansioni.sigla WHERE espansioni.nome = nome_espansione;
END §§
DELIMITER ;


DROP procedure ricerca_carta;
-- Ricerca di tutte le copie in vendita di una particolare con rarità decrescente
DELIMITER §§
CREATE PROCEDURE ricerca_carta(IN codice_carta varchar(5))
BEGIN
	select carte.nome, copie.prezzo, copie.lingua, carte.rarità as rarità from copie
    left join carte on copie.carta = carte.id where copie.stato != 'Venduta' order by rarità desc ;
END §§
DELIMITER ;

DROP TRIGGER aggiorna_grado;
-- Aggiornare il grado di una carta
DELIMITER §§
CREATE TRIGGER aggiorna_grado
AFTER INSERT ON gradazioni
FOR EACH ROW
BEGIN
    DECLARE voto_totale INT;
    DECLARE voto_count INT;
    DECLARE voto_medio float;
    
    SELECT SUM(valutazione), COUNT(*) INTO voto_totale, voto_count FROM gradazioni
    WHERE copia_valutata = NEW.copia_valutata;
    
    -- Aggiorna il voto medio nella tabella Carte
    UPDATE Copie
    SET grado = voto_totale / voto_count
    WHERE codice = NEW.copia_valutata;
END §§
DELIMITER ;

DROP procedure notifica_utenti;
-- Raccogliere le informazioni su utenti a cui è arrivato l'ordine per inviare la notifica
DELIMITER §§
CREATE PROCEDURE notifica_utenti(OUT lista_numeri varchar(4000))
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE numero_tel VARCHAR(20);
    DECLARE temp VARCHAR(4000) DEFAULT '';
    
    DECLARE cursore CURSOR FOR
    SELECT telefono FROM Ordini join Utenti on Ordini.utente = Utenti.username WHERE Ordini.status = 'completato' AND Ordini.notificato = 0;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
    OPEN cursore;
    
    WHILE (done = 0) DO
        FETCH cursore INTO numero_tel;
        IF done = 0 THEN
            SET temp = CONCAT(numero_tel,';',temp);
        END IF;
	END WHILE;
    CLOSE cursore;
    SET lista_numeri = temp;
END §§
DELIMITER ;

DROP procedure ricerca_carta_per_nome;
-- Reperire info sugli ordini dell'utente
DELIMITER §§
CREATE PROCEDURE ricerca_carta_per_nome(IN
username varchar(20), IN dettagli int)
BEGIN
-- dettagli sarà un valore binario che indica quali informazioni mostrare
IF (dettagli = 0) THEN
	select * from ordini where ordini.utente = username;
ELSE
	select * from ordini inner join dettagli_ordini on ordini.codice = dettagli_ordini.codice_ordine where ordini.utente = username;
END IF;
END §§
DELIMITER ;

DROP procedure crea_vendita;
-- Mettere una copia in vendita
DELIMITER §§
CREATE PROCEDURE crea_vendita(IN
username varchar(20), IN nome varchar(20), IN prezzo float, IN carta varchar(5), IN lingua varchar(20))
BEGIN

INSERT INTO Copie (prezzo, data_inizio_vendita, carta, venditore, lingua) VALUES
(prezzo, curdate(), carta, username, lingua);

END §§
DELIMITER ;

DELIMITER §§
CREATE PROCEDURE EseguiOrdini(IN codici VARCHAR(1000), IN username varchar(20), IN trasporto varchar(20), OUT importo_totale float)
BEGIN
    DECLARE codice_prod VARCHAR(20);
    DECLARE pos INT DEFAULT 1;
    DECLARE len INT;
    DECLARE my_codice_ordine INT;
    DECLARE totale_ordine float;
    
    START TRANSACTION;
    INSERT INTO ordini (utente, data_emissione, data_consegna, status, presa_a_carico) VALUES
	(username, curdate(), null, 'emesso', trasporto);
    SET my_codice_ordine = (SELECT codice FROM ordini ORDER BY codice DESC LIMIT 1);
    
    -- Individuare ciascun codice della stringa di input
    WHILE (pos <= LENGTH(codici)) DO
        SET len = LOCATE(';', codici, pos);
        -- LOCATE() ritorna la posiz. della prima occorrenza di una stringa in una stringa (le posizioni partono da 1)
        -- se la sottostringa non è presente ritorna 0
        IF len = 0 THEN
            SET len = LENGTH(codici) + 1;
        END IF;
        SET codice_prod = SUBSTRING(codici, pos, len - pos);
        -- SUBSTRING(stringa, inizio, fine) ritorna la substring corrisponde
        
        -- Eseguire l'operazione sulle tabelle per ciascun codice
        IF codice_prod != '' THEN
            -- Aggiornare lo stato dell'ordine
            UPDATE Copie
            SET stato = 'venduto'
            WHERE Copie.codice = codice_prod;
            
            INSERT INTO dettagli_ordini (prodotto, codice_ordine) VALUES
            (codice_prod, my_codice_ordine);
        END IF;
        SET pos = len + 1;
    END WHILE;
    SET totale_ordine = 
    (SELECT SUM(copie.prezzo) FROM dettagli_ordini INNER JOIN copie on prodotto = copie.codice WHERE codice_ordine = my_codice_ordine)
	+ (SELECT prezzo FROM società_di_trasporti WHERE nome = trasporto);
     
     SET importo_totale = totale_ordine;
     UPDATE ordini SET importo = totale_ordini WHERE codice = my_codice_ordine;
    -- Completare la transazione
    COMMIT;
END §§
DELIMITER ;

DROP procedure prezzo_medio_carta;
-- Calcolare il prezzo medio a cui è stata venduta una determinata carta
DELIMITER §§
CREATE PROCEDURE prezzo_medio_carta(IN codice_carta varchar(5), OUT prezzo_medio float)
BEGIN
	DECLARE temp float;
	SET temp = (SELECT AVG(prezzo) FROM copie WHERE carta = codice_carta and stato = 'Venduta');
    SET prezzo_medio = temp;
     
END §§
DELIMITER ;


DROP procedure ricerca_carta_per_artista;
-- Ricercare tutte le copie in vendita di carte illustrate da artisti di un determinato paese
DELIMITER §§
CREATE PROCEDURE ricerca_carta_per_artista(IN paese varchar(20))
BEGIN
	SELECT * FROM copie
    LEFT JOIN carte on copie.carta = carte.id
    LEFT JOIN illustratori on carte.illustratore = illustratori.firma WHERE illustratori.paese = paese;
    
END §§
DELIMITER ;
