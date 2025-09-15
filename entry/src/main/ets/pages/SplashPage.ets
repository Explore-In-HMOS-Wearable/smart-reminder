import LottieAnimation from '../animation/LottieAnimation'
import ConstantUI from '../util/ConstantUI'
import { BatteryDetailBuilder } from './BatteryDetailPage'
import { IndexPageBuilder } from './Index'

@Entry
@Component
export struct SplashPage {
  @Provide('NavPathStack') pageStack: NavPathStack = new NavPathStack()

  aboutToAppear() {
    setTimeout(() => {
      this.pageStack.replacePathByName('Index',null)
    }, ConstantUI.SPLASH_DELAY_MS)
  }

  build() {

    Navigation(this.pageStack) {
      Column() {
        LottieAnimation({ politeChickyPath: ConstantUI.RES_LOTTIE_REMINDER })
          .width(ConstantUI.FULL_WIDTH)
          .height(ConstantUI.FULL_HEIGHT)
      }
      .width(ConstantUI.FULL_WIDTH)
      .height(ConstantUI.FULL_HEIGHT)
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.Center)
    }
    .mode(NavigationMode.Stack)
    .hideTitleBar(true)
    .hideBackButton(true)
    .ignoreLayoutSafeArea()
    .navDestination(this.PageMap)
    .titleMode(NavigationTitleMode.Mini)

  }
  @Builder
  PageMap(name: string) {
    if (name === 'Index') {
      IndexPageBuilder()
    } else if (name === 'BatteryDetailPage') {
      BatteryDetailBuilder()
    }

  }
  pageTransition(): void {
    PageTransitionEnter({ type: RouteType.Push,
      duration: ConstantUI.TRANSITION_ENTER_DURATION
    }).slide(SlideEffect.Right)

    PageTransitionExit({ type: RouteType.Push,
      duration: ConstantUI.TRANSITION_EXIT_DURATION })
      .slide(SlideEffect.Left)
  }

}
