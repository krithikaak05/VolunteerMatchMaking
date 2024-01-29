-----------------1. SIMPLE QUERY----------------------------------------------
-- # To find opportunity details based on certain conditions #----------------------

select * from opportunity
where title in ('Tech Talk','Leadership Training') and
description like '%technology%';

----------------2. AGGREGATE QUERY----------------------------------------------
-- # Query  that identifies and retrieves engagements where the total hours worked exceed the average hours worked across all engagements #-------------

SELECT engagement_id,
    SUM(HOURS_WORKED) AS TotalHoursWorked
FROM
    VOLUNTEER_HOURS
GROUP BY
    ENGAGEMENT_ID
HAVING
    SUM(HOURS_WORKED) > (SELECT AVG(HOURS_WORKED) FROM VOLUNTEER_HOURS);
    
-------------3. USING EXISTS QUERY--------------------------------------------------------------------------
------------- # Query to retrieve usernames who's application status is pending #--------------------------

SELECT U.USERNAME
FROM USER U
WHERE EXISTS (
    SELECT 1
    FROM APPLICATION A
    WHERE U.USER_ID = A.USER_ID
    AND A.STATUS='PENDING' 
);
    
----------------4. JOINS 	QUERY--------------------------------------------------------------------------------------
---- # Query that retrieves details about opportunities based on certain conditions like start_date #-------

SELECT
    O.OPP_ID,
    O.TITLE,
    O.DESCRIPTION,
    O.ORG_ID,
    Org.ORG_NAME,
    O.LOCATION,
    L.CITY,
    L.STATE,
    L.COUNTRY,
    O.TIME_PERIOD,
    TP.START_DATE,
    TP.END_DATE,
    O.SKILLS_REQUIRED,
    S.SKILLS_NAME
FROM
    OPPORTUNITY O
LEFT JOIN
    ORGANISATION Org ON O.ORG_ID = Org.ORG_ID
LEFT JOIN
    LOCATION L ON O.LOCATION = L.LOCATION_ID
LEFT JOIN
    TIME_PERIOD TP ON O.TIME_PERIOD = TP.TIME_ID
LEFT JOIN
    SKILLS S ON O.SKILLS_REQUIRED = S.SKILLS_ID
WHERE
    TP.START_DATE > '2023-01-01';
    
   -------------5. UNION QUERY-------------------------------------------------------------------------------
-------------#Query to retrieve usernames of applications who's status is accepted and those who have not applied#--------------------------

SELECT
    A.APPLICATION_ID,
    A.APPLICATION_DATE,
    A.STATUS,
    U.USER_ID,
    U.USERNAME,
    O.OPP_ID,
    O.TITLE
FROM
    APPLICATION A
JOIN USER U ON A.USER_ID = U.USER_ID
JOIN OPPORTUNITY O ON A.OPPORTUNITY_ID = O.OPP_ID
WHERE
    A.STATUS = 'Accepted'
UNION
SELECT
    NULL AS APPLICATION_ID,
    NULL AS APPLICATION_DATE,
    NULL AS STATUS,
    U.USER_ID,
    U.USERNAME,
    NULL AS OPP_ID,
    NULL AS TITLE
FROM
    USER U
WHERE
    U.USER_ID NOT IN (SELECT USER_ID FROM APPLICATION);
    
    ----------6. CORRELATED SUBQUERY-----------------------------------------------------------------------
    --------# Query to select usernames who applied for opportunities in suburbia #------------------------
SELECT USERNAME
FROM USER
WHERE USER_ID NOT IN (
    SELECT USER_ID
    FROM APPLICATION
    WHERE OPPORTUNITY_ID IN (
        SELECT OPP_ID
        FROM OPPORTUNITY
        WHERE LOCATION = (
            SELECT LOCATION_ID
            FROM LOCATION
            WHERE CITY='Suburbia'
        )
    )
)
--------# Query to retrieve the application count for each organisation#--------------------------------
SELECT
    Org.ORG_NAME,
    (
        SELECT COUNT(A.APPLICATION_ID)
        FROM OPPORTUNITY O2
        LEFT JOIN APPLICATION A ON O2.OPP_ID = A.OPPORTUNITY_ID
        WHERE Org.ORG_ID = O2.ORG_ID
    ) AS ApplicationCount
FROM
    ORGANISATION Org
ORDER BY
    ApplicationCount DESC;

 ---------------7. NESTED QUERY-------------------------------------------------------------------
    ----# Query to fetch opportunities details based on a skill like programming #-------------------
    
    SELECT
    OPP_ID,
    TITLE,
    DESCRIPTION,
    ORG_NAME,
    LOCATION,
    CITY AS LOCATION
FROM
    (
        SELECT
            O.OPP_ID,
            O.TITLE,
            O.DESCRIPTION,
            Org.ORG_NAME,
            O.LOCATION,
            L.CITY
        FROM
            OPPORTUNITY O
        JOIN
            ORGANISATION Org ON O.ORG_ID = Org.ORG_ID
        JOIN
            LOCATION L ON L.LOCATION_ID = O.LOCATION
        WHERE
            O.SKILLS_REQUIRED = ANY (
                SELECT SKILLS_ID
                FROM SKILLS
                WHERE SKILLS_NAME LIKE '%Programming%'
            )
    ) AS Subquery;
    

-------------8. SUBQUERY using from & select clause---------------------------------------------------------------
-------------#Query retrieves the count of applications applied by each user #------------------------------------
SELECT
    U.USERNAME,
    (
        SELECT COUNT(*)
        FROM APPLICATION A
        WHERE A.USER_ID = U.USER_ID
    ) AS ApplicationCount
FROM
    USER U;
    -------------------------------------------------------------------------------------------------------------