import UIKit
import CommonCrypto

extension String {
    
    func hmac(key: String) -> String {
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA256), key, key.count, self, self.count, &digest)
        let data = Data(bytes: digest, count: Int(CC_SHA256_DIGEST_LENGTH))
        return data.base64EncodedString()
    }
    
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }
        
        return String(data: data, encoding: .utf8)
    }
    
    func toBase64() -> String {
        Data(utf8).base64EncodedString()
    }
    
    func qrCode(backgroundColor: UIColor = .clear, tintColor: UIColor = .black) -> UIImage? {
        guard !isEmpty else {
            return nil
        }
        
        let data = data(using: String.Encoding.ascii)
        
        guard
            let filter = CIFilter(name: "CIQRCodeGenerator"),
            let colorFilter = CIFilter(name: "CIFalseColor")
        else {
            return nil
        }
        
        filter.setValue(data, forKey: "inputMessage")
        colorFilter.setValue(filter.outputImage, forKey: "inputImage")
        colorFilter.setValue(CIColor(color: backgroundColor), forKey: "inputColor1") // Background white
        colorFilter.setValue(CIColor(color: tintColor), forKey: "inputColor0") // Foreground or the barcode RED
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        
        guard let output = colorFilter.outputImage?.transformed(by: transform) else {
            return nil
        }
        
        return UIImage(ciImage: output)
    }
    
    func split(by length: Int) -> [String] {
         var startIndex = self.startIndex
         var results = [Substring]()

         while startIndex < self.endIndex {
             let endIndex = self.index(startIndex, offsetBy: length, limitedBy: self.endIndex) ?? self.endIndex
             results.append(self[startIndex..<endIndex])
             startIndex = endIndex
         }

         return results.map { String($0) }
     }
    
    func replace(at index: Int, with newChar: Character) -> String {
        var chars = Array(self)
        chars[index] = newChar
        let modifiedString = String(chars)
        return modifiedString
    }
    
    func replaceFirst(of target: String, with replacement: String) -> String {
        if let range = self.range(of: target) {
            return self.replacingCharacters(in: range, with: replacement)
        }
        return self
    }
    
    func pad(with character: String, toLength length: Int) -> String {
        let padCount = length - count
        guard padCount > 0 else { return self }
        
        return String(repeating: character, count: padCount) + self
    }
    
    func getNilIfEmpty() -> String? {
        isEmpty ? nil : self
    }
}

extension String {
    
    func height(withConstrainedWidth width: CGFloat, attributes: [NSAttributedString.Key: Any]) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(
            with: constraintRect,
            options: .usesLineFragmentOrigin,
            attributes: attributes,
            context: nil
        )
        
        return ceil(boundingBox.height)
    }
    
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        height(withConstrainedWidth: width, attributes: [.font: font])
    }
    
    func width(withConstrainedHeight height: CGFloat, attributes: [NSAttributedString.Key: Any]) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(
            with: constraintRect,
            options: .usesLineFragmentOrigin,
            attributes: attributes,
            context: nil
        )
        
        return ceil(boundingBox.width)
    }
    
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        width(withConstrainedHeight: height, attributes: [.font: font])
    }
}

extension CharacterSet {
    static let rfc3986Unreserved = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~")
    static let ascii = CharacterSet(charactersIn: " !\"#$%&\'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~")
}

extension String {
    func removingRegexMatches(pattern: String, replaceWith: String = "") -> String {
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
            let range = NSRange(location: 0, length: count)
            return regex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: replaceWith)
        } catch {
            return self
        }
    }
    
    func removingRegexMatches(pattern: RegexPattern, replaceWith: String = "") -> String {
        do {
            let regex = try NSRegularExpression(pattern: pattern.rawValue, options: .caseInsensitive)
            let range = NSRange(location: 0, length: self.count)
            return regex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: replaceWith)
        } catch {
            return self
        }
    }
    
    func removingEmojis() -> String {
        var str = self.components(separatedBy: CharacterSet.symbols).joined()
        str = str.replacingOccurrences(of: "  ", with: " ")
        return str
    }
    
    func regexMatches(pattern: String) -> [String] {
        do {
            let regex: NSRegularExpression = try NSRegularExpression(pattern: pattern)
            let results = regex.matches(in: self, range: NSRange(self.startIndex..., in: self))
            return results.map {
                String(self[Range($0.range, in: self)!])
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    
    func evaluate(regexPattern: String) -> Bool {
        NSPredicate(format: "SELF MATCHES %@", regexPattern).evaluate(with: self)
    }
    
    func evaluate(regexPattern: RegexPattern) -> Bool {
        NSPredicate(format: "SELF MATCHES %@", regexPattern.rawValue).evaluate(with: self)
    }
    
    var digits: String {
        components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
    }
    
    var isInt: Bool {
        Int(self) != nil
    }
    
    var isPhone: Bool {
        let count = digits.count
        return count >= 8
    }
    
    var isPhoneRus: Bool {
        let count = digits.count
        return count == 11
    }
    
    var isPhoneKz: Bool {
        let count = digits.count
        return count >= 11 && count <= 16
    }
    
    var isPhoneRusOrKz: Bool {
        let count = digits.count
        return count >= 11 && count <= 16
    }
    
    var isLogin: Bool {
        isInt && 6...12 ~= count
    }
    
    var isInnRusPhysical: Bool {
        let innCount = count
        let inn: [Int] = compactMap { $0.wholeNumberValue }
        guard innCount == inn.count else { return false }
        
        let controlAmountTwelveFirst = [7, 2, 4, 10, 3, 5, 9, 4, 6, 8]
        let controlAmountTwelveSecond = [3, 7, 2, 4, 10, 3, 5, 9, 4, 6, 8]
        
        let isValidFirst = inn[10] == ((inn.dropLast(2).enumerated().map { $0.element * controlAmountTwelveFirst[$0.offset] }).reduce(0, +) % 11) % 10
        let isValidSecond = inn[11] == ((inn.dropLast().enumerated().map { $0.element * controlAmountTwelveSecond[$0.offset] }).reduce(0, +) % 11) % 10
        return isValidFirst && isValidSecond
    }
    
    var isInnRusJuridical: Bool {
        let innCount = count
        let inn: [Int] = compactMap { $0.wholeNumberValue }
        guard innCount == inn.count else { return false }
        
        let controlAmountTen = [2, 4, 10, 3, 5, 9, 4, 6, 8]
        
        return inn[9] == ((inn.dropLast().enumerated().map { $0.element * controlAmountTen[$0.offset] }).reduce(0, +) % 11) % 10
    }
}

enum RegexPattern {
//    case mobile
//    case phone
//    case phoneRus
//    case phoneKz
    case email
    case name
    case passportSeriesRus
    case passportNumberRus
    case innRusPhysical
    case innRusJuridical
    case iinKz
    case snils
    case newPassword
    case digits
    case decimal
    case postalCodeRu
    case url
    
    var rawValue: String {
        switch self {
//        case .mobile:
//            return "[\\+\\ ()-]"
//        case .phone:
//            return "^((\\+)|(00))[0-9]{6,14}$"
//        case .phoneRus:
////            evaluate(regexPattern: .phone) && self.digits.count == 11
//            return "^((\\+)|(00))[0-9]{6,14}$"
//        case .phoneKz:
////            evaluate(regexPattern: .phone) && self.digits.count >= 8 && self.digits.count <= 16
//            return "^(\\+)"
        case .email:
            return "[A-ZА-Я0-9a-zа-я._%+-]+@[A-ZА-Яa-zа-я0-9.-]+\\.[A-Za-zА-Яа-я]{2,64}"
        case .name:
            return "^[А-яЁё -]{1,300}$"
        case .passportSeriesRus:
            return "^\\d{4}$"
        case .passportNumberRus:
            return "^\\d{6}$"
        case .innRusPhysical:
            return "^\\d{12}$"
        case .innRusJuridical:
            return "^\\d{10}$"
        case .iinKz:
            return "^\\d{12}$"
        case .snils:
            return "^\\d{11}$"
        case .newPassword:
            return "(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z])[^а-яА-Я ]{6,}"
        case .digits:
            return "[0-9]+"
        case .decimal:
            return "[0-9,.]+"
        case .postalCodeRu:
            return "^\\d{6}$"
        case .url:
            return "(?i)https?://(?:www\\.)?\\S+(?:/|\\b)"
        }
    }
}

extension String {
    
    var masked: String {
        if self.count > 9 {
            return "\(self.prefix(2)) *** \(self.suffix(4))"
        } else {
            return "\(self.prefix(2)) *** \(self.suffix(2))"
        }
    }
}

extension String {
    
    func condenseWhitespace() -> String {
        let components = components(separatedBy: .whitespacesAndNewlines)
        return components.filter { !$0.isEmpty }.joined(separator: " ")
    }
    
    func removingSpaces() -> String {
        replacingOccurrences(of: " ", with: "")
    }
    
    func removingReturn() -> String {
        replacingOccurrences(of: "\n", with: "")
    }
    
    func toUppercaseAtSentenceBoundary() -> String {
        var result: String = ""
        self.enumerateSubstrings(in: self.startIndex..<self.endIndex, options: .bySentences) { (substring, _, _, _) in
            if let substring = substring {
                result += substring.prefix(1).uppercased() + substring.dropFirst(1)
            }
        }
        return result
    }
    
    func removeFirstSymbolAtSentenceBoundary() -> String {
        var result: String = ""
        self.enumerateSubstrings(in: self.startIndex..<self.endIndex, options: .bySentences) { (substring, _, _, _) in
            if let substring = substring {
                result += substring.prefix(1) == "," ? String(substring.dropFirst(1)) : substring
            }
        }
        return result
    }
    
    func capitalizingFirstLetter() -> String {
        prefix(1).uppercased() + lowercased().dropFirst()
    }
}

extension String {
    
    static func UUID(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).compactMap { _ in letters.randomElement() })
    }
}

extension String {
    
    var withoutHtmlTags: String {
        replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
    }
}

extension String {
    
    var attr: NSAttributedString {
        NSAttributedString(string: self)
    }
}

extension UIImage {
    
    func attr(alignCenter: Bool = false,
              customSize: CGSize? = nil,
              font: UIFont? = nil
    ) -> NSAttributedString {
        let attachment = NSTextAttachment()
        attachment.image = self
        attachment.bounds.size = .init(
            width: customSize?.width ?? size.width,
            height: customSize?.height ?? size.height
        )
        if alignCenter {
            let yOffset: CGFloat
            if let font = font {
                yOffset = (font.capHeight - attachment.bounds.height) / 2
            } else {
                yOffset = -attachment.bounds.height / 4
            }
            attachment.bounds = .init(
                x: 0,
                y: yOffset,
                width: attachment.bounds.width,
                height: attachment.bounds.height
            )
        }
        return NSAttributedString(attachment: attachment)
    }
}

extension String {
    
    func replacingFirstOccurrence(of string: String, with replacement: String) -> String {
        guard let range = self.range(of: string) else { return self }
        return replacingCharacters(in: range, with: replacement)
    }
}
