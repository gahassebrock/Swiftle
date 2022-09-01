import Foundation

extension JSONEncoder {
    static func encode<T: Encodable>(from data: T) {
        do {
            let jsonEncoder = JSONEncoder()
            jsonEncoder.outputFormatting = .prettyPrinted
            let json = try jsonEncoder.encode(data)
            let jsonString = String(data: json, encoding: .utf8)

            let path: URL = URL(fileURLWithPath: "/home/runner/basicWordleDupe", isDirectory: true)
            let filename = path.appendingPathComponent("output.txt")
            try jsonString!.write(to: filename, atomically: true, encoding: .utf8)
            
        } catch {
            print(error.localizedDescription)
        }
    }
}

struct AllWords: Codable {
    var word: String
    var didUse: Bool
    var dateUsed: Date?
}

extension AllWords {
    static func sampleData() -> [AllWords] {
        var items = [AllWords]()

        // Define and integrate input file
        let path=URL(fileURLWithPath: "/home/runner/basicWordleDupe/words2")
        let text=try? String(contentsOf: path)

        // Split input file into array, by newline
        let binArray: [String] = text!.components(separatedBy: "\n")

        for item in binArray {
            items.append(AllWords(word: item, didUse: false, dateUsed: nil))
        }
        return items
    }
}

JSONEncoder.encode(from: AllWords.sampleData())