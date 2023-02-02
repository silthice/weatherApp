//
//  ViewController.swift
//  WeatherApp
//
//  Created by Giap on 02/02/2023.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {

    @IBOutlet weak var cityNameTextField: UITextField!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.cityNameTextField.rx.controlEvent(.editingDidEndOnExit)
            .asObservable()
            .map {self.cityNameTextField.text}
            .subscribe(onNext: { city in
                if let city = city {
                    if city.isEmpty {
                        self.displayWeather(nil)
                    } else {
                        self.fetchWeather(by: city)
                    }
                }
            }).disposed(by: disposeBag)
    }


}

extension ViewController {
    func displayWeather(_ weather: Weather?){
        if let weather = weather {
            self.temperatureLabel.text = "\(weather.temp)  ℃"
            self.humidityLabel.text = "\(weather.humidity)  💦"
        } else {
            self.temperatureLabel.text = "Not found"
            self.humidityLabel.text = "Not found"
        }
    }
    
    func fetchWeather(by city: String) {
        guard let cityEncoded = city.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed),
              let url = URL.urlForWeatherAPI(city: cityEncoded) else {
            return
        }
        
        let resource = Resource<WeatherResult>(url: url)
        
        URLRequest.load(resource: resource)
            .observe(on: MainScheduler.instance)
            .catchAndReturn(WeatherResult.emptyWeatherResult)
            .subscribe(onNext: { result in
                
                let weather = result.main
                self.displayWeather(weather)
                
            }).disposed(by: disposeBag)
    }
}
