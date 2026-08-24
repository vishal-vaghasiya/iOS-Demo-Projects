//
//  WeatherView.swift
//  SwiftUILearning
//
//  Created by Nexios Technologies on 04/11/25.
//

import SwiftUI
import CoreLocation
import WeatherKit

@MainActor
struct WeatherDemoView: View {
    @StateObject private var viewModel = WeatherViewModel()

    var body: some View {
        VStack(spacing: 20) {
            if let weather = viewModel.weather {
                VStack(spacing: 10) {
                    Text("📍 \(viewModel.locationName)")
                        .font(.headline)

                    Text("\(weather.currentWeather.condition.description)")
                        .font(.title2)
                        .foregroundColor(.blue)

                    Text("\(Int(weather.currentWeather.temperature.value))°\(weather.currentWeather.temperature.unit.symbol)")
                        .font(.system(size: 56, weight: .bold))

                    Divider()

                    VStack(alignment: .leading, spacing: 8) {
                        Text("💨 Wind: \(Int(weather.currentWeather.wind.speed.value)) m/s")
                        Text("💧 Humidity: \(Int(weather.currentWeather.humidity * 100))%")
                        Text("☁️ Cloud Cover: \(Int(weather.currentWeather.cloudCover * 100))%")
                    }

                    Divider()

                    Text("🌅 Forecast")
                        .font(.headline)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(weather.hourlyForecast.prefix(6), id: \.date) { hour in
                                VStack {
                                    Text(hour.date, style: .time)
                                        .font(.caption)
                                    Image(systemName: icon(for: hour.condition))
                                        .font(.title2)
                                    Text("\(Int(hour.temperature.value))°")
                                        .font(.caption)
                                }
                                .padding(8)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(10)
                            }
                        }
                    }
                }
                .padding()
            } else if viewModel.isLoading {
                ProgressView("Fetching Weather…")
            } else if let error = viewModel.errorMessage {
                Text("❌ \(error)").foregroundColor(.red)
            } else {
                Button("Fetch Weather") {
                    Task { await viewModel.loadWeather() }
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .onAppear {
            Task { await viewModel.loadWeather() }
        }
    }

    private func icon(for condition: WeatherCondition) -> String {
        switch condition {
        case .clear, .mostlyClear: return "sun.max.fill"
        case .partlyCloudy, .mostlyCloudy: return "cloud.sun.fill"
        case .cloudy: return "cloud.fill"
        case .rain, .heavyRain: return "cloud.rain.fill"
        case .snow: return "snow"
        case .thunderstorms: return "cloud.bolt.rain.fill"
        default: return "cloud"
        }
    }
}

#Preview {
    WeatherDemoView()
}
