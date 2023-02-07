//
//  URL + Extensions.swift
//  WeatherApp
//
//  Created by Giap on 02/02/2023.
//

import Foundation

extension URL {
	static func urlForWeatherAPI(city: String) -> URL? {
		return URL(
			string: "https://api.openweathermap.org/data/2.5/weather?q=\(city)&appid=6dd8e790809a7ba61ed405bf3f4a7a75&units=metric"
		)
	}
}
