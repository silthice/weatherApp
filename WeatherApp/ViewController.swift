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
        
        //method 1 update UI thru functions usually with DispatchQueue
//        URLRequest.load(resource: resource)
//            .observe(on: MainScheduler.instance)
//            .catchAndReturn(WeatherResult.emptyWeatherResult)
//            .subscribe(onNext: { result in
//
//                let weather = result.main
//                self.displayWeather(weather)
//
//            }).disposed(by: disposeBag)
        
        //method 2 using rxcocoa binding
//        let search = URLRequest.load(resource: resource)
//                    .observe(on: MainScheduler.instance)
//                    .catchAndReturn(WeatherResult.emptyWeatherResult)
//
//        search.map { "\($0.main.temp) ℃"}
//            .bind(to: self.temperatureLabel.rx.text)
//            .disposed(by: disposeBag)
//
//        search.map { "\($0.main.humidity) 💦"}
//            .bind(to: self.humidityLabel.rx.text)
//            .disposed(by: disposeBag)
        
        //method 3 using driver
        let search = URLRequest.load(resource: resource)
            .observe(on: MainScheduler.instance)
            .asDriver(onErrorJustReturn: WeatherResult.emptyWeatherResult)
        
        search.map { "\($0.main.temp) ℃"}
            .drive(self.temperatureLabel.rx.text)
            .disposed(by: disposeBag)
        
        search.map { "\($0.main.humidity) 💦"}
            .drive(self.humidityLabel.rx.text)
            .disposed(by: disposeBag)
    }
}
