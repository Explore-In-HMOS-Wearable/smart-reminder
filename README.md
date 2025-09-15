> **Note:** To access all shared projects, get information about environment setup, and view other guides, please visit [Explore-In-HMOS-Wearable Index](https://github.com/Explore-In-HMOS-Wearable/hmos-index).

# Battery Monitor Wearable

A HarmonyOS ArkTS wearable app that continuously monitors the device battery level, provides background notifications, and stores history in a local RDB. Users can measure instantly, view history, and see battery status updates directly on their Huawei Watch.

# Preview
<div>
<img src="screenshots/preview.gif" width="25%" />
</div>

# Use Cases

- Monitor battery percentage in the background
- Receive notifications when battery is low/mid/ok
- Measure current battery level manually
- View detailed battery history in a list with timestamps
- Smooth navigation with splash, index, and detail pages

# Technology

## Stack
- **Languages:** ArkTS (TypeScript)
- **UI:** ArkUI (`@kit.ArkUI`)
- **Tools/IDE:** DevEco Studio **5.1.0.260**
- **SDK:** HarmonyOS SDK **5.1.0.54**
- **Libraries:** Built-in kits (`SensorServiceKit`, `BackgroundTasksKit`, `NotificationKit`, `ArkData`)
- **Database:** RelationalStore (RDB) for local persistence

## Required Permissions
- `ohos.permission.RUNNING_TASKS`
- `ohos.permission.NOTIFICATION_CONTROLLER`

# Directory Structure
```
entry/
└── ets/
    ├── animation/
    │   └── LottieAnimation.ets
    ├── data/
    │   └── BatteryTable.ets
    ├── model/
    │   └── BatteryRecord.ets
    ├── pages/
    │   ├── SplashPage.ets
    │   ├── Index.ets
    │   └── BatteryDetailPage.ets
    ├── util/
    │   ├── ConstantUI.ets
    │   └── CommonConstantsDb.ets
    ├── entryability/
    │   └── EntryAbility.ets
    └── entrybackupability/
        └── EntryBackupAbility.ets
```

# Constraints and Restrictions

## Supported Device
- Huawei Watch 5

## App Limits
- Local-only data (no external backend)
- Optimized for wearable small screens
- ArkUI navigation with slide transitions
- Compact UI components for better readability on wearables

# License
**Battery Monitor Wearable** is distributed under the terms of the MIT License  
See the [LICENSE](./LICENSE) for more information.
