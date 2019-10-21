USE [MailTrak]
GO

/****** Object:  StoredProcedure [dbo].[spBAC_InternalStats_previousMonth]    Script Date: 10/14/2019 10:46:44 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================


CREATE PROCEDURE  [dbo].[spBAC_InternalStats_previousMonth] 
	-- Add the parameters for the stored procedure here


AS
	Declare @FMailDate datetime		
	Declare @LMailDate datetime
	SELECT @FMailDate =  DATEADD(s,0,DATEADD(mm, DATEDIFF(m,0,getdate())-1,0)) 
  SELECT @LMailDate = DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,GETDATE()),0))
--    Set @FMailDate = '2013-06-01'
  --  Set @LMailDate = '2013-06-30'
    
    
create table #BACIntStats
(Job_Name  					varchar(50),
 JobName  					varchar(50),
 LOB							varchar(18),
 Pieces						bigint,
 FirstMailDate		datetime,
 LastMailDate			datetime,
 Scans						INTEGER,
 [Exit Scans]			INTEGER,
 [Median Count]			INTEGER,
 StandardDeviation	float,
 TravelDays	decimal(19,9),
 USPSDays	decimal(19,9),
 [Day 0]	INTEGER,
 [Day 1]	INTEGER,
 [Day 2]	INTEGER,
 [Day 3]  INTEGER,
 [Day 4]	INTEGER,
 [Day 5]	INTEGER,
 [Day 6]	INTEGER,
 [Day 7]	INTEGER,
 [Day 8]	INTEGER,
 [Day 9]	INTEGER,
 [Day 10]	INTEGER,
 [Day 11]	INTEGER,
 [Day 12]	INTEGER,
 [Day 13]	INTEGER,
 [Day 14]	INTEGER,
 [Day 15]	INTEGER,
 [Day 16]  iNTEGER,
 [Day 17]	INTEGER,
 [Day 18]	INTEGER,
 [Day 19]	INTEGER,
 [Day 20]	INTEGER,
 [Day 21]	INTEGER,
 [Day 22]	INTEGER,
 [Day 23]	INTEGER,
 [Day 24]	INTEGER,
 [Day 25]	INTEGER,
 [Day 26]	INTEGER,
 [Day 27]	INTEGER,
 [Day 28] INTEGER
 )
 

exec spBAC_InternalStats_job @FMailDate,@LMailDate

exec spBAC_InternalStats_LOB @FMailDate,@LMailDate


exec spBAC_InternalStats_All @FMailDate,@LMailDate

 select * from  #BACIntStats order by lob,Job_Name
 

             
drop table   #BACIntStats
GO

EXEC sys.sp_addextendedproperty @name=N'VSSComment', @value=N'This is the initial sync of the proc' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'PROCEDURE',@level1name=N'spBAC_InternalStats_previousMonth'
GO

EXEC sys.sp_addextendedproperty @name=N'VSSDate', @value=N'7/1/2010' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'PROCEDURE',@level1name=N'spBAC_InternalStats_previousMonth'
GO

EXEC sys.sp_addextendedproperty @name=N'VSSUserName', @value=N'Admin' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'PROCEDURE',@level1name=N'spBAC_InternalStats_previousMonth'
GO

EXEC sys.sp_addextendedproperty @name=N'VSSVersionNumber', @value=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'PROCEDURE',@level1name=N'spBAC_InternalStats_previousMonth'
GO

