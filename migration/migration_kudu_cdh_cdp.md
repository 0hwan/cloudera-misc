Apache Kudu Migration from CDH to CDP
======================================
How to migrate your Apache Kudu footprint from Cloudera's CDH to their new CDP

# Summary
When we migrate Kudu data from CDH to CDP we have to use the Kudu backup tool to back up and then restore the Kudu data.

Kudu supports both full and incremental table backups via a job implemented using Apache Spark. Additionally, it supports restoring tables from full and incremental backups via a restore job implemented using Apache Spark.

We have completed the POC on the test cluster and implemented kudu migration from CDH to CDP on a production cluster for one of our clients in our organization

# Kudu Migration Process

![](/images/kudu_migration_process.webp)
Note: Images may be subject to copyright. Above images is only used for knowledge transfer.

## I. Back Up Process
### CDH Cluster
First, confirm whether the kudu table is present or not on the impala

Go to the keytabs directory :
```
cd /opt/cloudera/security/keytabs/
```
#### 1. Take the valid keytab
```
[root@clairvoyant-cdh-nn1 keytabs]# kinit -kt user_test.keytab user_test@Clairvoyant.com
```
#### 2. Connect to the Impala Shell
```
impala-shell -i impala-cdh-clairvoyant -d default -k — ssl — ca_cert=/opt/cloudera/security/x509/ca-chain.cert.pem
```
#### 3. Use database
```
[impala-cdh-clairvoyant:21000] default> use cvhadoop_db;
```
### Confirm the kudu table count
```
[impala-cdh-clairvoyant:21000] cvhadoop_db > select count(*) from cvhadoop_db.test_event;
Query: select count(*) from cvhadoop_db.test_event
Query submitted at: 2022–04–22 09:49:32 (Coordinator: https://clairvoyant-cdh-nn3:25000)
Query progress can be monitored at: https://clairvoyant-cdh-nn3:25000/query_plan?query_id=3e40j46e4528b109:26c7277b00000000
+ — — — — — +
| count(*) |
+ — — — — — +
| 20445 |
+ — — — — — +
Fetched 1 row(s) in 0.13s
```

### Quit the impala-shell and perform a kinit using the hdfs keytab
#### 1. check the contents under the path /user/cv_bdr_user
```
[root@clairvoyant-cdh-nn1 14521-hdfs-NAMENODE]# hdfs dfs -ls /user/cv_bdr_user/kudu-bkp
```
#### 2. Kinit using the hue/impala ( depending upon your ranger rules), keytab and then run the back-up command after changing the table name

### Run the following command to start the backup process:
```
spark-submit — class org.apache.kudu.backup.KuduBackup /opt/cloudera/parcels/CDH/lib/kudu/kudu-backup2_2.11.jar — kuduMasterAddresses clairvoyant-cdh-nn1,clairvoyant-cdh-nn2,clairvoyant-cdh-nn3 — rootPath hdfs:///user/cv_bdr_user/kudu-bkp cvhadoop_db.test_event
```

### Where

• — kuduMasterAddresses is used to specify the addresses of the Kudu masters as a comma-separated list.

For example, clairvoyant-cdp-nn1,clairvoyant-cdp-nn2,clairvoyant-cdp-nn3, which are the host names of Kudu masters.

• — rootPath is used for specifying a path to store the backed up data.

• Example for HDFS: hdfs:///kudu-backups

#### 3. After the backup is successful kinit using hdfs keytab and then check for the files under hdfs /user/cv_bdr_user/kudu-bkp
```
[root@clairvoyant-cdh-nn1 14521-hdfs-NAMENODE]# hdfs dfs -ls /user/cv_bdr_user/kudu-bkp
Found 3 items
drwxr-xr-x — hdfs supergroup 0 2022–04–21 09:52 /user/cv_bdr_user/kudu-bkp/1723fbsdsd37ddsedd1d5ddd6dd258238542-cvhadoop_db.test_event
```
#### 4. Check for the files
```
[root@clairvoyant-cdp-nn1 14521-hdfs-NAMENODE]# hdfs dfs -ls /user/cv_bdr_user/kudu-bkp/1723fbsdsd37ddsedd1d5ddd6dd258238542-cvhadoop_db.test_event/1650559938445
Found 67 items
-rw-r — r — 3 hdfs supergroup 36341 2022–04–21 09:52 /user/cv_bdr_user/kudu-bkp/1723fbsdsd37ddsedd1d5ddd6dd258238542-cvhadoop_db.test_event/1650559938445/.kudu-metadata.json
-rw-r — r — 3 hdfs supergroup 0 2022–04–21 09:52 /user/cv_bdr_user/kudu-bkp/1723fbsdsd37ddsedd1d5ddd6dd258238542-cvhadoop_db.test_event/1650559938445/_SUCCESS
-rw-r — r — 3 hdfs supergroup 7999 2022–04–21 09:52 /user/cv_bdr_user/kudu-bkp/1723fbsdsd37ddsedd1d5ddd6dd258238542-cvhadoop_db.test_event/1650559938445/part-00000-a7126940-c30sdf3–43db-acd7-sfsd52b3c46fc0-c000.snappy.parquet
```
#### 5. Go to the CDP-CM UI and schedule hdfs replication using the BDR tool

## II. Replication Process
Run the following steps to start the replication process from CDH to CDP

### Step 1
![](/images/step_1.png)

### Step 2
![](/images/step_2.png)

### Step 3
![](/images/step_3.png)

#### 6. Save policy and then it will copy all the files under the hdfs location at the destination (CDP cluster)

#### 7. Check the files copied under the hdfs location
```
hdfs dfs -ls /user/cv_bdr_user/kudu-restore
```
```
[root@clairvoyant-cdp-nn1 741-hdfs-NAMENODE]# hdfs dfs -ls /user/cv_bdr_user/kudu-restore//1723fbsdsd37ddsedd1d5ddd6dd258238542-cvhadoop_db.test_event/1650559938445
Found 67 items
-rw-r — r — 3 hdfs supergroup 36341 2022–04–21 09:52 /user/cv_bdr_user/kudu-restore/1723fbsdsd37ddsedd1d5ddd6dd258238542-cvhadoop_db.test_event/1650559938445/.kudu-metadata.json
-rw-r — r — 3 hdfs supergroup 0 2022–04–21 09:52 /user/cv_bdr_user/kudu-restore/1723fbsdsd37ddsedd1d5ddd6dd258238542-cvhadoop_db.test_event/1650559938445/_SUCCESS
-rw-r — r — 3 hdfs supergroup 7999 2022–04–21 09:52 /user/cv_bdr_user/kudu-restore/1723fbsdsd37ddsedd1d5ddd6dd258238542-cvhadoop_db.test_event/1650559938445/part-00000-a7126940-c30sdf3–43db-acd7-sfsd52b3c46fc0-c000.snappy.parquet
```
#### 8. Go to impala-shell, if the database has not been created, then take the impala keytab,

Create the required database and quit impala shell

## III. Restore Process
#### 9. Run the restore spark command

```
spark-submit — class org.apache.kudu.backup.KuduRestore /opt/cloudera/parcels/CDH/lib/kudu/kudu-backup2_2.11.jar — kuduMasterAddresses clairvoyant-cdp-nn1,clairvoyant-cdp-nn2,clairvoyant-cdp-nn3 — restoreOwner false — rootPath hdfs:///user/cv_bdr_user/kudu-restore cvhadoop_db.test_event — createTables true
```

#### 10. After the restore is successful, go to the impala shell and use the required database and verify the table count.
```
[impala-cdp-prod:21000] default> use cvhadoop_db;Query: use cvhadoop_db
[impala-cdp-prod:21000] cvhadoop_db> select count(*) from cvhadoop_db.test_event;
Query: select count(*) from cvhadoop_db.test_event
Query submitted at: 2022–04–22 10:29:05 (Coordinator: https://clairvoyant-cdp-dn1:25000)
Query progress can be monitored at: https://clairvoyant-cdp-dn1:25000/query_plan?query_id=c44af0c754816b28:d6e79b8f00000000
+ — — — — — +
| count(*) |
+ — — — — — +
| 20445 |
+ — — — — — +
Fetched 1 row(s) in 0.19s
```

#### 11. The count of the tables should match the source cluster (CDH cluster).

# Possible Issues and their Resolutions
#### 1. If you observed the error below while restoring the kudu backup, please use the below resolution.
```
22/05/22 23:04:28 WARN scheduler.TaskSetManager: Lost task 6.0 in stage 0.0 (TID 13, clairvoyant-cdp-dn1, executor 24): java.lang.RuntimeException: Failed to write 1000 rows to Kudu; Sample errors: Timed out: cannot complete before timeout: Batch{operations=1000, tablet=”0c9aw3bs3452fbasdsa4cdf99074cd6046d” [0x0000000080000000000007E2, 0x0000000080000000000007E3), ignoredErrors=[NOT_FOUND], rpc=KuduRpc(method=Write, tablet=0c9aw3bs3452fbasdsa4cdf99074cd6046d, attempt=20, TimeoutTracker(timeout=30000, elapsed=27150), Trace Summary(27145 ms): Sent(20), Received(20), Delayed(20), MasterRefresh(0), AuthRefresh(0), Truncated: false
Sent: (9f94ccfaa0f14c67acd5f061faaf9714, [ Write, 20 ])
Received: (9f94ccfaa0f14c67acd5f061faaf9714, [ SERVICE_UNAVAILABLE, 20 ])
Delayed: (UNKNOWN, [ Write, 20 ]))}Timed out: cannot complete before timeout: Batch{operations=1000, tablet=”0c9aw3bs3452fbasdsa4cdf99074cd6046d” [0x0000000080000000000007E2, 0x0000000080000000000007E3), ignoredErrors=[NOT_FOUND], rpc=KuduRpc(method=Write, tablet=0c9aw3bs3452fbasdsa4cdf99074cd6046d, attempt=20, TimeoutTracker(timeout=30000, elapsed=27150), Trace Summary(27145 ms): Sent(20), Received(20), Delayed(20), MasterRefresh(0), AuthRefresh(0), Truncated: false
Sent: (9f94ccfaa0f14c67acd5f061faaf9714, [ Write, 20 ])Received: (9f94ccfaa0f14c67acd5f061faaf9714, [ SERVICE_UNAVAILABLE, 20 ])
```

### Resolution
```
— class spark.yarn.executor.memoryOverhead=10GB
```

### Example
```
spark-submit — class org.apache.kudu.backup.KuduRestore /opt/cloudera/parcels/CDH/lib/kudu/kudu-backup2_2.11.jar — class spark.yarn.executor.memoryOverhead=10GB — kuduMasterAddresses clairvoyant-cdp-nn1,clairvoyant-cdp-nn2,clairvoyant-cdp-nn3 — restoreOwner false — rootPath hdfs:///user/cv_bdr_user/kudu-restore cvhadoop_db.test_event — createTables false
```

#### 2. If you observed the error below while restoring the kudu backup

### Errors were detected:
```
database=cvhadoop_db Database already exists and does not match the exported database. Database URI mismatch — current:hdfs://nameservice1/warehouse/tablespace/external/hive/cvhadoop_db.db exported:/user/hive/warehouse/cvhadoop_db.db
Database: 1
Table: 265
Partition: 27395
Function: 0
Index: 0
Statistics: 31
Error detected: DATABASE_MISMATCH_ERROR
```
### Resolution
```
We use “— createTables” -false because table already created
```

#### 3. If you observed count mismatch after following the above process

### Possible Cause
#### 1. Job running on source cluster while taking backup.

#### 2. Issue with Source table

### Resolution

#### 1. Stop the jobs before taking the backup.

#### 2. Drop the table on the destination host and try to rerun the whole process again.

Hope this will help you to move data from CDH to the CDP environment.

