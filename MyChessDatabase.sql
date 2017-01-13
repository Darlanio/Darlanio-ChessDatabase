-- MyChessDatabase by Stefan "Darlanio" Alenius
--
-- Problems/TODO:
-- Storage of positions is ineffective since this implementation is using FEN. For larger databases huffman packing of chesspositions should be used.
-- Storage of several positions is ineffective since we are not using a separate table for storing all potentially new positions and then merge it into the table Position
-- For this last problem I have added a comment last in this file, which is a stored procedure to be used on newer databases.
USE master
GO
DROP DATABASE MyChessDatabase
GO
CREATE DATABASE MyChessDatabase
COLLATE Finnish_Swedish_CS_AS 
GO
USE MyChessDatabase
GO
---------------------
-- Player Database --
---------------------
CREATE TABLE Title (
    TitleId int IDENTITY(1,1) NOT NULL,
    TitleName varchar(300),
    TitleAbbreviation varchar(30),

    PRIMARY KEY CLUSTERED (TitleId ASC)
    )
GO
CREATE TABLE Player (
    PlayerId int IDENTITY(1,1) NOT NULL,
    Birth datetime,
    Death datetime,

    PRIMARY KEY CLUSTERED (PlayerId ASC)
    )
GO
CREATE TABLE PlayerName (
    PlayerNamesId int IDENTITY(1,1) NOT NULL,
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
    CountryId int IDENTITY(1,1) NOT NULL,
    CountryName varchar(300) NOT NULL,
    CountryFullName varchar(300) NOT NULL,
	CountryAlpha2Code varchar(2),
    CountryAbbreviation varchar(3),
	CountryNumericCode int NOT NULL,

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
    ELOId int IDENTITY(1,1) NOT NULL,
    PlayerId int NOT NULL,
    ELO int,
    StartDate datetime,
    EndDate datetime,

    PRIMARY KEY CLUSTERED (ELOId ASC),
    FOREIGN KEY (PlayerId) REFERENCES Player(PlayerId)
    )
GO
-------------------
-- Game database --
-------------------
CREATE TABLE Position (
    PositionId int IDENTITY(1,1) NOT NULL,
    FEN varchar(300) NOT NULL,
    FENHASH BINARY(20) NOT NULL,
    isWhiteToMove bit NOT NULL,
    Castling varchar(4), -- Kanske skall ändra typ på denna kolumn?
    EnPassantSquare varchar(2), -- changed from int 2013-07-24
    MaterialBalance INT NULL, -- used as flag when filling up database. NULL for children, correct calculated value for parents.

	PRIMARY KEY CLUSTERED (PositionId ASC),	
    )
GO
--CREATE INDEX IdX_Position_FENHASH_FEN ON Position (PositionId ASC, FENHASH ASC, FEN ASC)
CREATE INDEX IdX_Position_FENHASH ON Position (FENHASH ASC) -- PositionId kommer automatiskt med
--CREATE INDEX IdX_Position_FEN ON Position (PositionId ASC, FEN ASC)
CREATE INDEX IdX_Position_MaterialBalance ON Position (MaterialBalance ASC)
GO
CREATE TABLE TempPosition (
    PositionId int IDENTITY(1,1) NOT NULL,
    FEN varchar(300) NOT NULL,
    FENHASH BINARY(20) NOT NULL,
    isWhiteToMove bit NOT NULL,
    Castling varchar(4), -- Kanske skall ändra typ på denna kolumn?
    EnPassantSquare varchar(2), -- changed from int 2013-07-24
    MaterialBalance INT NULL, -- used as flag when filling up database. NULL for children, correct calculated value for parents.

	PRIMARY KEY CLUSTERED (PositionId ASC),	
    )
GO
CREATE TABLE Evaluation (
	EvaluationId int IDENTITY(1,1) NOT NULL,
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
    EventId int IDENTITY(1,1) NOT NULL,
    [Event] varchar(300),
    EventStartDate datetime,
    EventEndDate datetime,
    [Site] varchar(300),

	PRIMARY KEY CLUSTERED (EventId ASC)
    )
GO
CREATE TABLE Result (
    ResultId int IDENTITY(1,1) NOT NULL,
    Result VARCHAR(10) NOT NULL,
    
    PRIMARY KEY (ResultId ASC)
    )
GO
INSERT INTO Result (Result) VALUES ('0-0');
INSERT INTO Result (Result) VALUES ('1-0');
INSERT INTO Result (Result) VALUES ('1/2-1/2');
INSERT INTO Result (Result) VALUES ('0-1');
GO
CREATE TABLE Game (
    GameId int IDENTITY(1,1) NOT NULL,
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
CREATE TABLE Moves (
    ParentPositionId INT NOT NULL,
    ChildPositionId INT NOT NULL,
	GameId INT NOT NULL,
	MoveNumber int NOT NULL,
    DrawCounter int NULL,
	alfanumerical varchar(6), -- "e2e4", "g1f3", "e1g1", "a7a8Q"
	pgn varchar(20), -- "e4", "Nf3", "O-O", "a8Q", "a8=Q"
	fullpgn varchar(20), -- "e2-e4", "Ng1-f3", "O-O", "a7-a8=Q"
    
    PRIMARY KEY CLUSTERED (ParentPositionId ASC,ChildPositionId ASC, GameId ASC, MoveNumber ASC),
	FOREIGN KEY (ParentPositionId) REFERENCES Position(PositionId),
	FOREIGN KEY (ChildPositionId) REFERENCES Position(PositionId),
	FOREIGN KEY (GameId) REFERENCES Game(GameId)
    )
GO
--CREATE TABLE GamePosition (
--    GameId int NOT NULL,
--    PositionId int NOT NULL,
--    MoveNumber int,
--
--    PRIMARY KEY CLUSTERED (GameId ASC,PositionId ASC),
--    FOREIGN KEY (GameId) REFERENCES Game(GameId),
--    FOREIGN KEY (PositionId) REFERENCES Position(PositionId)
--    )
--GO
-- Titles
INSERT INTO Title (TitleName, TitleAbbreviation) VALUES ('International Grand Master','IGM');
INSERT INTO Title (TitleName, TitleAbbreviation) VALUES ('International Master','IM');
INSERT INTO Title (TitleName, TitleAbbreviation) VALUES ('FIdE Master','FM');
INSERT INTO Title (TitleName, TitleAbbreviation) VALUES ('Womens Grand Master','WGM');
INSERT INTO Title (TitleName, TitleAbbreviation) VALUES ('Womens International Master','WIM');
GO
-- Countries
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Afghanistan','Islamic Republic of Afghanistan','AF','AFG',4);
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Åland','Åland Islands','AX','ALA',248);
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Albania','Republic of Albania','AL','ALB',8);
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Algeria','People''s Democratic Republic of Algeria','DZ','DZA',12);
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('American Samoa','American Samoa','AS','ASM',16);
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Andorra','Principality of Andorra','AD','AND',20);
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Angola','Republic of Angola','AO','AGO',24);
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Anguilla','Anguilla','AI','AIA',660);
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Antarctica','Antarctica','AQ','ATA',10);
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Antigua and Barbuda','Antigua and Barbuda','AG','ATG',28);
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Argentina','Argentine Republic','AR','ARG',32);
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Armenia','Republic of Armenia','AM','ARM',51);
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Aruba','Aruba','AW','ABW',533);
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Australia','Commonwealth of Australia','AU','AUS',36);
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Austria','Republic of Austria','AT','AUT',40);
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Azerbaijan','Republic of Azerbaijan','AZ','AZE',31);
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Bahamas, The','Commonwealth of the Bahamas','BS','BHS',44);
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Bahrain','Kingdom of Bahrain','BH','BHR',48);
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Bangladesh','People''s Republic of Bangladesh','BD','BGD',50);
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Barbados','Barbados','BB','BRB',52);
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Belarus','Republic of Belarus','BY','BLR',112);
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Belgium','Kingdom of Belgium','BE','BEL',56);
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Belize','Belize','BZ','BLZ',84);
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Benin','Republic of Benin','BJ','BEN',204);
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Bermuda','Bermuda','BM','BMU',60);
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Bhutan','Kingdom of Bhutan','BT','BTN',64);
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Bolivia','Plurinational State of Bolivia','BO','BOL',68);
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Bonaire, Sint Eustatius and Saba','Bonaire, Sint Eustatius and Saba','BQ','BES',535);
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Bosnia and Herzegovina','Bosnia and Herzegovina','BA','BIH',70);
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Botswana','Republic of Botswana','BW','BWA',72);
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Bouvet Island','Bouvet Island','BV','BVT',74);
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Brazil','Federative Republic of Brazil','BR','BRA',76);
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('British Indian Ocean Territory','British Indian Ocean Territory','IO','IOT',86);
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Brunei Darussalam','Nation of Brunei, Abode of Peace','BN','BRN',96);
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Bulgaria','Republic of Bulgaria','BG','BGR',100);
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Burkina Faso','Burkina Faso','BF','BFA',854);
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Burundi','Republic of Burundi','BI','BDI',108);
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Cambodia','Kingdom of Cambodia','KH','KHM',116);
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Cameroon','Republic of Cameroon','CM','CMR',120);
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Canada','Canada','CA','CAN',124);
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Cape Verde','Republic of Cabo Verde','CV','CPV',132);
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Cayman Islands','Cayman Islands','KY','CYM',136);
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Central African Republic','Central African Republic','CF','CAF',140);
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Chad','Republic of Chad','TD','TCD',148);
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Chile','Republic of Chile','CL','CHL',152);
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('China','People''s Republic of China','CN','CHN',156);
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Christmas Island','Christmas Island','CX','CXR',162);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Cocos (Keeling) Islands','CC','CCK',166);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Colombia','CO','COL',170);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Comoros','KM','COM',174);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Congo','CG','COG',178);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Congo, the Democratic Republic of the','CD','COD',180);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Cook Islands','CK','COK',184);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Costa Rica','CR','CRI',188);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Côte d''Ivoire','CI','CIV',384);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Croatia','HR','HRV',191);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Cuba','CU','CUB',192);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Curaçao','CW','CUW',531);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Cyprus','CY','CYP',196);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Czech Republic','CZ','CZE',203);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Denmark','DK','DNK',208);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Djibouti','DJ','DJI',262);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Dominica','DM','DMA',212);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Dominican Republic','DO','DOM',214);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Ecuador','EC','ECU',218);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Egypt','EG','EGY',818);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('El Salvador','SV','SLV',222);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Equatorial Guinea','GQ','GNQ',226);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Eritrea','ER','ERI',232);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Estonia','EE','EST',233);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Ethiopia','ET','ETH',231);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Falkland Islands (Malvinas)','FK','FLK',238);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Faroe Islands','FO','FRO',234);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Fiji','FJ','FJI',242);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Finland','FI','FIN',246);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('France','FR','FRA',250);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('French Guiana','GF','GUF',254);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('French Polynesia','PF','PYF',258);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('French Southern Territories','TF','ATF',260);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Gabon','GA','GAB',266);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Gambia','GM','GMB',270);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Georgia','GE','GEO',268);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Germany','DE','DEU',276);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Ghana','GH','GHA',288);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Gibraltar','GI','GIB',292);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Greece','GR','GRC',300);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Greenland','GL','GRL',304);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Grenada','GD','GRD',308);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Guadeloupe','GP','GLP',312);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Guam','GU','GUM',316);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Guatemala','GT','GTM',320);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Guernsey','GG','GGY',831);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Guinea','GN','GIN',324);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Guinea-Bissau','GW','GNB',624);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Guyana','GY','GUY',328);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Haiti','HT','HTI',332);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Heard Island and McDonald Islands','HM','HMD',334);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Holy See (Vatican City State)','VA','VAT',336);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Honduras','HN','HND',340);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Hong Kong','HK','HKG',344);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Hungary','HU','HUN',348);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Iceland','IS','ISL',352);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('India','IN','IND',356);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Indonesia','ID','IDN',360);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Iran, Islamic Republic of','IR','IRN',364);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Iraq','IQ','IRQ',368);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Ireland','IE','IRL',372);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Isle of Man','IM','IMN',833);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Israel','IL','ISR',376);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Italy','IT','ITA',380);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Jamaica','JM','JAM',388);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Japan','JP','JPN',392);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Jersey','JE','JEY',832);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Jordan','JO','JOR',400);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Kazakhstan','KZ','KAZ',398);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Kenya','KE','KEN',404);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Kiribati','KI','KIR',296);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Korea, Democratic People''s Republic of','KP','PRK',408);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Korea, Republic of','KR','KOR',410);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Kuwait','KW','KWT',414);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Kyrgyzstan','KG','KGZ',417);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Lao People''s Democratic Republic','LA','LAO',418);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Latvia','LV','LVA',428);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Lebanon','LB','LBN',422);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Lesotho','LS','LSO',426);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Liberia','LR','LBR',430);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Libya','LY','LBY',434);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Liechtenstein','LI','LIE',438);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Lithuania','LT','LTU',440);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Luxembourg','LU','LUX',442);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Macao','MO','MAC',446);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Macedonia, the former Yugoslav Republic of','MK','MKD',807);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Madagascar','MG','MDG',450);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Malawi','MW','MWI',454);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Malaysia','MY','MYS',458);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Maldives','MV','MDV',462);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Mali','ML','MLI',466);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Malta','MT','MLT',470);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Marshall Islands','MH','MHL',584);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Martinique','MQ','MTQ',474);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Mauritania','MR','MRT',478);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Mauritius','MU','MUS',480);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Mayotte','YT','MYT',175);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Mexico','MX','MEX',484);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Micronesia, Federated States of','FM','FSM',583);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Moldova, Republic of','MD','MDA',498);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Monaco','MC','MCO',492);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Mongolia','MN','MNG',496);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Montenegro','ME','MNE',499);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Montserrat','MS','MSR',500);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Morocco','MA','MAR',504);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Mozambique','MZ','MOZ',508);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Myanmar','MM','MMR',104);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Namibia','NA','NAM',516);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Nauru','NR','NRU',520);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Nepal','NP','NPL',524);

INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Netherlands','Kingdom of the Netherlands','NL','NLD',528);

--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('New Caledonia','NC','NCL',540);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('New Zealand','NZ','NZL',554);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Nicaragua','NI','NIC',558);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Niger','NE','NER',562);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Nigeria','NG','NGA',566);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Niue','NU','NIU',570);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Norfolk Island','NF','NFK',574);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Northern Mariana Islands','MP','MNP',580);

INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Norway','Kingdom of Norway','NO','NOR',578);

--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Oman','OM','OMN',512);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Pakistan','PK','PAK',586);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Palau','PW','PLW',585);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Palestine, State of','PS','PSE',275);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Panama','PA','PAN',591);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Papua New Guinea','PG','PNG',598);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Paraguay','PY','PRY',600);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Peru','PE','PER',604);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Philippines','PH','PHL',608);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Pitcairn','PN','PCN',612);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Poland','PL','POL',616);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Portugal','PT','PRT',620);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Puerto Rico','PR','PRI',630);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Qatar','QA','QAT',634);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Réunion','RE','REU',638);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Romania','RO','ROU',642);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Russian Federation','RU','RUS',643);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Rwanda','RW','RWA',646);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Saint Barthélemy','BL','BLM',652);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Saint Helena, Ascension and Tristan da Cunha','SH','SHN',654);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Saint Kitts and Nevis','KN','KNA',659);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Saint Lucia','LC','LCA',662);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Saint Martin (French part)','MF','MAF',663);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Saint Pierre and Miquelon','PM','SPM',666);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Saint Vincent and the Grenadines','VC','VCT',670);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Samoa','WS','WSM',882);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('San Marino','SM','SMR',674);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Sao Tome and Principe','ST','STP',678);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Saudi Arabia','SA','SAU',682);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Senegal','SN','SEN',686);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Serbia','RS','SRB',688);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Seychelles','SC','SYC',690);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Sierra Leone','SL','SLE',694);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Singapore','SG','SGP',702);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Sint Maarten (Dutch part)','SX','SXM',534);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Slovakia','SK','SVK',703);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Slovenia','SI','SVN',705);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Solomon Islands','SB','SLB',90);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Somalia','SO','SOM',706);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('South Africa','ZA','ZAF',710);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('South Georgia and the South Sandwich Islands','GS','SGS',239);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('South Sudan','SS','SSD',728);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Spain','ES','ESP',724);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Sri Lanka','LK','LKA',144);
--INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Sudan','SD','SDN',729);

INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Suriname','Republic of Suriname','SR','SUR',740);
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Svalbard and Jan Mayen','Svalbard and Jan Mayen','SJ','SJM',744);
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Swaziland','Kingdom of Swaziland','SZ','SWZ',748);
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Sweden','Kingdom of Sweden','SE','SWE',752);
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Switzerland','Swiss Confederation','CH','CHE',756);
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Syria','Syrian Arab Republic','SY','SYR',760);
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Taiwan','Taiwan, Province of China','TW','TWN',158);
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Tajikistan','Republic of Tajikistan','TJ','TJK',762);
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Tanzania','United Republic of Tanzania','TZ','TZA',834);
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Thailand','Kingdom of Thailand','TH','THA',764);
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('East Timor','Democratic Republic of Timor-Leste','TL','TLS',626);
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Togo','Togolese Republic','TG','TGO',768);
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Tokelau','Tokelau','TK','TKL',772);
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Tonga','Kingdom of Tonga','TO','TON',776);
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Transnistria','Pridnestrovian Moldavian Republic',null,null,776);
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Trinidad and Tobago','Republic of Trinidad and Tobago','TT','TTO',780);
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Tunisia','Republic of Tunisia','TN','TUN',788);
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Turkey','Republic of Turkey','TR','TUR',792);
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Turkmenistan','Turkmenistan','TM','TKM',795);
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Turks and Caicos Islands','Turks and Caicos Islands','TC','TCA',796);
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Tuvalu','Tuvalu','TV','TUV',798);
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Uganda','Republic of Uganda','UG','UGA',800);
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Ukraine','Ukraine','UA','UKR',804);
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('United Arab Emirates','United Arab Emirates','AE','ARE',784);
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('United Kingdom','United Kingdom of Great Britain and Northern Ireland','GB','GBR',826);
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('United States','United States of America','US','USA',840);
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('United States Minor Outlying Islands','United States Minor Outlying Islands','UM','UMI',581);
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Uruguay','Oriental Republic of Uruguay','UY','URY',858);
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Uzbekistan','Republic of Uzbekistan','UZ','UZB',860);
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Vanuatu','Republic of Vanuatu','VU','VUT',548);
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Venezuela','Bolivarian Republic of Venezuela','VE','VEN',862);
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Viet Nam','Socialist Republic of Viet Nam','VN','VNM',704);
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Virgin Islands, British','Virgin Islands, British','VG','VGB',92);
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Virgin Islands, U.S.','Virgin Islands, U.S.','VI','VIR',850);
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Wallis and Futuna','Wallis and Futuna','WF','WLF',876);
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Western Sahara','Western Sahara','EH','ESH',732);
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Yemen','Republic of Yemen','YE','YEM',887);
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Zambia','Republic of Zambia','ZM','ZMB',894);
INSERT INTO [MyChessDatabase].[dbo].[Country] (CountryName, CountryFullName, CountryAlpha2Code, CountryAbbreviation, CountryNumericCode) VALUES ('Zimbabwe','Republic of Zimbabwe','ZW','ZWE',716);
GO
-- Players
DECLARE @PlayerID int
DECLARE @CountryId int
INSERT INTO dbo.Player (Birth, Death) VALUES ('1836-05-17','1900-08-12');
SET @PlayerId = @@IDENTITY
INSERT INTO dbo.PlayerName (PlayerId, FirstName, LastName) VALUES (@PlayerId, 'Wilhelm','Steinitz');
SELECT @CountryId=CountryId FROM [MyChessDatabase].[dbo].[Country] WHERE CountryAbbreviation='AUT';
INSERT INTO dbo.PlayerCountry (PlayerId, CountryId, StartDate, EndDate) VALUES (@PlayerId, @CountryId, '1836-05-17', '1883-06-30');
SELECT @CountryId=CountryId FROM [MyChessDatabase].[dbo].[Country] WHERE CountryAbbreviation='USA';
INSERT INTO dbo.PlayerCountry (PlayerId, CountryId, StartDate, EndDate) VALUES (@PlayerId, @CountryId, '1883-07-01', '1900-08-12');

INSERT INTO dbo.Player (Birth, Death) VALUES ('1868-12-24','1941-01-11');
SET @PlayerId = @@IDENTITY
INSERT INTO dbo.PlayerName (PlayerId, FirstName, LastName) VALUES (@PlayerId, 'Emanuel','Lasker');
INSERT INTO dbo.Player (Birth, Death) VALUES ('1888-11-19','1942-03-08');
SET @PlayerId = @@IDENTITY
INSERT INTO dbo.PlayerName (PlayerId, FirstName, LastName) VALUES (@PlayerId, 'José Raúl','Capablanca');
INSERT INTO dbo.Player (Birth, Death) VALUES ('1892-11-01','1946-03-24');
SET @PlayerId = @@IDENTITY
INSERT INTO dbo.PlayerName (PlayerId, FirstName, LastName) VALUES (@PlayerId, 'Aleksandr','Alechin');
INSERT INTO dbo.Player (Birth, Death) VALUES ('1901-05-20','1981-11-26');
SET @PlayerId = @@IDENTITY
INSERT INTO dbo.PlayerName (PlayerId, FirstName, LastName) VALUES (@PlayerId, 'Max','Euwe');
INSERT INTO dbo.Player (Birth, Death) VALUES ('1911-08-17','1995-05-05');
SET @PlayerId = @@IDENTITY
INSERT INTO dbo.PlayerName (PlayerId, FirstName, LastName) VALUES (@PlayerId, 'Michail','Botvinnik');
INSERT INTO dbo.Player (Birth, Death) VALUES ('1921-03-24','2010-03-27');
SET @PlayerId = @@IDENTITY
INSERT INTO dbo.PlayerName (PlayerId, FirstName, LastName) VALUES (@PlayerId, 'Vasilij','Smyslov');
INSERT INTO dbo.Player (Birth, Death) VALUES ('1936-11-09','1992-06-28');
SET @PlayerId = @@IDENTITY
INSERT INTO dbo.PlayerName (PlayerId, FirstName, LastName) VALUES (@PlayerId, 'Michail','Tal');
INSERT INTO dbo.Player (Birth, Death) VALUES ('1929-06-17','1984-08-13');
SET @PlayerId = @@IDENTITY
INSERT INTO dbo.PlayerName (PlayerId, FirstName, LastName) VALUES (@PlayerId, 'Tigran','Petrosian');
INSERT INTO dbo.Player (Birth, Death) VALUES ('1937-01-30',NULL);
SET @PlayerId = @@IDENTITY
INSERT INTO dbo.PlayerName (PlayerId, FirstName, LastName) VALUES (@PlayerId, 'Boris','Spasskij');
INSERT INTO dbo.Player (Birth, Death) VALUES ('1943-03-09','2008-01-17');
SET @PlayerId = @@IDENTITY
INSERT INTO dbo.PlayerName (PlayerId, FirstName, LastName) VALUES (@PlayerId, 'Bobby','Fischer');
INSERT INTO dbo.Player (Birth, Death) VALUES ('1951-05-23',NULL);
SET @PlayerId = @@IDENTITY
INSERT INTO dbo.PlayerName (PlayerId, FirstName, LastName) VALUES (@PlayerId, 'Anatolij','Karpov');
INSERT INTO dbo.Player (Birth, Death) VALUES ('1963-04-13',NULL);
SET @PlayerId = @@IDENTITY
INSERT INTO dbo.PlayerName (PlayerId, FirstName, LastName) VALUES (@PlayerId, 'Garri','Kasparov');
INSERT INTO dbo.Player (Birth, Death) VALUES ('1966-01-18',NULL);
SET @PlayerId = @@IDENTITY
INSERT INTO dbo.PlayerName (PlayerId, FirstName, LastName) VALUES (@PlayerId, 'Aleksandr','Chalifman');
INSERT INTO dbo.Player (Birth, Death) VALUES ('1969-12-11',NULL);
SET @PlayerId = @@IDENTITY
INSERT INTO dbo.PlayerName (PlayerId, FirstName, LastName) VALUES (@PlayerId, 'Viswanathan','Anand');
INSERT INTO dbo.Player (Birth, Death) VALUES ('1975-06-25',NULL);
SET @PlayerId = @@IDENTITY
INSERT INTO dbo.PlayerName (PlayerId, FirstName, LastName) VALUES (@PlayerId, 'Vladimir','Kramnik');
INSERT INTO dbo.Player (Birth, Death) VALUES ('1983-10-11',NULL);
SET @PlayerId = @@IDENTITY
INSERT INTO dbo.PlayerName (PlayerId, FirstName, LastName) VALUES (@PlayerId, 'Ruslan','Ponomarjov');
INSERT INTO dbo.Player (Birth, Death) VALUES ('1975-03-15',NULL);
SET @PlayerId = @@IDENTITY
INSERT INTO dbo.PlayerName (PlayerId, FirstName, LastName) VALUES (@PlayerId, 'Veselin','Topalov');

INSERT INTO dbo.Player (Birth, Death) VALUES ('1990-11-30',NULL);
SET @PlayerId = @@IDENTITY
INSERT INTO dbo.PlayerName (PlayerId, FirstName, LastName) VALUES (@PlayerId, 'Magnus', 'Carlsen');
SELECT @CountryId=CountryId FROM [MyChessDatabase].[dbo].[Country] WHERE CountryAbbreviation='NOR'
INSERT INTO dbo.PlayerCountry (PlayerId, CountryId, StartDate, EndDate) VALUES (@PlayerId, @CountryId, '1990-11-30', NULL);
GO
CREATE FUNCTION GetFENHASH
(   
    @pFEN varchar(300),
    @pisWhiteToMove bit,
    @pCastling varchar(4),
    @pEnPassantSquare varchar(2)
)
RETURNS BINARY(20)
AS
BEGIN
    DECLARE @hash int
	SET @hash = CONVERT(BINARY(20),HASHBYTES('SHA1',@pFEN + ' ' + CONVERT(VARCHAR,@pisWhiteToMove) + @pCastling + @pEnPassantSquare))
    RETURN @hash
END
GO
CREATE PROCEDURE SavePosition
(
    @pFEN varchar(300),
    @pisWhiteToMove bit,
    @pCastling varchar(4),
    @pEnPassantSquare varchar(2),
    @pMaterialBalance int
)
AS
BEGIN
    IF NOT EXISTS (
--        SELECT NULL FROM dbo.Position WHERE FENHASH=dbo.GetFENHASH(@pFEN,@pisWhiteToMove,@pCastling,@pEnPassantSquare)
        SELECT NULL FROM dbo.Position WHERE FENHASH=CONVERT(BINARY(20),HASHBYTES('SHA1',@pFEN + ' ' + CONVERT(VARCHAR,@pisWhiteToMove) + @pCastling + @pEnPassantSquare))
                  ) 
    -- AND FEN=@pFEN AND isWhiteToMove=@pisWhiteToMove AND Castling=@pCastling AND EnPassantSquare=@pEnPassantSquare)
    BEGIN
        INSERT INTO dbo.Position (FEN, FENHASH, isWhiteToMove, Castling, EnPassantSquare, MaterialBalance) Values (@pFEN, CONVERT(BINARY(20),HASHBYTES('SHA1',@pFEN + ' ' + CONVERT(VARCHAR,@pisWhiteToMove) + @pCastling + @pEnPassantSquare)) , @pisWhiteToMove, @pCastling, @pEnPassantSquare, @pMaterialBalance)
    END ELSE BEGIN
        IF @pMaterialBalance IS NOT NULL
        BEGIN
            UPDATE dbo.Position SET MaterialBalance=@pMaterialBalance WHERE FENHASH=CONVERT(BINARY(20),HASHBYTES('SHA1',@pFEN + ' ' + CONVERT(VARCHAR,@pisWhiteToMove) + @pCastling + @pEnPassantSquare))  -- AND FEN=@pFEN AND isWhiteToMove=@pisWhiteToMove AND Castling=@pCastling AND EnPassantSquare=@pEnPassantSquare
        END
    END
	--SELECT PositionId FROM dbo.Position WHERE FENHASH=dbo.GetFENHASH(@pFEN,@pisWhiteToMove,@pCastling,@pEnPassantSquare) --AND FEN=@pFEN AND isWhiteToMove=@pisWhiteToMove AND Castling=@pCastling AND EnPassantSquare=@pEnPassantSquare
	SELECT PositionId FROM dbo.Position WHERE FENHASH = CONVERT(BINARY(20),HASHBYTES('SHA1',@pFEN + ' ' + CONVERT(VARCHAR,@pisWhiteToMove) + @pCastling + @pEnPassantSquare))
END
GO
CREATE PROCEDURE MergePositions
AS
BEGIN
-- This won't work on SQL SERVER 2005 - NEEDS TO BE 2008 OR LATER!!!
    MERGE Position AS target
    USING TempPosition AS source
    ON (target.FENHASH = source.FENHASH AND target.FEN=source.FEN AND target.isWhiteToMove=source.isWhiteToMove AND target.Castling=source.Castling AND target.EnPassantSquare=source.EnPassantSquare)
--    WHEN MATCHED THEN
--        UPDATE SET target.isWhiteToMove = source.isWhiteToMove
    WHEN NOT MATCHED THEN
        INSERT (FEN,FENHASH,isWhiteToMove,Castling,EnPassantSquare,MaterialBalance)
        VALUES (source.FEN,source.FENHASH,source.isWhiteToMove,source.Castling,source.EnPassantSquare,source.MaterialBalance);
    --OUTPUT inserted.*, deleted.*;

    TRUNCATE TABLE TempPosition
END
GO
USE master
GO
