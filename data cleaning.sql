-- CLEANING DATASET IN SQL

-- USE practice
SELECT * FROM laptop;

-- taking backup 

CREATE TABLE laptop_backup LIKE laptop;
INSERT INTO laptop_backup
SELECT * FROM laptop;  		-- backup created

-- Number of rows

SELECT COUNT(*) FROM laptop;
-- 1272 rows

-- dropping unnecessary colm, but there are no unnecessary colms
-- Renaming clm name
ALTER TABLE laptop
RENAME COLUMN `Unnamed: 0` TO `id`;

-- memory consumption in kb

SELECT DATA_LENGTH/1024 FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'practice'
AND TABLE_NAME = 'laptop';
-- 256 kb

-- checking null values
SELECT * FROM LAPTOP
WHERE Company IS NULL AND
		Inches IS NULL AND
		TypeName IS NULL AND
		ScreenResolution IS NULL AND
		Cpu IS NULL AND 
		Ram IS NULL AND 
		Memory IS NULL AND
		Gpu IS NULL AND
		OpSys IS NULL AND 
		Weight IS NULL AND 
		Price IS NULL;
-- Therefore no rows containg null values in each clm

-- Checking duplicate rows

SELECT * FROM (SELECT id,Company, TypeName, Inches, ScreenResolution, Cpu, Ram, Memory, Gpu, OpSys, Weight, Price,
			COUNT(*) OVER(PARTITION BY Company, TypeName, Inches, ScreenResolution, Cpu, Ram, Memory, Gpu, OpSys, Weight, Price) AS 'count'
			FROM laptop) AS t
WHERE count>1;
DELETE FROM laptop
WHERE id IN (SELECT id FROM (SELECT id,Company, TypeName, Inches, ScreenResolution, Cpu, Ram, Memory, Gpu, OpSys, Weight, Price,
			MIN(id) OVER(PARTITION BY Company, TypeName, Inches, ScreenResolution, Cpu, Ram, Memory, Gpu, OpSys, Weight, Price ORDER BY id) AS 'min_id',
			COUNT(*) OVER(PARTITION BY Company, TypeName, Inches, ScreenResolution, Cpu, Ram, Memory, Gpu, OpSys, Weight, Price) AS 'count',
            ROW_NUMBER() OVER(PARTITION BY Company, TypeName, Inches, ScreenResolution, Cpu, Ram, Memory, Gpu, OpSys, Weight, Price) AS 'rank'
			FROM laptop) AS t
WHERE count>1 AND `rank` !=1);  -- Therefore 29 duplicate rows deleted

-- Now lets change Ram clm
UPDATE laptop
SET Ram = REPLACE(Ram,'GB','');
ALTER TABLE laptop MODIFY Ram INTEGER;

-- changing OpSys clm
SELECT DISTINCT OpSys FROM laptop;

UPDATE laptop
SET OpSys =  CASE
				WHEN OpSys LIKE 'Windows%' THEN 'windows'
                WHEN OpSys LIKE '%mac%' THEN 'mac'
                WHEN OpSys LIKE 'Linux%' THEN 'linux'
                WHEN OpSys LIKE 'Chrome%' THEN 'chrome'
                WHEN OpSys LIKE 'Android%' THEN 'android'
                WHEN OpSys LIKE 'No OS' THEN 'na'
			END;              
               
-- Chnaging Weight clm

UPDATE laptop
SET Weight = REPLACE(Weight,'kg','');
-- one weight cell contains '?'
UPDATE laptop
SET Weight = 0
WHERE Weight = '?';
ALTER TABLE laptop MODIFY Weight DECIMAL(5,2);

-- Changing Price clm
UPDATE laptop
SET Price = ROUND(Price);
ALTER TABLE laptop MODIFY Price INTEGER;

-- changing ScreenResolution clm

ALTER TABLE laptop ADD COLUMN ScreenWidth INT;
ALTER TABLE laptop RENAME COLUMN ScreenWidth TO ScreenHeight; 
ALTER TABLE laptop ADD COLUMN ScreenWidth INT  AFTER Price;
ALTER TABLE laptop ADD COLUMN ips_panel INT;
ALTER TABLE laptop MODIFY ips_panel CHAR(5);
ALTER TABLE laptop ADD COLUMN full_hd CHAR(5);
ALTER TABLE laptop ADD COLUMN retina_display CHAR(5);
ALTER TABLE laptop ADD COLUMN resolution_category VARCHAR(50);
ALTER TABLE laptop ADD COLUMN touchscreen CHAR(5);




UPDATE laptop
SET ScreenWidth = SUBSTRING_INDEX(ScreenResolution,'x',-1);

UPDATE laptop
SET ScreenWidth = SUBSTRING_INDEX(SUBSTRING_INDEX(ScreenResolution,'x',1),' ',-1);



SELECT id,ScreenResolution FROM laptop
WHERE ScreenResolution LIKE '%IPS Panel%';

UPDATE laptop
SET ips_panel = CASE
					WHEN ScreenResolution LIKE '%IPS Panel%' THEN 'yes'
					ELSE 'no'
				END;
                
UPDATE laptop
SET full_hd = CASE
					WHEN LOWER(ScreenResolution) LIKE '%full hd%' THEN 'yes'
					ELSE 'no'
				END;

UPDATE laptop
SET retina_display = CASE
					WHEN LOWER(ScreenResolution) LIKE '%retina display%' THEN 'yes'
					ELSE 'no'
				END;
                
UPDATE laptop
SET touchscreen = CASE
					WHEN LOWER(ScreenResolution) LIKE '%touchscreen%' THEN 'yes'
					ELSE 'no'
				END;

SELECT DISTINCT ScreenResolution FROM laptop;
UPDATE laptop
SET resolution_category = CASE
							WHEN LOWER(ScreenResolution) LIKE '%full hd%' THEN 'full hd'
							WHEN LOWER(ScreenResolution) LIKE '%quad hd%' THEN 'quad hd'
							WHEN LOWER(ScreenResolution) LIKE '%4k ultra hd%' THEN '4k ultra hd'
							ELSE 'other'
						END;
SELECT * FROM laptop
WHERE LOWER(ScreenResolution) LIKE '%retina display%';

ALTER TABLE laptop
DROP COLUMN ScreenResolution,
DROP COLUMN full_hd;


-- Now lets come to Cpu column

ALTER TABLE laptop ADD COLUMN cpu_brand VARCHAR(25) AFTER Inches;
ALTER TABLE laptop ADD COLUMN cpu_family VARCHAR(25) AFTER cpu_brand;
ALTER TABLE laptop ADD COLUMN cpu_model VARCHAR(25) AFTER cpu_family;

ALTER TABLE laptop ADD COLUMN cpu_speed_ghz DECIMAL(10,2) AFTER cpu_family;

UPDATE laptop
SET cpu_brand = CASE
					WHEN LOWER(Cpu) LIKE '%intel%' THEN 'intel'
                    WHEN LOWER(Cpu) LIKE '%amd%' THEN 'amd'
                    ELSE 'other'
				END;

UPDATE laptop
SET cpu_family = CASE
					WHEN LOWER(Cpu) LIKE '%intel core%' THEN 'core'
                    WHEN LOWER(Cpu) LIKE '%intel atom%' THEN 'atom'
                    WHEN LOWER(Cpu) LIKE '%intel celeron%' THEN 'celeron'
                    WHEN LOWER(Cpu) LIKE '%intel pentium%' THEN 'pentium'
                    WHEN LOWER(Cpu) LIKE '%intel xeon%' THEN 'xeon'
                    WHEN LOWER(Cpu) LIKE '%amd a%' THEN 'a-series'
					WHEN LOWER(Cpu) LIKE '%amd e%' THEN 'e-series'
                    WHEN LOWER(Cpu) LIKE '%amd fx%' THEN 'fx'
                    WHEN LOWER(Cpu) LIKE '%amd ryzen%' THEN 'ryzen'
                    ELSE 'other'
				END;
                
WITH cleaned_text AS (
    SELECT
        id,
        LTRIM(
            REPLACE(
                LOWER(Cpu),
                LOWER(CONCAT_WS(' ', cpu_brand, cpu_family)),
                ''
            )
        ) AS cleaned_cpu
    FROM laptop
)
UPDATE laptop AS l
JOIN cleaned_text AS c ON l.id = c.id
SET l.cpu_model = TRIM(
    LEFT(
        c.cleaned_cpu,
        LENGTH(c.cleaned_cpu)
        - LENGTH(SUBSTRING_INDEX(c.cleaned_cpu, ' ', -1))
        - 1
    )
);

ALTER TABLE laptop
DROP COLUMN `Cpu`;

-- ====================================================
-- Now Memory Column
-- =====================================================
SELECT DISTINCT `Memory` FROM laptop;
ALTER TABLE laptop ADD COLUMN memory_1_capacity_gb INTEGER AFTER `Memory`;
ALTER TABLE laptop ADD COLUMN memory_1_type VARCHAR(10) AFTER `Memory`;
ALTER TABLE laptop ADD COLUMN memory_2_type VARCHAR(10) AFTER memory_1_capacity_gb;
ALTER TABLE laptop ADD COLUMN memory_2_capacity_gb INTEGER AFTER memory_2_type;





UPDATE laptop
SET memory_1_capacity_gb = CASE
								WHEN `Memory` LIKE '%SSD%' THEN REPLACE(SUBSTRING_INDEX(`Memory`,' ' ,1),'GB','')
                                ELSE 0
							END;

                                
ALTER TABLE laptop DROP COLUMN memory_1_capacity_gb;
ALTER TABLE laptop ADD COLUMN memory_1_capacity_gb INTEGER AFTER memory_1_type;
ALTER TABLE laptop ADD COLUMN memory_2_capacity_gb INTEGER AFTER memory_2_type;


UPDATE laptop
SET memory_1_capacity_gb = CASE
    WHEN `Memory` LIKE '%SSD%'
         AND SUBSTRING_INDEX(TRIM(`Memory`), ' ', 1) REGEXP '^[0-9]+GB$'
    THEN CAST(
        REPLACE(
            SUBSTRING_INDEX(TRIM(`Memory`), ' ', 1),
            'GB',
            ''
        ) AS UNSIGNED
    )
    ELSE NULL
END;

UPDATE laptop
SET memory_1_type = CASE
						WHEN `Memory` LIKE '%SSD%' THEN 'SSD'
                        ELSE '-'
					END;
                    
UPDATE laptop
SET memory_2_type = CASE
						WHEN `Memory` LIKE '%HDD%' THEN 'HDD'
                        ELSE '-'
					END;
         



ALTER TABLE laptop
DROP COLUMN memory_1_type,
DROP COLUMN memory_2_type,
DROP COLUMN memory_1_capacity_gb,
DROP COLUMN memory_2_capacity_gb;

ALTER TABLE laptop ADD COlUMN memory_capacity_gb INTEGER AFTER `Memory`;
ALTER TABLE laptop RENAME COLUMN memory_capacity_gb TO primary_storage;
ALTER TABLE laptop ADD COLUMN memory_type VARCHAR(50) AFTER `Memory`;
ALTER TABLE laptop ADD COLUMN secondary_storage VARCHAR(50) AFTER primary_storage;


UPDATE laptop
SET memory_type = CASE
						WHEN Memory LIKE '%SSD%' AND Memory LIKE '%HDD%' THEN 'hybrid'
                        WHEN Memory LIKE '%SSD%' THEN 'ssd'
                        WHEN Memory LIKE '%HDD%' THEN 'hdd'
                        WHEN Memory LIKE '%Flash Storage%' THEN 'flash_storage'
                        WHEN LOWER(Memory) LIKE '%hybrid%' THEN 'hybrid'
                        WHEN LOWER(Memory) LIKE '%flash storage%' AND LOWER(Memory) LIKE '%hdd%' THEN 'hybrid'
                        WHEN Memory LIKE '?' THEN NULL
                        ELSE NULL
					END;
                 
UPDATE laptop
SET primary_storage = REGEXP_SUBSTR(SUBSTRING_INDEX(Memory,'+',1),'[0-9]+');

UPDATE laptop
SET secondary_storage =  CASE WHEN Memory LIKE "%+%" THEN REGEXP_SUBSTR(SUBSTRING_INDEX(Memory,'+',-1),'[0-9]+') ELSE '0' END;
                  
ALTER TABLE laptop
DROP COLUMN Memory;

-- Now manipulating Gpu column
ALTER TABLE laptop
ADD COLUMN gpu_brand VARCHAR(50) AFTER Gpu,
ADD COLUMN gpu_name VARCHAR(50) AFTER gpu_brand;

UPDATE laptop
SET gpu_brand = SUBSTRING_INDEX(Gpu,' ',1);

UPDATE laptop
SET gpu_name = REPLACE(Gpu,gpu_brand,'');

ALTER TABLE laptop
DROP COLUMN Gpu;

SELECT * FROM laptop


