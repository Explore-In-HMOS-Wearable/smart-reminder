import { sensor } from '@kit.SensorServiceKit'
import { common, wantAgent } from '@kit.AbilityKit'
import { backgroundTaskManager } from '@kit.BackgroundTasksKit'
import { batteryInfo, BusinessError } from '@kit.BasicServicesKit'
import { notificationManager } from '@kit.NotificationKit'
import ConstantUI from '../util/ConstantUI'
import BatteryTable from '../data/BatteryTable'
import BatteryRecord from '../model/BatteryRecord'


const BG = '#0B0F14'
const TEXT = '#E6EEF7'
const SUB = '#9BB0C3'

@Entry
@Component
struct Index {
  @State message: string = 'Monitoring\nfor crash...'
  @State crashDetected: boolean = false
  @State isRunning: boolean = false
  @State batteryPct: number = -1
  @Consume('NavPathStack') pageStack: NavPathStack

  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext
  private pollTimer?: number
  private lastNotifyBucket: 'LOW' | 'MID' | 'OK' | null = null
  private readonly NOTIF_ID: number = 7001


  private scroller: Scroller = new Scroller()

  private async startContinuousTask(): Promise<void> {
    const info: wantAgent.WantAgentInfo = {
      wants: [{
        bundleName: this.context.abilityInfo.bundleName,
        abilityName: this.context.abilityInfo.name
      }],
      operationType: wantAgent.OperationType.START_ABILITY,
      requestCode: 0,
      wantAgentFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG]
    }

    try {
      const agent = await wantAgent.getWantAgent(info)
      await backgroundTaskManager.startBackgroundRunning(
        this.context,
        backgroundTaskManager.BackgroundMode.DATA_TRANSFER,
        agent
      )
      this.isRunning = true
      console.info('Background task started')

      this.readBatteryOnce()
      this.startBatteryPolling()
    } catch (err) {
      console.error(`startBackgroundRunning failed: ${JSON.stringify(err)}`)
    }
  }

  private async stopContinuousTask(): Promise<void> {
    try {
      await backgroundTaskManager.stopBackgroundRunning(this.context)
      console.info('Background task stopped')
    } catch (err) {
      console.error(`stopBackgroundRunning failed: ${JSON.stringify(err)}`)
    } finally {
      this.isRunning = false
      this.clearBatteryPolling()
      try {
        sensor.off(sensor.SensorId.ACCELEROMETER)
      } catch (err2) {
        console.error('Sensor off error: ' + JSON.stringify(err2))
      }
    }
  }

  private readBatteryOnce(): void {
    try {
      const soc: number = batteryInfo.batterySOC
      this.batteryPct = soc
      console.info(`[BAT] ${soc}%`)

      let bucket: 'LOW' | 'MID' | 'OK'
      let label: string
      if (soc <= 15) { bucket = 'LOW'; label = 'Low battery' }
      else if (soc <= 40) { bucket = 'MID'; label = 'Consider charging soon' }
      else { bucket = 'OK'; label = 'Battery OK' }

      if (bucket !== this.lastNotifyBucket) {
        this.lastNotifyBucket = bucket
        if (this.isRunning) {
          this.notifyBattery(label, soc).then(() => {}).catch(() => {})
        }
      }
    } catch (e) {
      console.error('[BAT] read error: ' + JSON.stringify(e))
    }
  }

  private startBatteryPolling(intervalMs: number = 15000): void {
    this.clearBatteryPolling()
    this.pollTimer = setInterval(() => this.readBatteryOnce(), intervalMs)
  }

  private clearBatteryPolling(): void {
    if (this.pollTimer !== undefined) {
      clearInterval(this.pollTimer)
      this.pollTimer = undefined
    }
  }

  private async ensureNotificationSlot(): Promise<void> {
    try {
      await notificationManager.addSlot(notificationManager.SlotType.SERVICE_INFORMATION)
    } catch (e) {
      console.warn('[NOTIF] addSlot warn: ' + JSON.stringify(e))
    }
  }

  private async notifyBattery(levelText: string, percent: number): Promise<void> {
    await this.ensureNotificationSlot()

    const req: notificationManager.NotificationRequest = {
      id: this.NOTIF_ID,
      notificationSlotType: notificationManager.SlotType.SERVICE_INFORMATION,
      content: {
        notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
        normal: {
          title: 'Battery Status',
          text: `${percent}% • ${levelText}`
        }
      }
    }

    try {
      await notificationManager.publish(req)
      console.info('[NOTIF] published')
    } catch (e) {
      console.error('[NOTIF] publish error: ' + JSON.stringify(e))
    }
  }

  aboutToAppear(): void {
    const cb = (err: BusinessError): void => {
      if (err) {
        console.error('[ANS] requestEnableNotification failed:', err.code, err.message)
      } else {
        console.info('[ANS] requestEnableNotification success')
      }
    }
    notificationManager.requestEnableNotification(this.context, cb)
  }

  private saveCurrentBattery(): void {
    if (this.batteryPct < 0) {
      return
    }
    const rec: BatteryRecord = {
      ts: new Date().toISOString(),
      batteryPct: this.batteryPct
    }
    BatteryTable.insertMeasurement(this.context, rec, (ok) => {
      if (ok) {
        console.info(`Saved: ${rec.ts} • ${rec.batteryPct}%`)
      }
      else {
        console.error('Save failed')
      }
    })
  }

  aboutToDisappear(): void {
    this.stopContinuousTask()
  }

  build() {
    NavDestination() {
      Scroll(this.scroller) {
        Column({ space: 8 }) {
          Text(this.isRunning ? 'Background: ON' : 'Background: OFF')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(TEXT)
            .textAlign(TextAlign.Center)
            .margin({ top: 6 })

          Text(this.batteryPct >= 0 ? `Battery: ${this.batteryPct}%` : 'Battery: —')
            .fontSize(14)
            .fontColor(SUB)
            .textAlign(TextAlign.Center)


          Button(this.isRunning ? 'Stop & Exit Background' : 'Start Background & Measure')
            .type(ButtonType.Capsule)
            .onClick(async () => {
              if (this.isRunning) {
                await this.stopContinuousTask()
              }
              else {
                await this.startContinuousTask()
              }
            })
            .width('92%')
            .height(36)
            .margin({ top: 6 })

          Button('Measure Now')
            .type(ButtonType.Capsule)
            .onClick(() => {
              this.readBatteryOnce()
              this.saveCurrentBattery()
            })
            .width('92%')
            .height(32)
            .margin({ top: 4 })

          Button('View Battery Details')
            .type(ButtonType.Capsule)
            .onClick(() => this.pageStack.pushPathByName('BatteryDetailPage', null))
            .width('92%')
            .height(32)
            .margin({ top: 2, bottom: 6 })

          Text(this.message)
            .opacity(0.8)
            .fontSize(12)
            .fontColor(SUB)
            .textAlign(TextAlign.Center)
            .margin({ top: 6, bottom: 8 })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
        .padding({ left: 10, right: 10 })
      }
      .padding(12)
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Off)
      .width(ConstantUI.FULL_WIDTH)
      .height(ConstantUI.FULL_HEIGHT)
      .backgroundColor(BG)
    }
    .onBackPressed(() => {
      this.pageStack.disableAnimation(true)
      return true
    })
    .hideTitleBar(true)
  }
}

@Builder
export function IndexPageBuilder() {
  Index()
}
