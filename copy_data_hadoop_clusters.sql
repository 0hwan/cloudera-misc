--export
export table DB.table_name to 'hdfs://A:8020/data/import/table_name'

--distcp
hadoop distcp hdfs://A:8020/data/import/table_name hdfs://B:8020/data/import/table_name

--import
import external table DB.table_name from '/data/import/table_name'