//
//  WeatherHeaderCollectionView.swift
//  WeatherForecast
//
//  Created by Wonji Ha on 12/1/23.
//

import UIKit

class WeatherCollectionViewHeader: UICollectionReusableView {
    private lazy var horizontalStackView: UIStackView = {
       let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 2
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var weatherIcon: UIImageView = {
       let icon = UIImageView()
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.image = UIImage(systemName: "apple.logo")
        return icon
    }()
    
    var weatherImage: UIImage? {
        didSet {
            weatherIcon.image = weatherImage
        }
    }
    
    private lazy var verticallStackView: UIStackView = {
       let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .top
        stackView.distribution = .fillProportionally
        stackView.spacing = 3
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var addressStackView: UIStackView = {
        let stackView = UIStackView()
         stackView.axis = .horizontal
         stackView.alignment = .fill
         stackView.distribution = .fill
         stackView.spacing = 2
         stackView.translatesAutoresizingMaskIntoConstraints = false
         return stackView
    }()
    
    private lazy var addressLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()
    
    private lazy var addressSettingButton: UIButton = {
        let button = UIButton()
        button.setTitle("위치설정", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(.none, action: #selector(WeatherViewController().addressSettingButtonTapped(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var minMaxTemperatureLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var temperatureLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .boldSystemFont(ofSize: 30)
        return label
    }()
    
    private override init(frame: CGRect) {
        super.init(frame: frame)
        setUpLayouts()
        setUpConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setUpLayouts() {
        addressStackView.addArrangedSubviews([addressLabel, addressSettingButton])
        verticallStackView.addArrangedSubviews([addressStackView, minMaxTemperatureLabel, temperatureLabel])
        horizontalStackView.addArrangedSubviews([weatherIcon, verticallStackView])
        addSubview(horizontalStackView)
    }
    
    private func setUpConstraints() {
        NSLayoutConstraint.activate([
            horizontalStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            horizontalStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            horizontalStackView.heightAnchor.constraint(equalTo: self.heightAnchor),
        ])
    }
    
    func configureCell(_ current: CurrentWeatherInfo?) {
        guard let current = current else {
            temperatureLabel.text = "날씨 정보 없음"
            return
        }
        addressLabel.text = current.address
        temperatureLabel.text = current.mainInfo.temperature.temperatureFormatter() + "°"
        minMaxTemperatureLabel.text = "최저 \(current.mainInfo.temperatureMin.temperatureFormatter())° 최고 \(current.mainInfo.temperatureMax.temperatureFormatter())°"
    }
}
