USE [AQ]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




-- ==================================================================================================================
-- Author:		Daniel Emmons, Shurong Zheng
-- Create date: 1/17/2018
-- Description: OST-581 UHG_CS Datafeed (Community & State) UCEE (United Consumer Engagement Engine) Interaction File
-- Send monthly on the 5th of each month
-- ==================================================================================================================

--Silkona Mohanty
--OST 1978,Disable HIPPA

--Lorena Roman
--OST 1957

--Daniel Emmons
--OST-2472 - data feed resurrected

-- ==================================================================================================================
-- Author:		Emona Nakuci
-- Create date: 9/11/2019
-- Description: OST-3124 Changed disposition code and file export location
-- ==================================================================================================================

CREATE PROCEDURE [dbo].[UHG_CS_UCEE_InteractionFileDataExport_EN]
AS

BEGIN TRY
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.;
	SET NOCOUNT ON;

	--stored procedure script
	IF OBJECT_ID('tempdb.dbo.#TrackCodeList', 'U') IS NOT NULL
	DROP TABLE #TrackCodeList

	IF OBJECT_ID('tempdb.dbo.#StagingTable', 'U') IS NOT NULL
	DROP TABLE #StagingTable

	TRUNCATE TABLE tempUHG_InteractionFeed 

	--To pull the entire previous month(i.e., if February, pull everything from January)
	--DECLARE @ReportStartDate DATETIME = (SELECT DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0)) --First day of previous month
	--DECLARE @ReportEndDate DATETIME = (SELECT DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0))     --First day of current month

	--to pull custom dates
	--DECLARE @ReportStartDate datetime = '2019-05-17'
	--SET @ReportEndDate = date,'2019-03-10'
	
	/*

	--Current prodction runs every week
	--****Need to uncomment this for production and comment out the above lines****
	DECLARE @ReportStartDate DATETIME = (SELECT MAX(RunDate) FROM [dbo].[UHG_CS_UCEE_InteractionFileHistory]) --Get data since the last run
	DECLARE @ReportEndDate DATETIME = CONVERT(date,GETDATE()) --CONVERT to date to set to a clean cut off time of midnight


	
	-- 1st run
	-- for July test file generation
	DECLARE @ReportStartDate DATETIME = '2019-07-01'
	DECLARE @ReportEndDate DATETIME = '2019-08-01'
	
*/
	-- 2nd run
	-- for July 12th till today test file generation
	DECLARE @ReportStartDate DATETIME = '2019-07-12'
	DECLARE @ReportEndDate DATETIME =  CONVERT(date,GETDATE())
	
	DECLARE @v_StartDate DATETIME = @ReportStartDate
	DECLARE @v_EndDate DATETIME = dateadd(day,7,@v_StartDate)



	--Get the jobs, packages, and seeds
	DECLARE @SQL varchar(1000)

	IF OBJECT_ID('tempdb..#TrackCodeList') IS NOT NULL DROP TABLE #TrackCodeList
	CREATE TABLE #TrackCodeList (
			TableID int identity(1,1)
			,TrackCode1 varchar(15)
			,JobID int
			,Active bit
			,ClientID int
			,JobName varchar(50)
			,ClientJobNbr varchar(20)
			,ChildID int
			,PkgID int
			,MailDate datetime
			,LastMailDate datetime
			,SeedDate datetime
			,CPVersion varchar(20)
			,ClientSeqNbr varchar(25)
			,SeedsID bigint
			,TPRDateValue datetime
			,OpCodeLast smallint
		)
		
	
	-- iterate in a weekly fashion
	WHILE (@v_StartDate <= @ReportEndDate)

	BEGIN
--	SELECT @v_StartDate, @v_EndDate

	--Created an openquery to improve performance on stored procedure
	SELECT @SQL = 'SELECT * from openquery(mtdata,''SELECT DISTINCT 
		    s.TrackCode1
			,j.JobID
			,j.Active
			,j.ClientID
			,j.JobName
			,j.ClientJobNbr
			,j.ChildID
			,p.PkgID
			,p.MailDate
			,p.LastMailDate
			,p.SeedDate
			,s.CPVersion
			,s.ClientSeqNbr
			,s.SeedsID
			,tpr.datevalue
			,tpr.OpCodeLast
		FROM TblJobs j WITH(NOLOCK)
			INNER JOIN TblPackages p WITH(NOLOCK)
				ON j.JobID = p.JobID
			INNER JOIN TblSeeds s WITH(NOLOCK)
				ON p.SeedDate = s.SeedDate
				AND p.PkgID = s.PkgID
			LEFT JOIN tblPostalResp tpr
				ON s.TrackCode1 = tpr.TrackCode1
					AND tpr.datevalue >= '''''+CONVERT(varchar,@v_StartDate,120)+'''''
					AND tpr.datevalue < '''''+CONVERT(varchar,@v_EndDate,120)+'''''
		WHERE j.ClientID = 1857
			AND j.Active = 1
			AND j.Test = 0
			AND j.JobName like ''''%3340PREVENTATIVE%''''
			AND p.Active = 1
			AND s.Active = 1
			AND p.MailDate >= '''''+CONVERT(varchar,@v_StartDate-30,120)+''''' AND p.MailDate < '''''+CONVERT(varchar,@v_EndDate,120)+''''''')'

	--RAISERROR( 'About to pull seeds',0,1) WITH NOWAIT

	INSERT INTO #TrackCodeList EXEC(@sql)
	
	SET @v_StartDate = dateadd(day,7,@v_StartDate)
	SET @v_EndDate = dateadd(day,7,@v_StartDate)
	
END
	

	DECLARE @PrintMsg nvarchar(500)
	SELECT @PrintMsg = CONVERT(nvarchar(20),GETDATE(),20) + ': Seeds pulled: ' + CONVERT(nvarchar(20),COUNT(*)) FROM #TrackCodeList
	RAISERROR(@PrintMsg ,0,1) WITH NOWAIT

	--SELECT * FROM #TrackCodeList ORDER BY TableID
	--SELECT DISTINCT PkgID FROM #TrackCodeList

	-- Create staging table to hold original mails, out for delivery mails and nixies
	IF OBJECT_ID('tempdb..#StagingTable') IS NOT NULL DROP TABLE #StagingTable
	CREATE TABLE #StagingTable(
			JobID INT
			,Active BIT
			,ClientID INT
			,JobName VARCHAR(50)
			,ClientJobNbr CHAR(20)
			,ChildID INT
			,PkgID INT
			,InteractionDate DATETIME
			,LastMailDate DATETIME
			,SeedDate DATETIME
			,CPVersion CHAR(20)
			,ClientSeqNbr VARCHAR(25)
			,SeedsID BIGINT
			,TrackCode1 VARCHAR(15)
			,FullName VARCHAR(60)
			,MailFirst VARCHAR(60)
			,MailLast VARCHAR(60)
			,DispositionCode NVARCHAR(20)
		)

	--temp table to hold addressee names
	IF OBJECT_ID('tempdb..#NameTable') IS NOT NULL DROP TABLE #NameTable
	CREATE TABLE #NameTable(
			PkgID INT
			,SeedsID BIGINT
			,FullName VARCHAR(60)
			,MailFirst VARCHAR(60)
			,MailLast VARCHAR(60)
		)

	--get the addressee names from AddressMailed
	INSERT INTO #NameTable
	SELECT DISTINCT sp.PkgID
			,sp.SeedsID
			,amh.[Name] AS FullName
			,LEFT(dbo.nameparse(amh.Name,'F'),30) as MailFirst
			,LEFT(dbo.nameparse(amh.Name,'L'),30) as MailLast
		FROM #TrackCodeList  sp
			INNER JOIN [AQ].[dbo].[AddressMailed] amh WITH(NOLOCK, INDEX(idxTrackCode1))
				ON sp.pkgId = amh.PkgID
					AND sp.TrackCode1 = amh.TrackCode1

	CREATE INDEX idx_NameTable_PkgIDandSeedsID
		ON #NameTable (PkgID, SeedsID);

	SELECT @PrintMsg = CONVERT(nvarchar(20),GETDATE(),20) + ': Names pulled: ' + CONVERT(nvarchar(20),COUNT(*)) FROM #NameTable
	RAISERROR(@PrintMsg ,0,1) WITH NOWAIT

	--SELECT COUNT(*) FROM #StagingTable
	--SELECT COUNT(*) FROM #NameTable

	--Insert the mailed pieces to the staging table
    INSERT INTO #StagingTable
	SELECT sp.[JobID]
			,sp.[Active]
			,sp.[ClientID]
			,sp.[JobName]
			,sp.[ClientJobNbr]
			,sp.[ChildID]
			,sp.PkgID
            ,MIN(sp.TPRDateValue) AS InteractionDate
			,sp.LastMailDate
			,sp.SeedDate
			,sp.CPVersion
			,sp.ClientSeqNbr
			,sp.SeedsID
			,sp.[TrackCode1]
			,nt.FullName
			,nt.MailFirst
			,nt.MailLast
			,'MPMLD' AS DispositionCode			  
		FROM #TrackCodeList sp
			INNER JOIN #NameTable nt
				ON sp.PkgID = nt.PkgID
					AND sp.SeedsID = nt.SeedsID
		WHERE sp.OpCodeLast = 0
		GROUP BY sp.[JobID]
			,sp.[Active]
			,sp.[ClientID]
			,sp.[JobName]
			,sp.[ClientJobNbr]
			,sp.[ChildID]
			,sp.PkgID
			,sp.LastMailDate
			,sp.SeedDate
			,sp.CPVersion
			,sp.ClientSeqNbr
			,sp.SeedsID
			,sp.[TrackCode1]
			,nt.FullName
			,nt.MailFirst
			,nt.MailLast

	SELECT @PrintMsg = CONVERT(nvarchar(20),GETDATE(),20) + ': Staging Table Records: ' + CONVERT(nvarchar(20),COUNT(*)) FROM #StagingTable
	RAISERROR(@PrintMsg ,0,1) WITH NOWAIT

	--insert the OutForDelivery pieces to the staging table
    INSERT INTO #StagingTable
	SELECT sp.[JobID]
			,sp.[Active]
			,sp.[ClientID]
			,sp.[JobName]
			,sp.[ClientJobNbr]
			,sp.[ChildID]
			,sp.PkgID
            ,MAX(sp.TPRDateValue) AS InteractionDate
			,sp.LastMailDate
			,sp.SeedDate
			,sp.CPVersion
			,sp.ClientSeqNbr
			,sp.SeedsID
			,sp.[TrackCode1]
			,nt.FullName
			,nt.MailFirst
			,nt.MailLast
			,'MPOFDLVRY' AS DispositionCode			  
		FROM #TrackCodeList sp
			--INNER JOIN #OutForDelivery t 
			--	ON sp.trackcode1 = t.trackcode1
			INNER JOIN #NameTable nt
				ON sp.PkgID = nt.PkgID
					AND sp.SeedsID = nt.SeedsID
		WHERE sp.OpCodeLast = 1
		GROUP BY sp.[JobID]
			,sp.[Active]
			,sp.[ClientID]
			,sp.[JobName]
			,sp.[ClientJobNbr]
			,sp.[ChildID]
			,sp.PkgID
			,sp.LastMailDate
			,sp.SeedDate
			,sp.CPVersion
			,sp.ClientSeqNbr
			,sp.SeedsID
			,sp.[TrackCode1]
			,nt.FullName
			,nt.MailFirst
			,nt.MailLast

	SELECT @PrintMsg = CONVERT(nvarchar(20),GETDATE(),20) + ': Staging Table Records: ' + CONVERT(nvarchar(20),COUNT(*)) FROM #StagingTable
	RAISERROR(@PrintMsg ,0,1) WITH NOWAIT

	--*****add nixies in (No COA needed)*****
	INSERT INTO #StagingTable
	SELECT DISTINCT
			tcl.[JobID]
			,tcl.[Active]
			,tcl.[ClientID]
			,tcl.[JobName]
			,tcl.[ClientJobNbr]
			,tcl.[ChildID]
			,tcl.PkgID
			,h.SourceFileDate AS InteractionDate
			,tcl.MailDate
			,tcl.SeedDate
			,tcl.CPVersion
			,tcl.ClientSeqNbr
			,tcl.SeedsID
			,tcl.[TrackCode1]
			,nt.FullName
			,nt.MailFirst
			,nt.MailLast
			,'MPRTNUNDEL' AS DispositionCode
		FROM #TrackCodeList tcl
			INNER JOIN AQ.dbo.ACSDetail d WITH (NOLOCK, INDEX (idxTrackCode1), forceseek)
				ON tcl.TrackCode1 = d.TrackCode1
			INNER JOIN AQ.dbo.ACSHeader h WITH (NOLOCK, INDEX (idxFileDate))
				ON d.ACSHeaderId = h.ACSHeaderId
			INNER JOIN #NameTable nt
				ON tcl.PkgID = nt.PkgID
					AND tcl.SeedsID = nt.SeedsID
		WHERE d.DeliverabilityCode != '' 
			AND d.DeliverabilityCode != 'W'
			AND h.SourceFileDate >= @ReportStartDate 
			AND h.SourceFileDate < @ReportEndDate  --only previous month's records
			AND d.ACSDetailActive = 1

	SELECT @PrintMsg = CONVERT(nvarchar(20),GETDATE(),20) + ': Staging Table Records: ' + CONVERT(nvarchar(20),COUNT(*)) FROM #StagingTable
	RAISERROR(@PrintMsg ,0,1) WITH NOWAIT

	--SELECT * FROM #StagingTable ORDER BY InteractionDate DESC
	--DELETE FROM #StagingTable WHERE InteractionDate > '2019-07-09'

	--put the data into the export table
	INSERT INTO tempUHG_InteractionFeed 
	SELECT
			LEFT(ISNULL(MailFirst,''),20) AS FirstName
			,'' AS MiddleInitial
			,LEFT(ISNULL(MailLast,''),20) AS LastName
			,'' AS Suffix
			,'' AS Address1
			,'' AS Address2
			,'' AS City
			,'' AS State
			,'' AS Zip
			,'' AS EmailAddress
			,'' AS PhoneNumber
			,'' AS BirthDate
			,'' AS Gender
			,'' AS Deceased
			,'' AS Language
			,'' AS MaritalStatus
			,'' AS PrefMethodOfContact
			,'' AS OKToCall
			,'' AS OKToEmail
			,'' AS OKToMail
			,ISNULL(LEFT(REPLACE(CONVERT(VARCHAR(16),CONVERT(DATE,InteractionDate)),'-',''),8),'') AS InteractionDate
			,'' AS CellID
			,DispositionCode
			,'84' AS InboundChannel
			,'AC' AS Product
			,CPVersion AS ProspectSourceCode
			,'GH' AS SourceCode
			,'' AS SourceSystemIndividualID
			,'' AS Filler
			,'' AS MissingMedicarePartAorPartB
			,'' AS ESRDIndicator
			,'' AS HospiceIndicator
			,'' AS InboundPhoneNumber
			,'' AS SelfReportedMedicaidFlag
			,'' AS Filler2
			,'' AS Filler3
			,'' AS InternetAccessFlag
			,'' AS Filler4
			,'' AS Filler5
			,'' AS CaregiverCallingFlag
			,'' AS MilitaryCoverageFlag
			,'' AS EmployerCoverageFlag
			,'' AS Filler6
			,ISNULL(LEFT(CONVERT(VARCHAR(16),CONVERT(TIME,InteractionDate)),8),'') AS InteractionTime
			,'' AS PDPCompCoverageFlag
			,'' AS EligibilityGroupNumber
			,'' AS PlanEffectiveDate
			,'' AS ApplicationID
			,'' AS ApplicationStatus
			,'' AS PlanLOBID
			,'' AS ApplicationSourceCode
			,'' AS ApplicationSourceDesc
			,'' AS ApplicationReceiptDate
			,'' AS GPSPlanCode
			,'' AS BrokerID
			,'' AS CMSContractNumber
			,'' AS PBP
			,'' AS SalesInitiative
			,'' AS ApplicationStatusDate
			,'' AS AdjudicationStatusCode
			,'' AS AdjudicationStatusDesc
			,'' AS SourceSystemGeneratedID
			,'' AS MailingAddressLine1
			,'' AS MailingAddressLine2
			,'' AS MailingCity
			,'' AS MailingState
			,'' AS MailingZipCode
			,'' AS OtherPhone
			,'' AS PartyID
			,'' AS MedicareNumber
			,'' AS STARSMeasureYear
			,'' AS STARSMeasureCode
			,'' AS OpportunityCreateDate
			,'' AS MeetingDate
			,'' AS FutureEffectiveDate
			,'' AS GoogleClickID
			,'' AS AdobeVisitorID
			,CASE WHEN CHARINDEX('_', ISNULL(ClientSeqNbr,'')) = 0
				THEN ''
				ELSE LEFT(ClientSeqNbr,CHARINDEX('_', ClientSeqNbr)-1)
				END AS HealthPlan
			,CASE WHEN CHARINDEX('_', ISNULL(ClientSeqNbr,'')) = 0
				THEN ''
				ELSE SUBSTRING(ClientSeqNbr,CHARINDEX('_', ClientSeqNbr)+1,LEN(ClientSeqNbr))
				END AS MedicaidID
			,'' AS CSMeasureID
			,'' AS CSSubMeasure
		FROM #StagingTable

	--SELECT COUNT(*) FROM tempUHG_InteractionFeed
	--SELECT @PrintMsg = CONVERT(nvarchar(20),GETDATE(),20) + ': Export Table Records: ' + CONVERT(nvarchar(20),COUNT(*)) FROM tempUHG_InteractionFeed
	--RAISERROR(@PrintMsg ,0,1) WITH NOWAIT

	--keep the history of the data feed
	INSERT INTO [dbo].[UHG_CS_UCEE_InteractionFileHistory]
	SELECT JobID
			,Active
			,ClientID
			,JobName
			,ClientJobNbr
			,ChildID
			,PkgID
			,InteractionDate
			,LastMailDate
			,SeedDate
			,CPVersion
			,ClientSeqNbr
			,SeedsID
			,TrackCode1
			,FullName
			,MailFirst
			,MailLast
			,'' AS Address1
			,'' AS Address2
			,'' AS Address3
			,'' AS City
			,'' AS State
			,'' AS ZIP
			,DispositionCode
			,@ReportEndDate
		FROM #StagingTable

	--SELECT COUNT(*) FROM UHG_CS_UCEE_InteractionFileHistory WHERE RunDate = @ReportEndDate
	--SELECT @PrintMsg = CONVERT(nvarchar(20),GETDATE(),20) + ': History Table Records: ' + CONVERT(nvarchar(20),COUNT(*)) FROM UHG_CS_UCEE_InteractionFileHistory WHERE RunDate = @ReportEndDate
	--RAISERROR(@PrintMsg ,0,1) WITH NOWAIT

	--SELECT * FROM tempUHG_InteractionFeed
	--SELECT * FROM UHG_CS_UCEE_InteractionFileHistory WHERE RunDate = '2019-07-10'
		
--export to a file
			DECLARE @RecordCount INT 
			SELECT @RecordCount = COUNT(*) FROM tempUHG_InteractionFeed
			DECLARE @ExportDate VARCHAR(20) = CONVERT(VARCHAR(20),GETDATE(),120)

			DECLARE @CurrentDateTime VARCHAR(20) = REPLACE(CONVERT(VARCHAR(50),GETDATE(),112) + CONVERT(VARCHAR(50),GETDATE(),108),':','')

			--DECLARE @FilePath VARCHAR(50) = '\\pavfsql12\BOANAF\ACSExport\UHG\CS_UCEE\test\'
			DECLARE @FilePath VARCHAR(50) = '\\pavfsql12\BOANAF\ACSExport\UHG\CS_UCEE\'

			DECLARE @FilePrefix VARCHAR(50) = 'GH_INTXN_'
			DECLARE @FileName VARCHAR(50) = @FilePrefix + @CurrentDateTime + '.txt'
			DECLARE @FullyQualifiedFile VARCHAR(100) = @FilePath + @fileName
			DECLARE @bcpCommandSelect VARCHAR(4000) = 'bcp "SELECT * FROM tempUHG_InteractionFeed" queryout '
			DECLARE @bcpCommandArgs VARCHAR(4000) = @FullyQualifiedFile + ' -U dataetl -P Ghs54321 -c -t '
			DECLARE @bcpCommand VARCHAR(4000) = @bcpCommandSelect + @bcpCommandArgs
			DECLARE @ReturnValue INT

			EXEC @ReturnValue=master..xp_cmdshell @bcpCommand
				IF @ReturnValue<>0
				RAISERROR ('Failed to export file to \\pavfsql12\BOANAF\ACSExport\UHG\CS_UCEE\ !', 16,1)

			EXEC [sql05.ghscorp.com].[PerfMonitor].[dbo].[LogDateFeedExport] @ExportDate,'UHG_CS_UCEE_InteractionFileDataExport','AQ',@FileName,@RecordCount	

			--Control File Export
			SELECT @FileName = REPLACE(@FileName,'.txt','.ctr')
			SELECT @FullyQualifiedFile = @FilePath + @FileName
 
			SET @bcpCommand='bcp "SELECT count(*) from tempUHG_InteractionFeed" queryout "'
			SET @bcpCommand = @bcpCommand + @FullyQualifiedFile + '" -U dataetl -P Ghs54321  -c -t '
			EXEC @ReturnValue=master..xp_cmdshell @bcpCommand
			IF @ReturnValue<>0
				RAISERROR ('Failed to export control file to \\pavfsql12\BOANAF\ACSExport\UHG\CS_UCEE\ !', 16,1)  

END TRY

BEGIN CATCH
			DECLARE @subject VARCHAR(200), @body VARCHAR(1000)
			SELECT @subject ='Data Feed Error -- UHG_CS_UCEE_InteractionFileDataExport'
			SELECT @body='Procedure Name: ' + ISNULL(OBJECT_NAME(@@PROCID),'')
			SELECT @body = @body + '<BR>This procedure is called by UHG_CS_UCEE_InteractionFileDataExport on AQ.'
			SELECT @body = @body + '<BR>Error Message: '+ERROR_MESSAGE()
 
			EXEC dbo.spSendEmail @subject, @body,'dataetl@grayhairsoftware.com;sys_admins@grayhairsoftware.com'
END CATCH


GO

