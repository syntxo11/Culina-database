
-- Procedure 1: Register a new user
-- This procedure creates a new user in UserInfo.
-- If not, it creates a new UserID and a default UserLevel row.
CREATE OR REPLACE PROCEDURE PR_RegisterUser(
    p_Username        IN  UserInfo.Username%TYPE,
    p_EmailAddress    IN  UserInfo.EmailAddress%TYPE,
    p_CityOfResidence IN  UserInfo.CityOfResidence%TYPE,
    p_Password        IN  UserInfo.Password%TYPE,
    o_UserID          OUT UserInfo.UserID%TYPE
)
IS
    v_NewId   UserInfo.UserID%TYPE;
    v_Exists  NUMBER;
BEGIN
    -- Check for uniqueness
    SELECT COUNT(*)
    INTO v_Exists
    FROM UserInfo
    WHERE Username = p_Username
       OR EmailAddress = p_EmailAddress;

    IF v_Exists > 0 THEN
        raise_application_error(-20001, 'User with this username or email already exists.');
    END IF;

    -- Generate new UserID
    SELECT NVL(MAX(UserID), 0) + 1
    INTO v_NewId
    FROM UserInfo;

    -- Insert new user
    INSERT INTO UserInfo (UserID, Username, EmailAddress, CityOfResidence, Password)
    VALUES (v_NewId, p_Username, p_EmailAddress, p_CityOfResidence, p_Password);

    -- Create default user level
    INSERT INTO UserLevel (UserID, Ratings, ChefLevel)
    VALUES (v_NewId, 0, 0);

    o_UserID := v_NewId;

    DBMS_OUTPUT.PUT_LINE('Registered user "' || p_Username || '" with ID=' || v_NewId);
END;
/

-- Procedure 2: Recalculate user levels
-- This procedure uses a cursor to go through all users.
-- For each user it counts recipes, likes and ratings.
-- Based on this data it updates the UserLevel table.
CREATE OR REPLACE PROCEDURE PR_RecalculateUserLevels
IS
    CURSOR c_users IS
        SELECT u.UserID, u.Username
        FROM UserInfo u
        ORDER BY u.UserID;

    v_UserID        UserInfo.UserID%TYPE;
    v_Username      UserInfo.Username%TYPE;

    v_RecipesCount  NUMBER;
    v_LikesSum      NUMBER;
    v_AvgRating     NUMBER;
    v_RatingsCount  NUMBER;

    v_Points        NUMBER;
    v_ChefLevel     NUMBER;
BEGIN
    OPEN c_users;

    LOOP
        FETCH c_users INTO v_UserID, v_Username;
        EXIT WHEN c_users%NOTFOUND;

        -- Count user recipes
        SELECT COUNT(*)
        INTO v_RecipesCount
        FROM RecipeData
        WHERE UserID = v_UserID;

        -- Sum likes for user recipes
        SELECT NVL(SUM(Likes), 0)
        INTO v_LikesSum
        FROM RecipeData
        WHERE UserID = v_UserID;

        -- Calculate average rating and number of ratings
        SELECT NVL(AVG(rr.Rating), 0), COUNT(rr.RatingID)
        INTO v_AvgRating, v_RatingsCount
        FROM RecipeData rd
        LEFT JOIN RecipeRatings rr ON rr.RecipeID = rd.RecipeID
        WHERE rd.UserID = v_UserID;

        -- Calculate points and level
        v_Points    := (v_RecipesCount * 10) + (v_LikesSum * 1) + (ROUND(v_AvgRating, 2) * 5);
        v_ChefLevel := FLOOR(v_Points / 20);

        -- Update or insert UserLevel
        UPDATE UserLevel
        SET Ratings   = v_RatingsCount,
            ChefLevel = v_ChefLevel
        WHERE UserID = v_UserID;

        IF SQL%ROWCOUNT = 0 THEN
            INSERT INTO UserLevel (UserID, Ratings, ChefLevel)
            VALUES (v_UserID, v_RatingsCount, v_ChefLevel);
        END IF;

        DBMS_OUTPUT.PUT_LINE(
            'UserID=' || v_UserID || ' (' || v_Username || ') ' ||
            'Level=' || v_ChefLevel
        );
    END LOOP;

    CLOSE c_users;
END;
/

-- Trigger 1 (FOR EACH ROW): Update recipe likes
-- This trigger automatically updates Likes in RecipeData.
-- INSERT into Favorites increases Likes.
-- DELETE from Favorites decreases Likes.
CREATE OR REPLACE TRIGGER TR_Favorites_LikesCounter
AFTER INSERT OR DELETE ON Favorites
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        UPDATE RecipeData
        SET Likes = Likes + 1
        WHERE RecipeID = :NEW.RecipeID;

    ELSIF DELETING THEN
        UPDATE RecipeData
        SET Likes = CASE WHEN Likes > 0 THEN Likes - 1 ELSE 0 END
        WHERE RecipeID = :OLD.RecipeID;
    END IF;
END;
/

-- Trigger 2 (FOR EACH ROW): Validate recipe ratings
-- This trigger checks rating value and blocks self-rating.
-- Rating must be between 1 and 5.
-- User cannot rate their own recipe.
CREATE OR REPLACE TRIGGER TR_RecipeRatings_Validate
BEFORE INSERT OR UPDATE ON RecipeRatings
FOR EACH ROW
DECLARE
    v_OwnerUserID RecipeData.UserID%TYPE;
BEGIN
    -- Check rating range
    IF :NEW.Rating < 1 OR :NEW.Rating > 5 THEN
        raise_application_error(-20011, 'Rating must be between 1 and 5.');
    END IF;

    -- Check recipe owner
    SELECT UserID
    INTO v_OwnerUserID
    FROM RecipeData
    WHERE RecipeID = :NEW.RecipeID;

    IF v_OwnerUserID = :NEW.UserID THEN
        raise_application_error(-20012, 'You cannot rate your own recipe.');
    END IF;
END;
/

------------------------------------TEST CODE--------------------------------------
SELECT object_name, object_type, status
FROM user_objects
WHERE object_name IN ('PR_REGISTERUSER','PR_RECALCULATEUSERLEVELS')
  AND object_type = 'PROCEDURE';

SELECT trigger_name, status
FROM user_triggers
WHERE trigger_name IN ('TR_FAVORITES_LIKESCOUNTER', 'TR_RECIPERATINGS_VALIDATE');

-- TEST 1: Procedure PR_RegisterUser
-- Expectation:
--   - New user inserted with unique id
--   - UserLevel row created with Ratings=0, ChefLevel=0
--   - Repeatable (unique username/email) + ROLLBACK
select * from USERINFO;
DECLARE
    v_NewUserId UserInfo.UserID%TYPE;
    v_Cnt       NUMBER;
    v_Name      VARCHAR2(50);
BEGIN
    SELECT 'test_user_' || (NVL(MAX(UserID),0) + 1)
    INTO v_Name
    FROM UserInfo;

    PR_RegisterUser(v_Name, v_Name || '@example.com', 'Gdansk', 'pass999', v_NewUserId);

    SELECT COUNT(*) INTO v_Cnt
    FROM UserLevel
    WHERE UserID = v_NewUserId;

    DBMS_OUTPUT.PUT_LINE('UserLevel row exists for new user? count=' || v_Cnt);

    --ROLLBACK;
END;
/

-- TEST 2: Trigger TR_Favorites_LikesCounter
-- Expectation:
--   - Inserting into Favorites increases RecipeData.Likes by 1
--   - Deleting from Favorites decreases RecipeData.Likes by 1
--   - Repeatable (FavoriteID = MAX+1) + ROLLBACK
DECLARE
    v_Before NUMBER;
    v_After  NUMBER;
    v_FavId  NUMBER;
BEGIN
    SELECT NVL(MAX(FavoriteID),0) + 1 INTO v_FavId FROM Favorites;

    SELECT Likes INTO v_Before
    FROM RecipeData
    WHERE RecipeID = 200;

    DBMS_OUTPUT.PUT_LINE('Before INSERT favorite: RecipeID=200 Likes=' || v_Before);

    INSERT INTO Favorites (UserID, RecipeID, FavoriteID)
    VALUES (1, 200, v_FavId);

    SELECT Likes INTO v_After
    FROM RecipeData
    WHERE RecipeID = 200;

    DBMS_OUTPUT.PUT_LINE('After INSERT favorite:  RecipeID=200 Likes=' || v_After);

    DELETE FROM Favorites
    WHERE FavoriteID = v_FavId;

    SELECT Likes INTO v_After
    FROM RecipeData
    WHERE RecipeID = 200;

    DBMS_OUTPUT.PUT_LINE('After DELETE favorite:  RecipeID=200 Likes=' || v_After);

    ROLLBACK;
END;
/

-- TEST 3: Trigger TR_RecipeRatings_Validate (invalid rating)
-- Expectation:
--   - Insert with Rating=6 fails with -20011
--   - (RatingID = MAX+1) + ROLLBACK
DECLARE
    v_RatingId NUMBER;
BEGIN
    SELECT NVL(MAX(RatingID),0) + 1 INTO v_RatingId FROM RecipeRatings;

    BEGIN
        INSERT INTO RecipeRatings (RatingID, UserID, RecipeID, Rating)
        VALUES (v_RatingId, 2, 202, 6);
        DBMS_OUTPUT.PUT_LINE('ERROR: invalid rating insert should fail.');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Expected error (invalid rating): ' || SQLERRM);
    END;

    ROLLBACK;
END;
/

-- TEST 4: Trigger TR_RecipeRatings_Validate (self-rating)
-- Expectation:
--   - Owner cannot rate own recipe -> -20012
--   - (RatingID = MAX+1) + ROLLBACK
DECLARE
    v_RatingId NUMBER;
    v_RecipeId NUMBER;
    v_OwnerId  NUMBER;
BEGIN
    SELECT NVL(MAX(RatingID),0) + 1 INTO v_RatingId FROM RecipeRatings;

    SELECT RecipeID, UserID
    INTO v_RecipeId, v_OwnerId
    FROM RecipeData
    WHERE ROWNUM = 1;

    BEGIN
        INSERT INTO RecipeRatings (RatingID, UserID, RecipeID, Rating)
        VALUES (v_RatingId, v_OwnerId, v_RecipeId, 5);
        DBMS_OUTPUT.PUT_LINE('ERROR: self-rating insert should fail.');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Expected error (self-rating): ' || SQLERRM);
    END;

    ROLLBACK;
END;
/

-- TEST 5: Procedure PR_RecalculateUserLevels
-- Expectation:
--   - Adds likes (simple +5) so results change
--   - Runs PR_RecalculateUserLevels
DECLARE
    v_Before NUMBER;
    v_After  NUMBER;
BEGIN
    SELECT NVL(SUM(Likes),0) INTO v_Before FROM RecipeData;
    DBMS_OUTPUT.PUT_LINE('Total likes BEFORE = ' || v_Before);

    UPDATE RecipeData
    SET Likes = Likes + 15
    WHERE NULL IS NULL;


    SELECT NVL(SUM(Likes),0) INTO v_After FROM RecipeData;
    DBMS_OUTPUT.PUT_LINE('Total likes AFTER  = ' || v_After);

    PR_RecalculateUserLevels;

    ROLLBACK;
END;
/
