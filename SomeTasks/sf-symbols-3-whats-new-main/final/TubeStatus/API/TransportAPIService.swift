/// Copyright (c) 2021 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import Foundation
import Combine

enum HTTPError: LocalizedError {
  case statusCode
  case status
}

struct TransportAPILineStatus: Decodable {
  let friendlyName: String
  let status: String

  enum CodingKeys: String, CodingKey {
    case friendlyName = "friendly_name"
    case status = "status"
  }
}

struct TransportAPILinesResponse: Decodable {
  let bakerloo: TransportAPILineStatus
  let central: TransportAPILineStatus
  let circle: TransportAPILineStatus
  let district: TransportAPILineStatus
  let hammersmith: TransportAPILineStatus
  let jubilee: TransportAPILineStatus
  let metropolitan: TransportAPILineStatus
  let northern: TransportAPILineStatus
  let piccadilly: TransportAPILineStatus
  let victoria: TransportAPILineStatus
  let waterlooandcity: TransportAPILineStatus
  let dlr: TransportAPILineStatus
}

struct TransportAPIStatusResponse: Decodable {
  let requestTime: String
  let statusRefreshTime: String
  let lines: TransportAPILinesResponse

  enum CodingKeys: String, CodingKey {
    case requestTime = "request_time"
    case statusRefreshTime = "status_refresh_time"
    case lines = "lines"
  }
}

final class TransportAPIService {
  var cancellable: AnyCancellable?
  let dateFormatter = DateFormatter()

  let appId = Bundle.main.object(forInfoDictionaryKey: "TRANSPORT_API_SERVICE_APP_ID") as? String
  let appKey = Bundle.main.object(forInfoDictionaryKey: "TRANSPORT_API_SERVICE_APP_KEY") as? String

  init() {
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss xxxx"
  }
}

// MARK: Data transformation
extension TransportAPIService {
  func transportAPIStatusResponseToAllLinesStatus(_ apiResponse: TransportAPIStatusResponse) -> AllLinesStatus {
    let lastUpdated = apiResponse.statusRefreshTime
    let apiResponseLines = apiResponse.lines

    var lines: [LineStatus] = []
    let bakerlooLineStatus = LineStatus(
      line: bakerlooLine,
      status: TFLLineStatus.tflLineStatus(from: apiResponseLines.bakerloo.status)
    )
    lines.append(bakerlooLineStatus)

    let centralLineStatus = LineStatus(
      line: centralLine,
      status: TFLLineStatus.tflLineStatus(from: apiResponseLines.central.status)
    )
    lines.append(centralLineStatus)

    let circleLineStatus = LineStatus(
      line: circleLine,
      status: TFLLineStatus.tflLineStatus(from: apiResponseLines.circle.status)
    )
    lines.append(circleLineStatus)

    let districtLineStatus = LineStatus(
      line: districtLine,
      status: TFLLineStatus.tflLineStatus(from: apiResponseLines.district.status)
    )
    lines.append(districtLineStatus)

    let hammersmithLineStatus = LineStatus(
      line: hammersmithAndCityLine,
      status: TFLLineStatus.tflLineStatus(from: apiResponseLines.hammersmith.status)
    )
    lines.append(hammersmithLineStatus)

    let jubileeLineStatus = LineStatus(
      line: jubileeLine,
      status: TFLLineStatus.tflLineStatus(from: apiResponseLines.jubilee.status)
    )
    lines.append(jubileeLineStatus)

    let metropolitanLineStatus = LineStatus(
      line: metropolitanLine,
      status: TFLLineStatus.tflLineStatus(from: apiResponseLines.metropolitan.status)
    )
    lines.append(metropolitanLineStatus)

    let northernLineStatus = LineStatus(
      line: northernLine,
      status: TFLLineStatus.tflLineStatus(from: apiResponseLines.northern.status)
    )
    lines.append(northernLineStatus)

    let piccadillyLineStatus = LineStatus(
      line: piccadillyLine,
      status: TFLLineStatus.tflLineStatus(from: apiResponseLines.piccadilly.status)
    )
    lines.append(piccadillyLineStatus)

    let victoriaLineStatus = LineStatus(
      line: victoriaLine,
      status: TFLLineStatus.tflLineStatus(from: apiResponseLines.victoria.status)
    )
    lines.append(victoriaLineStatus)

    let waterlooAndCityLineStatus = LineStatus(
      line: waterlooAndCityLine,
      status: TFLLineStatus.tflLineStatus(from: apiResponseLines.waterlooandcity.status)
    )
    lines.append(waterlooAndCityLineStatus)

    let dlrStatus = LineStatus(
      line: dlr,
      status: TFLLineStatus.tflLineStatus(from: apiResponseLines.dlr.status)
    )
    lines.append(dlrStatus)

    let lastUpdatedDate = dateFormatter.date(from: lastUpdated)
    return AllLinesStatus(lastUpdated: lastUpdatedDate, linesStatus: lines)
  }
}

// MARK: TubeLinesStatusFetcher

extension TransportAPIService: TubeLinesStatusFetcher {
  func fetchStatus() -> Future<AllLinesStatus, Error> {
    guard
      let appId = appId,
      let appKey = appKey
    else {
      fatalError("Could no find a valid AppID or AppKey. Make sure you have setup your xcconfig file correctly")
    }

    var urlComponents = URLComponents()
    urlComponents.scheme = "https"
    urlComponents.host = "transportapi.com"
    urlComponents.path = "/v3/uk/tube/lines.json"
    urlComponents.queryItems = [
      URLQueryItem(name: "include_status", value: "true"),
      URLQueryItem(name: "app_id", value: appId),
      URLQueryItem(name: "app_key", value: appKey)
    ]

    guard let url = urlComponents.url else {
      fatalError("Failed to build URL, this is likely a programming error")
    }

    return Future { promise in
      self.cancellable = URLSession.shared.dataTaskPublisher(for: url)
        .tryMap { output in
          guard
            let response = output.response as? HTTPURLResponse,
            response.statusCode == 200
          else {
            throw HTTPError.statusCode
          }
          return output.data
        }
        .decode(type: TransportAPIStatusResponse.self, decoder: JSONDecoder())
        .sink(receiveCompletion: { completion in
          switch completion {
          case .finished:
            break
          case .failure(let error):
            DispatchQueue.main.async {
              promise(.failure(error))
            }
          }
        }, receiveValue: { [self] statusResponse in
          let allLinesStatus = transportAPIStatusResponseToAllLinesStatus(statusResponse)
          promise(.success(allLinesStatus))
        })
    }
  }
}
