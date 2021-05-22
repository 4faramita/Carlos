//
//  OCR.swift
//  Carlos
//
//  Created by Zang Zhihao on 2021-05-16.
//

import UIKit
import Vision

struct Identifier {
    struct Unit {
        static let kcal = "kcal"
        static let gram = "g"
    }

    struct Name {
        static let calorie = "熱量"
        static let carb = "炭水化物"

        struct Surffix {
            static let shitsu = "質"
        }
    }
}

class OCR {
    static func recognize(_ image: UIImage, completion: @escaping (Int) -> Void) {
        // Get the CGImage on which to perform requests.
        guard let cgImage = image.cgImage else {
            fatalError()
        }

        // Create a new image-request handler.
        let requestHandler = VNImageRequestHandler(cgImage: cgImage)

        // Create a new request to recognize text.
        let request = VNRecognizeTextRequest { (request: VNRequest, error: Error?) in
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                return
            }
            let recognizedStrings = observations.compactMap { observation in
                // Return the string of the top VNRecognizedText instance.
                return observation.topCandidates(1).first?.string
            }
            if let index = recognizedStrings.firstIndex(where: { (string: String) in
                string.lowercased().hasSuffix(Identifier.Unit.kcal)
            }) {
                // The same element?
                let elementWithKCal = recognizedStrings[index]
                let maybeNumber = elementWithKCal.replacingOccurrences(of: Identifier.Unit.kcal, with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                if let number = Int(maybeNumber) {
                    completion(number)
                    return
                }

                // Separate element?
                guard recognizedStrings.indices.contains(index - 1) else { return }
                let maybeSeparateNumberElement = recognizedStrings[index - 1].trimmingCharacters(in: .whitespacesAndNewlines)
                if let number = Int(maybeSeparateNumberElement) {
                    completion(number)
                }
            }
        }

        request.recognitionLevel = .fast
//        request.recognitionLanguages = ["zh-Hant", "zh-Hans", "en-US"]

        do {
            // Perform the text-recognition request.
            try requestHandler.perform([request])
        } catch {
            print("Unable to perform the requests: \(error).")
        }
    }
}
