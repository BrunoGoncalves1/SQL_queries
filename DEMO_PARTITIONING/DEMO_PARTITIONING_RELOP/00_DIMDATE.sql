BEGIN TRY
	DROP TABLE [dbo].[DimDate]
END TRY

BEGIN CATCH
	/*No Action*/
END CATCH

/**********************************************************************************/

CREATE TABLE [dbo].[DimDate]
	(	[DateKey] INT primary key, 
		[Date] DATETIME,
		[FullDateUK] CHAR(10), -- Date in dd-MM-yyyy format
		[FullDateUSA] CHAR(10),-- Date in MM-dd-yyyy format
		[DayOfMonth] VARCHAR(2), -- Field will hold Day number of Month
		[DaySuffix] VARCHAR(4), -- Apply suffix as 1st, 2nd ,3rd etc
		[DayName] VARCHAR(9), -- Contains name of the Day, SunDay, MonDay 
		[DayOfWeekUSA] CHAR(1),-- First Day SunDay=1 and SaturDay=7
		[DayOfWeekUK] CHAR(1),-- First Day MonDay=1 and SunDay=7
		[DayOfWeekInMonth] VARCHAR(2), --1st MonDay or 2nd MonDay in Month
		[DayOfWeekInYear] VARCHAR(2),
		[DayOfQuarter] VARCHAR(3),
		[DayOfYear] VARCHAR(3),
		[WeekOfMonth] VARCHAR(1),-- Week Number of Month 
		[WeekOfQuarter] VARCHAR(2), --Week Number of the Quarter
		[WeekOfYear] VARCHAR(2),--Week Number of the Year
		[Month] VARCHAR(2), --Number of the Month 1 to 12
		[MonthName] VARCHAR(9),--January, February etc
		[MonthOfQuarter] VARCHAR(2),-- Month Number belongs to Quarter
		[Quarter] CHAR(1),
		[QuarterName] VARCHAR(9),--First,Second..
		[Year] CHAR(4),-- Year value of Date stored in Row
		[YearName] CHAR(7), --CY 2012,CY 2013
		[MonthYear] CHAR(10), --Jan-2013,Feb-2013
		[MMYYYY] CHAR(6),
		[FirstDayOfMonth] DATE,
		[LastDayOfMonth] DATE,
		[FirstDayOfQuarter] DATE,
		[LastDayOfQuarter] DATE,
		[FirstDayOfYear] DATE,
		[LastDayOfYear] DATE,
		[IsHoliDayUSA] BIT,-- Flag 1=National HoliDay, 0-No National HoliDay
		[IsWeekDay] BIT,-- 0=Week End ,1=Week Day
		[HoliDayUSA] VARCHAR(50),--Name of HoliDay in US
		[IsHoliDayUK] BIT Null,-- Flag 1=National HoliDay, 0-No National HoliDay
		[HoliDayUK] VARCHAR(50) Null --Name of HoliDay in UK
	)
GO



DECLARE @StartDate DATETIME = '01/01/2018' --Starting value of Date Range
DECLARE @EndDate DATETIME = '03/31/2018' --End Value of Date Range

--Temporary Variables To Hold the Values During Processing of Each Date of Year
DECLARE
	@DayOfWeekInMonth INT,
	@DayOfWeekInYear INT,
	@DayOfQuarter INT,
	@WeekOfMonth INT,
	@CurrentYear INT,
	@CurrentMonth INT,
	@CurrentQuarter INT

/*Table Data type to store the Day of week count for the month and Year*/
DECLARE @DayOfWeek TABLE (DOW INT, MonthCount INT, QuarterCount INT, YearCount INT)

INSERT INTO @DayOfWeek VALUES (1, 0, 0, 0)
INSERT INTO @DayOfWeek VALUES (2, 0, 0, 0)
INSERT INTO @DayOfWeek VALUES (3, 0, 0, 0)
INSERT INTO @DayOfWeek VALUES (4, 0, 0, 0)
INSERT INTO @DayOfWeek VALUES (5, 0, 0, 0)
INSERT INTO @DayOfWeek VALUES (6, 0, 0, 0)
INSERT INTO @DayOfWeek VALUES (7, 0, 0, 0)

--Extract and assign various parts of Values from Current Date to Variable

DECLARE @CurrentDate AS DATETIME = @StartDate
SET @CurrentMonth = DATEPART(MM, @CurrentDate)
SET @CurrentYear = DATEPART(YY, @CurrentDate)
SET @CurrentQuarter = DATEPART(QQ, @CurrentDate)

/********************************************************************************************/
--Proceed only if Start Date(Current date ) is less than End date you specified above

WHILE @CurrentDate < @EndDate
BEGIN
 
/*Begin Day of week logic*/

         /*Check for Change in Month of the Current date if Month changed then 
          Change variable value*/
	IF @CurrentMonth != DATEPART(MM, @CurrentDate) 
	BEGIN
		UPDATE @DayOfWeek
		SET MonthCount = 0
		SET @CurrentMonth = DATEPART(MM, @CurrentDate)
	END

        /* Check for Change in Quarter of the Current date if Quarter changed then change 
         Variable value*/

	IF @CurrentQuarter != DATEPART(QQ, @CurrentDate)
	BEGIN
		UPDATE @DayOfWeek
		SET QuarterCount = 0
		SET @CurrentQuarter = DATEPART(QQ, @CurrentDate)
	END
       
        /* Check for Change in Year of the Current date if Year changed then change 
         Variable value*/
	

	IF @CurrentYear != DATEPART(YY, @CurrentDate)
	BEGIN
		UPDATE @DayOfWeek
		SET YearCount = 0
		SET @CurrentYear = DATEPART(YY, @CurrentDate)
	END
	
        -- Set values in table data type created above from variables 

	UPDATE @DayOfWeek
	SET 
		MonthCount = MonthCount + 1,
		QuarterCount = QuarterCount + 1,
		YearCount = YearCount + 1
	WHERE DOW = DATEPART(DW, @CurrentDate)

	SELECT
		@DayOfWeekInMonth = MonthCount,
		@DayOfQuarter = QuarterCount,
		@DayOfWeekInYear = YearCount
	FROM @DayOfWeek
	WHERE DOW = DATEPART(DW, @CurrentDate)
	
/*End Day of week logic*/


/* Populate Your Dimension Table with values*/
	
	INSERT INTO [dbo].[DimDate]
	SELECT
		
		CONVERT (char(8),@CurrentDate,112) as DateKey,
		@CurrentDate AS Date,
		CONVERT (char(10),@CurrentDate,103) as FullDateUK,
		CONVERT (char(10),@CurrentDate,101) as FullDateUSA,
		DATEPART(DD, @CurrentDate) AS DayOfMonth,
		--Apply Suffix values like 1st, 2nd 3rd etc..
		CASE 
			WHEN DATEPART(DD,@CurrentDate) IN (11,12,13) 
			THEN CAST(DATEPART(DD,@CurrentDate) AS VARCHAR) + 'th'
			WHEN RIGHT(DATEPART(DD,@CurrentDate),1) = 1 
			THEN CAST(DATEPART(DD,@CurrentDate) AS VARCHAR) + 'st'
			WHEN RIGHT(DATEPART(DD,@CurrentDate),1) = 2 
			THEN CAST(DATEPART(DD,@CurrentDate) AS VARCHAR) + 'nd'
			WHEN RIGHT(DATEPART(DD,@CurrentDate),1) = 3 
			THEN CAST(DATEPART(DD,@CurrentDate) AS VARCHAR) + 'rd'
			ELSE CAST(DATEPART(DD,@CurrentDate) AS VARCHAR) + 'th' 
			END AS DaySuffix,
		
		DATENAME(DW, @CurrentDate) AS DayName,
		DATEPART(DW, @CurrentDate) AS DayOfWeekUSA,

		-- check for Day of week as Per US and change it as per UK format 
		CASE DATEPART(DW, @CurrentDate)
			WHEN 1 THEN 7
			WHEN 2 THEN 1
			WHEN 3 THEN 2
			WHEN 4 THEN 3
			WHEN 5 THEN 4
			WHEN 6 THEN 5
			WHEN 7 THEN 6
			END 
			AS DayOfWeekUK,
		
		@DayOfWeekInMonth AS DayOfWeekInMonth,
		@DayOfWeekInYear AS DayOfWeekInYear,
		@DayOfQuarter AS DayOfQuarter,
		DATEPART(DY, @CurrentDate) AS DayOfYear,
		DATEPART(WW, @CurrentDate) + 1 - DATEPART(WW, CONVERT(VARCHAR, 
		DATEPART(MM, @CurrentDate)) + '/1/' + CONVERT(VARCHAR, 
		DATEPART(YY, @CurrentDate))) AS WeekOfMonth,
		(DATEDIFF(DD, DATEADD(QQ, DATEDIFF(QQ, 0, @CurrentDate), 0), 
		@CurrentDate) / 7) + 1 AS WeekOfQuarter,
		DATEPART(WW, @CurrentDate) AS WeekOfYear,
		DATEPART(MM, @CurrentDate) AS Month,
		DATENAME(MM, @CurrentDate) AS MonthName,
		CASE
			WHEN DATEPART(MM, @CurrentDate) IN (1, 4, 7, 10) THEN 1
			WHEN DATEPART(MM, @CurrentDate) IN (2, 5, 8, 11) THEN 2
			WHEN DATEPART(MM, @CurrentDate) IN (3, 6, 9, 12) THEN 3
			END AS MonthOfQuarter,
		DATEPART(QQ, @CurrentDate) AS Quarter,
		CASE DATEPART(QQ, @CurrentDate)
			WHEN 1 THEN 'First'
			WHEN 2 THEN 'Second'
			WHEN 3 THEN 'Third'
			WHEN 4 THEN 'Fourth'
			END AS QuarterName,
		DATEPART(Year, @CurrentDate) AS Year,
		'CY ' + CONVERT(VARCHAR, DATEPART(Year, @CurrentDate)) AS YearName,
		LEFT(DATENAME(MM, @CurrentDate), 3) + '-' + CONVERT(VARCHAR, 
		DATEPART(YY, @CurrentDate)) AS MonthYear,
		RIGHT('0' + CONVERT(VARCHAR, DATEPART(MM, @CurrentDate)),2) + 
		CONVERT(VARCHAR, DATEPART(YY, @CurrentDate)) AS MMYYYY,
		CONVERT(DATETIME, CONVERT(DATE, DATEADD(DD, - (DATEPART(DD, 
		@CurrentDate) - 1), @CurrentDate))) AS FirstDayOfMonth,
		CONVERT(DATETIME, CONVERT(DATE, DATEADD(DD, - (DATEPART(DD, 
		(DATEADD(MM, 1, @CurrentDate)))), DATEADD(MM, 1, 
		@CurrentDate)))) AS LastDayOfMonth,
		DATEADD(QQ, DATEDIFF(QQ, 0, @CurrentDate), 0) AS FirstDayOfQuarter,
		DATEADD(QQ, DATEDIFF(QQ, -1, @CurrentDate), -1) AS LastDayOfQuarter,
		CONVERT(DATETIME, '01/01/' + CONVERT(VARCHAR, DATEPART(YY, 
		@CurrentDate))) AS FirstDayOfYear,
		CONVERT(DATETIME, '12/31/' + CONVERT(VARCHAR, DATEPART(YY, 
		@CurrentDate))) AS LastDayOfYear,
		NULL AS IsHoliDayUSA,
		CASE DATEPART(DW, @CurrentDate)
			WHEN 1 THEN 0
			WHEN 2 THEN 1
			WHEN 3 THEN 1
			WHEN 4 THEN 1
			WHEN 5 THEN 1
			WHEN 6 THEN 1
			WHEN 7 THEN 0
			END AS IsWeekDay,
		NULL AS HoliDayUSA, Null, Null

	SET @CurrentDate = DATEADD(DD, 1, @CurrentDate)
END

/********************************************************************************************/
 
--Step 3.
--Update Values of HoliDay as per UK Government Declaration for National HoliDay.

/*Update HOLIDay fields of UK as per Govt. Declaration of National HoliDay*/
	
-- Good FriDay  April 18 
	UPDATE [dbo].[DimDate]
		SET HoliDayUK = 'Good FriDay'
	WHERE [Month] = 4 AND [DayOfMonth]  = 18

-- Easter MonDay  April 21 
	UPDATE [dbo].[DimDate]
		SET HoliDayUK = 'Easter MonDay'
	WHERE [Month] = 4 AND [DayOfMonth]  = 21

-- Early May Bank HoliDay   May 5 
   UPDATE [dbo].[DimDate]
		SET HoliDayUK = 'Early May Bank HoliDay'
	WHERE [Month] = 5 AND [DayOfMonth]  = 5

-- Spring Bank HoliDay  May 26 
	UPDATE [dbo].[DimDate]
		SET HoliDayUK = 'Spring Bank HoliDay'
	WHERE [Month] = 5 AND [DayOfMonth]  = 26

-- Summer Bank HoliDay  August 25 
    UPDATE [dbo].[DimDate]
		SET HoliDayUK = 'Summer Bank HoliDay'
	WHERE [Month] = 8 AND [DayOfMonth]  = 25

-- Boxing Day  December 26  	
    UPDATE [dbo].[DimDate]
		SET HoliDayUK = 'Boxing Day'
	WHERE [Month] = 12 AND [DayOfMonth]  = 26	

--CHRISTMAS
	UPDATE [dbo].[DimDate]
		SET HoliDayUK = 'Christmas Day'
	WHERE [Month] = 12 AND [DayOfMonth]  = 25

--New Years Day
	UPDATE [dbo].[DimDate]
		SET HoliDayUK  = 'New Year''s Day'
	WHERE [Month] = 1 AND [DayOfMonth] = 1

--Update flag for UK HoliDays 1= HoliDay, 0=No HoliDay
	
	UPDATE [dbo].[DimDate]
		SET IsHoliDayUK  = CASE WHEN HoliDayUK   IS NULL 
		THEN 0 WHEN HoliDayUK   IS NOT NULL THEN 1 END
		
 
--Step 4.
--Update Values of HoliDay as per USA Govt. Declaration for National HoliDay.

/*Update HOLIDay Field of USA In dimension*/
	
 	/*THANKSGIVING - Fourth THURSDay in November*/
	UPDATE [dbo].[DimDate]
		SET HoliDayUSA = 'Thanksgiving Day'
	WHERE
		[Month] = 11 
		AND [DayOfWeekUSA] = 'ThursDay' 
		AND DayOfWeekInMonth = 4

	/*CHRISTMAS*/
	UPDATE [dbo].[DimDate]
		SET HoliDayUSA = 'Christmas Day'
		
	WHERE [Month] = 12 AND [DayOfMonth]  = 25

	/*4th of July*/
	UPDATE [dbo].[DimDate]
		SET HoliDayUSA = 'Independance Day'
	WHERE [Month] = 7 AND [DayOfMonth] = 4

	/*New Years Day*/
	UPDATE [dbo].[DimDate]
		SET HoliDayUSA = 'New Year''s Day'
	WHERE [Month] = 1 AND [DayOfMonth] = 1

	/*Memorial Day - Last MonDay in May*/
	UPDATE [dbo].[DimDate]
		SET HoliDayUSA = 'Memorial Day'
	FROM [dbo].[DimDate]
	WHERE DateKey IN 
		(
		SELECT
			MAX(DateKey)
		FROM [dbo].[DimDate]
		WHERE
			[MonthName] = 'May'
			AND [DayOfWeekUSA]  = 'MonDay'
		GROUP BY
			[Year],
			[Month]
		)

	/*Labor Day - First MonDay in September*/
	UPDATE [dbo].[DimDate]
		SET HoliDayUSA = 'Labor Day'
	FROM [dbo].[DimDate]
	WHERE DateKey IN 
		(
		SELECT
			MIN(DateKey)
		FROM [dbo].[DimDate]
		WHERE
			[MonthName] = 'September'
			AND [DayOfWeekUSA] = 'MonDay'
		GROUP BY
			[Year],
			[Month]
		)

	/*Valentine's Day*/
	UPDATE [dbo].[DimDate]
		SET HoliDayUSA = 'Valentine''s Day'
	WHERE
		[Month] = 2 
		AND [DayOfMonth] = 14

	/*Saint Patrick's Day*/
	UPDATE [dbo].[DimDate]
		SET HoliDayUSA = 'Saint Patrick''s Day'
	WHERE
		[Month] = 3
		AND [DayOfMonth] = 17

	/*Martin Luthor King Day - Third MonDay in January starting in 1983*/
	UPDATE [dbo].[DimDate]
		SET HoliDayUSA = 'Martin Luthor King Jr Day'
	WHERE
		[Month] = 1
		AND [DayOfWeekUSA]  = 'MonDay'
		AND [Year] >= 1983
		AND DayOfWeekInMonth = 3

	/*President's Day - Third MonDay in February*/
	UPDATE [dbo].[DimDate]
		SET HoliDayUSA = 'President''s Day'
	WHERE
		[Month] = 2
		AND [DayOfWeekUSA] = 'MonDay'
		AND DayOfWeekInMonth = 3

	/*Mother's Day - Second SunDay of May*/
	UPDATE [dbo].[DimDate]
		SET HoliDayUSA = 'Mother''s Day'
	WHERE
		[Month] = 5
		AND [DayOfWeekUSA] = 'SunDay'
		AND DayOfWeekInMonth = 2

	/*Father's Day - Third SunDay of June*/
	UPDATE [dbo].[DimDate]
		SET HoliDayUSA = 'Father''s Day'
	WHERE
		[Month] = 6
		AND [DayOfWeekUSA] = 'SunDay'
		AND DayOfWeekInMonth = 3

	/*Halloween 10/31*/
	UPDATE [dbo].[DimDate]
		SET HoliDayUSA = 'Halloween'
	WHERE
		[Month] = 10
		AND [DayOfMonth] = 31

	/*Election Day - The first TuesDay after the first MonDay in November*/
	BEGIN
	DECLARE @HoliDays TABLE (ID INT IDENTITY(1,1), 
	DateID int, Week TINYINT, Year CHAR(4), Day CHAR(2))

		INSERT INTO @HoliDays(DateID, [Year],[Day])
		SELECT
			DateKey,
			[Year],
			[DayOfMonth] 
		FROM [dbo].[DimDate]
		WHERE
			[Month] = 11
			AND [DayOfWeekUSA] = 'MonDay'
		ORDER BY
			Year,
			DayOfMonth 

		DECLARE @CNTR INT, @POS INT, @STARTYear INT, @ENDYear INT, @MINDay INT

		SELECT
			@CurrentYear = MIN([Year])
			, @STARTYear = MIN([Year])
			, @ENDYear = MAX([Year])
		FROM @HoliDays

		WHILE @CurrentYear <= @ENDYear
		BEGIN
			SELECT @CNTR = COUNT([Year])
			FROM @HoliDays
			WHERE [Year] = @CurrentYear

			SET @POS = 1

			WHILE @POS <= @CNTR
			BEGIN
				SELECT @MINDay = MIN(Day)
				FROM @HoliDays
				WHERE
					[Year] = @CurrentYear
					AND [Week] IS NULL

				UPDATE @HoliDays
					SET [Week] = @POS
				WHERE
					[Year] = @CurrentYear
					AND [Day] = @MINDay

				SELECT @POS = @POS + 1
			END

			SELECT @CurrentYear = @CurrentYear + 1
		END

		UPDATE [dbo].[DimDate]
			SET HoliDayUSA  = 'Election Day'				
		FROM [dbo].[DimDate] DT
			JOIN @HoliDays HL ON (HL.DateID + 1) = DT.DateKey
		WHERE
			[Week] = 1
	END
	--set flag for USA holiDays in Dimension
	UPDATE [dbo].[DimDate]
SET IsHoliDayUSA = CASE WHEN HoliDayUSA  IS NULL THEN 0 WHEN HoliDayUSA  IS NOT NULL THEN 1 END
/*****************************************************************************************/

--SELECT * FROM [dbo].[DimDate]
