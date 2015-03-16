-- MyChessDatabase by Stefan "Darlanio" Alenius
--
-- Problems/TODO:
-- Storage of positions is ineffective since this implementation is using FEN. For larger databases huffman packing of chesspositions should be used.
-- Storage of several positions is ineffective since we are not using a separate table for storing all potentially new positions and then merge it into the table Position
-- For this last problem I have added a comment last in this file, which is a stored procedure to be used on newer databases.
--USE master
--GO
--DROP DATABASE MyChessDatabase
--GO
--CREATE DATABASE MyChessDatabase
--COLLATE Finnish_Swedish_CS_AS 
--GO
USE MyChessDatabase
GO
-- Player Database
CREATE TABLE Title (
    TitleId int IdENTITY(1,1) NOT NULL,
    TitleName varchar(300),
    TitleAbbreviation varchar(30),

    PRIMARY KEY CLUSTERED (TitleId ASC)
    )
GO
CREATE TABLE Player (
    PlayerId int IdENTITY(1,1) NOT NULL,
    Birth datetime,
    Death datetime,

    PRIMARY KEY CLUSTERED (PlayerId ASC)
    )
GO
CREATE TABLE PlayerName (
    PlayerNamesId int IdENTITY(1,1) NOT NULL,
	PlayerId int NOT NULL,
    FirstName varchar(300),
    LastName varchar(300)

    PRIMARY KEY CLUSTERED (PlayerNamesId ASC)
	FOREIGN KEY (PlayerId) REFERENCES Player(PlayerId)
    )
GO
CREATE TABLE PlayerTitle (
    PlayerId int NOT NULL,
    TitleId int NOT NULL,
    StartDate datetime,
    EndDate datetime,

    PRIMARY KEY CLUSTERED (PlayerId ASC, TitleId ASC),
    FOREIGN KEY (PlayerId) REFERENCES Player(PlayerId),
    FOREIGN KEY (TitleId) REFERENCES Title(TitleId)
    )
GO
CREATE TABLE Country (
    CountryId int IdENTITY(1,1) NOT NULL,
    CountryName varchar(300),
    CountryFullName varchar(300),
    CountryAbbreviation varchar(30),

    PRIMARY KEY CLUSTERED (CountryId ASC)
    )
GO
CREATE TABLE PlayerCountry (
    PlayerId int NOT NULL,
    CountryId int NOT NULL,
    StartDate datetime,
    EndDate datetime,

    PRIMARY KEY CLUSTERED (PlayerId ASC, CountryId ASC),
    FOREIGN KEY (PlayerId) REFERENCES Player(PlayerId),
    FOREIGN KEY (CountryId) REFERENCES Country(CountryId)
    )
GO
CREATE TABLE ELO (
    ELOId int IdENTITY(1,1) NOT NULL,
    PlayerId int NOT NULL,
    ELO int,
    StartDate datetime,
    EndDate datetime,

    PRIMARY KEY CLUSTERED (ELOId ASC),
    FOREIGN KEY (PlayerId) REFERENCES Player(PlayerId)
    )
GO
-- Game database
CREATE TABLE Position (
    PositionId int IdENTITY(1,1) NOT NULL,
    FEN varchar(300) NOT NULL,
    FENHASH BINARY(20) NOT NULL,
    isWhiteToMove bit NOT NULL,
    Castling varchar(4), -- Kanske skall ändra typ på denna kolumn?
    EnPassantSquare varchar(2), -- ändrat från int 2013-07-24
    DrawCounter int NULL, -- tanken är att den inte skall vara null i partierna, men enstaka ställningar får lagras med null
    MaterialBalance INT NULL, -- används som flagga för att markera om ställningen är ett barn (NULL) eller om den blivit förälder (rätt värde).

	PRIMARY KEY CLUSTERED (PositionId ASC),
	
    )
GO
--CREATE INDEX IdX_Position_FENHASH_FEN ON Position (PositionId ASC, FENHASH ASC, FEN ASC)
CREATE INDEX IdX_Position_FENHASH ON Position (FENHASH ASC) -- PositionId kommer automatiskt med
--CREATE INDEX IdX_Position_FEN ON Position (PositionId ASC, FEN ASC)
CREATE INDEX IdX_Position_MaterialBalance ON Position (MaterialBalance ASC)
GO
CREATE TABLE Moves (
    ParentPositionId INT NOT NULL,
    ChildPositionId INT NOT NULL,
    
    PRIMARY KEY CLUSTERED (ParentPositionId ASC,ChildPositionId ASC)
    )
GO
CREATE TABLE Evaluation (
	EvaluationId int IdENTITY(1,1) NOT NULL,
	PositionId int NOT NULL,
	[Date] datetime,
	Depth int,
	ElapsedTime datetime, -- int, -- Seconds or milliseconds? Maybe time or similar is better here?
	Engine varchar(300),
	Evaluation float,
	PrimaryVariation varchar(300),
	isBestEvaluation bit, -- highest evaluation for the player to move

	PRIMARY KEY CLUSTERED (EvaluationId ASC),
	FOREIGN KEY (PositionId) REFERENCES Position(PositionId)
	)
GO
CREATE TABLE [Event] (
    EventId int IdENTITY(1,1) NOT NULL,
    [Event] varchar(300),
    EventStartDate datetime,
    EventEndDate datetime,
    [Site] varchar(300),

	PRIMARY KEY CLUSTERED (EventId ASC)
    )
GO
CREATE TABLE Result (
    ResultId int IdENTITY(1,1) NOT NULL,
    Result VARCHAR(10) NOT NULL,
    
    PRIMARY KEY (ResultId ASC)
    )
GO
CREATE TABLE Game (
    GameId int IdENTITY(1,1) NOT NULL,
    EventId int,
    [Date] datetime,
    [Round] int,
    WhiteId int,
    BlackId int,
    ResultId int,
    PGN varchar(8000),

	PRIMARY KEY CLUSTERED (GameId ASC),
    FOREIGN KEY (EventId) REFERENCES [Event](EventId),
    FOREIGN KEY (WhiteId) REFERENCES Player(PlayerId),
    FOREIGN KEY (BlackId) REFERENCES Player(PlayerId),
    FOREIGN KEY (ResultId) REFERENCES Result(ResultId)
    )
GO
CREATE TABLE GamePosition (
    GameId int NOT NULL,
    PositionId int NOT NULL,
    MoveNumber int,

    PRIMARY KEY CLUSTERED (GameId ASC,PositionId ASC),
    FOREIGN KEY (GameId) REFERENCES Game(GameId),
    FOREIGN KEY (PositionId) REFERENCES Position(PositionId)
    )
GO
-- Players
INSERT INTO dbo.Player (Birth, Death) VALUES ('1836-05-17','1900-08-12');
INSERT INTO dbo.PlayerName (PlayerId, FirstName, LastName) VALUES (@@IDENTITY, 'Wilhelm','Steinitz');
INSERT INTO dbo.Player (Birth, Death) VALUES ('1868-12-24','1941-01-11');
INSERT INTO dbo.PlayerName (PlayerId, FirstName, LastName) VALUES (@@IDENTITY, 'Emanuel','Lasker');
INSERT INTO dbo.Player (Birth, Death) VALUES ('1888-11-19','1942-03-08');
INSERT INTO dbo.PlayerName (PlayerId, FirstName, LastName) VALUES (@@IDENTITY, 'José Raúl','Capablanca');
INSERT INTO dbo.Player (Birth, Death) VALUES ('1892-11-01','1946-03-24');
INSERT INTO dbo.PlayerName (PlayerId, FirstName, LastName) VALUES (@@IDENTITY, 'Aleksandr','Alechin');
INSERT INTO dbo.Player (Birth, Death) VALUES ('1901-05-20','1981-11-26');
INSERT INTO dbo.PlayerName (PlayerId, FirstName, LastName) VALUES (@@IDENTITY, 'Max','Euwe');
INSERT INTO dbo.Player (Birth, Death) VALUES ('1911-08-17','1995-05-05');
INSERT INTO dbo.PlayerName (PlayerId, FirstName, LastName) VALUES (@@IDENTITY, 'Michail','Botvinnik');
INSERT INTO dbo.Player (Birth, Death) VALUES ('1921-03-24','2010-03-27');
INSERT INTO dbo.PlayerName (PlayerId, FirstName, LastName) VALUES (@@IDENTITY, 'Vasilij','Smyslov');
INSERT INTO dbo.Player (Birth, Death) VALUES ('1936-11-09','1992-06-28');
INSERT INTO dbo.PlayerName (PlayerId, FirstName, LastName) VALUES (@@IDENTITY, 'Michail','Tal');
INSERT INTO dbo.Player (Birth, Death) VALUES ('1929-06-17','1984-08-13');
INSERT INTO dbo.PlayerName (PlayerId, FirstName, LastName) VALUES (@@IDENTITY, 'Tigran','Petrosian');
INSERT INTO dbo.Player (Birth, Death) VALUES ('1937-01-30',NULL);
INSERT INTO dbo.PlayerName (PlayerId, FirstName, LastName) VALUES (@@IDENTITY, 'Boris','Spasskij');
INSERT INTO dbo.Player (Birth, Death) VALUES ('1943-03-09','2008-01-17');
INSERT INTO dbo.PlayerName (PlayerId, FirstName, LastName) VALUES (@@IDENTITY, 'Bobby','Fischer');
INSERT INTO dbo.Player (Birth, Death) VALUES ('1951-05-23',NULL);
INSERT INTO dbo.PlayerName (PlayerId, FirstName, LastName) VALUES (@@IDENTITY, 'Anatolij','Karpov');
INSERT INTO dbo.Player (Birth, Death) VALUES ('1963-04-13',NULL);
INSERT INTO dbo.PlayerName (PlayerId, FirstName, LastName) VALUES (@@IDENTITY, 'Garri','Kasparov');
INSERT INTO dbo.Player (Birth, Death) VALUES ('1966-01-18',NULL);
INSERT INTO dbo.PlayerName (PlayerId, FirstName, LastName) VALUES (@@IDENTITY, 'Aleksandr','Chalifman');
INSERT INTO dbo.Player (Birth, Death) VALUES ('1969-12-11',NULL);
INSERT INTO dbo.PlayerName (PlayerId, FirstName, LastName) VALUES (@@IDENTITY, 'Viswanathan','Anand');
INSERT INTO dbo.Player (Birth, Death) VALUES ('1975-06-25',NULL);
INSERT INTO dbo.PlayerName (PlayerId, FirstName, LastName) VALUES (@@IDENTITY, 'Vladimir','Kramnik');
INSERT INTO dbo.Player (Birth, Death) VALUES ('1983-10-11',NULL);
INSERT INTO dbo.PlayerName (PlayerId, FirstName, LastName) VALUES (@@IDENTITY, 'Ruslan','Ponomarjov');
INSERT INTO dbo.Player (Birth, Death) VALUES ('1975-03-15',NULL);
INSERT INTO dbo.PlayerName (PlayerId, FirstName, LastName) VALUES (@@IDENTITY, 'Veselin','Topalov');
INSERT INTO dbo.Player (Birth, Death) VALUES ('1990-11-30',NULL);
INSERT INTO dbo.PlayerName (PlayerId, FirstName, LastName) VALUES (@@IDENTITY, 'Magnus', 'Carlsen');
GO
-- Titles
INSERT INTO Title (TitleName, TitleAbbreviation) VALUES ('International Grand Master','IGM');
INSERT INTO Title (TitleName, TitleAbbreviation) VALUES ('International Master','IM');
INSERT INTO Title (TitleName, TitleAbbreviation) VALUES ('FIdE Master','FM');
INSERT INTO Title (TitleName, TitleAbbreviation) VALUES ('Womens Grand Master','WGM');
INSERT INTO Title (TitleName, TitleAbbreviation) VALUES ('Womens International Master','WIM');
GO
-- Countries
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Afghanistan','Afghanistan','AFG');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Albania','Albania','ALB');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Algeria','Algeria','ALG');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Andorra','Andorra','AND');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Angola','Angola','ANG');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Antigua','Antigua','ANT');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Argentina','Argentina','ARG');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Armenia','Armenia','ARM');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Aruba','Aruba','ARU');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('American','American','ASA');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Australia','Australia','AUS');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Austria','Austria','AUT');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Azerbaijan','Azerbaijan','AZE');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Bahamas','Bahamas','BAH');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Bangladesh','Bangladesh','BAN');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Barbados','Barbados','BAR');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Burundi','Burundi','BDI');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Belgium','Belgium','BEL');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Benin','Benin','BEN');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Bermuda','Bermuda','BER');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Bhutan','Bhutan','BHU');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Bosnia','Bosnia','BIH');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Belize','Belize','BIZ');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Belarus','Belarus','BLR');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Bolivia','Bolivia','BOL');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Botswana','Botswana','BOT');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Brazil','Brazil','BRA');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Bahrain','Bahrain','BRN');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Brunei','Brunei','BRU');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Bulgaria','Bulgaria','BUL');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Burkina','Burkina','BUR');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Central','Central','CAF');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Cambodia','Cambodia','CAM');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Canada','Canada','CAN');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Cayman','Cayman','CAY');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Congo','Congo','CGO');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Chad','Chad','CHA');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Chile','Chile','CHI');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('China','China','CHN');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Côte','Côte','CIV');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Cameroon','Cameroon','CMR');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('DR','DR','COD');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Cook','Cook','COK');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Colombia','Colombia','COL');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Comoros','Comoros','COM');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Cape','Cape','CPV');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Costa','Costa','CRC');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Croatia','Croatia','CRO');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Cuba','Cuba','CUB');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Cyprus','Cyprus','CYP');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Czech','Czech','CZE');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Denmark','Denmark','DEN');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Djibouti','Djibouti','DJI');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Dominica','Dominica','DMA');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Dominican','Dominican','DOM');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Ecuador','Ecuador','ECU');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Egypt','Egypt','EGY');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Eritrea','Eritrea','ERI');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('El','El','ESA');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Spain','Spain','ESP');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Estonia','Estonia','EST');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Ethiopia','Ethiopia','ETH');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Fiji','Fiji','FIJ');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Finland','Finland','FIN');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('France','France','FRA');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Federated','Federated','FSM');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Gabon','Gabon','GAB');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Gambia','Gambia','GAM');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Great','Great','GBR');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Guinea-Bissau','Guinea-Bissau','GBS');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Georgia','Georgia','GEO');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Equatorial','Equatorial','GEQ');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Germany','Germany','GER');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Ghana','Ghana','GHA');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Greece','Greece','GRE');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Grenada','Grenada','GRN');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Guatemala','Guatemala','GUA');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Guinea','Guinea','GUI');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Guam','Guam','GUM');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Guyana','Guyana','GUY');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Haiti','Haiti','HAI');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Hong','Hong','HKG');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Honduras','Honduras','HON');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Hungary','Hungary','HUN');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Indonesia','Indonesia','INA');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('India','India','IND');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Iran','Iran','IRI');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Ireland','Ireland','IRL');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Iraq','Iraq','IRQ');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Iceland','Iceland','ISL');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Israel','Israel','ISR');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Virgin','Virgin','ISV');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Italy','Italy','ITA');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('British','British','IVB');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Jamaica','Jamaica','JAM');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Jordan','Jordan','JOR');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Japan','Japan','JPN');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Kazakhstan','Kazakhstan','KAZ');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Kenya','Kenya','KEN');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Kyrgyzstan','Kyrgyzstan','KGZ');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Kiribati','Kiribati','KIR');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('South','South','KOR');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Saudi','Saudi','KSA');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Kuwait','Kuwait','KUW');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Laos','Laos','LAO');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Latvia','Latvia','LAT');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Libya','Libya','LBA');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Liberia','Liberia','LBR');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Saint','Saint','LCA');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Lesotho','Lesotho','LES');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Lebanon','Lebanon','LIB');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Liechtenstein','Liechtenstein','LIE');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Lithuania','Lithuania','LTU');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Luxembourg','Luxembourg','LUX');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Madagascar','Madagascar','MAD');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Morocco','Morocco','MAR');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Malaysia','Malaysia','MAS');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Malawi','Malawi','MAW');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Moldova','Moldova','MDA');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Maldives','Maldives','MDV');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Mexico','Mexico','MEX');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Mongolia','Mongolia','MGL');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Marshall','Marshall','MHL');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Macedonia','Macedonia','MKD');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Mali','Mali','MLI');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Malta','Malta','MLT');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Montenegro','Montenegro','MNE');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Monaco','Monaco','MON');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Mozambique','Mozambique','MOZ');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Mauritius','Mauritius','MRI');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Mauritania','Mauritania','MTN');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Myanmar','Myanmar','MYA');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Namibia','Namibia','NAM');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Nicaragua','Nicaragua','NCA');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Netherlands','Netherlands','NED');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Nepal','Nepal','NEP');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Nigeria','Nigeria','NGR');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Niger','Niger','NIG');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Norway','Norway','NOR');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Nauru','Nauru','NRU');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('New','New','NZL');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Oman','Oman','OMA');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Pakistan','Pakistan','PAK');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Panama','Panama','PAN');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Paraguay','Paraguay','PAR');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Peru','Peru','PER');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Philippines','Philippines','PHI');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Palestine','Palestine','PLE');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Palau','Palau','PLW');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Papua','Papua','PNG');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Poland','Poland','POL');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Portugal','Portugal','POR');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('North','North','PRK');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Puerto','Puerto','PUR');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Qatar','Qatar','QAT');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Romania','Romania','ROU');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('South','South','RSA');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Russia','Russia','RUS');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Rwanda','Rwanda','RWA');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Samoa','Samoa','SAM');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Senegal','Senegal','SEN');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Seychelles','Seychelles','SEY');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Singapore','Singapore','SIN');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Saint','Saint','SKN');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Sierra','Sierra','SLE');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Slovenia','Slovenia','SLO');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('San','San','SMR');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Solomon','Solomon','SOL');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Somalia','Somalia','SOM');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Serbia','Serbia','SRB');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Sri','Sri','SRI');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('São','São','STP');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Sudan','Sudan','SUD');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Switzerland','Switzerland','SUI');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Suriname','Suriname','SUR');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Slovakia','Slovakia','SVK');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Sweden','Sweden','SWE');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Swaziland','Swaziland','SWZ');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Syria','Syria','SYR');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Tanzania','Tanzania','TAN');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Tonga','Tonga','TGA');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Thailand','Thailand','THA');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Tajikistan','Tajikistan','TJK');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Turkmenistan','Turkmenistan','TKM');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Timor-Leste','Timor-Leste','TLS');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Togo','Togo','TOG');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Chinese','Chinese','TPE');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('TrinIdad','TrinIdad','TRI');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Tunisia','Tunisia','TUN');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Turkey','Turkey','TUR');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Tuvalu','Tuvalu','TUV');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('United','United','UAE');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Uganda','Uganda','UGA');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Ukraine','Ukraine','UKR');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Uruguay','Uruguay','URU');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('United','United','USA');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Uzbekistan','Uzbekistan','UZB');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Vanuatu','Vanuatu','VAN');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Venezuela','Venezuela','VEN');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Vietnam','Vietnam','VIE');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Saint','Saint','VIN');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Yemen','Yemen','YEM');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Zambia','Zambia','ZAM');
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAbbreviation) VALUES ('Zimbabwe','Zimbabwe','ZIM');
GO
CREATE PROCEDURE SavePosition
(
    @pFEN varchar(300),
    @pisWhiteToMove bit,
    @pCastling varchar(4),
    @pEnPassantSquare varchar(2),
    @pDrawCounter int,
    @pMaterialBalance int
)
AS
BEGIN
    IF NOT EXISTS (
        SELECT NULL FROM dbo.Position WHERE FENHASH=
            CONVERT(BINARY(20),HASHBYTES('SHA1',@pFEN + ' ' + CONVERT(VARCHAR,@pisWhiteToMove) + @pCastling + @pEnPassantSquare))
                  ) 
    -- AND FEN=@pFEN AND isWhiteToMove=@pisWhiteToMove AND Castling=@pCastling AND EnPassantSquare=@pEnPassantSquare)
    BEGIN
        INSERT INTO dbo.Position (FEN, FENHASH, isWhiteToMove, Castling, EnPassantSquare, DrawCounter, MaterialBalance) Values (@pFEN, CONVERT(BINARY(20),HASHBYTES('SHA1',@pFEN + ' ' + CONVERT(VARCHAR,@pisWhiteToMove) + @pCastling + @pEnPassantSquare)) , @pisWhiteToMove, @pCastling, @pEnPassantSquare, @pDrawCounter, @pMaterialBalance)
        --INSERT INTO dbo.Position (FEN, isWhiteToMove, Castling, EnPassantSquare, DrawCounter, MaterialBalance) Values (@pFEN, @pisWhiteToMove, @pCastling, @pEnPassantSquare, @pDrawCounter, @pMaterialBalance)
    END ELSE BEGIN
        IF @pMaterialBalance IS NOT NULL
        BEGIN
            UPDATE dbo.Position SET MaterialBalance=@pMaterialBalance WHERE FENHASH=CONVERT(BINARY(20),HASHBYTES('SHA1',@pFEN + ' ' + CONVERT(VARCHAR,@pisWhiteToMove) + @pCastling + @pEnPassantSquare))  -- AND FEN=@pFEN AND isWhiteToMove=@pisWhiteToMove AND Castling=@pCastling AND EnPassantSquare=@pEnPassantSquare
            --UPDATE dbo.Position SET MaterialBalance=@pMaterialBalance WHERE FEN=@pFEN AND isWhiteToMove=@pisWhiteToMove AND Castling=@pCastling AND EnPassantSquare=@pEnPassantSquare
        END
    END
END
GO
--CREATE PROCEDURE MergePositions
--AS
--BEGIN
---- This won't work on SQL SERVER 2005 - NEEDS TO BE 2008 OR LATER!!!
--    MERGE Position AS target
--    USING TempPosition AS source
--    ON (target.FENHASH = source.FENHASH)
----    WHEN MATCHED THEN
----        UPDATE SET target = source
--    WHEN NOT MATCHED THEN
--        INSERT (FEN,FENHASH,isWhiteToMove,Castling,EnPassantSquare,DrawCounter,MaterialBalance)
--        VALUES (source.FEN,source.FENHASH,source.isWhiteToMove,source.Castling,source.EnPassantSquare,source.DrawCounter,source.MaterialBalance);

--    TRUNCATE TABLE TempPosition
--END
USE master
GO
