-- Procedure 1: Register a new user
-- This procedure creates a new user in UserInfo.
-- It creates a new UserID (MAX + 1) and also creates a default row in UserLevel.
GO
CREATE OR ALTER PROCEDURE PR_RegisterUser
    @Username        VARCHAR(100),
    @EmailAddress    VARCHAR(200),
    @CityOfResidence VARCHAR(100),
    @Password        VARCHAR(100),
    @NewUserID       INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Id INT;

    -- Generate new UserID
    SELECT @Id = ISNULL(MAX(UserID), 0) + 1
    FROM UserInfo;

    -- Insert new user
    INSERT INTO UserInfo (UserID, Username, EmailAddress, CityOfResidence, Password)
    VALUES (@Id, @Username, @EmailAddress, @CityOfResidence, @Password);

    -- Create default user level
    INSERT INTO UserLevel (UserID, Ratings, ChefLevel)
    VALUES (@Id, 0, 0);

    SET @NewUserID = @Id;

    PRINT 'Registered user "' + @Username + '" with ID=' + CAST(@Id AS VARCHAR(10));
END;
GO


-- Procedure 2: Recalculate user levels
-- This procedure uses a cursor to go through all users.
-- For each user it counts recipes, likes and ratings, then updates UserLevel.
GO
CREATE OR ALTER PROCEDURE PR_RecalculateUserLevels
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @UserID INT, @Username VARCHAR(100);

    DECLARE @RecipesCount INT,
            @LikesSum INT,
            @AvgRating FLOAT,
            @RatingsCount INT,
            @Points FLOAT,
            @ChefLevel INT;

    DECLARE c_users CURSOR FOR
        SELECT UserID, Username
        FROM UserInfo
        ORDER BY UserID;

    OPEN c_users;
    FETCH NEXT FROM c_users INTO @UserID, @Username;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Count user recipes
        SELECT @RecipesCount = COUNT(*)
        FROM RecipeData
        WHERE UserID = @UserID;

        -- Sum likes for user recipes
        SELECT @LikesSum = ISNULL(SUM(Likes), 0)
        FROM RecipeData
        WHERE UserID = @UserID;

        -- Calculate average rating and number of ratings
        SELECT
            @AvgRating = ISNULL(AVG(CAST(rr.Rating AS FLOAT)), 0),
            @RatingsCount = COUNT(rr.RatingID)
        FROM RecipeData rd
        LEFT JOIN RecipeRatings rr ON rr.RecipeID = rd.RecipeID
        WHERE rd.UserID = @UserID;

        -- Calculate points and level
        SET @Points = (@RecipesCount * 10.0) + (@LikesSum * 1.0) + (ROUND(@AvgRating, 2) * 5.0);
        SET @ChefLevel = FLOOR(@Points / 20.0);

        -- Update or insert UserLevel
        UPDATE UserLevel
        SET Ratings = @RatingsCount,
            ChefLevel = @ChefLevel
        WHERE UserID = @UserID;

        IF @@ROWCOUNT = 0
        BEGIN
            INSERT INTO UserLevel (UserID, Ratings, ChefLevel)
            VALUES (@UserID, @RatingsCount, @ChefLevel);
        END

        PRINT 'UserID=' + CAST(@UserID AS VARCHAR(10)) +
              ' (' + @Username + ') Level=' + CAST(@ChefLevel AS VARCHAR(10));

        FETCH NEXT FROM c_users INTO @UserID, @Username;
    END

    CLOSE c_users;
    DEALLOCATE c_users;
END;
GO


-- Trigger 1: Update recipe likes
-- This trigger automatically updates Likes in RecipeData.
-- INSERT into Favorites increases Likes, DELETE decreases Likes (not below 0).
GO
CREATE OR ALTER TRIGGER TR_Favorites_LikesCounter
ON Favorites
AFTER INSERT, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- Increase likes for inserted favorites
    UPDATE rd
    SET rd.Likes = rd.Likes + x.cnt
    FROM RecipeData rd
    JOIN (
        SELECT RecipeID, COUNT(*) AS cnt
        FROM Inserted
        GROUP BY RecipeID
    ) x ON x.RecipeID = rd.RecipeID;

    -- Decrease likes for deleted favorites (not below 0)
    UPDATE rd
    SET rd.Likes = CASE WHEN rd.Likes >= x.cnt THEN rd.Likes - x.cnt ELSE 0 END
    FROM RecipeData rd
    JOIN (
        SELECT RecipeID, COUNT(*) AS cnt
        FROM Deleted
        GROUP BY RecipeID
    ) x ON x.RecipeID = rd.RecipeID;
END;
GO


-- Trigger 2: Validate recipe ratings
-- This trigger blocks wrong rating values and self-rating.
-- Rating must be between 1 and 5, and user cannot rate own recipe.
GO
CREATE OR ALTER TRIGGER TR_RecipeRatings_Validate
ON RecipeRatings
INSTEAD OF INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Check rating range
        IF EXISTS (SELECT 1 FROM Inserted WHERE Rating < 1 OR Rating > 5)
        BEGIN
            RAISERROR('Rating must be between 1 and 5.', 16, 1);
            RETURN;
        END

        -- Check recipe owner (self-rating)
        IF EXISTS (
            SELECT 1
            FROM Inserted i
            JOIN RecipeData rd ON rd.RecipeID = i.RecipeID
            WHERE rd.UserID = i.UserID
        )
        BEGIN
            RAISERROR('You cannot rate your own recipe.', 16, 1);
            RETURN;
        END

        -- If it is UPDATE
        IF EXISTS (SELECT 1 FROM Deleted)
        BEGIN
            UPDATE rr
            SET rr.UserID = i.UserID,
                rr.RecipeID = i.RecipeID,
                rr.Rating = i.Rating
            FROM RecipeRatings rr
            JOIN Inserted i ON i.RatingID = rr.RatingID;

            RETURN;
        END

        -- If it is INSERT
        INSERT INTO RecipeRatings (RatingID, UserID, RecipeID, Rating)
        SELECT RatingID, UserID, RecipeID, Rating
        FROM Inserted;

    END TRY
    BEGIN CATCH
        DECLARE @Msg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@Msg, 16, 1);
    END CATCH
END;
GO


------------------------------------TEST CODE--------------------------------------

-- Quick check: objects exist
SELECT name, type_desc
FROM sys.objects
WHERE name IN ('PR_RegisterUser','PR_RecalculateUserLevels',
              'TR_Favorites_LikesCounter','TR_RecipeRatings_Validate');


-- TEST 1: Procedure PR_RegisterUser
-- Expectation:
--   - New user inserted with unique id
--   - UserLevel row created with Ratings=0, ChefLevel=0
--   - Repeatable (unique username/email) + ROLLBACK
BEGIN TRAN;

DECLARE @NewUserID INT;
DECLARE @NewName VARCHAR(50);
DECLARE @NewEmail VARCHAR(80);

SELECT @NewName = 'test_user_' + CAST(ISNULL(MAX(UserID),0) + 1 AS VARCHAR(10))
FROM UserInfo;
SET @NewEmail = @NewName + '@example.com';

EXEC PR_RegisterUser @NewName, @NewEmail, 'Gdansk', 'pass999', @NewUserID OUTPUT;

SELECT ui.UserID, ui.Username, ul.Ratings, ul.ChefLevel
FROM UserInfo ui
LEFT JOIN UserLevel ul ON ul.UserID = ui.UserID
WHERE ui.UserID = @NewUserID;

ROLLBACK;


-- TEST 2: Trigger TR_Favorites_LikesCounter
-- Expectation:
--   - Inserting into Favorites increases RecipeData.Likes
--   - Deleting from Favorites decreases RecipeData.Likes
--   - Repeatable (FavoriteID = MAX+1) + ROLLBACK
BEGIN TRAN;

DECLARE @BeforeLikes INT, @AfterLikes INT, @FavID INT;

SELECT @FavID = ISNULL(MAX(FavoriteID),0) + 1 FROM Favorites;

SELECT @BeforeLikes = Likes
FROM RecipeData
WHERE RecipeID = 200;

PRINT 'Before INSERT favorite: RecipeID=200 Likes=' + CAST(@BeforeLikes AS VARCHAR(10));

INSERT INTO Favorites (UserID, RecipeID, FavoriteID)
VALUES (1, 200, @FavID);

SELECT @AfterLikes = Likes
FROM RecipeData
WHERE RecipeID = 200;

PRINT 'After INSERT favorite:  RecipeID=200 Likes=' + CAST(@AfterLikes AS VARCHAR(10));

DELETE FROM Favorites WHERE FavoriteID = @FavID;

SELECT @AfterLikes = Likes
FROM RecipeData
WHERE RecipeID = 200;

PRINT 'After DELETE favorite:  RecipeID=200 Likes=' + CAST(@AfterLikes AS VARCHAR(10));

ROLLBACK;


-- TEST 3: Trigger TR_RecipeRatings_Validate (invalid rating)
-- Expectation:
--   - Insert with Rating=6 fails
BEGIN TRAN;

BEGIN TRY
    DECLARE @NewRatingID INT;
    SELECT @NewRatingID = ISNULL(MAX(RatingID),0) + 1 FROM RecipeRatings;

    INSERT INTO RecipeRatings (RatingID, UserID, RecipeID, Rating)
    VALUES (@NewRatingID, 2, 202, 6);

    PRINT 'ERROR: invalid rating insert should fail.';
END TRY
BEGIN CATCH
    PRINT 'Expected error (invalid rating): ' + ERROR_MESSAGE();
END CATCH

ROLLBACK;


-- TEST 4: Trigger TR_RecipeRatings_Validate (self-rating)
-- Expectation:
--   - Owner cannot rate own recipe -> fails
BEGIN TRAN;

BEGIN TRY
    DECLARE @NewRatingID2 INT, @RecipeID INT, @OwnerID INT;
    SELECT @NewRatingID2 = ISNULL(MAX(RatingID),0) + 1 FROM RecipeRatings;

    SELECT TOP (1) @RecipeID = RecipeID, @OwnerID = UserID
    FROM RecipeData
    ORDER BY RecipeID;

    INSERT INTO RecipeRatings (RatingID, UserID, RecipeID, Rating)
    VALUES (@NewRatingID2, @OwnerID, @RecipeID, 5);

    PRINT 'ERROR: self-rating insert should fail.';
END TRY
BEGIN CATCH
    PRINT 'Expected error (self-rating): ' + ERROR_MESSAGE();
END CATCH

ROLLBACK;


-- TEST 5: Procedure PR_RecalculateUserLevels
-- Expectation:
--   - Adds likes (+5 per recipe) so results change
--   - Runs PR_RecalculateUserLevels
--   - Repeatable + ROLLBACK
BEGIN TRAN;

DECLARE @SumBefore INT, @SumAfter INT;

SELECT @SumBefore = ISNULL(SUM(Likes),0) FROM RecipeData;
PRINT 'Total likes BEFORE = ' + CAST(@SumBefore AS VARCHAR(10));

DECLARE c_recipes CURSOR FOR
    SELECT RecipeID FROM RecipeData;

DECLARE @RID INT;
OPEN c_recipes;
FETCH NEXT FROM c_recipes INTO @RID;

WHILE @@FETCH_STATUS = 0
BEGIN
    UPDATE RecipeData
    SET Likes = Likes + 5
    WHERE RecipeID = @RID;

    FETCH NEXT FROM c_recipes INTO @RID;
END

CLOSE c_recipes;
DEALLOCATE c_recipes;

SELECT @SumAfter = ISNULL(SUM(Likes),0) FROM RecipeData;
PRINT 'Total likes AFTER  = ' + CAST(@SumAfter AS VARCHAR(10));

EXEC PR_RecalculateUserLevels;

ROLLBACK;
