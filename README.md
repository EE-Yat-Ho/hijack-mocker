
# Hi-Jack-Mocker 소개 (API Hijacking &amp; Moking)
- Hi-Jack-Mocker는 URLProtocol를 활용하여 네트워크 요청과 응답을 가로채고 수정하여 UI를 쉽게 검증할 수 있게 해주는 프로젝트입니다.
- API 네트워크 요청과 응답을 하이재킹하고, 모킹하여 다양한 조건에서 UI를 확인할 수 있는 라이브러리입니다.
- 비개발자가 엣지 케이스에 대한 UI 테스트를 할 때 겪는 문제를 해결하기 위해 만들어졌습니다. 
(..만, 저는 개발할 때도 잘 사용하고 있습니다.)

- 해당 프로젝트는 드로이드나이츠 "혹시 API Mocking좀 해주실래요? - API Mocking 도구로 생산성 올리기" 발표 세션에 영감을 받아 만들게 되었습니다.
- 안드로이드 처럼 Interceptor를 활용하고 싶었지만, Alamofire의 Interceptor는 validation에 걸릴 경우에만 retry 콜백에 걸리기 때문에 적합하지 않았습니다.
- 의존성을 없앨 겸, URLProtocol를 활용해서 만들었습니다.

------------
# Useful Cases
- Label에 긴 문자열이 들어갔을 때를 테스트 해야하는데, 짧은 문자열만 내려올 때
- NoData UI를 테스트 해야하는데, 자꾸 데이터가 내려올 때
- 데이터가 많아서 스크롤이 잘 되는지 봐야하는데, 데이터가 별로 없을 때
- more load가 잘 되는지 봐야하는데, 데이터가 별로 없을 때
(request의 offset이나 page를 조절하면 가능)
- Flag값이 다르게 내려왔을 때를 테스트 해야할 때

------------

# How to use

1. HijackMoker 사용 여부를 결정
> - Dev앱이거나, Debug환경에서 사용하길 추천합니다.
> ```Swift
> /// Dev 앱인지 여부 (Prod 앱과 반대)
> public static func isDevApp() -> Bool {
>     let prefix = "io.mytest.app.dev"
>     guard let bundle = Bundle.main.bundleIdentifier else { return false }
>     return bundle.hasPrefix(prefix)
> }
> 
> /// Debug 환경인지 여부 (Release 환경과 반대)
> public static func isDebug() -> Bool {
>     #if DEBUG
>     true
>     #else
>     false
>     #endif
> }
> 
> /// 하이잭모커 사용 여부
> /// Dev앱 || Debug환경에서 사용하길 추천합니다
> /// Window와, Session에 Side Effect가 있습니다
> public static func useHijackMoker() -> Bool {
>     isDevApp() || isDebug()
> }
> ```

2. UIKit의 경우, Window를 HijackMoker를 사용하도록 수정 
> - 다른 window나 Subview에 덮혀도, 계속해서 Switch를 최상단으로 올리기 위해
> 
> ```Swift
> // AppDelegate.swift
> var window: UIWindow? = LKStaticMethods.useHijackMoker()
>     ? HijackMokerWindow(frame: UIScreen.main.bounds)
>     : UIWindow(frame: UIScreen.main.bounds)
> ```

3. SwiftUI의 경우, HijackMokerToggle() 를 활용
> 
> ```Swift
> @main
> struct HijackMokerDemoApp: App {
>     var body: some Scene {
>         WindowGroup {
>             ZStack {
>                 HijackMokerToggle()
>                 PoketMonList()
>             }
>         }
>     }
> }
> ```

4. Session 수정 필요
> - URLProtocol을 활용하기 위해
> 
> ```Swift
> private func createSession(timeout: CGFloat = 10) -> URLSession {
>     let configuration = URLSessionConfiguration.default
>     
>     if StaticMethods.useHijackMoker() {
>         HijackMokerService.setTimeout(second: timeout)
>         configuration.timeoutIntervalForRequest = .infinity
>         configuration.protocolClasses = [HijackMokerURLProtocol.self]
>     } else {
>         configuration.timeoutIntervalForRequest = timeout
>     }
>     return URLSession(configuration: configuration)
> }
> ```


* 내부적으로 UserDefaults에 Switch용 On/Off 여부 저장 중.
> ```Swift
> var hijackMoekrIsOn: Bool {
>     get {
>         UserDefaults.standard.bool(forKey: "HijackMokerSwitch")
>     }
>     set {
>         UserDefaults.standard.set(newValue, forKey: "HijackMokerSwitch")
>     }
> }
> ```


