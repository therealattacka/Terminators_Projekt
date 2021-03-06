USE Auktion;

-- 1. 
-- Registrera en produkt 
DROP PROCEDURE IF EXISTS RegistreraProdukt;
DELIMITER //

CREATE PROCEDURE RegistreraProdukt(IN Namn VARCHAR(100), IN Provision FLOAT, IN Beskrivning VARCHAR(200))

BEGIN
	DECLARE ProduktFinnsRedan BOOL DEFAULT FALSE;
    DECLARE CONTINUE HANDLER FOR 1062 SET ProduktFinnsRedan = TRUE;
    
    DECLARE EXIT HANDLER FOR 1048
    BEGIN
		ROLLBACK;
	END;
    
    START TRANSACTION;
		INSERT INTO Produkt(Namn,Provision,Beskrivning)
			VALUES (Namn, Provision, Beskrivning);
        
        IF ProduktFinnsRedan THEN
        UPDATE Produkt
			SET Produkt.Namn = Namn,
				Produkt.Provision = Provision,
                Produkt.Beskrivning = Beskrivning;
		END IF;
        COMMIT;
END //
DELIMITER ;

CALL RegistreraProdukt( 'Bokhylla', 0.10,  'En välvårdat bokhylla tillverkad');
SELECT * FROM Produkt;

-- Skapa en aukton utifrån en viss produkt där man kan sätta utgångspris, acceptpris samt start och slutdatum för auktionen. 
-- 2.
DROP PROCEDURE IF EXISTS SkapaAuktion;

DELIMITER //
CREATE PROCEDURE SkapaAuktion(IN UtGångsPris INT, IN AcceptPris INT, IN StartDatum DATE, IN SlutDatum DATE, IN Produktnummer INT)
BEGIN
	
	DECLARE EXIT HANDLER FOR 1048
		BEGIN
			ROLLBACK;
		END;
        
	START TRANSACTION;

        INSERT INTO `auktion` ( `StartDatum`, `Produktnummer`, `SlutDatum`, `UtgångsPris`, `AcceptPris`)
        VALUES ( StartDatum, ProduktNummer,SlutDatum, UtGångsPris, AcceptPris);
        
	COMMIT;				
END //
DELIMITER ;

CALL SkapaAuktion(13500, 22000, '2016-04-08', '2016-04-11',9);
SELECT * FROM Produkt;
SELECT * FROM Auktion;
-- SELECT * FROM AuktionsProdukt;

-- Lista pågående auktioner samt kunna se det högsta budet och vilken kund som lagt det. 
-- 3.
SELECT Kund.Förnamn, Kund.Efternamn, MAX(Bud.Budsumma) AS Högsta_bud, Produkt.Namn, Auktion.StartDatum, Auktion.SlutDatum FROM Kund
INNER JOIN Bud ON Kund.KundNummer = Bud.KundNummer
INNER JOIN Auktion ON Bud.AuktionId = Auktion.AuktionId
INNER JOIN Produkt ON Auktion.Produktnummer = Produkt.Produktnummer
WHERE SlutDatum > current_date()
GROUP BY Produkt.Namn;


--  Se budhistoriken på en viss auktion, samt vilka kunder som lagt buden(Löste med View)
-- 4.
DROP VIEW IF EXISTS KundBudHistorik;

CREATE VIEW KundBudHistorik
AS SELECT Förnamn, Efternamn, Budsumma, AcceptPris, Namn AS Produkt_Namn FROM Kund
INNER JOIN Bud ON Kund.KundNummer = Bud.KundNummer
INNER JOIN Auktion ON Bud.AuktionId = Auktion.AuktionId
INNER JOIN Produkt ON Auktion.Produktnummer = Produkt.Produktnummer
WHERE Auktion.AuktionId = '2'
GROUP BY Kund.Förnamn;

SELECT * FROM KundBudHistorik;

-- 5

DROP PROCEDURE IF EXISTS GetAvslutadeAuktioner;
DELIMITER //
CREATE PROCEDURE GetAvslutadeAuktioner(startdatum DATE, slutdatum DATE)
BEGIN
    SELECT Auktionshistorik.AuktionshistorikId, ROUND(Sum((Produkt.Provision* auktionshistorik.SlutPris))) AS Provision FROM Auktionshistorik
        INNER JOIN Produkt ON Produkt.Produktnummer = Auktionshistorik.Produktnummer
        WHERE Auktionshistorik.SlutDatum BETWEEN startdatum AND slutdatum
        GROUP BY Auktionshistorik.AuktionshistorikId;
END //
DELIMITER ;

CALL GetAvslutadeAuktioner('2016-01-03','2016-04-10');

-- 6. Auktioner utan köpare

SHOW EVENTS;
SET GLOBAL event_scheduler = ON;

DROP EVENT IF EXISTS ArkiveraAuktionerUtanKöpare;
DELIMITER //
CREATE EVENT ArkiveraAuktionerUtanKöpare
ON SCHEDULE EVERY 10 SECOND
ON COMPLETION PRESERVE
DO
BEGIN
	INSERT INTO AuktionerUtanKöpare(SELECT Auktion.AuktionId, Produkt.Produktnummer, auktion.AcceptPris, MAX(bud.Budsumma)
	as SistaBud, Auktion.SlutDatum FROM Auktion
		LEFT JOIN Bud ON Auktion.AuktionId = Bud.AuktionId
		LEFT JOIN Produkt ON Auktion.Produktnummer = Produkt.Produktnummer
        GROUP BY Auktion.AuktionID HAVING (SistaBud < AcceptPris OR SistaBud IS NULL) AND Auktion.SlutDatum < current_date());
	DELETE FROM Auktion WHERE Auktion.AuktionId IN (SELECT AuktionerUtanKöpare.AuktionId FROM AuktionerUtanKöpare);
END //
DELIMITER ;
 

SELECT * FROM AuktionerUtanKöpare;
SELECT * FROM Auktion;


-- 7.
DROP EVENT IF EXISTS Auktion;
SET GLOBAL event_scheduler = ON;
DELIMITER //
CREATE EVENT Auktion
ON SCHEDULE EVERY 10 SECOND
ON COMPLETION PRESERVE
DO
BEGIN
    INSERT INTO auktionshistorik (SELECT Auktion.AuktionId, auktion.Produktnummer, MAX(Bud.Budsumma), Auktion.SlutDatum FROM Kund
        INNER JOIN Bud ON Kund.KundNummer = Bud.KundNummer
        INNER JOIN Auktion ON Bud.AuktionId = Auktion.AuktionId
        INNER JOIN Produkt ON auktion.Produktnummer = Produkt.Produktnummer
        WHERE Bud.Budsumma >= Auktion.AcceptPris AND Auktion.SlutDatum < current_date()
        GROUP BY auktion.Produktnummer);
    DELETE FROM auktion WHERE Bud.Budsumma >= Auktion.Utgångspris AND Auktion.SlutDatum < current_date();
END //
DELIMITER ;

DROP TRIGGER IF EXISTS onAuktionAcceptPris;
DELIMITER //
CREATE TRIGGER Auktion.onAuktionAcceptPris AFTER INSERT ON auktion.bud
FOR EACH ROW
	BEGIN
		IF (NEW.Budsumma >= (SELECT AcceptPris FROM auktion WHERE auktion.AuktionId = NEW.AuktionId)
		AND (SELECT COUNT(1) FROM Bud WHERE AuktionID = NEW.AuktionID) = 1) THEN
			
			INSERT INTO auktionshistorik (SELECT Auktion.AuktionId, auktion.Produktnummer, MAX(Bud.Budsumma), Auktion.SlutDatum FROM Kund
				INNER JOIN Bud ON Kund.KundNummer = Bud.KundNummer
				INNER JOIN Auktion ON Bud.AuktionId = Auktion.AuktionId
				INNER JOIN Produkt ON auktion.Produktnummer = Produkt.Produktnummer
				WHERE auktion.AuktionId = NEW.AuktionId
				GROUP BY auktion.Produktnummer);
			DELETE FROM auktion WHERE auktion.AuktionId = NEW.AuktionId;
            
		END IF;
END //
DELIMITER ;


-- DROP EVENT IF EXISTS ArkiveraAuktion;
SELECT * FROM Auktionshistorik;
SELECT * FROM Auktion;


-- 8.
DROP VIEW IF EXISTS KundLista;
CREATE VIEW KundLista AS
SELECT CONCAT_WS(' ', Kund.Förnamn, Kund.Efternamn) AS Kund, AuktionsHistorik.SlutPris AS Total FROM Kund
INNER JOIN AuktionsHistorik ON Kund.KundNummer = AuktionsHistorik.AuktionsHistorikID
GROUP BY Kund, Total
ORDER BY Total DESC;

SELECT * FROM KundLista;


--  Vad den totala provisionen är per månad.
-- 9.
DROP VIEW IF EXISTS totalprovision;

CREATE VIEW TotalProvision AS
SELECT MONTHNAME(AuktionsHistorik.SlutDatum) AS Månad, ROUND(SUM(Produkt.Provision * auktionshistorik.SlutPris))
AS TotalProvision_PerMånad FROM AuktionsHistorik
INNER JOIN produkt ON AuktionsHistorik.Produktnummer = produkt.Produktnummer
GROUP BY MONTHNAME(AuktionsHistorik.SlutDatum)
ORDER BY Månad DESC;

SELECT * FROM TotalProvision