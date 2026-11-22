IF DB_ID(N'CommunityGarden') IS NULL
    CREATE DATABASE [CommunityGarden];
GO

USE [CommunityGarden];
GO

IF OBJECT_ID(N'dbo.GardenSite', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.GardenSite
    (
        GardenSiteId int IDENTITY(1,1) NOT NULL CONSTRAINT PK_GardenSite PRIMARY KEY,
        SiteCode varchar(16) NOT NULL CONSTRAINT UQ_GardenSite_SiteCode UNIQUE,
        SiteName nvarchar(100) NOT NULL,
        Neighborhood nvarchar(80) NOT NULL
    );
END;
GO

IF OBJECT_ID(N'dbo.GardenBed', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.GardenBed
    (
        GardenBedId int IDENTITY(1,1) NOT NULL CONSTRAINT PK_GardenBed PRIMARY KEY,
        GardenSiteId int NOT NULL,
        BedCode varchar(16) NOT NULL,
        SoilType nvarchar(40) NOT NULL,
        AreaSquareMetres decimal(7,2) NOT NULL,
        CONSTRAINT FK_GardenBed_GardenSite FOREIGN KEY (GardenSiteId)
            REFERENCES dbo.GardenSite(GardenSiteId),
        CONSTRAINT UQ_GardenBed_Site_BedCode UNIQUE (GardenSiteId, BedCode),
        CONSTRAINT CK_GardenBed_Area CHECK (AreaSquareMetres > 0)
    );
END;
GO

IF OBJECT_ID(N'dbo.CropPlan', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.CropPlan
    (
        CropPlanId int IDENTITY(1,1) NOT NULL CONSTRAINT PK_CropPlan PRIMARY KEY,
        GardenBedId int NOT NULL,
        CropName nvarchar(60) NOT NULL,
        Variety nvarchar(80) NOT NULL,
        PlantedOn date NOT NULL,
        TargetHarvestOn date NULL,
        PlanStatus varchar(16) NOT NULL,
        CONSTRAINT FK_CropPlan_GardenBed FOREIGN KEY (GardenBedId)
            REFERENCES dbo.GardenBed(GardenBedId),
        CONSTRAINT CK_CropPlan_Status CHECK (PlanStatus IN ('PLANNED', 'GROWING', 'HARVESTED'))
    );
END;
GO

IF OBJECT_ID(N'dbo.HarvestLog', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.HarvestLog
    (
        HarvestLogId int IDENTITY(1,1) NOT NULL CONSTRAINT PK_HarvestLog PRIMARY KEY,
        CropPlanId int NOT NULL,
        HarvestedOn date NOT NULL,
        QuantityKilograms decimal(7,2) NOT NULL,
        RecordedBy nvarchar(80) NOT NULL,
        CONSTRAINT FK_HarvestLog_CropPlan FOREIGN KEY (CropPlanId)
            REFERENCES dbo.CropPlan(CropPlanId),
        CONSTRAINT CK_HarvestLog_Quantity CHECK (QuantityKilograms > 0)
    );
END;
GO

IF NOT EXISTS (SELECT 1 FROM dbo.GardenSite WHERE SiteCode = 'RIVER-01')
    INSERT dbo.GardenSite (SiteCode, SiteName, Neighborhood)
    VALUES ('RIVER-01', N'Riverside Garden', N'Eastbank');
IF NOT EXISTS (SELECT 1 FROM dbo.GardenSite WHERE SiteCode = 'LIBRARY-02')
    INSERT dbo.GardenSite (SiteCode, SiteName, Neighborhood)
    VALUES ('LIBRARY-02', N'Library Roof Garden', N'Old Town');
GO

DECLARE @RiversideSiteId int = (SELECT GardenSiteId FROM dbo.GardenSite WHERE SiteCode = 'RIVER-01');
DECLARE @LibrarySiteId int = (SELECT GardenSiteId FROM dbo.GardenSite WHERE SiteCode = 'LIBRARY-02');

IF NOT EXISTS (SELECT 1 FROM dbo.GardenBed WHERE GardenSiteId = @RiversideSiteId AND BedCode = 'BED-A')
    INSERT dbo.GardenBed (GardenSiteId, BedCode, SoilType, AreaSquareMetres)
    VALUES (@RiversideSiteId, 'BED-A', N'Loam', 18.50);
IF NOT EXISTS (SELECT 1 FROM dbo.GardenBed WHERE GardenSiteId = @LibrarySiteId AND BedCode = 'ROOF-1')
    INSERT dbo.GardenBed (GardenSiteId, BedCode, SoilType, AreaSquareMetres)
    VALUES (@LibrarySiteId, 'ROOF-1', N'Raised-bed mix', 12.00);
GO

DECLARE @RiversideBedId int = (
    SELECT bed.GardenBedId
    FROM dbo.GardenBed AS bed
    INNER JOIN dbo.GardenSite AS site ON site.GardenSiteId = bed.GardenSiteId
    WHERE site.SiteCode = 'RIVER-01' AND bed.BedCode = 'BED-A'
);
DECLARE @LibraryBedId int = (
    SELECT bed.GardenBedId
    FROM dbo.GardenBed AS bed
    INNER JOIN dbo.GardenSite AS site ON site.GardenSiteId = bed.GardenSiteId
    WHERE site.SiteCode = 'LIBRARY-02' AND bed.BedCode = 'ROOF-1'
);

IF NOT EXISTS (SELECT 1 FROM dbo.CropPlan WHERE GardenBedId = @RiversideBedId AND CropName = N'Tomato' AND Variety = N'Black Krim')
    INSERT dbo.CropPlan (GardenBedId, CropName, Variety, PlantedOn, TargetHarvestOn, PlanStatus)
    VALUES (@RiversideBedId, N'Tomato', N'Black Krim', '2026-04-20', '2026-08-15', 'GROWING');
IF NOT EXISTS (SELECT 1 FROM dbo.CropPlan WHERE GardenBedId = @LibraryBedId AND CropName = N'Kale' AND Variety = N'Lacinato')
    INSERT dbo.CropPlan (GardenBedId, CropName, Variety, PlantedOn, TargetHarvestOn, PlanStatus)
    VALUES (@LibraryBedId, N'Kale', N'Lacinato', '2026-03-28', '2026-06-01', 'HARVESTED');
GO

DECLARE @HarvestedKaleId int = (
    SELECT plan.CropPlanId
    FROM dbo.CropPlan AS plan
    INNER JOIN dbo.GardenBed AS bed ON bed.GardenBedId = plan.GardenBedId
    INNER JOIN dbo.GardenSite AS site ON site.GardenSiteId = bed.GardenSiteId
    WHERE site.SiteCode = 'LIBRARY-02' AND bed.BedCode = 'ROOF-1' AND plan.CropName = N'Kale'
);

IF NOT EXISTS (SELECT 1 FROM dbo.HarvestLog WHERE CropPlanId = @HarvestedKaleId AND HarvestedOn = '2026-05-30')
    INSERT dbo.HarvestLog (CropPlanId, HarvestedOn, QuantityKilograms, RecordedBy)
    VALUES (@HarvestedKaleId, '2026-05-30', 4.75, N'Jordan Lee');
GO

CREATE OR ALTER VIEW dbo.vw_GardenHarvestSummary
AS
SELECT
    site.SiteCode,
    site.SiteName,
    COUNT(DISTINCT bed.GardenBedId) AS BedCount,
    COUNT(DISTINCT plan.CropPlanId) AS CropPlanCount,
    COALESCE(SUM(harvest.QuantityKilograms), 0) AS TotalHarvestKilograms
FROM dbo.GardenSite AS site
LEFT JOIN dbo.GardenBed AS bed ON bed.GardenSiteId = site.GardenSiteId
LEFT JOIN dbo.CropPlan AS plan ON plan.GardenBedId = bed.GardenBedId
LEFT JOIN dbo.HarvestLog AS harvest ON harvest.CropPlanId = plan.CropPlanId
GROUP BY site.SiteCode, site.SiteName;
GO
