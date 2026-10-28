-- MS SQL 
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- Created by Vertabelo (http://vertabelo.com)
-- Last modification date: 2025-06-12

-- tables
-- Table: Collections
CREATE TABLE Collections (
    CollectionID int NOT NULL,
    UserID int NOT NULL,
    CollectionName varchar(100) NOT NULL,
    CONSTRAINT Collections_pk PRIMARY KEY (CollectionID)
);
GO


-- Table: Favorites
CREATE TABLE Favorites (
    UserID int NOT NULL,
    RecipeID int NOT NULL,
    FavoriteID int NOT NULL,
    CONSTRAINT Favorites_pk PRIMARY KEY (UserID, RecipeID)
);
GO


-- Table: IngredientType
CREATE TABLE IngredientType (
    IngredientTypeId int NOT NULL,
    TypeName varchar(40) NOT NULL,
    TypeSpesifics varchar(80) NOT NULL,
    CONSTRAINT IngredientType_pk PRIMARY KEY (IngredientTypeId)
);
GO


-- Table: Ingredients
CREATE TABLE Ingredients (
    IngredientID int NOT NULL,
    RecipeID int NOT NULL,
    IngredientTypeID int NOT NULL,
    IngredientName varchar(20) NOT NULL,
    CONSTRAINT Ingredients_pk PRIMARY KEY (IngredientID)
);
GO


-- Table: RecipeCollections
CREATE TABLE RecipeCollections (
    RecipeID int NOT NULL,
    CollectionID int NOT NULL,
    CONSTRAINT RecipeCollections_pk PRIMARY KEY (RecipeID, CollectionID)
);
GO


-- Table: RecipeData
CREATE TABLE RecipeData (
    RecipeID int NOT NULL,
    UserID int NOT NULL,
    RecipeName varchar(100) NOT NULL,
    IngredientsSummary varchar(100) NOT NULL,
    CookingInstructions varchar(1400) NOT NULL,
    IsPublic char(1) NOT NULL,
    Likes int DEFAULT 0 NOT NULL,
    Comments int DEFAULT 0 NOT NULL,
    CONSTRAINT RecipeData_pk PRIMARY KEY (RecipeID)
);
GO


-- Table: RecipeRatings
CREATE TABLE RecipeRatings (
    RatingID int NOT NULL,
    UserID int NOT NULL,
    RecipeID int NOT NULL,
    Rating int NOT NULL,
    CONSTRAINT RecipeRatings_pk PRIMARY KEY (RatingID)
);
GO


-- Table: RecipeTags
CREATE TABLE RecipeTags (
    RecipeID int NOT NULL,
    TagID int NOT NULL,
    CONSTRAINT RecipeTags_pk PRIMARY KEY (RecipeID, TagID)
);
GO


-- Table: TagDictionary
CREATE TABLE TagDictionary (
    TagID int NOT NULL,
    TagName varchar(50) NOT NULL,
    CONSTRAINT TagDictionary_pk PRIMARY KEY (TagID),
    CONSTRAINT AK_TagName UNIQUE (TagName)
);
GO


-- Table: UserInfo
CREATE TABLE UserInfo (
    UserID int NOT NULL,
    Username varchar(50) NOT NULL,
    EmailAddress varchar(100) NOT NULL,
    CityOfResidence varchar(20) NOT NULL,
    Password varchar(10) NOT NULL,
    CONSTRAINT UserInformation_pk PRIMARY KEY (UserID),
    CONSTRAINT UserInfo_username_uq UNIQUE (Username),
    CONSTRAINT UserInfo_email_uq UNIQUE (EmailAddress)
);
GO


-- Table: UserLevel
CREATE TABLE UserLevel (
    UserID int NOT NULL,
    Ratings int DEFAULT 0 NOT NULL,
    ChefLevel int DEFAULT 0 NULL,
    CONSTRAINT UserInteractions_pk PRIMARY KEY (UserID)
);
GO


-- foreign keys
-- Reference: FK_RecipeData_UserInfo (table: RecipeData)
ALTER TABLE RecipeData ADD CONSTRAINT FK_RecipeData_UserInfo
    FOREIGN KEY (UserID)
    REFERENCES UserInfo (UserID);
GO


-- Reference: FK_UserLevel_UserInfo (table: UserLevel)
ALTER TABLE UserLevel ADD CONSTRAINT FK_UserLevel_UserInfo
    FOREIGN KEY (UserID)
    REFERENCES UserInfo (UserID);
GO


-- Reference: FK_Favorites_UserInfo (table: Favorites)
ALTER TABLE Favorites ADD CONSTRAINT FK_Favorites_UserInfo
    FOREIGN KEY (UserID)
    REFERENCES UserInfo (UserID);
GO


-- Reference: FK_Favorites_RecipeData (table: Favorites)
ALTER TABLE Favorites ADD CONSTRAINT FK_Favorites_RecipeData
    FOREIGN KEY (RecipeID)
    REFERENCES RecipeData (RecipeID);
GO


-- Reference: FK_Collections_UserInfo (table: Collections)
ALTER TABLE Collections ADD CONSTRAINT FK_Collections_UserInfo
    FOREIGN KEY (UserID)
    REFERENCES UserInfo (UserID);
GO


-- Reference: FK_RecipeCollections_RecipeData (table: RecipeCollections)
ALTER TABLE RecipeCollections ADD CONSTRAINT FK_RecipeCollections_RecipeData
    FOREIGN KEY (RecipeID)
    REFERENCES RecipeData (RecipeID);
GO


-- Reference: FK_RecipeCollections_Collections (table: RecipeCollections)
ALTER TABLE RecipeCollections ADD CONSTRAINT FK_RecipeCollections_Collections
    FOREIGN KEY (CollectionID)
    REFERENCES Collections (CollectionID);
GO


-- Reference: FK_Ingredients_IngredientType (table: Ingredients)
ALTER TABLE Ingredients ADD CONSTRAINT FK_Ingredients_IngredientType
    FOREIGN KEY (IngredientTypeID)
    REFERENCES IngredientType (IngredientTypeId);
GO


-- Reference: FK_Ingredients_RecipeData (table: Ingredients)
ALTER TABLE Ingredients ADD CONSTRAINT FK_Ingredients_RecipeData
    FOREIGN KEY (RecipeID)
    REFERENCES RecipeData (RecipeID);
GO


-- Reference: FK_RecipeRatings_RecipeData (table: RecipeRatings)
ALTER TABLE RecipeRatings ADD CONSTRAINT FK_RecipeRatings_RecipeData
    FOREIGN KEY (RecipeID)
    REFERENCES RecipeData (RecipeID);
GO


-- Reference: FK_RecipeRatings_UserInfo (table: RecipeRatings)
ALTER TABLE RecipeRatings ADD CONSTRAINT FK_RecipeRatings_UserInfo
    FOREIGN KEY (UserID)
    REFERENCES UserInfo (UserID);
GO


-- Reference: FK_RecipeTags_TagDictionary (table: RecipeTags)
ALTER TABLE RecipeTags ADD CONSTRAINT FK_RecipeTags_TagDictionary
    FOREIGN KEY (TagID)
    REFERENCES TagDictionary (TagID);
GO


-- Reference: FK_RecipeTags_RecipeData (table: RecipeTags)
ALTER TABLE RecipeTags ADD CONSTRAINT FK_RecipeTags_RecipeData
    FOREIGN KEY (RecipeID)
    REFERENCES RecipeData (RecipeID);
GO
