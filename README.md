# 🌤️ 날씨 앱
> API를 이용하여 받아온 데이터를 통해 현재 날씨와 5일 예보를 알려주는 날씨 앱입니다.

<br>

## 👨🏻‍💻 프로젝트 참여자
|newJunsung|COMDORI|
|:--:|:--:|
|<img src="https://avatars.githubusercontent.com/u/107932188?v=4" width=200>|<img src="https://avatars.githubusercontent.com/u/22284092?v=4" width=200>|


## 📆 프로젝트 기간
> 2023.11.20. ~ 2023.12.22.

<br>

## 🌟 프로젝트 핵심사항
- [x] 날씨 데이터를 API를 이용하여 JSON 데이터 파싱
- [x] CodingKeys 프로토콜 활용 
- [x] 서버와 통신할 타입 및 네트워킹 타입 구현
- [x] URLSession 활용
- [x] CoreLocation을 활용하여 좌표, 주소 구현
- [x] 컬렉션 헤드, 셀 뷰, UICollectionViewCompositionalLayout 활용
- [x] 컬렉션 뷰 셀 이미지 지연 로딩 문제 해결을 위한 NSCache 활용
- [x] 컬렉션 뷰 DiffableDataSource 활용
- [x] Refresh Control의 활용
- [x] DateFormatter 활용한 날짜 표현
- [x] UIAlertController TextField 활용
- [x] 커스텀 뷰 구현과 StackView, 오토레이아웃 활용
- [x] 적절한 Extension 활용
- [x] Combine 활용
- [x] Xcode 프로젝트 관리 구조의 이해와 응용

<br>


## 📷 동작 화면
|날씨 보기|위치 변경|날씨 새로고침 및 현위치 재설정|
|:--:|:--:|:--:|
![날씨 보기](https://github.com/newJunsung/ios-weather-forecast/assets/22284092/b9d59584-c220-4259-8ec3-7ec15ee757a1)|![위치 변경](https://github.com/newJunsung/ios-weather-forecast/assets/22284092/8335a67f-144c-4ba0-8779-1b2a7f229cbc)|![날씨 새로고침 및 현위치 변경](https://github.com/newJunsung/ios-weather-forecast/assets/22284092/ea153835-f50e-4dab-9406-ac29e834439c)



## 🛠️ 프로젝트 설계 패턴
- 디자인 패턴: `MVC`

<br>

## 🗂️ 프로젝트 디렉토리 구조
```
    WeatherForecast
    ├── WeatherForecast
    │   ├── APIKey.plist
    │   ├── AppDelegate.swift
    │   ├── Assets.xcassets
    │   │   ├── AccentColor.colorset
    │   │   │   └── Contents.json
    │   │   ├── AppIcon.appiconset
    │   │   │   └── Contents.json
    │   │   ├── Contents.json
    │   │   └── background.imageset
    │   │       ├── Contents.json
    │   │       └── ios-4-1125-x-2436-2k5qyo7bymv98ccz.jpg
    │   ├── Base.lproj
    │   │   └── LaunchScreen.storyboard
    │   ├── Extensions
    │   │   ├── CALayer+Extension.swift
    │   │   ├── Date+Extension.swift
    │   │   ├── Double+Extension.swift
    │   │   ├── UIAlertAction+Extension.swift
    │   │   └── UIView+Extension.swift
    │   ├── Info.plist
    │   ├── Models
    │   │   ├── CurrentWeather.swift
    │   │   ├── WeatherBases.swift
    │   │   └── WeatherForecast.swift
    │   ├── Networks
    │   │   ├── WeatherHTTPClient.swift
    │   │   └── WeatherURLManager.swift
    │   ├── Protocols
    │   │   ├── HTTPClient.swift
    │   │   └── WeatherUIDelegate.swift
    │   ├── SceneDelegate.swift
    │   ├── URLSession.swift
    │   ├── Utils
    │   │   ├── Errors.swift
    │   │   ├── WeatherImageCache.swift
    │   │   └── WeatherLocationManager.swift
    │   ├── Views
    │   │   ├── WeatherCollectionViewCell.swift
    │   │   ├── WeatherCollectionViewHeader.swift
    │   │   └── WeatherViewController.swift
    │   └── WeatherClient.swift
    ├── WeatherForecast.xcodeproj
    │   ├── project.pbxproj
    │   └── project.xcworkspace
    ├── WeatherForecastTests
    │   ├── Info.plist
    │   └── WeatherForecastTests.swift
    └── WeatherForecastUITests
    │   ├── Info.plist
    │   └── WeatherForecastUITests.swift
    └── README.md
```

## 🚀 트러블 슈팅

### fatalError 메소드의 위험성
- guard문 탈출이나 에외상황 해결하기 위해 fatalError()메소드를 사용하였는데, 이 메소드를 사용하여 오류를 만났을 때 앱이 강제로 종료될 수 있는 상황을 사용자에게 보여줌으로써 사용자가 놀랄 수 있으므로 오류 표시를 Alert으로 표현하던, 다른 방식으로 처리하여 앱이 강제 종료되지 않게 해야 함을 깨달았습니다.

```swift=
// 수정 전
guard (200..<300).contains(httpResponse.statusCode) else {
    fatalError("status code 오류")
}

if data.count <= 0 {
    fatalError("data가 없음")
}

// 수정 후
guard (200..<300).contains(httpResponse.statusCode) else {
throw StatusCodeError.httpError(httpResponse.statusCode)
}

if data.count <= 0 {
    throw URLError(.zeroByteResource)
}

```

### 강한 참조가 일어나는 이슈
```swift=
// 강한 참조 문제 발생
{ completion in
    switch completion {
    case .finished:
        return
    case .failure(let error):
        self.countryLabel.text = error.localizedDescription
        print(error)
    }
 
 // 순환 참조 문제 해결 후
{ [weak self] completion in
    // guard let self = self else { return }
    
    switch completion {
    case .finished:
        return
    case .failure(let error):
        self?.countryLabel.text = error.localizedDescription
    }
}
 
```
- `[weak self]`로 캡처하여 순환참조 문제가 발생하지 않게 하였습니다. 또한 guard 구문으로 self를 언래핑하게 되면 같은 메모리를 가르켜 RC가 실제로 +1 증가 하지만, 이 구문이 끝남과 동시에 RC가 -1 되기때문에 약한참조가 되어서 해당 이슈를 해결할 수 있었습니다.  


### 컬렉션뷰 셀의 데이터가 바뀌지 않는 이슈 1 [^1]
```swift=
var snapshot = NSDiffableDataSourceSnapshot<Section, Forecast>()
snapshot.appendSections([.main])
snapshot.appendItems(forecast, toSection: .main)
snapshot.reloadSections([.main])
self?.weatherDataSource.apply(snapshot)
```
- 위의 코드를 적용하면 헤더의 데이터는 변경되나 셀의 데이터가 변경되지 않는 점이 있어서 `self?.weatherDataSource.applySnapshotUsingReloadData(snapshot)` 메소드를 사용했으나 애니메이션이 동작하지 않는 이슈가 발생하여 한번 더 `apply()`메소드를 호출하여 스냅샷의 데이터가 변경되었음을 인지하고 셀이 다시 한번 reload되어 셀의 데이터도 최신화되고, 애니메이션 효과도 동작하여 문제점을 해결하였습니다.

```swift=
var snapshot = NSDiffableDataSourceSnapshot<Section, Forecast>()
snapshot.appendSections([.main])
self?.weatherDataSource.apply(snapshot)

snapshot.appendItems(forecast, toSection: .main)
snapshot.reloadSections([.main])
self?.weatherDataSource.apply(snapshot)
```

### 컬렉션뷰 셀의 데이터가 바뀌지 않는 이슈 2 
- 스냅샷이 컬렉션뷰를 그려주는 부분이 문제가 아니라 근본적인 문제는 데이터를 판단해주는 조건문이 시간으로만 판단하여 데이터가 달라졌음에도 시간이 같다고 판단하여 새로운 날씨 데이터를 최신화 못 해주는 문제가 발생하였습니다. 이를 해결하기 위해 날씨의 온도를 가지고 판단해주는 조건식을 추가하여 `DiffableDataSource`가 바뀐 데이터를 인지할 수 있도록 하여 셀의 날씨가 바뀔 수 있도록 문제를 해결하였습니다.

```swift=
// 문제가 있는 함수
static func == (lhs: Forecast, rhs: Forecast) -> Bool {
    return lhs.timeOfData == rhs.timeOfData
}

// 이슈를 해결한 함수
static func == (lhs: Forecast, rhs: Forecast) -> Bool {
    return lhs.timeOfData == rhs.timeOfData && lhs.mainInfo.temperature == rhs.mainInfo.temperature
}
```

[^1]: https://velog.io/@alexcho617/Realm-DiffableDataSource
