DROP DATABASE IF EXISTS Auktion;
CREATE DATABASE Auktion;
USE Auktion;

CREATE TABLE Leverantör(
LeverantörId INT AUTO_INCREMENT PRIMARY KEY,
Namn VARCHAR(100) NOT NULL,
Epost VARCHAR(100) NOT NULL,
Telefonnummer CHAR(20) NOT NULL
);
CREATE INDEX IX_Leverantör_Namn ON Leverantör(Namn);

CREATE TABLE Produkt(
Produktnummer INT AUTO_INCREMENT PRIMARY KEY,
Namn VARCHAR(100) NOT NULL,
Provision FLOAT NOT NULL,
Beskrivning VARCHAR(200)
);
CREATE INDEX IX_Produkt_Namn ON Produkt(Namn);

CREATE TABLE ProduktLeverantör(
LeverantörId INT,
Produktnummer INT,
PRIMARY KEY(LeverantörId, Produktnummer),
FOREIGN KEY (LeverantörId) REFERENCES Leverantör(LeverantörId) ON DELETE CASCADE ON UPDATE CASCADE,
FOREIGN KEY (Produktnummer) REFERENCES Produkt(Produktnummer) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Auktion(
AuktionId INT AUTO_INCREMENT PRIMARY KEY,
Produktnummer INT,
StartDatum DATE NOT NULL, 
SlutDatum DATE NOT NULL, 
UtgångsPris INT NOT NULL,
AcceptPris INT NOT NULL,
FOREIGN KEY (Produktnummer) REFERENCES Produkt(Produktnummer) ON DELETE CASCADE ON UPDATE CASCADE

);

CREATE TABLE Kund(
KundNummer INT AUTO_INCREMENT PRIMARY KEY,
Förnamn VARCHAR(100) NOT NULL,
Efternamn VARCHAR(100) NOT NULL,
Gata VARCHAR(100) NOT NULL,
Ort VARCHAR(50) NOT NULL,
Epost VARCHAR(100) NOT NULL
);
CREATE INDEX IX_Kund_Efternamn ON kund(Efternamn);

CREATE TABLE Bud(
BudId INT AUTO_INCREMENT PRIMARY KEY,
AuktionId INT,
KundNummer INT,
BudDatum DATE,
Tid TIME,
Budsumma INT,
FOREIGN KEY(AuktionId) REFERENCES Auktion(AuktionId) ON DELETE CASCADE ON UPDATE CASCADE,
FOREIGN KEY(KundNummer) REFERENCES Kund(KundNummer) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE auktionshistorik(
AuktionsHistorikID INT,
Produktnummer INT,
SlutPris INT,
SlutDatum DATE,
PRIMARY KEY(AuktionsHistorikID),
FOREIGN KEY (Produktnummer) REFERENCES Produkt(Produktnummer) ON DELETE CASCADE ON UPDATE CASCADE
); 

CREATE TABLE AuktionerUtanKöpare(
AuktionId INT,
ProduktId INT,
Acceptpris INT,
SistaBud INT,
SlutDatum DATE,
PRIMARY KEY(AuktionId),
FOREIGN KEY (ProduktId) REFERENCES Produkt(Produktnummer) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE user_account(
	usr VARCHAR(50),
	pwd VARCHAR(50)
);
INSERT INTO user_account(usr, pwd) VALUES("gunnar", "gunnar");

-- Leverantör
INSERT INTO Leverantör(Namn, epost, telefonnummer) VALUES('AntikButiken', 'antik@hotmail.com', '08231192');
INSERT INTO Leverantör(Namn, epost, telefonnummer) VALUES('AuktionsAffären', 'aa@mail.com', '08222444');
INSERT INTO Leverantör(Namn, epost, telefonnummer) VALUES('ItBeasten', 'thebeast@mail.com', '0702929292');
INSERT INTO Leverantör(Namn, epost, telefonnummer) VALUES('GammaltOchNytt', 'gon@mail.com', '080328928');
INSERT INTO Leverantör(Namn, epost, telefonnummer) VALUES('MöbelJätten', 'jatten@hotmail.com', '0764266262');
INSERT INTO Leverantör(Namn, epost, telefonnummer) VALUES('TavlorDeluxe', 'deluxe@mail.com', '0721616111');

-- Produkter
INSERT INTO Produkt(Namn, provision,  beskrivning) VALUE('OljeTavla', 0.05, 'Fin tavla från Italien');
INSERT INTO Produkt(Namn, provision,  beskrivning) VALUE('Mahogny Bord', 0.07, 'Fint bord från Grekland');
INSERT INTO Produkt(Namn, provision,  beskrivning) VALUE('Mahogny Stol', 0.04, 'Fin stol från 1600-talet');
INSERT INTO Produkt(Namn, provision,  beskrivning) VALUE('Persiskt Matta', 0.10, 'Äkta persisk matta från 1800-talet');
INSERT INTO Produkt(Namn, provision,  beskrivning) VALUE('Guld Ring', 0.02, 'Guld Ring från StormaktsTiden');
INSERT INTO Produkt(Namn, provision,  beskrivning) VALUE('Gevär', 0.09, 'Gammalt gevär från 1700-talet');
INSERT INTO Produkt(Namn, provision,  beskrivning) VALUE('Kinesisk Kruka', 0.05, 'Porslin från ming dynastin');
INSERT INTO Produkt(Namn, provision,  beskrivning) VALUE('Antik Guld klocka', 0.05, 'Antik Guld klocka från Italien'); 
INSERT INTO Produkt(Namn, provision,  beskrivning) VALUE('Tand från mamut', 0.08, 'Gammal tand från en gigantisk mamut'); 

-- ProduktLeverantör
INSERT INTO ProduktLeverantör (LeverantörId, ProduktNummer) VALUES(1,1);
INSERT INTO ProduktLeverantör (LeverantörId, ProduktNummer) VALUES(2,2);
INSERT INTO ProduktLeverantör (LeverantörId, ProduktNummer) VALUES(3,3);
INSERT INTO ProduktLeverantör (LeverantörId, ProduktNummer) VALUES(4,4);
INSERT INTO ProduktLeverantör (LeverantörId, ProduktNummer) VALUES(5,5);
INSERT INTO ProduktLeverantör (LeverantörId, ProduktNummer) VALUES(6,6);
INSERT INTO ProduktLeverantör (LeverantörId, ProduktNummer) VALUES(1,7);
INSERT INTO ProduktLeverantör (LeverantörId, ProduktNummer) VALUES(2,8);
INSERT INTO ProduktLeverantör (LeverantörId, ProduktNummer) VALUES(4,9); 

-- Auktion
INSERT INTO Auktion(StartDatum,Produktnummer, SlutDatum, utgångspris, acceptpris) VALUES('2017-02-01',1 ,'2017-02-17', 4000, 9000); 
INSERT INTO Auktion(StartDatum,Produktnummer, SlutDatum, utgångspris, acceptpris) VALUES('2017-02-01',2 ,'2017-02-20', 17000, 19000); 
INSERT INTO Auktion(StartDatum,Produktnummer, SlutDatum, utgångspris, acceptpris) VALUES('2017-02-01',3 ,'2017-02-22', 15000, 20000); 
INSERT INTO Auktion(StartDatum,Produktnummer, SlutDatum, utgångspris, acceptpris) VALUES('2017-02-01',4 ,'2017-02-20', 20000, 30000); 
INSERT INTO Auktion(StartDatum,Produktnummer, SlutDatum, utgångspris, acceptpris) VALUES('2017-02-01',5 ,'2017-02-15', 30000, 50000); 
INSERT INTO Auktion(StartDatum,Produktnummer, SlutDatum, utgångspris, acceptpris) VALUES('2017-02-01',6 ,'2017-02-14', 14000, 19000); 
INSERT INTO Auktion(StartDatum,Produktnummer, SlutDatum, utgångspris, acceptpris) VALUES('2017-02-11',7 ,'2017-02-23', 25000, 40000); 
INSERT INTO Auktion(StartDatum,Produktnummer, SlutDatum, utgångspris, acceptpris) VALUES('2017-02-08',8 ,'2017-02-20', 30000, 50000); 

-- Kund
INSERT INTO Kund (Förnamn, Efternamn, Gata, Ort, Epost) VALUES('Lisa', 'Strömberg', 'Körsbärsgatan 5', 'Stockholm', 'lisa@mail.com,');
INSERT INTO Kund (Förnamn, Efternamn, Gata, Ort, Epost) VALUES('Arnold', 'Johansson', 'terminategatan 12', 'Göteborg', 'ilbeback@mail.com');
INSERT INTO Kund (Förnamn, Efternamn, Gata, Ort, Epost) VALUES('Erik', 'Eriksson', 'kylgatan 25', 'Linköping', 'erikeriksson@mail.com');
INSERT INTO Kund (Förnamn, Efternamn, Gata, Ort, Epost) VALUES('Gunde', 'Svan', 'FortBoyard 23', 'Stockholm', 'theshit@mail.com');
INSERT INTO Kund (Förnamn, Efternamn, Gata, Ort, Epost) VALUES('Sven', 'Svensson', 'svennegatan 100', 'Göteborg', 'svensson@yahoo.com');
INSERT INTO Kund (Förnamn, Efternamn, Gata, Ort, Epost) VALUES('Rolf', 'Nilsson', 'stigen 26', 'Linköping', 'nilssson@mail.co,');
INSERT INTO Kund (Förnamn, Efternamn, Gata, Ort, Epost) VALUES('Anders', 'Larsson', 'hackestifen 1', 'Gotland', 'larsson@gmail.com');

-- Bud
INSERT INTO Bud (AuktionId, KundNummer, BudDatum, Tid, Budsumma) VALUES(1,2, '2016-01-03', '11:10', 9000); 
INSERT INTO Bud (AuktionId, KundNummer, BudDatum, Tid, Budsumma) VALUES(2,2, '2016-04-09', '15:00', 17400);
INSERT INTO Bud (AuktionId, KundNummer, BudDatum, Tid, Budsumma) VALUES(2,3, '2016-04-10', '16:30', 17550);
INSERT INTO Bud (AuktionId, KundNummer, BudDatum, Tid, Budsumma) VALUES(2,4, '2016-04-10', '16:50', 19550); 
INSERT INTO Bud (AuktionId, KundNummer, BudDatum, Tid, Budsumma) VALUES(3,3, '2016-07-12', '11:00', 16000);
INSERT INTO Bud (AuktionId, KundNummer, BudDatum, Tid, Budsumma) VALUES(3,7, '2016-07-12', '12:00', 20000); 
INSERT INTO Bud (AuktionId, KundNummer, BudDatum, Tid, Budsumma) VALUES(4,4, '2017-02-03', '13:00', 22000); 
INSERT INTO Bud (AuktionId, KundNummer, BudDatum, Tid, Budsumma) VALUES(5,5, '2017-02-07', '10:00', 31700);
INSERT INTO Bud (AuktionId, KundNummer, BudDatum, Tid, Budsumma) VALUES(5,2, '2017-02-01', '15:00', 33200); 
INSERT INTO Bud (AuktionId, KundNummer, BudDatum, Tid, Budsumma) VALUES(6,6, '2017-02-01', '14:00', 14300);
INSERT INTO Bud (AuktionId, KundNummer, BudDatum, Tid, Budsumma) VALUES(6,4, '2017-02-05', '15:00', 15000); 
INSERT INTO Bud (AuktionId, KundNummer, BudDatum, Tid, Budsumma) VALUES(4,7, '2017-02-03', '13:30', 23400);
INSERT INTO Bud (AuktionId, KundNummer, BudDatum, Tid, Budsumma) VALUES(4,1, '2017-02-03', '13:40', 30000); 
INSERT INTO Bud (AuktionId, KundNummer, BudDatum, Tid, Budsumma) VALUES(8,1, '2017-02-09', '13:40', 35000);  
INSERT INTO Bud (AuktionId, KundNummer, BudDatum, Tid, Budsumma) VALUES(8,2, '2017-02-09', '15:00', 51000); 
INSERT INTO Bud (AuktionId, KundNummer, BudDatum, Tid, Budsumma) VALUES(8,3, '2017-02-09', '15:10', 52000); 

-- auktionshistorik
 INSERT INTO Auktionshistorik(AuktionsHistorikId,Produktnummer,SlutPris,SlutDatum) VALUES(-1,1,9000,'2016-01-03');
 INSERT INTO Auktionshistorik(AuktionsHistorikId,Produktnummer,SlutPris,SlutDatum) VALUES(-2,2,19550,'2016-04-10');
 INSERT INTO Auktionshistorik(AuktionsHistorikId,Produktnummer,SlutPris,SlutDatum) VALUES(-3,3,20000,'2016-07-12');