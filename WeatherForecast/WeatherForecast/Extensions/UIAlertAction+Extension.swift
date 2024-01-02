//
//  UIAlertAction+Extension.swift
//  WeatherForecast
//
//  Created by Wonji Ha on 12/18/23.
//

import UIKit

extension UIAlertController {
    func addActions(_ actions: [UIAlertAction]) {
        actions.forEach {
            self.addAction($0)
        }
    }
}
