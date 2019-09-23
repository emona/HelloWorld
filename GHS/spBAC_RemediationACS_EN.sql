USE [AQ]
GO
/****** Object:  StoredProcedure [dbo].[spBAC_RemediationACS] Script Date:4/22/2019 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spBAC_RemediationACS_EN]
AS
-- =============================================
-- Author:		Leon Matthews
-- Create date: 2019-04-19
-- Description:	Produce ACS Records for the BAC 
--				Remediation job seeds
-- =============================================
-- Author:		Emona Nakuci
-- JIRA:			BCR-371
-- Create date: 2019-09-11
-- Description:	Remove Blanks and W records
-- =============================================
BEGIN


	declare @JobId int, @JobName varchar(50), @PkgID varchar(20), @ClientJobNbr char(20), @ExportCount int
	declare @bcpCommand varchar(500),@filePath varchar(200), @fileName varchar(200), @file varchar(200)
	declare @JbNm varchar(100), @JbNmLen int, @CharPos int
	declare @ret int -- hold return value from master..xp_cmdshell, if not 0, means trouble
	declare @ExportDate datetime
	--Truncate the tempBACACSRemediation table
	truncate table tempBACACSRemediation

	--Select any and all packages for the BAC Remediation LOB
	select isnull(ChildUploadLog.Logid,ParentUploadLog.logid) as LogId, 
	SelectSolutionPkgLogs.ClientPkgNbr as PkgNbr,
	pkgs.PkgID,
	jobs.JobID, 
	jobs.JobName, 
	jobs.ClientJobNbr
	INTO #Export
	from FullProcessFileUploadLog ParentUploadLog with (nolock)
	inner join mtdata.mailtrak.dbo.SelectSolutionPkgLogs SelectSolutionPkgLogs with (nolock)
	on ParentUploadLog.logid = SelectSolutionPkgLogs.logid
	inner join mtdata.mailtrak.dbo.TblPackages as pkgs with (nolock)
	on SelectSolutionPkgLogs.PkgId = pkgs.PkgID
	inner join mtdata.mailtrak.dbo.TblJobs as jobs with (nolock)
	on pkgs.JobID = jobs.JobID
	left outer join FullProcessFileGroup with (nolock)
	on SelectSolutionPkgLogs.logid = FullProcessFileGroup.logid
	left outer join FullProcessFileUploadLog ChildUploadLog with (nolock)
	on FullProcessFileGroup.FullProcessFileGroupId = ChildUploadLog.FileGrpId
	--[OST-2404] Added 'left outer join' to the Export select to 
	-- allow the sp to ignore jobs/packages that had already been processed
	left outer join BAC_RemediationExportLog as tbr 
	on tbr.JobName = jobs.JobName 
	and (ChildUploadLog.logid = tbr.ParentLogId OR ParentUploadLog.LogID = tbr.ParentLogId)
	 where convert(varchar(10), ParentUploadLog.FullProcessStart,120) > CONVERT(varchar(10), getdate()-120,120)
	--where convert(varchar(10),ParentUploadLog.FullProcessStart,120) = CONVERT(varchar(10),getdate()-@DaysAfter,120)
	and pkgs.Active = 1 
	and jobs.ClientID = 378 
	--and ((TblJobs.ChildID in (751,1406,2100) and TblJobs.ContactID in (4489,6182,7628,6181,11956)) or TblJobs.JobID in (61540,62141,62620,65725,66140))
	and ((jobs.ChildID in (751,1406,2100) and jobs.ContactID in (4489,6182,7628,6181,11956,5778)) or jobs.JobID in (61540,62141,62620,65725,66140))
	and jobs.Active = 1
	and jobs.Test = 0


	--Loop round a local cursor for each package and pull them.
	declare  Export  cursor local for 
		select distinct JobId, JobName, ClientJobNbr, PkgID from #Export
	open Export
	fetch next from Export into @JobId, @JobName, @ClientJobNbr, @PkgID
	begin
		begin try
			while @@fetch_status=0
			begin
				--Pull the ACS Detail from the last even days
				INSERT INTO tempBACACSRemediation
						   ([MoveType]
						   ,[MoveEffectiveDate]
						   ,[DeliverabilityCode]
						   ,[IntelligentMailBarcode]
						   ,[UniqueRecordIdentifier]
						   ,[Name]
						   ,[BusinessName]
						   ,[Address1]
						   ,[Address2]
						   ,[Address3]
						   ,[City]
						   ,[State]
						   ,[Zip])
				select 
					ISNULL(a.MoveType,''),
					ISNULL(a.MoveEffectiveDate,''),
					a.DeliverabilityCode,
					x.IMB+x.IMBPostnet as IMB,
					x.seqNbr,
					x.FullName,
					x.BusiName,
					a.NewPrimaryNbr+a.NewPreDirectional+a.NewStreetName+a.NewStreetSuffix+a.NewPostDirectional as Address1,
					a.NewUnitDesignator+a.NewSecondaryNbr as Address2,
					'' as Address3,
					a.NewCity,
					a.NewState,
					ISNULL(a.New5Zip,'')
				from #Export with (nolock)
				inner join [MTSelectSol\MTSelect].MTSelectSolution.dbo.MTSelectFullProcessData x with (nolock)
					on #Export.LogId = x.LogId
						and #Export.JobId = x.JobId	
						and #Export.Pkgnbr = x.Pkgnbr
					inner join [MTDATA].[MailTrak].[dbo].[TblSeeds] s with (nolock)
					on #Export.PkgID = s.PkgID 
						and #Export.JobID = s.JobID
						and x.seqNbr = s.ClientSeqNbr
				inner join ACSDetail as a WITH (NoLock)
					ON a.TrackCode1 = s.TrackCode1 
				-- and a.HeaderDate >= GETDATE() -7
						and a.HeaderDate >= GETDATE() -35 --just for generating the test file
						and a.DeliverabilityCode not in ('W', ' ', '')
				where #Export.JobId = @JobID
					and #Export.PkgID = @PkgID
				fetch next from Export into @JobId, @JobName, @ClientJobNbr, @PkgID
			end
			
				--The filename and location of the output file
				select @filepath='E:\BOANAF\ACS\BAC\BACRemediation\'
				select @fileName = 'BACCRO_ReturnMail_'+CONVERT(varchar(10),getdate(),112)+'.txt'
		    
			--Write the entries to an output file.
			select @file = @filePath + @fileName
			SET @bcpCommand='bcp "select * from tempBACACSRemediation" queryout "'
			SET @bcpCommand = @bcpCommand + @file + '" -U dataetl -P Ghs54321  -c -t '
			--EXEC @ret=master..xp_cmdshell @bcpCommand
			if @ret<>0
				RAISERROR (@file , 16,1)
		end try
		begin catch 
			-- Send error email notification
			DECLARE @Subject varchar(100) = 'Error happened with BAC RemediationACS'
			DECLARE @Body varchar(500) = 'Procedure name: '+ISNULL(OBJECT_NAME(@@PROCID),'spBAC_RemediationACS')
				+'<BR>Error message: '+ERROR_MESSAGE()
				+'<BR>Line number: '+CAST(ERROR_LINE() AS char)

			EXEC spSendEmail @Subject,@Body,'dataetl@grayhairsoftware.com;sys_admins@grayhairsoftware.com'

		end catch
	end

	drop table #Export
	close Export
	deallocate Export

END


