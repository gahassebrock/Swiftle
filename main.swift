import Foundation

var gameOver: Bool = false
var didWin: Bool = false
var attempts: Int16 = 1
let jsonPath = URL(fileURLWithPath: "words.json")
let jsonData: Data = try! Data(contentsOf: jsonPath, options: .mappedIfSafe)
var jsonResult: [AllWords] = try! JSONDecoder().decode([AllWords].self, from: jsonData)
let answer: String = genWordOfDay(inList: jsonResult)
var finalGuesses = [String]()

//print("\(answer)")
startGame()

enum AttemptWarning: Error {
    case outOfAttempts
    case invalidAttempt
    case incorrectAttempt
    case correctAttempt
    case unexpected
}

enum PositionToActual {
    case isInSpot
    case isInWord
    case isNotInWord
}

struct AllWords: Codable {
    let word: String
    let didUse: Bool
    let dateUsed: Date?
}

struct WordChar: Equatable {
    let char: Character
    let pos: Int
    let userGuess: PositionToActual?

    static var charNums: [String: Int] = [:]

    static func updateDict(using list: [String]) {
        for char in list {
            if charNums.keys.contains(char) {
                charNums.updateValue(charNums[char] + 1, forKey: char)
            }
            else {
                charNums.updateValue(1, forKey: char)
            }
    
    }

    func compare(to item: WordChar) -> PositionToActual {
        guard self.char == item.char else {
            return PositionToActual.isNotInWord
        }
        if pos == item.pos {
            return PositionToActual.isInSpot
        }
        return PositionToActual.isInWord
    }
}

/// Easily get properly-formatted environment variable values
/// - Parameter name: The name of the environment variable to retrieve
/// - Returns: A UTF-8 String representation of the value stored
///
/// > Warning: May return a nil value if the specified environment variable cannot be retrieved
func getEnvVar(of name: String) -> String? {
    if let val = getenv(name) {
        return String(validatingUTF8: val)
    }
    return nil
}

func checkAttempt(_ named: String) throws {
    guard named.lowercased() != answer.lowercased() else {
        print(checkChars(of: named))
        didWin = true
        gameOver = true
        throw AttemptWarning.correctAttempt
    }
    print(checkChars(of: named))
}

func checkChars(of guess: String) -> String {
    var result: String = ""
    var index = 0
    for char in guess {
        if char == Array(answer)[index] {
            result.append("\u{1F7E9}")
        }
        else {
            if answer.contains(char) {
                result.append("\u{1F7E7}")
            }
            else {
                result.append("\u{2B1C}")
            }
        }
        index += 1
    }
    finalGuesses.append(result)
    return "\(result)\n"
}

func getRandomIndex(from day: Int) -> Int {
    if let token = Int(getEnvVar(of: "staticToken") ?? "4152") {
        var gen = SeededGenerator(using: UInt64(day))
        return (Int(gen.next()) % token)
    }
    return 0
}

func genWordOfDay(inList: [AllWords]) -> String {
    let daysSince1970: Int = Int(Date().timeIntervalSince1970 / (60 * 60 * 24))
    let randIndex = getRandomIndex(from: daysSince1970)
    return inList[randIndex].word
}

/// Get input from user
func getInput(_ list: [AllWords]) throws -> String? {
    if let input = readLine() {
        if getEnvVar(of: "megaDoom") ?? "rhodeLovesAll" == input {
            print(blowTheThing())
            throw AttemptWarning.unexpected
        }
        for wordElem in list {
            if wordElem.word == input.lowercased() {
                attempts += 1
                return input
            }
        }
    }
    throw AttemptWarning.invalidAttempt
}

func greetUser() {
    print("""
          /---------------------\\
          | Welcome to Swiftle! |
          \\---------------------/

          Enter a guess below:
          """)
}

/// Start the basicWordleDupe game
func startGame() {
    greetUser()
    while(!gameOver) {
        do {
            guard attempts < 6 else {
                gameOver = true
                throw AttemptWarning.outOfAttempts
            }
            if let userGuess = try getInput(jsonResult) {
                try checkAttempt(userGuess)
            }
            else {
                throw AttemptWarning.unexpected
            }
        }
        catch AttemptWarning.outOfAttempts {
            print("Aww, you lost. The word was: \(answer)")
            print("\n\n\(finalGuesses.joined(separator: "\n"))")
        }
        catch AttemptWarning.incorrectAttempt {
            print("Your guess was incorrect...")
        }
        catch AttemptWarning.correctAttempt {
            print("Yay! You won! :)")
            print("\n\n\(finalGuesses.joined(separator: "\n"))")
        }
        catch AttemptWarning.invalidAttempt {
            print("Uh oh! Your guess was not found in the list.")
        }
        catch {
            print("An unexpected error occured. Ending game now.")
            gameOver = true
        }
    }
}