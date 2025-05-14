import Foundation

@propertyWrapper
struct Storage<T: Codable> {
    private let key: String
    private let defaultValue: T
    
    struct Wrapper<T>: Codable where T: Codable {
        let wrapped: T
    }

    init(key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }

    var wrappedValue: T {
        get {
            // Read value from UserDefaults
            guard let data = UserDefaults.standard.object(forKey: key) as? Data else {
                // Return defaultValue when no data in UserDefaults
                return defaultValue
            }

            // Convert data to the desire data type
            let value = try? JSONDecoder().decode(Wrapper<T>.self, from: data)
            return value?.wrapped ?? defaultValue
        }
        set {
            // Convert newValue to data
            let data = try? JSONEncoder().encode(Wrapper(wrapped: newValue))
            // Set value to UserDefaults
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
