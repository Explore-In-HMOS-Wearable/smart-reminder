import { relationalStore } from '@kit.ArkData';

export interface TableDefinition {
  tableName: string;
  sqlCreate: string;
  columns: string[];
}

export default class CommonConstantsDb {
  static readonly STORE_CONFIG: relationalStore.StoreConfig = {
    name: 'bluetooth_conn_monitor.db',
    securityLevel: relationalStore.SecurityLevel.S1
  };


  static readonly Battery_Table: TableDefinition = {
    tableName: 'battery_measure',
    sqlCreate: `CREATE TABLE IF NOT EXISTS battery_measure(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      ts TEXT NOT NULL,
      batteryPct INTEGER NOT NULL
    )`,
    columns: ['id','ts','batteryPct']
  };

  static readonly RDB_TAG = '[Debug.Rdb]';
}
