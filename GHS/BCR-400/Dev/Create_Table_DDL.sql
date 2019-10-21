-- =============================================
-- Author:		Emona Nakuci
-- JIRA:			BCR-400
-- Create date: 2019-10-14
-- Description:	Crete a control table BACJobCodes holding jobcodes and jobname (LOB) data
-- =============================================
Create Table BACJobCodes(
JobCode varchar(5),
JobName varchar(15),
CreationDate datetime DEFAULT GETDATE()
)

insert into BACJobCodes (JobCode, JobName)
select 'AC' as JobCode, 'Card' as JobName 
union all select 'AD' as JobCode, 'Card' as JobName
union all select 'AU' as JobCode, 'Card' as JobName
union all select 'SC' as JobCode, 'Card' as JobName
union all select 'SS' as JobCode, 'Card' as JobName
union all select 'BD' as JobCode, 'Deposits' as JobName
union all select 'BI' as JobCode, 'Deposits' as JobName
union all select 'CD' as JobCode, 'Deposits' as JobName
union all select 'CI' as JobCode, 'Deposits' as JobName
union all select 'CM' as JobCode, 'Deposits' as JobName
union all select 'CR' as JobCode, 'Deposits' as JobName
union all select 'CS' as JobCode, 'Deposits' as JobName
union all select 'HA' as JobCode, 'Deposits' as JobName
union all select 'HD' as JobCode, 'Deposits' as JobName
union all select 'HF' as JobCode, 'Deposits' as JobName
union all select 'HI' as JobCode, 'Deposits' as JobName
union all select 'HJ' as JobCode, 'Deposits' as JobName
union all select 'HR' as JobCode, 'Deposits' as JobName
union all select 'HS' as JobCode, 'Deposits' as JobName
union all select 'HX' as JobCode, 'Deposits' as JobName
union all select 'LI' as JobCode, 'Deposits' as JobName
union all select 'LS' as JobCode, 'Deposits' as JobName
union all select 'MD' as JobCode, 'Deposits' as JobName
union all select 'MI' as JobCode, 'Deposits' as JobName
union all select 'MR' as JobCode, 'Deposits' as JobName
union all select 'MS' as JobCode, 'Deposits' as JobName
union all select 'NE' as JobCode, 'Deposits' as JobName
union all select 'NI' as JobCode, 'Deposits' as JobName
union all select 'NS' as JobCode, 'Deposits' as JobName
union all select 'UQ' as JobCode, 'Deposits' as JobName
union all select 'US' as JobCode, 'Deposits' as JobName
union all select 'UT' as JobCode, 'Deposits' as JobName
union all select 'WV' as JobCode, 'Deposits' as JobName
union all select 'WY' as JobCode, 'Deposits' as JobName
union all select 'WZ' as JobCode, 'Deposits' as JobName
union all select 'AE' as JobCode, 'Deposits' as JobName
union all select 'AF' as JobCode, 'Deposits' as JobName
union all select 'AG' as JobCode, 'Deposits' as JobName
union all select 'AH' as JobCode, 'Deposits' as JobName
union all select 'AI' as JobCode, 'Deposits' as JobName
union all select 'AJ' as JobCode, 'Deposits' as JobName
union all select 'AK' as JobCode, 'Deposits' as JobName
union all select 'AL' as JobCode, 'Deposits' as JobName
union all select 'AM' as JobCode, 'Deposits' as JobName
union all select 'AN' as JobCode, 'Deposits' as JobName
union all select 'AO' as JobCode, 'Deposits' as JobName
union all select 'AP' as JobCode, 'Deposits' as JobName
union all select 'XO' as JobCode, 'Merrill Lynch' as JobName
union all select 'ME' as JobCode, 'Merrill Lynch' as JobName
union all select 'VN' as JobCode, 'Merrill Lynch' as JobName
union all select 'VM' as JobCode, 'Merrill Lynch' as JobName
union all select 'VO' as JobCode, 'Merrill Lynch' as JobName
union all select 'VP' as JobCode, 'Merrill Lynch' as JobName
union all select 'VE' as JobCode, 'Merrill Lynch' as JobName
union all select 'XR' as JobCode, 'Merrill Lynch' as JobName
union all select 'VZ' as JobCode, 'Merrill Lynch' as JobName
union all select 'VH' as JobCode, 'Merrill Lynch' as JobName
union all select 'VF' as JobCode, 'Merrill Lynch' as JobName
union all select 'YP' as JobCode, 'Merrill Lynch' as JobName

