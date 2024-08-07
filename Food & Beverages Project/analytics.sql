USE food_and_beverage;

-- Created first table named dim_cities
CREATE TABLE dim_cities(
	city_id VARCHAR(50) PRIMARY KEY,
    city TEXT,
    tier TEXT
);

SELECT * FROM dim_cities;

-- Created second table named dim_respondents table
CREATE TABLE dim_respondents(
	respondent_id INT PRIMARY KEY,
    `name` VARCHAR(100),
    age VARCHAR(50),
    gender VARCHAR(50),
    city_id varchar(50),
    FOREIGN KEY(city_id) REFERENCES dim_cities(city_id)
    ON DELETE SET NULL
    ON UPDATE CASCADE
);

SELECT *
FROM dim_respondents;

-- Created third table named fact_survey_responses
CREATE TABLE fact_survey_responses(
	response_id INT PRIMARY KEY,
    respondent_id INT,
    consume_frequency VARCHAR(100),
    consume_time VARCHAR(100),
    consume_reason VARCHAR(100),
    heard_before VARCHAR(100),
    brand_perception VARCHAR(100),
    general_perception VARCHAR(100),
    tried_before VARCHAR(100),
    taste_experience INT,
    reasons_preventing_trying VARCHAR(100),
    current_brands VARCHAR(100),
    reason_for_chosing_brand VARCHAR(100),
    improvements_desired VARCHAR(100),
    ingredients_expected VARCHAR(100),
    health_concern VARCHAR(100),
    interest_in_natural_or_organic VARCHAR(100),
    marketing_channels VARCHAR(100),
    packaging_preference VARCHAR(100),
    limited_edition_packaging VARCHAR(100),
    price_range VARCHAR(100),
    purchase_location VARCHAR(100),
    typical_consumption_situations VARCHAR(100),
    FOREIGN KEY (respondent_id) REFERENCES dim_respondents(respondent_id)
    ON DELETE SET NULL
    ON UPDATE CASCADE
);


SELECT * 
FROM fact_survey_responses;

-- checking if all tables connected successfully or not
SELECT `name` , city, current_brands
FROM dim_cities
JOIN dim_respondents ON dim_cities.city_id = dim_respondents.city_id
JOIN fact_survey_responses ON dim_respondents.respondent_id = fact_survey_responses.respondent_id;

-- ------------------------------------------------------- 1. DEMOGRAPHIC INSIGHTS ---------------------------------------------------------------------

-- 1. Who prefers energy drink more?  (male/female/non-binary?) 				ANSWER ==> Male prefers more energy drink.
SELECT dim_respondents.gender, COUNT(fact_survey_responses.respondent_id) AS `COUNT`
FROM dim_respondents
JOIN fact_survey_responses ON dim_respondents.respondent_id = fact_survey_responses.respondent_id
GROUP BY gender
ORDER BY `COUNT` DESC;

-- 2. Which age group prefers energy drinks more? 								ANSWER ==> 19-30 Age group prefers more energy Drink.
SELECT dim_respondents.age as `Age Group`, COUNT(fact_survey_responses.respondent_id) AS `No. Of Consumers`
FROM dim_respondents
JOIN fact_survey_responses ON dim_respondents.respondent_id = fact_survey_responses.respondent_id
GROUP BY age
ORDER BY `No. Of Consumers` DESC;

-- 3. Which type of marketing reaches the most Youth (15-30)?					ANSWER ==> Online Ads = 3373
SELECT fact_survey_responses.marketing_channels, COUNT(fact_survey_responses.respondent_id) AS `COUNT`
FROM fact_survey_responses
JOIN dim_respondents ON fact_survey_responses.respondent_id = dim_respondents.respondent_id
WHERE dim_respondents.age = "15-18" OR dim_respondents.age = "19-30"
GROUP BY fact_survey_responses.marketing_channels
ORDER BY `COUNT` DESC;



-- ------------------------------------------------------------ 2. CONSUMER PREFERENCES ------------------------------------------------------------------------------------------ 

-- 1. What are the preferred ingredients of energy drinks among respondents?			ANSWER ==> Caffeine
SELECT fact_survey_responses.ingredients_expected AS Ingredients, COUNT(fact_survey_responses.respondent_id) AS `COUNT`
FROM fact_survey_responses
GROUP BY fact_survey_responses.ingredients_expected
ORDER BY `COUNT` DESC;


-- 2. What packaging preferences do respondents have for energy drinks?					ANSWER ==> Compact and Portable Cans
SELECT fact_survey_responses.packaging_preference AS `Package Type`, COUNT(fact_survey_responses.packaging_preference) AS `Count`
FROM fact_survey_responses
GROUP BY fact_survey_responses.packaging_preference
ORDER BY `Count` DESC;



-- ---------------------------------------------------------- 3. COMPETITION ANALYSIS -------------------------------------------------------

-- 1. Who are the current market leaders?			ANSWER ==> Cola-Coka
SELECT fact_survey_responses.current_brands AS Brand , COUNT(fact_survey_responses.respondent_id) AS `Count`
FROM fact_survey_responses
GROUP BY Brand
ORDER BY `Count` DESC;

-- 2. What are the primary reasons consumers prefer those brands over ours?	   ANSWER ==> Brand reputation, Taste and Availability are the primary reason to chose those brands rather than CodeX
SELECT fact_survey_responses.reason_for_chosing_brand
FROM fact_survey_responses
WHERE fact_survey_responses.current_brands NOT LIKE "%CodeX"
GROUP BY fact_survey_responses.reason_for_chosing_brand
ORDER BY COUNT(fact_survey_responses.reason_for_chosing_brand) DESC;

-- ------------------------------------------------- 4. Brand Penetration ------------------------------------------------

-- 1. What do people think about our brand? (overall rating)			ANSWER ==> Most respondents have given 3(286) and 4(248) Star Rating out of 5
SELECT fact_survey_responses.taste_experience AS Rating, COUNT(fact_survey_responses.taste_experience) AS `Count Of Rating`
FROM fact_survey_responses
WHERE current_brands = "CodeX"
GROUP BY Rating
ORDER BY `Count Of Rating` DESC;

-- 2.  Which cities do we need to focus more on? 		ANSWER ==> Lucknow, Jaipur, Delhi, Ahmedabad, Kolkata
SELECT dim_cities.city AS City, COUNT(fact_survey_responses.respondent_id) AS `Count`
FROM dim_cities
JOIN dim_respondents ON dim_cities.city_id = dim_respondents.city_id
JOIN fact_survey_responses ON dim_respondents.respondent_id = fact_survey_responses.respondent_id
WHERE fact_survey_responses.current_brands = "CodeX"
GROUP BY City
HAVING `Count` < 50
ORDER BY `Count` ASC;


-- ------------------------------------------------- 5. Purchase Behaviour ---------------------------------------------------------------

-- 1. Where do respondents prefer to purchase energy drinks?		ANSWER ==> Supermarkets
SELECT fact_survey_responses.purchase_location AS Location, COUNT(fact_survey_responses.purchase_location) AS `Count`
FROM fact_survey_responses
GROUP BY Location
ORDER BY `Count` DESC;

-- 2. What are the typical consumption situations for energy drinks among respondents?		ANSWER ==> Sports/Exercise
SELECT fact_survey_responses.typical_consumption_situations AS Situation, COUNT(fact_survey_responses.typical_consumption_situations) AS `Count`
FROM fact_survey_responses
GROUP BY Situation
ORDER BY `Count` DESC;

-- ---------------------------------------------------------6. Product Development ---------------------------------------------------------
-- 1. Which area of improvement should we focus more on our product development? 		ANSWER ==> Reduce Sugar, Use natural ingredients and diverisfy products
SELECT fact_survey_responses.improvements_desired AS `Area of Improvement`, COUNT(fact_survey_responses.improvements_desired) AS `Count`
FROM fact_survey_responses
GROUP BY `Area of Improvement`
ORDER BY `Count` DESC;

-- 2. Which area of Business should we focus more on our product development? 		ANSWER ==> Branding
SELECT fact_survey_responses.reason_for_chosing_brand AS `Area of Improvement`, COUNT(fact_survey_responses.reason_for_chosing_brand) AS `Count`
FROM fact_survey_responses
WHERE NOT fact_survey_responses.current_brands = "CodeX"
GROUP BY `Area of Improvement`
ORDER BY `Count` DESC;

-- Ideal price of the energy drinks 		ANSWER ==> 50-99
SELECT fact_survey_responses.price_range AS `Price Range`, COUNT(fact_survey_responses.price_range) AS `Count`
FROM fact_survey_responses
GROUP BY `Price Range`
ORDER BY `Count` DESC;

