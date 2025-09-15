import { common } from '@kit.AbilityKit'
import BatteryTable from '../data/BatteryTable'
import BatteryRecord from '../model/BatteryRecord'
import ConstantUI from '../util/ConstantUI'

const BG = '#0B0F14'
const CARD = '#141A21'
const TEXT = '#E6EEF7'
const SUBTEXT = '#9BB0C3'
const DIVIDER = '#223043'

@Component
export struct BatteryDetailPage {
  @Consume('NavPathStack') pageStack: NavPathStack
  @State records: BatteryRecord[] = []

  aboutToAppear(): void {
    BatteryTable.getAll(getContext(this) as common.UIAbilityContext, (rows) => {
      this.records = rows.reverse()
    })
  }

  private fmt(ts: string): string {
    try {
      const d = new Date(ts)
      const pad = (n: number) => (n < 10 ? `0${n}` : `${n}`)
      return `${pad(d.getDate())}.${pad(d.getMonth() + 1)} ${pad(d.getHours())}:${pad(d.getMinutes())}`
    } catch {
      return ts
    }
  }

  private badgeBg(pct: number): Color {
    if (pct <= 15) {
      return Color.Red
    }
    if (pct <= 40) {
      return Color.Orange
    }
    return Color.Green
  }

  build() {
    NavDestination() {
      Column({ space: 8 }) {

        Text('Battery History')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor(TEXT)
          .textAlign(TextAlign.Center)
          .margin({ top: 6, bottom: 2 })


        if (this.records.length === 0) {

          Column() {
            Text('No records yet')
              .fontSize(14)
              .fontColor(SUBTEXT)
              .textAlign(TextAlign.Center)
              .margin({ bottom: 8 })
            Button('Back')
              .type(ButtonType.Normal)
              .onClick(() => this.pageStack.pop())
          }
          .width('100%')
          .alignItems(HorizontalAlign.Center)
          .justifyContent(FlexAlign.Center)
          .layoutWeight(1)
        } else {

          List({ space: 6 }) {
            ForEach(this.records, (item: BatteryRecord, idx: number) => {
              ListItem() {

                Row() {

                  Column() {
                    Text(`${item.batteryPct}`)
                      .fontSize(16).fontWeight(FontWeight.Bold)
                      .fontColor(Color.White)
                    Text('%')
                      .fontSize(9)
                      .fontColor(Color.White).opacity(0.85)
                  }
                  .width(40).height(40)
                  .backgroundColor(this.badgeBg(item.batteryPct))
                  .borderRadius(20)
                  .alignItems(HorizontalAlign.Center)
                  .justifyContent(FlexAlign.Center)
                  .margin({ right: 8 })


                  Column({ space: 2 }) {
                    Text(`Battery ${item.batteryPct}%`)
                      .fontSize(14)
                      .fontWeight(FontWeight.Medium)
                      .fontColor(TEXT)
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })

                    Text(this.fmt(item.ts))
                      .fontSize(11)
                      .fontColor(SUBTEXT)
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                  }
                  .alignItems(HorizontalAlign.Start)
                  .justifyContent(FlexAlign.Center)

                  Blank()
                }
                .padding({ left: 10, right: 10, top: 8, bottom: 8 })
                .width('100%')
                .backgroundColor(CARD)
                .borderRadius(12)
                .shadow(1)
                .border({ width: 0.5, color: DIVIDER })
              }
              .padding({ left: 6, right: 6, top: idx === 0 ? 2 : 0 })
            }, (item: BatteryRecord) => item.id?.toString() ?? item.ts)
          }
          .layoutWeight(1)
          .width('100%')
          .edgeEffect(EdgeEffect.None)

          Row({ space: 10 }) {
            Button('Back')
              .type(ButtonType.Capsule)
              .onClick(() => this.pageStack.pop())

          }
          .margin({ top: 6 })
        }
      }
      .width(ConstantUI.FULL_WIDTH)
      .height(ConstantUI.FULL_HEIGHT)
      .padding(10)
      .backgroundColor(BG)
      .alignItems(HorizontalAlign.Center)
    }
    .hideTitleBar(true)
  }
}

@Builder
export function BatteryDetailBuilder() {
  BatteryDetailPage()
}
