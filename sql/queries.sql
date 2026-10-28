    -- 5 SELECT queries using WHERE
-- 1
SELECT *
FROM RecipeData
WHERE Likes > 10;

-- 2
SELECT Username, EmailAddress
FROM UserInfo
WHERE CityOfResidence = 'Warsaw';

-- 3
SELECT *
FROM IngredientType
WHERE TypeName = 'Fruit';

-- 4
SELECT *
FROM TagDictionary
WHERE TagName LIKE 'V%';

-- 5
SELECT RecipeName
FROM RecipeData
WHERE IsPublic = 'Y';
    -- 5 SELECT queries that require joining tables
-- 1
SELECT RecipeName, Username
FROM RecipeData
JOIN UserInfo ON RecipeData.UserID = UserInfo.UserID;

-- 2
SELECT IngredientName, TypeName
FROM Ingredients
JOIN IngredientType ON Ingredients.IngredientTypeID = IngredientType.IngredientTypeId;

-- 3
SELECT RecipeName, TagName
FROM RecipeTags
JOIN RecipeData ON RecipeTags.RecipeID = RecipeData.RecipeID
JOIN TagDictionary ON RecipeTags.TagID = TagDictionary.TagID;

-- 4
SELECT Username, RecipeName
FROM Favorites
JOIN UserInfo ON Favorites.UserID = UserInfo.UserID
JOIN RecipeData ON Favorites.RecipeID = RecipeData.RecipeID;

-- 5
SELECT CollectionName, RecipeName
FROM RecipeCollections
JOIN Collections ON RecipeCollections.CollectionID = Collections.CollectionID
JOIN RecipeData ON RecipeCollections.RecipeID = RecipeData.RecipeID;
  -- 5 SELECT queries using GROUP BY + aggregate function like COUNT or MAX
-- 1
SELECT UserInfo.UserID, UserInfo.Username, COUNT(*) AS TotalRecipes
FROM RecipeData
JOIN UserInfo ON RecipeData.UserID = UserInfo.UserID
GROUP BY UserInfo.UserID, UserInfo.Username;
-- 2
SELECT CollectionID, COUNT(*) AS RecipeInCollection
FROM RecipeCollections
GROUP BY CollectionID;

-- 3
SELECT RecipeID, COUNT(*) AS TagCount
FROM RecipeTags
GROUP BY RecipeID;

-- 4
SELECT UserID, MAX(Rating) AS MaxRating
FROM RecipeRatings
GROUP BY UserID;

-- 5
SELECT IngredientTypeID, COUNT(*) AS CountPerType
FROM Ingredients
GROUP BY IngredientTypeID;
   -- 3 SELECT queries using subquery, at least 1 of them being a correlated subquery


-- 1 

SELECT RecipeName
FROM RecipeData
WHERE Likes > (SELECT AVG(Likes) FROM RecipeData);

-- 2 

SELECT Username
FROM UserInfo
WHERE UserID IN (
    SELECT DISTINCT UserID FROM RecipeRatings
);

-- 3 

SELECT RecipeName, Likes
FROM RecipeData
WHERE Likes = (
    SELECT MAX(Likes)
    FROM RecipeData R2
    WHERE R2.UserID = RecipeData.UserID
);