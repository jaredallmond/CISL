/*
	CSIL - Columnstore Indexes Scripts Library for SQL Server 2014: 
	Columnstore Tests - cstore_GetRowGroups is tested with the columnstore table containing 1 row in compressed row group and a Delta-Store with 1 row 
	Version: 1.4.2, December 2016

	Copyright 2015-2016 Niko Neugebauer, OH22 IS (http://www.nikoport.com/columnstore/), (http://www.oh22.is/)

	Licensed under the Apache License, Version 2.0 (the "License");
	you may not use this file except in compliance with the License.
	You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
*/

IF NOT EXISTS (select * from sys.objects where type = 'p' and name = 'testRowGroupAndDelta' and schema_id = SCHEMA_ID('RowGroups') )
	exec ('create procedure [RowGroups].[testRowGroupAndDelta] as select 1');
GO

ALTER PROCEDURE [RowGroups].[testRowGroupAndDelta] AS
BEGIN
	IF OBJECT_ID('tempdb..#ExpectedRowGroups') IS NOT NULL
		DROP TABLE #ExpectedRowGroups;

	create table #ExpectedRowGroups(
		[TableName] nvarchar(256),
		[Type] varchar(20),
		[Location] varchar(15),
		[Partition] int,
		[Compression Type] varchar(50),
		[BulkLoadRGs] int,
		[Open DeltaStores] int,
		[Closed DeltaStores] int,
		[Compressed RowGroups] int,
		[Total RowGroups] int,
		[Deleted Rows] Decimal(18,6),
		[Active Rows] Decimal(18,6),
		[Total Rows] Decimal(18,6),
		[Size in GB] Decimal(18,3),
		[Scans] int,
		[Updates] int,
		[LastScan] DateTime
	);

	select top (0) *
		into #ActualRowGroups
		from #ExpectedRowGroups;

	-- CCI
	-- Insert expected result
	insert into #ExpectedRowGroups (TableName, Type, Location, Partition, [Compression Type], [BulkLoadRGs], [Open DeltaStores], [Closed DeltaStores],
									[Compressed RowGroups], [Total RowGroups], [Deleted Rows], [Active Rows], [Total Rows], [Size in GB], [Scans], [Updates],  [LastScan])
		select '[dbo].[RowGroupAndDeltaCCI]', 'Clustered', 'Disk-Based', 1, 'COLUMNSTORE', 0, 1, 0, 
				1, 2, 0.0 /*Del Rows*/, 0.000002 /*Active Rows*/, 0.000002 /*Total Rows*/, 0.0, 0, 1, NULL;

	insert into #ActualRowGroups
		exec dbo.cstore_GetRowGroups @tableName = 'RowGroupAndDelta';

	update #ExpectedRowGroups
		set Scans = NULL, Updates = NULL, LastScan = NULL;
	update #ActualRowGroups
		set Scans = NULL, Updates = NULL, LastScan = NULL;

	exec tSQLt.AssertEqualsTable '#ExpectedRowGroups', '#ActualRowGroups';


END

GO
