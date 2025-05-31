CREATE DATABASE HotelDB;
USE HotelDB;

CREATE TABLE Hotel (
    Id_Hotel INT PRIMARY KEY,
    Ville TEXT,
    Pays TEXT,
    Code_postal NUMERIC
);


CREATE TABLE Client (
    Id_Client INT PRIMARY KEY,
    Adresse TEXT,
    Ville TEXT,
    Code_postal NUMERIC,
    Email TEXT,
    Numero_telephone TEXT,
    Nom_complet TEXT
);


CREATE TABLE Prestation (
    Id_Prestation INT PRIMARY KEY,
    Prix NUMERIC,
    Description TEXT
);


CREATE TABLE Type_Chambre (
    Id_Type INT PRIMARY KEY,
    Type TEXT,
    Tarif NUMERIC
);


CREATE TABLE Chambre (
    Id_Chambre INT PRIMARY KEY,
    Numero INT,
    Etage NUMERIC,
    Fumeurs BOOLEAN,
    Id_Type INT,
    Id_Hotel INT,
    FOREIGN KEY (Id_Type) REFERENCES Type_Chambre(Id_Type),
    FOREIGN KEY (Id_Hotel) REFERENCES Hotel(Id_Hotel)
);


CREATE TABLE Reservation (
    Id_Reservation INT PRIMARY KEY,
    Date_arrivee DATE,
    Date_depart DATE,
    Id_Client INT,
    FOREIGN KEY (Id_Client) REFERENCES Client(Id_Client)
);

CREATE TABLE Evaluation (
    Id_Evaluation INT PRIMARY KEY,
    Date_arrivee DATE,
    La_note NUMERIC,
    Texte_descriptif TEXT,
    Id_Client INT,
    FOREIGN KEY (Id_Client) REFERENCES Client(Id_Client)
);

CREATE TABLE Concerner (
    Id_Reservation INT,
    Id_Chambre INT,
    PRIMARY KEY (Id_Reservation, Id_Chambre),
    FOREIGN KEY (Id_Reservation) REFERENCES Reservation(Id_Reservation),
    FOREIGN KEY (Id_Chambre) REFERENCES Chambre(Id_Chambre)
);


INSERT INTO Hotel VALUES
(1, 'Paris', 'France', 75001),
(2, 'Lyon', 'France', 69002);

INSERT INTO Client VALUES
(1, '12 Rue de Paris', 'Paris', 75001, 'jean.dupont@email.fr', '0612345678', 'Jean Dupont'),
(2, '5 Avenue Victor Hugo', 'Lyon', 69002, 'marie.leroy@email.fr', '0623456789', 'Marie Leroy'),
(3, '8 Boulevard Saint-Michel', 'Marseille', 13005, 'paul.moreau@email.fr', '0634567890', 'Paul Moreau'),
(4, '27 Rue Nationale', 'Lille', 59800, 'lucie.martin@email.fr', '0645678901', 'Lucie Martin'),
(5, '3 Rue des Fleurs', 'Nice', 06000, 'emma.giraud@email.fr', '0656789012', 'Emma Giraud');

INSERT INTO Prestation VALUES
(1, 15, 'Petit-déjeuner'),
(2, 30, 'Navette aéroport'),
(3, 0, 'Wi-Fi gratuit'),
(4, 50, 'Spa et bien-être'),
(5, 20, 'Parking sécurisé');

INSERT INTO Type_Chambre VALUES
(1, 'Simple', 80),
(2, 'Double', 120);

INSERT INTO Chambre VALUES
(1, 201, 2, 0, 1, 1),
(2, 502, 5, 1, 1, 2),
(3, 305, 3, 0, 2, 1),
(4, 410, 4, 0, 2, 2),
(5, 104, 1, 1, 2, 2),
(6, 202, 2, 0, 1, 1),
(7, 307, 3, 1, 1, 2),
(8, 101, 1, 0, 1, 1);

INSERT INTO Reservation VALUES
(1, '2025-06-15', '2025-06-18', 1),
(2, '2025-07-01', '2025-07-05', 2),
(3, '2025-08-10', '2025-08-14', 3),
(4, '2025-09-05', '2025-09-07', 4),
(5, '2025-09-20', '2025-09-25', 5),
(7, '2025-11-12', '2025-11-14', 2),
(9, '2026-01-15', '2026-01-18', 4),
(10, '2026-02-01', '2026-02-05', 2);

INSERT INTO Evaluation VALUES
(1, '2025-06-15', 5, 'Excellent séjour, personnel très accueillant.', 1),
(2, '2025-07-01', 4, 'Chambre propre, bon rapport qualité/prix.', 2),
(3, '2025-08-10', 3, 'Séjour correct mais bruyant la nuit.', 3),
(4, '2025-09-05', 5, 'Service impeccable, je recommande.', 4),
(5, '2025-09-20', 4, 'Très bon petit-déjeuner, hôtel bien situé.', 5);


SELECT 
    R.Id_Reservation,
    C.Nom_complet,
    H.Ville AS Ville_Hotel
FROM 
    Reservation R
JOIN Client C ON R.Id_Client = C.Id_Client
JOIN Chambre Ch ON R.Id_Reservation = Ch.Id_Chambre 
JOIN Hotel H ON Ch.Id_Hotel = H.Id_Hotel;
-- b. Clients qui habitent à Paris
SELECT * 
FROM Client 
WHERE Ville = 'Paris';


SELECT 
    C.Nom_complet,
    COUNT(R.Id_Reservation) AS Nombre_Reservations
FROM 
    Client C
LEFT JOIN Reservation R ON C.Id_Client = R.Id_Client
GROUP BY C.Id_Client;


SELECT 
    T.Type,
    COUNT(Ch.Id_Chambre) AS Nombre_Chambres
FROM 
    Type_Chambre T
LEFT JOIN Chambre Ch ON T.Id_Type = Ch.Id_Type
GROUP BY T.Type;


SET @date_debut = '2025-07-01';
SET @date_fin = '2025-07-10';

SELECT *
FROM Chambre Ch
WHERE Ch.Id_Chambre NOT IN (
    SELECT Co.Id_Chambre
    FROM Concerner Co
    JOIN Reservation R ON Co.Id_Reservation = R.Id_Reservation
    WHERE R.Date_arrivee <= @date_fin AND R.Date_depart >= @date_debut
);