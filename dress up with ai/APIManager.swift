

//
//  APIManager.swift
//  dress up with ai
//
//  Created by paulprakash ladarla on 26/09/25.
//

import Foundation
import UIKit

class APIManager {
    static let shared = APIManager()
    private let apiKey = ImaggaConfig.apiKey
    private let apiSecret = ImaggaConfig.apiSecret
    private let apiURL = "https://api.imagga.com/v2/colors"

    private init() {}

    func fetchColors(for image: UIImage, completion: @escaping (Result<[String], Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            completion(.failure(NSError(domain: "com.dressupwithai.error", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get JPEG data from image."])))
            return
        }

        let boundary = UUID().uuidString
        var request = URLRequest(url: URL(string: apiURL)!)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.addValue("Basic \(Data("\(apiKey):\(apiSecret)".utf8).base64EncodedString())", forHTTPHeaderField: "Authorization")

        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "com.dressupwithai.error", code: -2, userInfo: [NSLocalizedDescriptionKey: "No data received from API."])))
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let result = json["result"] as? [String: Any],
                   let colorsData = result["colors"] as? [String: Any],
                   let imageColors = colorsData["image_colors"] as? [[String: Any]] {
                    let hexColors = imageColors.compactMap { $0["html_code"] as? String }
                    completion(.success(hexColors))
                } else {
                    completion(.failure(NSError(domain: "com.dressupwithai.error", code: -3, userInfo: [NSLocalizedDescriptionKey: "Failed to parse API response."])))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
