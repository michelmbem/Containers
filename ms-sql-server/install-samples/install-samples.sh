#!/usr/bin/env bash
set -euo pipefail

sqlcmd=/opt/mssql-tools18/bin/sqlcmd
sql_args=(-C -b -W -S tcp:sql-server,1433 -U sa -P "$MSSQL_SA_PASSWORD")

if "${sqlcmd}" "${sql_args[@]}" -h -1 -Q "SET NOCOUNT ON; IF OBJECT_ID(N'master.dbo.SampleInstallState', N'U') IS NOT NULL AND EXISTS (SELECT 1 FROM master.dbo.SampleInstallState WHERE InstallKey = N'all-samples-v1') SELECT 1 ELSE SELECT 0" | grep -qx '1'; then
  echo 'SQL Server samples have already been installed; skipping.'
  exit 0
fi

sample_dir=/samples

if ! "${sqlcmd}" "${sql_args[@]}" -h -1 -Q "SET NOCOUNT ON; SELECT IIF(DB_ID(N'Northwind') IS NULL, 0, 1)" | grep -qx '1'; then
  "${sqlcmd}" "${sql_args[@]}" -Q "CREATE DATABASE [Northwind]"
  "${sqlcmd}" "${sql_args[@]}" -d Northwind -i "${sample_dir}/instnwnd.sql"
fi

if ! "${sqlcmd}" "${sql_args[@]}" -h -1 -Q "SET NOCOUNT ON; SELECT IIF(DB_ID(N'pubs') IS NULL, 0, 1)" | grep -qx '1'; then
  "${sqlcmd}" "${sql_args[@]}" -i "${sample_dir}/instpubs.sql"
fi

"${sqlcmd}" "${sql_args[@]}" -Q "IF DB_ID(N'AdventureWorks2022') IS NULL
BEGIN
  RESTORE DATABASE [AdventureWorks2022]
  FROM DISK = N'${sample_dir}/AdventureWorks2022.bak'
  WITH MOVE N'AdventureWorks2022' TO N'/var/opt/mssql/data/AdventureWorks2022.mdf',
       MOVE N'AdventureWorks2022_Log' TO N'/var/opt/mssql/data/AdventureWorks2022_log.ldf',
       RECOVERY, STATS = 5;
END"

"${sqlcmd}" "${sql_args[@]}" -i /scripts/01_community_garden.sql
"${sqlcmd}" "${sql_args[@]}" -Q "IF OBJECT_ID(N'master.dbo.SampleInstallState', N'U') IS NULL
  CREATE TABLE master.dbo.SampleInstallState (InstallKey sysname NOT NULL PRIMARY KEY, InstalledAt datetime2 NOT NULL DEFAULT SYSUTCDATETIME());
IF NOT EXISTS (SELECT 1 FROM master.dbo.SampleInstallState WHERE InstallKey = N'all-samples-v1')
  INSERT master.dbo.SampleInstallState (InstallKey) VALUES (N'all-samples-v1')"

echo 'SQL Server sample databases installed successfully.'
