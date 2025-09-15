import { relationalStore } from '@kit.ArkData';
import BatteryRecord from '../model/BatteryRecord';
import CommonConstantsDb from '../util/CommonConstantsDb';

export default class BatteryTable {
  private static store: relationalStore.RdbStore | null = null;

  private static getStore(context: Context, cb: () => void) {
    if (BatteryTable.store) { cb(); return; }
    relationalStore.getRdbStore(
      context,
      CommonConstantsDb.STORE_CONFIG,
      (err, store) => {
        if (err) {
          console.error('[RDB] open error', JSON.stringify(err));
          return;
        }
        BatteryTable.store = store;
        BatteryTable.store.executeSql(CommonConstantsDb.Battery_Table.sqlCreate);
        cb();
      }
    );
  }

  static insertMeasurement(context: Context, rec: BatteryRecord, cb: (ok: boolean) => void) {
    BatteryTable.getStore(context, () => {
      if (!BatteryTable.store) {
        return cb(false);
      }
      const values: relationalStore.ValuesBucket = {
        ts: rec.ts,
        batteryPct: rec.batteryPct
      };
      BatteryTable.store!.insert(CommonConstantsDb.Battery_Table.tableName, values, (err, rowId) => {
        if (err) {
          console.error('[RDB] insert fail', JSON.stringify(err));
          cb(false);
        } else {
          console.info(`[RDB] inserted rowId=${rowId}`);
          cb(true);
        }
      });
    });
  }

  static getAll(context: Context, cb: (rows: BatteryRecord[]) => void) {
    BatteryTable.getStore(context, () => {
      if (!BatteryTable.store) {
        return cb([]);
      }
      const p = new relationalStore.RdbPredicates(CommonConstantsDb.Battery_Table.tableName);
      BatteryTable.store!.query(p, [], (err, rs) => {
        if (err || !rs) { cb([]); return; }
        const out: BatteryRecord[] = [];
        rs.goToFirstRow();
        for (let i = 0; i < rs.rowCount; i++) {
          out.push({
            id: rs.getLong(rs.getColumnIndex('id')),
            ts: rs.getString(rs.getColumnIndex('ts')),
            batteryPct: rs.getLong(rs.getColumnIndex('batteryPct'))
          });
          rs.goToNextRow();
        }
        rs.close();
        cb(out);
      });
    });
  }
}
