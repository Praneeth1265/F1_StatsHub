-- ===============================================
-- F1 DB: Procedures, Triggers, Functions
-- Works with your existing data
-- ===============================================

USE F1;

--------------------------------------------------------------------------------
-- 0) Drop existing routines and triggers (if any)
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- 1) FUNCTION: getDriverFullName(driver_id)
-- Returns "Forename Surname" for a given Driver_ID
--------------------------------------------------------------------------------
DELIMITER $$
CREATE FUNCTION getDriverFullName(dID INT) RETURNS VARCHAR(200)
DETERMINISTIC
BEGIN
    DECLARE fname VARCHAR(50);
    DECLARE sname VARCHAR(50);
    SELECT Forename, Surname INTO fname, sname
    FROM Drivers
    WHERE Driver_ID = dID;
    RETURN CONCAT_WS(' ', fname, sname);
END$$
DELIMITER ;

--------------------------------------------------------------------------------
-- 2) TRIGGER: Before insert on Results
-- Automatically assigns Points if NULL or 0 based on Position_Order
--------------------------------------------------------------------------------
DELIMITER $$
CREATE TRIGGER trg_results_before_insert
BEFORE INSERT ON Results
FOR EACH ROW
BEGIN
    IF NEW.Points IS NULL OR NEW.Points = 0 THEN
        SET NEW.Points =
            CASE
                WHEN NEW.Position_Order = 1 THEN 25
                WHEN NEW.Position_Order = 2 THEN 18
                WHEN NEW.Position_Order = 3 THEN 15
                WHEN NEW.Position_Order = 4 THEN 12
                WHEN NEW.Position_Order = 5 THEN 10
                WHEN NEW.Position_Order = 6 THEN 8
                WHEN NEW.Position_Order = 7 THEN 6
                WHEN NEW.Position_Order = 8 THEN 4
                WHEN NEW.Position_Order = 9 THEN 2
                WHEN NEW.Position_Order = 10 THEN 1
                ELSE 0
            END;
    END IF;
END$$
DELIMITER ;
--------------------------------------------------------------------------------
-- 3) TRIGGER: Before insert on Results
-- Throws an error if duplicate
--------------------------------------------------------------------------------
DELIMITER $$

CREATE TRIGGER PreventDuplicateResults
BEFORE INSERT ON Results
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1
        FROM Results
        WHERE Driver_ID = NEW.Driver_ID
          AND Constructor_ID = NEW.Constructor_ID
          AND Position_Order = NEW.Position_Order
          AND Race_ID = NEW.Race_ID
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Duplicate entry: This driver-constructor-position combination already exists for the race.';
    END IF;
END$$

DELIMITER ;

--------------------------------------------------------------------------------
-- 4) PROCEDURE: RecalculateAllRaceRanks()
-- Recalculates RaceRank for every race in Results.
-- Returns all rows grouped by Race_ID and sorted by RaceRank.
--------------------------------------------------------------------------------
DELIMITER $$
CREATE PROCEDURE RecalculateAllRaceRanks()
BEGIN
    -- Initialize variables
    SET @current_race := 0;
    SET @rank := 0;

    -- Update all rows with proper ranking
    UPDATE Results r
    JOIN (
        SELECT 
            Result_ID,
            Race_ID,
            @rank := IF(@current_race = Race_ID, @rank + 1, 1) AS new_rank,
            @current_race := Race_ID
        FROM Results
        CROSS JOIN (SELECT @rank := 0, @current_race := 0) AS vars
        ORDER BY Race_ID ASC, Position_Order ASC
    ) AS sub
    ON r.Result_ID = sub.Result_ID
    SET r.RaceRank = sub.new_rank;

    -- Return all results sorted
    SELECT *
    FROM Results
    ORDER BY Race_ID ASC, RaceRank ASC;
END$$

DELIMITER ;

--------------------------------------------------------------------------------
-- 5) PROCEDURE: assign_points_for_race(race_id)
-- Updates Points for all results of a race based on Position_Order
--------------------------------------------------------------------------------
DELIMITER $$
CREATE PROCEDURE assign_points_for_race(IN rID INT)
BEGIN
    UPDATE Results
    SET Points = CASE
            WHEN Position_Order = 1 THEN 25
            WHEN Position_Order = 2 THEN 18
            WHEN Position_Order = 3 THEN 15
            WHEN Position_Order = 4 THEN 12
            WHEN Position_Order = 5 THEN 10
            WHEN Position_Order = 6 THEN 8
            WHEN Position_Order = 7 THEN 6
            WHEN Position_Order = 8 THEN 4
            WHEN Position_Order = 9 THEN 2
            WHEN Position_Order = 10 THEN 1
            ELSE 0
        END
    WHERE Race_ID = rID;
END$$
DELIMITER ;

--------------------------------------------------------------------------------
-- 6) PROCEDURE: add_result(...)
-- Inserts a result row with validation
-- Points will be auto-assigned by trigger
--------------------------------------------------------------------------------
DELIMITER $$

DROP PROCEDURE IF EXISTS add_result $$
CREATE PROCEDURE add_result(
    IN p_Race_ID INT,
    IN p_Driver_ID INT,
    IN p_Constructor_ID INT,
    IN p_Car_ID INT,
    IN p_Position_Order INT,
    IN p_Grid INT,
    IN p_Status_ID INT
)
BEGIN
    -- Validate foreign keys
    IF NOT EXISTS (SELECT 1 FROM Races WHERE Race_ID = p_Race_ID) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Race does not exist';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM Drivers WHERE Driver_ID = p_Driver_ID) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Driver does not exist';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM Constructors WHERE Constructor_ID = p_Constructor_ID) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Constructor does not exist';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM Cars WHERE Car_ID = p_Car_ID) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Car does not exist';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM Status WHERE Status_ID = p_Status_ID) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Status does not exist';
    END IF;

    -- Insert new result row
    INSERT INTO Results (Race_ID, Driver_ID, Constructor_ID, Car_ID, Position_Order, Grid, Status_ID)
    VALUES (p_Race_ID, p_Driver_ID, p_Constructor_ID, p_Car_ID, p_Position_Order, p_Grid, p_Status_ID);

    -- Recalculate RaceRank using ROW_NUMBER()
    WITH ranked AS (
        SELECT Result_ID,
               ROW_NUMBER() OVER (PARTITION BY Race_ID ORDER BY Position_Order ASC) AS new_rank
        FROM Results
        WHERE Race_ID = p_Race_ID
    )
    UPDATE Results r
    JOIN ranked rk ON r.Result_ID = rk.Result_ID
    SET r.RaceRank = rk.new_rank;

END $$

DELIMITER ;

--------------------------------------------------------------------------------
-- 7) PROCEDURE: swap
-- Swaps any two driver's finishing posi in result table
--------------------------------------------------------------------------------
DELIMITER $$

CREATE PROCEDURE swap_driver_positions(
    IN p_Race_ID INT,
    IN p_Driver1_ID INT,
    IN p_Driver2_ID INT
)
BEGIN
    DECLARE pos1 INT;
    DECLARE pos2 INT;

    -- Get both drivers' positions in the race
    SELECT Position_Order INTO pos1
    FROM Results
    WHERE Race_ID = p_Race_ID AND Driver_ID = p_Driver1_ID;

    SELECT Position_Order INTO pos2
    FROM Results
    WHERE Race_ID = p_Race_ID AND Driver_ID = p_Driver2_ID;

    -- Validate existence
    IF pos1 IS NULL OR pos2 IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'One or both drivers not found in the race.';
    END IF;

    -- Swap positions
    UPDATE Results
    SET Position_Order = CASE 
        WHEN Driver_ID = p_Driver1_ID THEN pos2
        WHEN Driver_ID = p_Driver2_ID THEN pos1
    END
    WHERE Race_ID = p_Race_ID AND Driver_ID IN (p_Driver1_ID, p_Driver2_ID);

    -- Recalculate race ranks after swap
    CALL RecalculateAllRaceRanks();
END$$

DELIMITER ;

--------------------------------------------------------------------------------
-- 8) PROCEDURE: delete a result tuple
-- Deletes a tuple from result table
--------------------------------------------------------------------------------
DELIMITER $$
CREATE PROCEDURE delete_result(
    IN p_race_id INT,
    IN p_driver_id INT,
    IN p_position_order INT
)
BEGIN
    DECLARE cnt INT;

    -- Check if the result exists
    SELECT COUNT(*) INTO cnt
    FROM Results
    WHERE Race_ID = p_race_id
      AND Driver_ID = p_driver_id
      AND Position_Order = p_position_order;

    IF cnt = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '❌ No such result found for this race, driver, and position.';
    ELSE
        DELETE FROM Results
        WHERE Race_ID = p_race_id
          AND Driver_ID = p_driver_id
          AND Position_Order = p_position_order
        LIMIT 1;
    END IF;
END$$
DELIMITER ;