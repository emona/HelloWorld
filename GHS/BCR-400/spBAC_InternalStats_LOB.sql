USE [MailTrak]
GO

/****** Object:  StoredProcedure [dbo].[spBAC_InternalStats_LOB]    Script Date: 10/14/2019 10:47:39 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Everette Mills
-- Create date: 4/22/2010
-- Description:	Bank of America Internal Reporting at LOB Level
-- 4/20/2011 Case 2797 addedd Merrill Lynch
-- 8/22/2013 6719 Added new JobIDs
-- =============================================
CREATE PROCEDURE [dbo].[spBAC_InternalStats_LOB]
	-- Add the parameters for the stored procedure here
@FMailDate datetime,
@LMailDate datetime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    
Create Table #TempStat(
JobName varchar(15),
Seeds bigint,
FirstMailDate datetime,
LastMailDate datetime,
TDays decimal(28,9),
USPSDays decimal(28,9)
)


Insert into #TempStat
Select 
Case tblBAC_Stat.JobName
when 'AC' then 'Card'
when 'AD' then 'Card'
when 'AU' then 'Card'
when 'SC' then 'Card'
when 'SS' then 'Card'
when 'BD' then 'Deposits'
when 'BI' then 'Deposits'
when 'CD' then 'Deposits'
when 'CI' then 'Deposits'
when 'CM' then 'Deposits'
when 'CR' then 'Deposits'
when 'CS' then 'Deposits'
when 'HA' then 'Deposits'
when 'HD' then 'Deposits'
when 'HF' then 'Deposits'
when 'HI' then 'Deposits'
when 'HJ' then 'Deposits'
when 'HR' then 'Deposits'
when 'HS' then 'Deposits'
when 'HX' then 'Deposits'
when 'LI' then 'Deposits'
when 'LS' then 'Deposits'
when 'MD' then 'Deposits'
when 'MI' then 'Deposits'
when 'MR' then 'Deposits'
when 'MS' then 'Deposits'
when 'NE' then 'Deposits'
when 'NI' then 'Deposits'
when 'NS' then 'Deposits'
when 'UQ' then 'Deposits'
when 'US' then 'Deposits'
when 'UT' then 'Deposits'
when 'WV' then 'Deposits'
when 'WY' then 'Deposits'
when 'WZ' then 'Deposits'
when 'AE' then 'Deposits'
when 'AF' then 'Deposits'
when 'AG' then 'Deposits'
when 'AH' then 'Deposits'
when 'AI' then 'Deposits'
when 'AJ' then 'Deposits'
when 'AK' then 'Deposits'
when 'AL' then 'Deposits'
when 'AM' then 'Deposits'
when 'AN' then 'Deposits'
when 'AO' then 'Deposits'
when 'AP' then 'Deposits'
when 'XO' then 'Merrill Lynch'
when 'ME' then 'Merrill Lynch'
when 'VN' then 'Merrill Lynch'
when 'VM' then 'Merrill Lynch'
when 'VO' then 'Merrill Lynch'
when 'VP' then 'Merrill Lynch'
when 'VE' then 'Merrill Lynch'
when 'XR' then 'Merrill Lynch'
when 'VZ' then 'Merrill Lynch'
when 'VH' then 'Merrill Lynch'
when 'VF' then 'Merrill Lynch'
when 'YP' then 'Merrill Lynch'
end
, SUM(tblbac_Stat.SeedCount),
MIN(tblbac_Stat.MailDate) as 'First Mail Date', MAX(LastMailDate) as 'Last Mail Date',
(CAST((SUM(ExitScans * tblBAC_Stat.Days)) as decimal(28,9))/SUM(tblBAC_Stat.ExitScans)) as 'TravelDays',
  (CAST((SUM(ExitScans * tblBAC_stat.USPSDays)) as decimal(28,9))/SUM(tblBAC_Stat.ExitScans) ) as 'USPSDays'
from tblBAC_Stat
where (MailDate >= @FMailDate) and (tblBAC_Stat.LastMailDate <= @LMailDate)
group by Case tblBAC_Stat.JobName
when 'AC' then 'Card'
when 'AD' then 'Card'
when 'AU' then 'Card'
when 'SC' then 'Card'
when 'SS' then 'Card'
when 'BD' then 'Deposits'
when 'BI' then 'Deposits'
when 'CD' then 'Deposits'
when 'CI' then 'Deposits'
when 'CM' then 'Deposits'
when 'CR' then 'Deposits'
when 'CS' then 'Deposits'
when 'HA' then 'Deposits'
when 'HD' then 'Deposits'
when 'HF' then 'Deposits'
when 'HI' then 'Deposits'
when 'HJ' then 'Deposits'
when 'HR' then 'Deposits'
when 'HS' then 'Deposits'
when 'HX' then 'Deposits'
when 'LI' then 'Deposits'
when 'LS' then 'Deposits'
when 'MD' then 'Deposits'
when 'MI' then 'Deposits'
when 'MR' then 'Deposits'
when 'MS' then 'Deposits'
when 'NE' then 'Deposits'
when 'NI' then 'Deposits'
when 'NS' then 'Deposits'
when 'UQ' then 'Deposits'
when 'US' then 'Deposits'
when 'UT' then 'Deposits'
when 'WV' then 'Deposits'
when 'WY' then 'Deposits'
when 'WZ' then 'Deposits'
when 'AE' then 'Deposits'
when 'AF' then 'Deposits'
when 'AG' then 'Deposits'
when 'AH' then 'Deposits'
when 'AI' then 'Deposits'
when 'AJ' then 'Deposits'
when 'AK' then 'Deposits'
when 'AL' then 'Deposits'
when 'AM' then 'Deposits'
when 'AN' then 'Deposits'
when 'AO' then 'Deposits'
when 'AP' then 'Deposits'
when 'XO' then 'Merrill Lynch'
when 'ME' then 'Merrill Lynch'
when 'VN' then 'Merrill Lynch'
when 'VM' then 'Merrill Lynch'
when 'VO' then 'Merrill Lynch'
when 'VP' then 'Merrill Lynch'
when 'VE' then 'Merrill Lynch'
when 'XR' then 'Merrill Lynch'
when 'VZ' then 'Merrill Lynch'
when 'VH' then 'Merrill Lynch'
when 'VF' then 'Merrill Lynch'
when 'YP' then 'Merrill Lynch'
 end




Select #TempStat.JobName as LOB,
 #TempStat.Seeds as 'Pieces',
#tempStat.FirstMailDate, #tempStat.LastMailDate,
SUM(ScanCount) as 'Scans', isnull(SUM(ExitScans),0) as 'Exit Scans', SUM(ExitScans)/2 as 'Median Count',

SQRT(Sum(power(Days - #TempStat.TDays,2) * ExitScans)/SUM(tblBAC_Stat.ExitScans)) as 'StandardDeviation',
     #TempStat.TDays as 'TravelDays',
  #TempStat.USPSDays as 'USPSDays',
SUM(Case when tblBAC_Stat.Days = 0 then ExitScans else 0 end) as 'Day 0',
SUM(Case when tblBAC_Stat.Days = 1 then ExitScans else 0 end) as 'Day 1',
SUM(Case when tblBAC_Stat.Days = 2 then ExitScans else 0 end) as 'Day 2',
SUM(Case when tblBAC_Stat.Days = 3 then ExitScans else 0 end) as 'Day 3',
SUM(Case when tblBAC_Stat.Days = 4 then ExitScans else 0 end) as 'Day 4',
SUM(Case when tblBAC_Stat.Days = 5 then ExitScans else 0 end) as 'Day 5',
SUM(Case when tblBAC_Stat.Days = 6 then ExitScans else 0 end) as 'Day 6',
SUM(Case when tblBAC_Stat.Days = 7 then ExitScans else 0 end) as 'Day 7',
SUM(Case when tblBAC_Stat.Days = 8 then ExitScans else 0 end) as 'Day 8',
SUM(Case when tblBAC_Stat.Days = 9 then ExitScans else 0 end) as 'Day 9',
SUM(Case when tblBAC_Stat.Days = 10 then ExitScans else 0 end) as 'Day 10',
SUM(Case when tblBAC_Stat.Days = 11 then ExitScans else 0 end) as 'Day 11',
SUM(Case when tblBAC_Stat.Days = 12 then ExitScans else 0 end) as 'Day 12',
SUM(Case when tblBAC_Stat.Days = 13 then ExitScans else 0 end) as 'Day 13',
SUM(Case when tblBAC_Stat.Days = 14 then ExitScans else 0 end) as 'Day 14',
SUM(Case when tblBAC_Stat.Days = 15 then ExitScans else 0 end) as 'Day 15',
SUM(Case when tblBAC_Stat.Days = 16 then ExitScans else 0 end) as 'Day 16',
SUM(Case when tblBAC_Stat.Days = 17 then ExitScans else 0 end) as 'Day 17',
SUM(Case when tblBAC_Stat.Days = 18 then ExitScans else 0 end) as 'Day 18',
SUM(Case when tblBAC_Stat.Days = 19 then ExitScans else 0 end) as 'Day 19',
SUM(Case when tblBAC_Stat.Days = 20 then ExitScans else 0 end) as 'Day 20',
SUM(Case when tblBAC_Stat.Days = 21 then ExitScans else 0 end) as 'Day 21',
SUM(Case when tblBAC_Stat.Days = 22 then ExitScans else 0 end) as 'Day 22',
SUM(Case when tblBAC_Stat.Days = 23 then ExitScans else 0 end) as 'Day 23',
SUM(Case when tblBAC_Stat.Days = 24 then ExitScans else 0 end) as 'Day 24',
SUM(Case when tblBAC_Stat.Days = 25 then ExitScans else 0 end) as 'Day 25',
SUM(Case when tblBAC_Stat.Days = 26 then ExitScans else 0 end) as 'Day 26',
SUM(Case when tblBAC_Stat.Days = 27 then ExitScans else 0 end) as 'Day 27',
SUM(Case when tblBAC_Stat.Days = 28 then ExitScans else 0 end) as 'Day 28'
into #TempStat2
from tblBAC_Stat inner join #TempStat on 
Case tblBAC_Stat.JobName
when 'AC' then 'Card'
when 'AD' then 'Card'
when 'AU' then 'Card'
when 'SC' then 'Card'
when 'SS' then 'Card'
when 'BD' then 'Deposits'
when 'BI' then 'Deposits'
when 'CD' then 'Deposits'
when 'CI' then 'Deposits'
when 'CM' then 'Deposits'
when 'CR' then 'Deposits'
when 'CS' then 'Deposits'
when 'HA' then 'Deposits'
when 'HD' then 'Deposits'
when 'HF' then 'Deposits'
when 'HI' then 'Deposits'
when 'HJ' then 'Deposits'
when 'HR' then 'Deposits'
when 'HS' then 'Deposits'
when 'HX' then 'Deposits'
when 'LI'  then 'Deposits'
when 'LS' then 'Deposits'
when 'MD' then 'Deposits'
when 'MI' then 'Deposits'
when 'MR' then 'Deposits'
when 'MS' then 'Deposits'
when 'NE' then 'Deposits'
when 'NI' then 'Deposits'
when 'NS' then 'Deposits'
when 'UQ' then 'Deposits'
when 'US' then 'Deposits'
when 'UT' then 'Deposits'
when 'WV' then 'Deposits'
when 'WY' then 'Deposits'
when 'WZ' then 'Deposits'
when 'AE' then 'Deposits'
when 'AF' then 'Deposits'
when 'AG' then 'Deposits'
when 'AH' then 'Deposits'
when 'AI' then 'Deposits'
when 'AJ' then 'Deposits'
when 'AK' then 'Deposits'
when 'AL' then 'Deposits'
when 'AM' then 'Deposits'
when 'AN' then 'Deposits'
when 'AO' then 'Deposits'
when 'AP' then 'Deposits'
when 'XO' then 'Merrill Lynch'
when 'ME' then 'Merrill Lynch'
when 'VN' then 'Merrill Lynch'
when 'VM' then 'Merrill Lynch'
when 'VO' then 'Merrill Lynch'
when 'VP' then 'Merrill Lynch'
when 'VE' then 'Merrill Lynch'
when 'XR' then 'Merrill Lynch'
when 'VZ' then 'Merrill Lynch'
when 'VH' then 'Merrill Lynch'
when 'VF' then 'Merrill Lynch'
when 'YP' then 'Merrill Lynch'
end = #TempStat.JobName
--where Days > -1
where (MailDate >= #TempStat.FirstMailDate) and (tblBAC_Stat.LastMailDate <= #TempStat.LastMailDate)
group by  #TempStat.JobName, #TempStat.Seeds,
#tempStat.FirstMailDate, #tempStat.LastMailDate,
     #TempStat.TDays,
  #TempStat.USPSDays
  --order by tblBAC_Stat.JobName

insert into  #BACIntStats
--Calculate Median
Select Case #TempStat2.Lob 
	when 'Card' then 'ZZCard Total' 
	when 'Deposits' then 'ZZDeposit Total' 
	when 'Merrill Lynch' then 'ZZMerrill Lynch' 
	end as JobName,
	Case #TempStat2.Lob 
	when 'Card' then 'Card Total' 
	when 'Deposits' then 'Deposit Total' 
	when 'Merrill Lynch' then 'Merrill Lynch' 
	end as Job_Name,
#TempStat2.Lob,Pieces, FirstMailDate,LastMailDate,Scans,[Exit Scans],
  Case 
	when #TempStat2.[Day 0] > #TempStat2.[Median Count] then 0  
		 when ([Day 0] + [Day 1]) > #TempStat2.[Median Count] then 1  --Check for Day 1
			when ([Day 0] + [Day 1] + [Day 2]) > #TempStat2.[Median Count] then 2  --Check for Day 2
			when ([Day 0] + [Day 1] + [Day 2] + [Day 3]) > #TempStat2.[Median Count] then 3  --Check for Day 3
			when ([Day 0] + [Day 1] + [Day 2] + [Day 3] + [Day 4]) > #TempStat2.[Median Count] then 4  --Check for Day 4
			when ([Day 0] + [Day 1] + [Day 2] + [Day 3] + [Day 4]+ [Day 5]) > #TempStat2.[Median Count] then 5  --Check for Day 5
			when ([Day 0] + [Day 1] + [Day 2] + [Day 3] + [Day 4]+ [Day 5]+ [Day 6]) > #TempStat2.[Median Count] then 6  --Check for Day 6
			when ([Day 0] + [Day 1] + [Day 2] + [Day 3] + [Day 4]+ [Day 5]+ [Day 6]+ [Day 7]) > #TempStat2.[Median Count] then 7  --Check for Day 7
			when ([Day 0] + [Day 1] + [Day 2] + [Day 3] + [Day 4]+ [Day 5]+ [Day 6]+ [Day 7]+ [Day 8]) > #TempStat2.[Median Count] then 8  --Check for Day 8
			when ([Day 0] + [Day 1] + [Day 2] + [Day 3] + [Day 4]+ [Day 5]+ [Day 6]+ [Day 7]+ [Day 8] + [Day 9]) > #TempStat2.[Median Count] then 9  --Check for Day 9
			when ([Day 0] + [Day 1] + [Day 2] + [Day 3] + [Day 4]+ [Day 5]+ [Day 6]+ [Day 7]+ [Day 8] + [Day 9] + [Day 10]) > #TempStat2.[Median Count] then 10  --Check for Day 10
			when ([Day 0] + [Day 1] + [Day 2] + [Day 3] + [Day 4]+ [Day 5]+ [Day 6]+ [Day 7]+ [Day 8] + [Day 9] + [Day 10] + [Day 11]) > #TempStat2.[Median Count] then 11  --Check for Day 11
			when ([Day 0] + [Day 1] + [Day 2] + [Day 3] + [Day 4]+ [Day 5]+ [Day 6]+ [Day 7]+ [Day 8] + [Day 9] + [Day 10] + [Day 11] + [Day 12]) > #TempStat2.[Median Count] then 12  --Check for Day 12
			else Null end as [Median Count]
			,StandardDeviation,TravelDays,USPSDays,
 [Day 0], [Day 1], [Day 2], [Day 3], [Day 4], [Day 5], [Day 6], [Day 7], [Day 8], [Day 9],
 [Day 10], [Day 11], [Day 12], [Day 13], [Day 14], [Day 15], [Day 16], [Day 17], [Day 18], [Day 19],
[Day 20], [Day 21], [Day 22], [Day 23], [Day 24], [Day 25], [Day 26], [Day 27], [Day 28] 
from #TempStat2


Drop Table #TempStat
Drop Table #TempStat2

END

GO

EXEC sys.sp_addextendedproperty @name=N'VSSComment', @value=N'This is the 2 version of this proc' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'PROCEDURE',@level1name=N'spBAC_InternalStats_LOB'
GO

EXEC sys.sp_addextendedproperty @name=N'VSSDate', @value=N'5/24/2010' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'PROCEDURE',@level1name=N'spBAC_InternalStats_LOB'
GO

EXEC sys.sp_addextendedproperty @name=N'VSSUserName', @value=N'Admin' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'PROCEDURE',@level1name=N'spBAC_InternalStats_LOB'
GO

EXEC sys.sp_addextendedproperty @name=N'VSSVersionNumber', @value=N'2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'PROCEDURE',@level1name=N'spBAC_InternalStats_LOB'
GO

