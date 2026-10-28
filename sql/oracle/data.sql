-- UserInfo
INSERT INTO UserInfo (UserID, Username, EmailAddress, CityOfResidence, Password)
VALUES (1, 'jdoe', 'jdoe@example.com', 'Warsaw', 'pass123');

INSERT INTO UserInfo (UserID, Username, EmailAddress, CityOfResidence, Password)
VALUES (2, 'asmith', 'asmith@example.com', 'Krakow', 'pass456');

INSERT INTO UserInfo (UserID, Username, EmailAddress, CityOfResidence, Password)
VALUES (3, 'ahmed', 'ahmed@example.com', 'Poznan', 'pass657');

INSERT INTO UserInfo (UserID, Username, EmailAddress, CityOfResidence, Password)
VALUES (4, 'anatolii', 'conandoil@example.com', 'Lwow', 'pass457');

INSERT INTO UserInfo (UserID, Username, EmailAddress, CityOfResidence, Password)
VALUES (5, 'joe', 'joebiden@example.com', 'Lodz', 'pass890');


--  UserLevel
INSERT INTO UserLevel (UserID, Ratings, ChefLevel)
VALUES (1, 5, 2);

INSERT INTO UserLevel (UserID, Ratings, ChefLevel)
VALUES (2, 10, 3);

INSERT INTO UserLevel (UserID, Ratings, ChefLevel)
VALUES (3, 7, 2);

INSERT INTO UserLevel (UserID, Ratings, ChefLevel)
VALUES (4, 3, 1);

INSERT INTO UserLevel (UserID, Ratings, ChefLevel)
VALUES (5, 12, 4);


--  Collections
INSERT INTO Collections (CollectionID, UserID, CollectionName)
VALUES (100, 1, 'Healthy Meals');

INSERT INTO Collections (CollectionID, UserID, CollectionName)
VALUES (101, 2, 'Desserts');

INSERT INTO Collections (CollectionID, UserID, CollectionName)
VALUES (102, 3, 'Quick Lunch');

INSERT INTO Collections (CollectionID, UserID, CollectionName)
VALUES (103, 4, 'Traditional Food');

INSERT INTO Collections (CollectionID, UserID, CollectionName)
VALUES (104, 5, 'Gym Meals');


-- RecipeData
INSERT INTO RecipeData (RecipeID, UserID, RecipeName, IngredientsSummary, CookingInstructions, IsPublic, Likes, Comments)
VALUES (200, 1, 'Avocado Toast', 'Avocado, Bread, Salt', 'Toast bread and add mashed avocado with salt.', 'Y', 15, 2);

INSERT INTO RecipeData (RecipeID, UserID, RecipeName, IngredientsSummary, CookingInstructions, IsPublic, Likes, Comments)
VALUES (201, 2, 'Chocolate Cake', 'Flour, Cocoa, Sugar, Eggs', 'Mix and bake at 180C for 30 min.', 'Y', 25, 5);

INSERT INTO RecipeData (RecipeID, UserID, RecipeName, IngredientsSummary, CookingInstructions, IsPublic, Likes, Comments)
VALUES (202, 3, 'Greek Salad', 'Tomato, Cucumber, Feta', 'Mix all ingredients.', 'Y', 9, 1);

INSERT INTO RecipeData (RecipeID, UserID, RecipeName, IngredientsSummary, CookingInstructions, IsPublic, Likes, Comments)
VALUES (203, 4, 'Borscht', 'Beetroot, Cabbage, Potato', 'Cook vegetables together.', 'Y', 30, 8);

INSERT INTO RecipeData (RecipeID, UserID, RecipeName, IngredientsSummary, CookingInstructions, IsPublic, Likes, Comments)
VALUES (204, 5, 'Oatmeal', 'Oats, Milk, Banana', 'Cook oats with milk.', 'N', 4, 0);


-- Favorites
INSERT INTO Favorites (UserID, RecipeID, FavoriteID)
VALUES (1, 201, 500);

INSERT INTO Favorites (UserID, RecipeID, FavoriteID)
VALUES (2, 200, 501);

INSERT INTO Favorites (UserID, RecipeID, FavoriteID)
VALUES (3, 202, 502);

INSERT INTO Favorites (UserID, RecipeID, FavoriteID)
VALUES (4, 203, 503);

INSERT INTO Favorites (UserID, RecipeID, FavoriteID)
VALUES (5, 204, 504);


-- IngredientType
INSERT INTO IngredientType (IngredientTypeId, TypeName, TypeSpesifics)
VALUES (1, 'Fruit', 'Fresh');

INSERT INTO IngredientType (IngredientTypeId, TypeName, TypeSpesifics)
VALUES (2, 'Bakery', 'Baked');

INSERT INTO IngredientType (IngredientTypeId, TypeName, TypeSpesifics)
VALUES (3, 'Vegetable', 'Fresh');

INSERT INTO IngredientType (IngredientTypeId, TypeName, TypeSpesifics)
VALUES (4, 'Dairy', 'Refrigerated');

INSERT INTO IngredientType (IngredientTypeId, TypeName, TypeSpesifics)
VALUES (5, 'Grain', 'Dry');


-- Ingredients
INSERT INTO Ingredients (IngredientID, RecipeID, IngredientTypeID, IngredientName)
VALUES (1, 200, 1, 'Avocado');

INSERT INTO Ingredients (IngredientID, RecipeID, IngredientTypeID, IngredientName)
VALUES (2, 201, 2, 'Flour');

INSERT INTO Ingredients (IngredientID, RecipeID, IngredientTypeID, IngredientName)
VALUES (3, 202, 3, 'Tomato');

INSERT INTO Ingredients (IngredientID, RecipeID, IngredientTypeID, IngredientName)
VALUES (4, 203, 3, 'Beetroot');

INSERT INTO Ingredients (IngredientID, RecipeID, IngredientTypeID, IngredientName)
VALUES (5, 204, 5, 'Oats');


-- RecipeCollections
INSERT INTO RecipeCollections (RecipeID, CollectionID)
VALUES (200, 100);

INSERT INTO RecipeCollections (RecipeID, CollectionID)
VALUES (201, 101);

INSERT INTO RecipeCollections (RecipeID, CollectionID)
VALUES (202, 102);

INSERT INTO RecipeCollections (RecipeID, CollectionID)
VALUES (203, 103);

INSERT INTO RecipeCollections (RecipeID, CollectionID)
VALUES (204, 104);


-- RecipeRatings
INSERT INTO RecipeRatings (RatingID, UserID, RecipeID, Rating)
VALUES (1, 1, 201, 5);

INSERT INTO RecipeRatings (RatingID, UserID, RecipeID, Rating)
VALUES (2, 2, 200, 4);

INSERT INTO RecipeRatings (RatingID, UserID, RecipeID, Rating)
VALUES (3, 3, 202, 4);

INSERT INTO RecipeRatings (RatingID, UserID, RecipeID, Rating)
VALUES (4, 4, 203, 5);

INSERT INTO RecipeRatings (RatingID, UserID, RecipeID, Rating)
VALUES (5, 5, 204, 3);


--  TagDictionary
INSERT INTO TagDictionary (TagID, TagName)
VALUES (1, 'Vegan');

INSERT INTO TagDictionary (TagID, TagName)
VALUES (2, 'Sweet');

INSERT INTO TagDictionary (TagID, TagName)
VALUES (3, 'Healthy');

INSERT INTO TagDictionary (TagID, TagName)
VALUES (4, 'Quick');

INSERT INTO TagDictionary (TagID, TagName)
VALUES (5, 'Traditional');


--  RecipeTags
INSERT INTO RecipeTags (RecipeID, TagID)
VALUES (200, 1);

INSERT INTO RecipeTags (RecipeID, TagID)
VALUES (201, 2);

INSERT INTO RecipeTags (RecipeID, TagID)
VALUES (202, 3);

INSERT INTO RecipeTags (RecipeID, TagID)
VALUES (203, 5);

INSERT INTO RecipeTags (RecipeID, TagID)
VALUES (204, 4);
