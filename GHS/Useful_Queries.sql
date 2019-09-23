-----------------------------------------------
--sql server anonymous block execution
-----------------------------------------------

declare @codsociedad as varchar(255)
declare @codCliente as varchar(255)
set @codsociedad = '20'
set @codCliente = '5001'

begin
--write sql code here
EXEC dbo.Liberbank_Expedientes  20,  '5001',  '[192.168.1.193\GIRA43B]',  'GIRA_HA';
end


select @db = valorParametro from hi.dbo.ConfiguracionAplicacion where codParametro='BDHA'
select @ServidorGIRA = valorParametro from hi.dbo.ConfiguracionAplicacion where codParametro='servidorGIRA'
	
-----------------------------------------------
--convert miliseconds to HH:mm:ss
-----------------------------------------------	

DECLARE @seconds INT

SELECT @seconds = -593

SELECT CONVERT(VARCHAR, DATEADD(second,@seconds,0),108)

ALTER SCHEMA test TRANSFER stg.Dim_Agents_en

-----------------------------------------------
--call a store procedure with parameters
-----------------------------------------------	
EXEC dbo.Liberbank_Expedientes  20,  '5001',  '[192.168.1.193\GIRA43B]',  'GIRA_HA';
GO

-----------------------------------------------
-- adding column descriptions to tables
-----------------------------------------------
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Client id is the id coming from GIRA the operational database' , 
@level0type=N'SCHEMA',@level0name=N'collection_1', 
@level1type=N'TABLE',@level1name=N'DIM_Clients_en', 
@level2type=N'COLUMN',@level2name=N'client_id'

-----------------------------------------------
--call a store procedure with OUTPUT parameters
-----------------------------------------------	
declare @CodClientes as varchar(255)
declare @CargaCompleta as BIT
declare @CargaHistorico as BIT
declare @ControlProgramacion as BIT
declare @retorno as BIT

set @CodClientes = ?
set @CargaCompleta = ?
set @CargaHistorico = ?
set @ControlProgramacion = ?

exec dbo.TDXGestionLegalAdicional_Carga @CodClientes, @CargaCompleta, @CargaHistorico, @ControlProgramacion, @retorno OUTPUT

-----------------------------------------------
-- check open sessions
-- login with sa
-----------------------------------------------	

SELECT sqltext.TEXT,
req.session_id,
req.status,
req.start_time,
req.command,
req.cpu_time,
req.total_elapsed_time
FROM sys.dm_exec_requests req
CROSS APPLY sys.dm_exec_sql_text(sql_handle) AS sqltext 




SELECT * 
FROM sys.dm_exec_sessions   
where session_id in (102,106)


select * from master..sysprocesses where blocked <> 0

SELECT r.session_id,
       st.TEXT AS batch_text,
       qp.query_plan AS 'XML Plan',
       r.start_time,
       r.status,
       r.total_elapsed_time
FROM sys.dm_exec_requests AS r
     CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) AS st
     CROSS APPLY sys.dm_exec_query_plan(r.plan_handle) AS qp
WHERE DB_NAME(r.database_id) = 'ORACULO'
ORDER BY cpu_time DESC;

-- kill session_id
KILL 60 

-----------------------------------------------	
-- Find most time consuming queries
-----------------------------------------------	
SELECT  creation_time 
        ,last_execution_time
        ,total_physical_reads
        ,total_logical_reads 
        ,total_logical_writes
        , execution_count
        , total_worker_time
        , total_elapsed_time
        , total_elapsed_time / execution_count avg_elapsed_time
        ,SUBSTRING(st.text, (qs.statement_start_offset/2) + 1,
         ((CASE statement_end_offset
          WHEN -1 THEN DATALENGTH(st.text)
          ELSE qs.statement_end_offset END
            - qs.statement_start_offset)/2) + 1) AS statement_text
FROM sys.dm_exec_query_stats AS qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) st
ORDER BY total_elapsed_time / execution_count DESC;


-----------------------------------------------
-- Find idle sessions that have open transactions
-----------------------------------------------	
SELECT s.*   
FROM sys.dm_exec_sessions AS s  
WHERE EXISTS   
    (  
    SELECT *   
    FROM sys.dm_tran_session_transactions AS t  
    WHERE t.session_id = s.session_id  
    )  
    AND NOT EXISTS   
    (  
    SELECT *   
    FROM sys.dm_exec_requests AS r  
    WHERE r.session_id = s.session_id  
    );
	

-----------------------------------------------
--assign programacion, same as HA interface
-----------------------------------------------	
Asignar_Programacion -- to assign a programacion date

exec Asignar_Programacion 264852,null , null, '2019-10-01 13:38:00', null

ResumenIntegracion -- to check the status of programacion
-----------------------------------------------
--extract date
-----------------------------------------------	
select CONVERT(date, fechahora),fechahora, refExpediente
from fu_intervinientes_hist
where codCliente = 5001 
and CONVERT(date, fechahora) = '2018-12-18'

CAST(CAST(g.fechacreaciongestion as DATE) as VARCHAR(10)) as [fecha_llamada],
CAST(CAST(g.fechacreaciongestion as TIME) as VARCHAR(08)) as [hora_llamada],

-- get the date of "d = 10" days ago with respect to current date
declare @d AS INT = 10
DATEADD(day, -@d, CONVERT(VARCHAR(8), CURRENT_TIMESTAMP, 112));

-----------------------------------------------
--print number of rows modified by the transaction
-----------------------------------------------	
declare @rowcount int
SELECT @rowcount = @@rowcount
PRINT Convert(Varchar(12),@rowCount) + ' record(s) inserted into FU_Intervinientes table.'

-----------------------------------------------
--find current server name
-----------------------------------------------	
SELECT @@SERVERNAME
--GIRA43B\GIRA43B

----------------------------------------------

declare @comando nvarchar(4000)
set @comando =  N'
select COUNT(*) as cnt, ag.monthId, ag.agente
from dbo.LDWH_AgentMonthlyObjectives ag
where ag.monthId = @fecha
group by ag.monthId, ag.agente
having COUNT(*) > 1'

exec sp_executesql @comando, N'@fecha varchar', '201901'

select @@rowcount as t


-----------------------------------------------
-- borrar flujos en HI
-----------------------------------------------

/****** Error  152: Type mismatch on external name: COMPLETADATOSENHI *******/
/****** es decir que el flujo existe ya y no esta integrado, asi que hay que borrar el flujo anterior *******/

exec borrarflujo <idflujo>, <iduser>
exec borrarflujo 231078, 11724

select * from flujos
order by idflujo desc
-- se marca como borrado con una fechaBorrada
-----------------------------------------------
--find my user id
-----------------------------------------------	
select * from mac_usuarios

-----------------------------------------------
--reset password and unlock user
-----------------------------------------------	
ALTER LOGIN yoursqllogin WITH PASSWORD = 'newpassword' OLD_PASSWORD = 'oldpassword'
Alter login [test1] with PASSWORD = 'pass123' UNLOCK 
-----------------------------------------------
--replace weird symbols
-----------------------------------------------	
--°
select texto, replace(replace(texto,CHAR(176),''), CHAR(1),'') as new_text
from LiberbankGestiones

-- find unicode for a character
select UNICODE ( '.' )  
-----------------------------------------------
--system parameters
-----------------------------------------------	
select * from configuracionaplicacion; 

-----------------------------------------------
-- call a store procedure via declared parameters
-----------------------------------------------
declare @codsociedad as varchar(4);

set @codsociedad = ?;

declare @codclientejudicial as varchar(10);

set @codclientejudicial = ?;


exec CETELEMExpedientes @codsociedad,@codclientejudicial,'[192.168.1.28]','GIRAHA','[192.168.1.196]','GIRA'

--------------------------------------------------
-- show execution plan
--------------------------------------------------
SET SHOWPLAN_ALL ON   

SET SHOWPLAN_ALL OFF 

--------------------------------------------------
-- Temp Tables
--------------------------------------------------
-- SQL Server, tempdb’s size will default to 8 MB and its growth increment will default to 10 percent
-- On Restart of the server tempdb gets erased
-- All temp tables are stored in tempdb

local temp tables #local_temp_table_name 
/*
* are accessed only in the session where they are created
* persists in memory until the sessoin where it got created terminates
*/

global temp table ##global_temp_table_name 
/*
* are accessed by all active sessions
* it persists in memory until the creating session terminates
*/
--------------------------------------------------
-- bash command MOVE
--------------------------------------------------
move @[user::ficheroFullPathLocal] @[user::rutaProcesadosLocal]

move "C:\Users\emonan\Documents\My Received Files\expedientes_728 - Copy.txt" "C:\Users\emonan\Documents\My Received Files\processed"

--------------------------------------------------
-- to select only part of an excel, use sql command instead of a table or view from the drop down list
-- A1 is the starting cell of the top most left side, B5 is the right down cell
--------------------------------------------------
SELECT * FROM [Sheet1$A1:B5]
SELECT * FROM [Hoja1$A1:F15]

SELECT * FROM ['Stock a Gestionar'$]


--------------------------------------------------
-- extract the definition of a Stored Procedure
-- is not historized, keeps only the latest version
--------------------------------------------------
SELECT top 10
    N'Initial control',
    OBJECT_DEFINITION([object_id]),
    DB_NAME(),
    OBJECT_SCHEMA_NAME([object_id]),
    OBJECT_NAME([object_id])
FROM
    sys.procedures
    where lower(OBJECT_NAME(object_id)) like lower('%usp_LDWH_informePlanesDePagosMes%')

--------------------------------------------------
-- generate index creation
--------------------------------------------------

SELECT schema_name(t.schema_id), t.name,  i.name 
 FROM sys.indexes i
 INNER JOIN sys.tables t ON t.object_id= i.object_id
 WHERE i.type>0 and t.is_ms_shipped=0 and t.name<>'sysdiagrams'
 and (is_primary_key=0 and is_unique_constraint=0)
 and t.name ='SabadellEE_Expedientes_Contratos_v2'
 
 ----------------------------
 
 SELECT ' CREATE ' + 
    CASE WHEN I.is_unique = 1 THEN ' UNIQUE ' ELSE '' END  +  
    I.type_desc COLLATE DATABASE_DEFAULT +' INDEX ' +   
    I.name  + ' ON '  +  
    Schema_name(T.Schema_id)+'.'+T.name + ' ( ' + 
    KeyColumns + ' )  ' + 
    ISNULL(' INCLUDE ('+IncludedColumns+' ) ','') + 
    ISNULL(' WHERE  '+I.Filter_definition,'') + ' WITH ( ' + 
    CASE WHEN I.is_padded = 1 THEN ' PAD_INDEX = ON ' ELSE ' PAD_INDEX = OFF ' END + ','  + 
    'FILLFACTOR = '+CONVERT(CHAR(5),CASE WHEN I.Fill_factor = 0 THEN 100 ELSE I.Fill_factor END) + ','  + 
    -- default value 
    'SORT_IN_TEMPDB = OFF '  + ','  + 
    CASE WHEN I.ignore_dup_key = 1 THEN ' IGNORE_DUP_KEY = ON ' ELSE ' IGNORE_DUP_KEY = OFF ' END + ','  + 
    CASE WHEN ST.no_recompute = 0 THEN ' STATISTICS_NORECOMPUTE = OFF ' ELSE ' STATISTICS_NORECOMPUTE = ON ' END + ','  + 
    -- default value  
    ' DROP_EXISTING = ON '  + ','  + 
    -- default value  
    ' ONLINE = OFF '  + ','  + 
   CASE WHEN I.allow_row_locks = 1 THEN ' ALLOW_ROW_LOCKS = ON ' ELSE ' ALLOW_ROW_LOCKS = OFF ' END + ','  + 
   CASE WHEN I.allow_page_locks = 1 THEN ' ALLOW_PAGE_LOCKS = ON ' ELSE ' ALLOW_PAGE_LOCKS = OFF ' END  + ' ) ON [' + 
   DS.name + ' ] '  [CreateIndexScript] 
FROM sys.indexes I   
 JOIN sys.tables T ON T.Object_id = I.Object_id    
 JOIN sys.sysindexes SI ON I.Object_id = SI.id AND I.index_id = SI.indid   
 JOIN (SELECT * FROM (  
    SELECT IC2.object_id , IC2.index_id ,  
        STUFF((SELECT ' , ' + C.name + CASE WHEN MAX(CONVERT(INT,IC1.is_descending_key)) = 1 THEN ' DESC ' ELSE ' ASC ' END 
    FROM sys.index_columns IC1  
    JOIN Sys.columns C   
       ON C.object_id = IC1.object_id   
       AND C.column_id = IC1.column_id   
       AND IC1.is_included_column = 0  
    WHERE IC1.object_id = IC2.object_id   
       AND IC1.index_id = IC2.index_id   
    GROUP BY IC1.object_id,C.name,index_id  
    ORDER BY MAX(IC1.key_ordinal)  
       FOR XML PATH('')), 1, 2, '') KeyColumns   
    FROM sys.index_columns IC2   
    --WHERE IC2.Object_id = object_id('Person.Address') --Comment for all tables  
    GROUP BY IC2.object_id ,IC2.index_id) tmp3 )tmp4   
  ON I.object_id = tmp4.object_id AND I.Index_id = tmp4.index_id  
 JOIN sys.stats ST ON ST.object_id = I.object_id AND ST.stats_id = I.index_id   
 JOIN sys.data_spaces DS ON I.data_space_id=DS.data_space_id   
 JOIN sys.filegroups FG ON I.data_space_id=FG.data_space_id   
 LEFT JOIN (SELECT * FROM (   
    SELECT IC2.object_id , IC2.index_id ,   
        STUFF((SELECT ' , ' + C.name  
    FROM sys.index_columns IC1   
    JOIN Sys.columns C    
       ON C.object_id = IC1.object_id    
       AND C.column_id = IC1.column_id    
       AND IC1.is_included_column = 1   
    WHERE IC1.object_id = IC2.object_id    
       AND IC1.index_id = IC2.index_id    
    GROUP BY IC1.object_id,C.name,index_id   
       FOR XML PATH('')), 1, 2, '') IncludedColumns    
   FROM sys.index_columns IC2    
   --WHERE IC2.Object_id = object_id('Person.Address') --Comment for all tables   
   GROUP BY IC2.object_id ,IC2.index_id) tmp1   
   WHERE IncludedColumns IS NOT NULL ) tmp2    
ON tmp2.object_id = I.object_id AND tmp2.index_id = I.index_id   
WHERE I.is_primary_key = 0 AND I.is_unique_constraint = 0 
--AND I.Object_id = object_id('Person.Address') --Comment for all tables 
--AND I.name = 'IX_Address_PostalCode' --comment for all indexes 
 and   t.name ='SabadellEE_Recibos'
 
 ----------------------------
 ---- deploy SSIS packages -----------
 -----------------------------
 
Create catalog in SSISDB

catalog.create_folder [@folder_name =] folder_name, [@folder_id =] folder_id OUTPUT

https://docs.microsoft.com/en-us/sql/integration-services/catalog/ssis-catalog?view=sql-server-2017#Configuration

 ----------------------------
 ---- execute SSIS packages -----------
 -----------------------------
 -- runs a package in SSISDB stored procedure

https://docs.microsoft.com/en-us/sql/integration-services/ssis-quickstart-run-tsql-vscode?view=sql-server-2017
https://docs.microsoft.com/en-us/sql/integration-services/system-stored-procedures/catalog-start-execution-ssisdb-database?view=sql-server-2017

Declare @execution_id bigint  
EXEC [SSISDB].[catalog].[create_execution] @package_name=N'Child1.dtsx', @execution_id=@execution_id OUTPUT, @folder_name=N'TestDeply4', @project_name=N'Integration Services Project1', @use32bitruntime=False, @reference_id=Null  
Select @execution_id  
DECLARE @var0 sql_variant = N'Child1.dtsx'  
EXEC [SSISDB].[catalog].[set_execution_parameter_value] @execution_id, @object_type=20, @parameter_name=N'Parameter1', @parameter_value=@var0  
DECLARE @var1 sql_variant = N'Child2.dtsx'  
EXEC [SSISDB].[catalog].[set_execution_parameter_value] @execution_id, @object_type=20, @parameter_name=N'Parameter2', @parameter_value=@var1  
DECLARE @var2 smallint = 1  
EXEC [SSISDB].[catalog].[set_execution_parameter_value] @execution_id, @object_type=50, @parameter_name=N'LOGGING_LEVEL', @parameter_value=@var2  
EXEC [SSISDB].[catalog].[start_execution] @execution_id  
GO


---- Run a package with dtexec
---- run via command line

1. Open a Command Prompt window.

CD C:\Program Files (x86)\Microsoft SQL Server\140\DTS\Binn

Change to the exe file of SQL SERVERNAME

2. Run DTExec.exe and provide values at least for the ISServer and the Server parameters, as shown in the following example:

dtexec /ISServer "\SSISDB\Project1Folder\Integration Services Project1\Package.dtsx" /Server "localhost"


https://www.databasejournal.com/features/mssql/executing-a-ssis-package-from-stored-procedure-in-sql-server.html

