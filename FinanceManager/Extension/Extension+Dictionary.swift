import Foundation

extension Dictionary {
    
    public static func += (lhs: inout [Key: Value], rhs: [Key: Value]) {
        rhs.forEach { lhs[$0] = $1 }
    }
    
    public func without(key: Key) -> [Key: Value] {
        var temp = self
        temp.removeValue(forKey: key)
        return temp
    }
    
    public func without(keys: [Key]) -> [Key: Value] {
        var temp = self
        keys.forEach { (key) in
            temp.removeValue(forKey: key)
        }
        return temp
    }
    
    func getJsonString(encoding: String.Encoding = .ascii) -> String? {
        guard let jsonData = try? JSONSerialization.data(
            withJSONObject: self,
            options: []
        )
        else {
            return nil
        }
        return String(data: jsonData, encoding: encoding)
    }
}
