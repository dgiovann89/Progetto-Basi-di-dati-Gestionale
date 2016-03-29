
/*
SCRIPT PROGETTO BASI CON TABELLA AMMINISTRATORI!!

NOTE INFORMATIVE:
Per MySQL non è disponibile nativamente il tipo di dato BOOL, esso (come BOOLEAN) non è altro che un sinonimo di un altro tipo di dato
realmente esistente: TINYINT(1); per BOOL un valore zero viene considerato “false” mentre i valori diversi da zero sono considerati “true”,
false e true non sono altro che degli alias (riferimenti) ai valori reali “0″ e “1″.

il formato della data e' AAAA.MM.DD
*/
/*Connessione al database*/
CONNECT dgiovann-PR;

/*Disabilita controllo chiavi esterne */
SET FOREIGN_KEY_CHECKS=0;

/* Elimino le tabelle-trigger-funzioni-procedure se esistono gia' */
DROP TRIGGER IF EXISTS ControlloSconto;
DROP TRIGGER IF EXISTS ControlloInserimentoOrdine;
DROP FUNCTION IF EXISTS ControllaGaranziaArticoli;
DROP FUNCTION IF EXISTS ControllaGaranziaDispositivi;
DROP PROCEDURE IF EXISTS AumentaPrezzo;
DROP PROCEDURE IF EXISTS DiminuisciPrezzo;
DROP TABLE IF EXISTS Errori;
DROP TABLE IF EXISTS Articoli;
DROP TABLE IF EXISTS Persone;
DROP TABLE IF EXISTS Clienti;
DROP TABLE IF EXISTS Amministratori;
DROP TABLE IF EXISTS Fornitori;
DROP TABLE IF EXISTS Dipendenti;
DROP TABLE IF EXISTS Categorie;
DROP TABLE IF EXISTS Dispositivi;
DROP TABLE IF EXISTS DispositiviInAssistenza;
DROP TABLE IF EXISTS Assistenza;
DROP TABLE IF EXISTS Servizi;
DROP TABLE IF EXISTS ServiziScelti;
DROP TABLE IF EXISTS Ordini;

/*CREAZIONE DELLE TABELLE*/

/* Creo la tabella delle Persone */
CREATE TABLE Persone(
IdPersona INTEGER NOT NULL AUTO_INCREMENT,
Indirizzo VARCHAR(50),
Citta VARCHAR(20),
Cap CHAR(5),
PRIMARY KEY (IdPersona)
)
ENGINE=InnoDB;

/* Creo la tabella dei Clienti */
CREATE TABLE Clienti (
IdCliente INTEGER NOT NULL, -- AUTO_INCREMENT,
Nome VARCHAR(20),
Cognome VARCHAR(20) NOT NULL,
DataDiNascita DATE,
Email VARCHAR(50),
TelCasa VARCHAR(14),
Cellulare VARCHAR(14),
Username VARCHAR(15),
Password VARCHAR(15),
PRIMARY KEY (IdCliente),
FOREIGN KEY (IdCliente) REFERENCES Persone(IdPersona) ON UPDATE CASCADE ON DELETE CASCADE
)
ENGINE=InnoDB;


/* Creo la tabella dei Amministratori */
CREATE TABLE Amministratori (
IdAmministratore INTEGER NOT NULL, -- AUTO_INCREMENT,
Nome VARCHAR(20) NOT NULL,
Cognome VARCHAR(20) NOT NULL,
Username VARCHAR(15) NOT NULL,
Password VARCHAR(15) NOT NULL,
PRIMARY KEY (IdAmministratore),
FOREIGN KEY (IdAmministratore) REFERENCES Persone(IdPersona) ON DELETE CASCADE ON UPDATE CASCADE
)
ENGINE=InnoDB;

/* Creo la tabella dei Fornitori */
CREATE TABLE Fornitori(
IdFornitore INTEGER NOT NULL, -- AUTO_INCREMENT,
RagioneSociale VARCHAR(50) NOT NULL,
Piva VARCHAR(20),
TelUfficio VARCHAR(14),
Fax VARCHAR(14),
Email VARCHAR(30),
WebSite VARCHAR(50),
PRIMARY KEY (IdFornitore),
FOREIGN KEY (IdFornitore) REFERENCES Persone(IdPersona) ON UPDATE CASCADE ON DELETE CASCADE
)
ENGINE=InnoDB;

/* Creo la tabella dei Dipendenti */
CREATE TABLE Dipendenti(
IdFornitore INTEGER NOT NULL,
NomeCognome VARCHAR(40) NOT NULL,
Ruolo VARCHAR(50),
Email VARCHAR(30),
Cellulare VARCHAR(12),
TelUfficio VARCHAR(12),
PRIMARY KEY (NomeCognome),
FOREIGN KEY (IdFornitore) REFERENCES Fornitori(IdFornitore) ON DELETE CASCADE ON UPDATE CASCADE
)
ENGINE=InnoDB;

/* Creo la tabella delle Categorie */
CREATE TABLE Categorie (
NomeCategoria VARCHAR(50) NOT NULL,
Descrizione VARCHAR(250),
PRIMARY KEY (NomeCategoria)
)
ENGINE=InnoDB;

/* Creo la tabella dei Dispositivi dei clienti */
CREATE TABLE Dispositivi (
IdDispositivo INTEGER NOT NULL,
IdCliente INTEGER NOT NULL,
Nome VARCHAR(50),
Descrizione BLOB,
SerialNumber VARCHAR(20),
Immagine BLOB, 
DataAcq DATE,
Categoria VARCHAR(20),
SitoDriver VARCHAR(100),
Note BLOB,
PRIMARY KEY (IdDispositivo),
FOREIGN KEY (Categoria) REFERENCES Categorie(NomeCategoria),
FOREIGN KEY (IdCliente) REFERENCES Clienti(IdCliente) ON UPDATE CASCADE ON DELETE CASCADE
)
ENGINE=InnoDB;

/* Creo la tabella dei DispositiviInAssistenza */
CREATE TABLE DispositiviInAssistenza (
IdAssistenza INTEGER NOT NULL,
IdDispositivo INTEGER NOT NULL,
PRIMARY KEY (IdDispositivo, IdAssistenza),
FOREIGN KEY (IdDispositivo) REFERENCES Dispositivi(IdDispositivo) ON UPDATE CASCADE ON DELETE CASCADE,
FOREIGN KEY (IdAssistenza) REFERENCES Assistenza(IdAssistenza)
)
ENGINE=InnoDB;

/* Creo la tabella Assistenza */
CREATE TABLE Assistenza (
IdAssistenza INTEGER NOT NULL AUTO_INCREMENT,
Richiesta BLOB,
Soluzione BLOB,
DataRichiesta DATE,
DataTermine DATE,
PrezzoTot FLOAT,
Sconto FLOAT,
PRIMARY KEY (IdAssistenza)
)
ENGINE=InnoDB;

/* Creo la tabella dei Servizi */
CREATE TABLE Servizi (
IdServizio INTEGER NOT NULL,
Nome VARCHAR(50) NOT NULL,
Descrizione VARCHAR(250) NOT NULL,
Prezzo FLOAT NOT NULL,
PRIMARY KEY (IdServizio)
) 
ENGINE=InnoDB;

/* Creo la tabella ServiziScelti */
CREATE TABLE ServiziScelti (
IdAssistenza INTEGER NOT NULL,
IdServizio INTEGER NOT NULL,
PRIMARY KEY (IdAssistenza,IdServizio),
FOREIGN KEY (IdAssistenza) REFERENCES Assistenza(IdAssistenza),
FOREIGN KEY (IdServizio) REFERENCES Servizi(IdServizio)
)
ENGINE=InnoDB;

/* Creo la tabella degli Ordini */
CREATE TABLE Ordini (
IdOrdine INTEGER NOT NULL,
IdPersona INTEGER NOT NULL,
Referente VARCHAR(30),
DataEmissione DATE NOT NULL,
DataConsegna DATE,
PrezzoTot FLOAT,
Note BLOB,
PRIMARY KEY (IdOrdine),
FOREIGN KEY (IdPersona) REFERENCES Fornitori(IdFornitore) ON UPDATE CASCADE ON DELETE CASCADE, 
FOREIGN KEY (Referente) REFERENCES Dipendenti(NomeCognome) ON UPDATE CASCADE ON DELETE CASCADE
)
ENGINE=InnoDB;

/* Creo la tabella degli Articoli */
CREATE TABLE Articoli (
IdArticolo INTEGER NOT NULL,
IdOrdine INTEGER,
SerialNumber VARCHAR(20) NOT NULL,
Descrizione VARCHAR(250),
Categoria VARCHAR(20),
PrezzoAcq FLOAT,
PrezzoVend FLOAT,
Garanzia ENUM('Fuori Garanzia','1', '2', '3', '5', 'A vita'),
Uso ENUM('Interno','Vendita'),
Venduto TINYINT(1),
IdAssistenza INTEGER, 
Note VARCHAR(250),
PRIMARY KEY (IdArticolo),
FOREIGN KEY (Categoria) REFERENCES Categorie(NomeCategoria) ON UPDATE CASCADE, 
FOREIGN KEY (IdAssistenza) REFERENCES Assistenza(IdAssistenza) ON UPDATE CASCADE,
FOREIGN KEY (IdOrdine) REFERENCES Ordini(IdOrdine) ON UPDATE CASCADE ON DELETE CASCADE
)
ENGINE=InnoDB;

/* POPOLAMENTO TABELLE */
LOAD DATA LOCAL INFILE 'Clienti.txt' INTO TABLE Clienti FIELDS TERMINATED BY '#' (IdCliente,Nome,Cognome,DataDiNascita,Email,TelCasa,Cellulare,Username,Password);
LOAD DATA LOCAL INFILE 'Amministratori.txt' INTO TABLE Amministratori FIELDS TERMINATED BY '#' (IdAmministratore,Nome,Cognome,Username,Password);
LOAD DATA LOCAL INFILE 'Fornitori.txt' INTO TABLE Fornitori FIELDS TERMINATED BY '#' (IdFornitore,RagioneSociale,Piva,TelUfficio,Fax,Email,WebSite);
LOAD DATA LOCAL INFILE 'Persone.txt' INTO TABLE Persone FIELDS TERMINATED BY '#' (IdPersona,Indirizzo,Citta,Cap);
LOAD DATA LOCAL INFILE 'Dispositivi.txt' INTO TABLE Dispositivi FIELDS TERMINATED BY '#' (IdDispositivo,IdCliente,Nome,Descrizione,SerialNumber,Immagine,DataAcq,Categoria,SitoDriver,Note);
LOAD DATA LOCAL INFILE 'Dipendenti.txt' INTO TABLE Dipendenti FIELDS TERMINATED BY '#' (IdFornitore,NomeCognome,Ruolo,Email,Cellulare,TelUfficio);
LOAD DATA LOCAL INFILE 'Servizi.txt' INTO TABLE Servizi FIELDS TERMINATED BY '#' (IdServizio,Nome,Descrizione,Prezzo);
LOAD DATA LOCAL INFILE 'Categorie.txt' INTO TABLE Categorie FIELDS TERMINATED BY '#' (NomeCategoria,Descrizione);
LOAD DATA LOCAL INFILE 'Ordini.txt' INTO TABLE Ordini FIELDS TERMINATED BY '#' (IdOrdine,IdPersona,Referente,DataEmissione,DataConsegna,PrezzoTot,Note);
LOAD DATA LOCAL INFILE 'Assistenza.txt' INTO TABLE Assistenza FIELDS TERMINATED BY '#' (IdAssistenza,Richiesta,Soluzione,DataRichiesta,DataTermine,PrezzoTot,Sconto);
LOAD DATA LOCAL INFILE 'Articoli.txt' INTO TABLE Articoli FIELDS TERMINATED BY '#' (IdArticolo,IdOrdine,SerialNumber,Descrizione,Categoria,PrezzoAcq,PrezzoVend,Garanzia,Uso,Venduto,IdAssistenza,Note);
LOAD DATA LOCAL INFILE 'DispositiviInAssistenza.txt' INTO TABLE DispositiviInAssistenza FIELDS TERMINATED BY '#' (IdAssistenza,IdDispositivo);
LOAD DATA LOCAL INFILE 'ServiziScelti.txt' INTO TABLE ServiziScelti FIELDS TERMINATED BY '#' (IdAssistenza,IdServizio);

/*Attivazione DELIMITER*/
delimiter //

/*Creo il trigger1 ControlloSconto*/
CREATE TRIGGER ControlloSconto
BEFORE INSERT ON Assistenza
FOR EACH ROW
BEGIN
        IF new.Sconto < 0 THEN
                SET new.Sconto = 0;
        ELSEIF new.Sconto > new.PrezzoTot THEN
                SET new.Sconto = new.PrezzoTot;
        END IF;
END;//

/*Creo il trigger2 ControlloInserimentoOrdine e la relativa tabella Errori*/
CREATE TABLE Errori(
	Id CHAR(3) PRIMARY KEY)
ENGINE=InnoDB;

CREATE TRIGGER ControlloInserimentoOrdine
BEFORE INSERT ON Ordini
FOR EACH ROW
BEGIN
	IF new.IdPersona NOT IN (SELECT IdFornitore FROM Fornitori WHERE IdFornitore=new.IdPersona)
	THEN 
		INSERT INTO Errori VALUES (NULL);
	END IF;
END;//

/*Creo la funzione ControllaGaranziaArticoli*/
CREATE FUNCTION ControllaGaranziaArticoli (IdArticolo INT) 
RETURNS VARCHAR(100)
BEGIN
	DECLARE AnniGaranzia VARCHAR(10);
	DECLARE GiorniGaranzia INT;
	DECLARE DataAcquisto DATE;
	DECLARE x INT;

	SELECT a.Garanzia INTO AnniGaranzia
	FROM Articoli a 
	WHERE a.IdArticolo = IdArticolo;

	IF (AnniGaranzia = 'Fuori Garanzia') THEN 
		SET GiorniGaranzia = 0;
	END IF;
	IF (AnniGaranzia = 1) THEN 
		SET GiorniGaranzia = 365;
	END IF;
	IF (AnniGaranzia = 2) THEN 
		SET GiorniGaranzia = 730;
	END IF;
	IF (AnniGaranzia = 3) THEN 
		SET GiorniGaranzia = 1095;
	END IF;
	IF (AnniGaranzia = 5) THEN 
		SET GiorniGaranzia = 1825;
	END IF;				
	IF (AnniGaranzia = 'A vita') THEN 
		SET GiorniGaranzia = 50000;
	END IF;		

	SELECT o.DataConsegna INTO DataAcquisto
	FROM Ordini o JOIN Articoli a ON (o.IdOrdine = a.IdOrdine)
	WHERE a.IdArticolo = IdArticolo
	GROUP BY a.IdArticolo;

	SELECT DATEDIFF(current_date(),DataAcquisto) INTO x;

	IF (x>GiorniGaranzia) THEN 
		RETURN 'Questo articolo è fuori dalla garanzia';
	ELSE
		RETURN 'Questo articolo è ancora in garanzia';
	END IF;

END; //

/*Creo la funzione ControllaGaranziaDispositivi*/
CREATE FUNCTION ControllaGaranziaDispositivi (IdDispositivo INT) 
RETURNS VARCHAR(50)
BEGIN
	DECLARE GiorniGaranzia INT DEFAULT 730;
	DECLARE DataAcquisto DATE;
	DECLARE x INT;		

	SELECT d.DataAcq INTO DataAcquisto
	FROM Dispositivi d
	WHERE d.IdDispositivo = IdDispositivo
	GROUP BY d.IdDispositivo;

	SELECT DATEDIFF(current_date(),DataAcquisto) INTO x;

	IF (x>GiorniGaranzia) THEN 
		RETURN 'Questo dispositivo è fuori dalla garanzia';
	ELSE
		RETURN 'Questo dispositivo è ancora in garanzia';
	END IF;

END; //

/*Creo la procedura AumentaPrezzo*/
CREATE PROCEDURE AumentaPrezzo (IN num DOUBLE)
BEGIN
	UPDATE Servizi
	SET Prezzo = Prezzo + (Prezzo/100*num);
END; //

/*Creo la procedura DiminuisciPrezzo*/
CREATE PROCEDURE DiminuisciPrezzo (IN num DOUBLE)
BEGIN
	UPDATE Servizi
	SET Prezzo = Prezzo - (Prezzo/100*num);
END; //

/*Distattivazione DELIMITER*/
delimiter ;

/*Abilita controllo chiavi esterne*/
SET FOREIGN_KEY_CHECKS=1;
