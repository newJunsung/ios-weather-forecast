//
//  WeatherForecast - WeatherViewController.swift
//  Created by yagom.
//  Copyright © yagom. All rights reserved.
//

import UIKit
import Combine
import CoreLocation

class WeatherViewController: UIViewController {
    typealias Item = (current: CurrentWeatherInfo?, forecasts: [Forecast])
    enum Section {
        case main
    }
    
    @Published private var weatherInfo: Item = (nil, [])
    private let locationManager = WeatherLocationManager()
    private var subscribers = Set<AnyCancellable>()
    private var weatherDataSource: UICollectionViewDiffableDataSource<Section, Forecast>!
    private var collectionHeaderRegisteration: UICollectionView.SupplementaryRegistration<WeatherCollectionViewHeader>!
    private var collectionCellRegisteration: UICollectionView.CellRegistration<WeatherCollectionViewCell, Forecast>!
    private var coordinate: (lat: Double?, lon: Double?)
    
    private lazy var backgroundImage: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.image = UIImage(named: "background")
        return image
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeCompositionalLayout())
        collectionView.backgroundColor = .none
        collectionView.register(WeatherCollectionViewHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "Header")
        collectionView.register(WeatherCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.refreshControl = refreshWeather
        return collectionView
    }()
    
    private lazy var refreshWeather: UIRefreshControl = {
        let refresher = UIRefreshControl()
        refresher.tintColor = UIColor.systemPink
        refresher.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
        return refresher
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        
        setUpLayouts()
        setUpConstraints()
        
        registCell()
        registHeader()
        configureDatasource()
        bind()
    }
    
    @objc
    private func handleRefreshControl() {
        refreshWeather.beginRefreshing()
        if let lat = coordinate.lat, let lon = coordinate.lon {
            locationManager.getAddress(from: CLLocationCoordinate2D(latitude: lat, longitude: lon))
        } else {
            locationManager.requestLocation()
        }
        refreshWeather.endRefreshing()
    }
    
    private func registCell() {
        collectionHeaderRegisteration = UICollectionView.SupplementaryRegistration<WeatherCollectionViewHeader>(elementKind: UICollectionView.elementKindSectionHeader) { supplementaryView, elementKind, indexPath in
            guard let current = self.weatherInfo.current,
                  let url = WeatherURLManager().forecastWeatherIconGetURL(id: current.iconID),
                  let nsURL = NSURL(string: url.absoluteString) else { return }
            supplementaryView.configureCell(current)
            
            WeatherHTTPClient.updateWeatherIcon(from: URLRequest(url: url), valueHandler: { uiImage in
                supplementaryView.weatherImage = uiImage
                WeatherImageCache.shared.store(uiImage, to: nsURL)
            })
            .store(in: &self.subscribers)
        }
    }
    
    private func registHeader() {
        collectionCellRegisteration = UICollectionView.CellRegistration<WeatherCollectionViewCell, Forecast> { cell, indexPath, item in
            guard let iconID = item.weather.first?.icon,
                  let url = WeatherURLManager().forecastWeatherIconGetURL(id: iconID),
                  let nsURL = NSURL(string: url.absoluteString) else { return }
            cell.configureCell(to: item)
            
            WeatherHTTPClient.updateWeatherIcon(from: URLRequest(url: url)) { uiImage in
                cell.weatherImage = uiImage
                WeatherImageCache.shared.store(uiImage, to: nsURL)
            }
            .store(in: &self.subscribers)
        }
    }
    
    private func configureDatasource() {
        weatherDataSource = UICollectionViewDiffableDataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueConfiguredReusableCell(using: self.collectionCellRegisteration, for: indexPath, item: itemIdentifier)
            return cell
        })
        weatherDataSource.supplementaryViewProvider = { collectionView , kind , indexPath in
            collectionView.dequeueConfiguredReusableSupplementary(using: self.collectionHeaderRegisteration, for: indexPath)
        }
    }
    
    @objc
    func addressSettingButtonTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "위치변경", message: "변경할 좌표를 선택해주세요", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "변경", style: .destructive, handler: { [self] _ in
            guard let latText = alert.textFields?[0].text, let lonText = alert.textFields?[1].text,
                  let lat = Double(latText), let lon = Double(lonText) else { return }
            self.coordinate = (lat, lon)
            let loaction = CLLocationCoordinate2D(latitude: lat , longitude: lon)
            self.locationManager.getAddress(from: loaction)
        })
        let currentLocationWeatherAction = UIAlertAction(title: "현재 위치로 재설정", style: .default, handler: { [self] _ in
            locationManager.requestLocation()
            debugPrint("날씨가 새로고침 됨.")
        })
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        
        alert.addActions([okAction, currentLocationWeatherAction, cancelAction])
        
        alert.addTextField() { (textField) in
            textField.placeholder = "위도"
            textField.keyboardType = .decimalPad
        }
        alert.addTextField() { (textField) in
            textField.placeholder = "경도"
            textField.keyboardType = .decimalPad
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    func bind() {
        $weatherInfo
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (current, forecast) in
                var snapshot = NSDiffableDataSourceSnapshot<Section, Forecast>()
                snapshot.appendSections([.main])
                snapshot.appendItems(forecast, toSection: .main)
                snapshot.reloadSections([.main])
                self?.weatherDataSource.apply(snapshot)
            }
            .store(in: &subscribers)
    }
    
    private func setUpLayouts() {
        view.addSubview(backgroundImage)
        view.addSubview(collectionView)
    }
    
    private func setUpConstraints() {
        NSLayoutConstraint.activate([
            backgroundImage.topAnchor.constraint(equalTo: self.view.topAnchor),
            backgroundImage.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            backgroundImage.widthAnchor.constraint(equalTo: self.view.widthAnchor),
            
            collectionView.topAnchor.constraint(equalTo: self.view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            collectionView.widthAnchor.constraint(equalTo: self.view.widthAnchor),
        ])
    }
}

extension WeatherViewController: WeatherUIDelegate {
    func updateLocationWeather(_ coordinate: CLLocationCoordinate2D, _ addressString: String) {
        self.coordinate = (coordinate.latitude, coordinate.longitude)
        let urlManager = WeatherURLManager()
        guard let weatherURLRequest = urlManager.configureURLRequest(lat: coordinate.latitude, lon: coordinate.longitude, apiType: .weather) else { return }
        guard let forecastURLRequest = urlManager.configureURLRequest(lat: coordinate.latitude, lon: coordinate.longitude, apiType: .forecast) else { return }
        let weatherInfoPublisher = WeatherHTTPClient.publishForecast(from: weatherURLRequest, forecastType: CurrentWeather?.self)
        let forecastInfoPublisher = WeatherHTTPClient.publishForecast(from: forecastURLRequest, forecastType: FiveDayWeatherForecast.self)
        
        Publishers.Zip(forecastInfoPublisher, weatherInfoPublisher)
            .tryMap { (forecast, current) in
                guard let current = current, let weather = current.weathers.first else {
                    return (nil, forecast.list)
                }
                let currentWeatherData = CurrentWeatherInfo(address: addressString, iconID: weather.icon, mainInfo: current.mainInfo)
                return Item(currentWeatherData, forecast.list)
            }
            .handleEvents(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    debugPrint(error)
                }
            })
            .replaceError(with: (nil, []))
            .assign(to: \.weatherInfo, on: self)
            .store(in: &subscribers)
    }
}

extension WeatherViewController {
    private func makeCompositionalLayout() -> UICollectionViewCompositionalLayout {
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.15))
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.6))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: -10, leading: 3, bottom: -10, trailing: 3)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.07))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 10)
        section.boundarySupplementaryItems = [
            NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        ]
        
        return UICollectionViewCompositionalLayout(section: section)
    }
}
