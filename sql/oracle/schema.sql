-- Created by Vertabelo (http://vertabelo.com)
-- Last modification date: 2025-06-12

-- tables
-- Table: Collections
CREATE TABLE Collections (
    CollectionID integer NOT NULL,
    UserID integer NOT NULL,
    CollectionName varchar2(100) NOT NULL,
    CONSTRAINT Collections_pk PRIMARY KEY (CollectionID)
);

-- Table: Favorites
CREATE TABLE Favorites (
    UserID integer NOT NULL,
    RecipeID integer NOT NULL,
    FavoriteID integer NOT NULL,
    CONSTRAINT Favorites_pk PRIMARY KEY (UserID, RecipeID)
);

-- Table: IngredientType
CREATE TABLE IngredientType (
    IngredientTypeId integer NOT NULL,
    TypeName varchar2(40) NOT NULL,
    TypeSpesifics varchar2(80) NOT NULL,
    CONSTRAINT IngredientType_pk PRIMARY KEY (IngredientTypeId)
);

-- Table: Ingredients
CREATE TABLE Ingredients (
    IngredientID integer NOT NULL,
    RecipeID integer NOT NULL,
    IngredientTypeID integer NOT NULL,
    IngredientName varchar2(20) NOT NULL,
    CONSTRAINT Ingredients_pk PRIMARY KEY (IngredientID)
);

-- Table: RecipeCollections
CREATE TABLE RecipeCollections (
    RecipeID integer NOT NULL,
    CollectionID integer NOT NULL,
    CONSTRAINT RecipeCollections_pk PRIMARY KEY (RecipeID, CollectionID)
);

-- Table: RecipeData
CREATE TABLE RecipeData (
    RecipeID integer NOT NULL,
    UserID integer NOT NULL,
    RecipeName varchar2(100) NOT NULL,
    IngredientsSummary varchar2(100) NOT NULL,
    CookingInstructions varchar2(1400) NOT NULL,
    IsPublic char(1) NOT NULL,
    Likes integer DEFAULT 0 NOT NULL,
    Comments integer DEFAULT 0 NOT NULL,
    CONSTRAINT RecipeData_pk PRIMARY KEY (RecipeID)
);

-- Table: RecipeRatings
CREATE TABLE RecipeRatings (
    RatingID integer NOT NULL,
    UserID integer NOT NULL,
    RecipeID integer NOT NULL,
    Rating integer NOT NULL,
    CONSTRAINT RecipeRatings_pk PRIMARY KEY (RatingID)
);

-- Table: RecipeTags
CREATE TABLE RecipeTags (
    RecipeID integer NOT NULL,
    TagID integer NOT NULL,
    CONSTRAINT RecipeTags_pk PRIMARY KEY (RecipeID, TagID)
);

-- Table: TagDictionary
CREATE TABLE TagDictionary (
    TagID integer NOT NULL,
    TagName varchar2(50) NOT NULL,
    CONSTRAINT TagDictionary_pk PRIMARY KEY (TagID),
    CONSTRAINT AK_TagName UNIQUE (TagName)
);

-- Table: UserInfo
CREATE TABLE UserInfo (
    UserID integer NOT NULL,
    Username varchar2(50) NOT NULL,
    EmailAddress varchar2(100) NOT NULL,
    CityOfResidence varchar2(20) NOT NULL,
    Password varchar2(10) NOT NULL,
    CONSTRAINT UserInformation_pk PRIMARY KEY (UserID),
    CONSTRAINT UserInfo_username_uq UNIQUE (Username),
    CONSTRAINT UserInfo_email_uq UNIQUE (EmailAddress)
);

-- Table: UserLevel
CREATE TABLE UserLevel (
    UserID integer NOT NULL,
    Ratings integer DEFAULT 0 NOT NULL,
    ChefLevel integer DEFAULT 0 NULL,
    CONSTRAINT UserInteractions_pk PRIMARY KEY (UserID)
);

-- foreign keys
-- Reference: FK_RecipeData_UserInfo (table: RecipeData)
ALTER TABLE RecipeData ADD CONSTRAINT FK_RecipeData_UserInfo
    FOREIGN KEY (UserID)
    REFERENCES UserInfo (UserID);

-- Reference: FK_UserLevel_UserInfo (table: UserLevel)
ALTER TABLE UserLevel ADD CONSTRAINT FK_UserLevel_UserInfo
    FOREIGN KEY (UserID)
    REFERENCES UserInfo (UserID);

-- Reference: FK_Favorites_UserInfo (table: Favorites)
ALTER TABLE Favorites ADD CONSTRAINT FK_Favorites_UserInfo
    FOREIGN KEY (UserID)
    REFERENCES UserInfo (UserID);

-- Reference: FK_Favorites_RecipeData (table: Favorites)
ALTER TABLE Favorites ADD CONSTRAINT FK_Favorites_RecipeData
    FOREIGN KEY (RecipeID)
    REFERENCES RecipeData (RecipeID);

-- Reference: FK_Collections_UserInfo (table: Collections)
ALTER TABLE Collections ADD CONSTRAINT FK_Collections_UserInfo
    FOREIGN KEY (UserID)
    REFERENCES UserInfo (UserID);

-- Reference: FK_RecipeCollections_RecipeData (table: RecipeCollections)
ALTER TABLE RecipeCollections ADD CONSTRAINT FK_RecipeCollections_RecipeData
    FOREIGN KEY (RecipeID)
    REFERENCES RecipeData (RecipeID);

-- Reference: FK_RecipeCollections_Collections (table: RecipeCollections)
ALTER TABLE RecipeCollections ADD CONSTRAINT FK_RecipeCollections_Collections
    FOREIGN KEY (CollectionID)
    REFERENCES Collections (CollectionID);

-- Reference: FK_Ingredients_IngredientType (table: Ingredients)
ALTER TABLE Ingredients ADD CONSTRAINT FK_Ingredients_IngredientType
    FOREIGN KEY (IngredientTypeID)
    REFERENCES IngredientType (IngredientTypeId);

-- Reference: FK_Ingredients_RecipeData (table: Ingredients)
ALTER TABLE Ingredients ADD CONSTRAINT FK_Ingredients_RecipeData
    FOREIGN KEY (RecipeID)
    REFERENCES RecipeData (RecipeID);

-- Reference: FK_RecipeRatings_RecipeData (table: RecipeRatings)
ALTER TABLE RecipeRatings ADD CONSTRAINT FK_RecipeRatings_RecipeData
    FOREIGN KEY (RecipeID)
    REFERENCES RecipeData (RecipeID);

-- Reference: FK_RecipeRatings_UserInfo (table: RecipeRatings)
ALTER TABLE RecipeRatings ADD CONSTRAINT FK_RecipeRatings_UserInfo
    FOREIGN KEY (UserID)
    REFERENCES UserInfo (UserID);

-- Reference: FK_RecipeTags_TagDictionary (table: RecipeTags)
ALTER TABLE RecipeTags ADD CONSTRAINT FK_RecipeTags_TagDictionary
    FOREIGN KEY (TagID)
    REFERENCES TagDictionary (TagID);

-- Reference: FK_RecipeTags_RecipeData (table: RecipeTags)
ALTER TABLE RecipeTags ADD CONSTRAINT FK_RecipeTags_RecipeData
    FOREIGN KEY (RecipeID)
    REFERENCES RecipeData (RecipeID);

-- End of file.
