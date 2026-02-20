import Foundation

enum CodablePersistence {
    static func loadFromFile<Value: Decodable>(
        _ type: Value.Type,
        at url: URL,
        decoder: JSONDecoder = JSONDecoder()
    ) -> Value? {
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try? decoder.decode(Value.self, from: data)
    }

    static func saveToFile<Value: Encodable>(
        _ value: Value,
        at url: URL,
        encoder: JSONEncoder = JSONEncoder()
    ) throws {
        let data = try encoder.encode(value)
        try data.write(to: url, options: [.atomic])
    }

    static func loadFromUserDefaults<Value: Decodable>(
        _ type: Value.Type,
        key: String,
        userDefaults: UserDefaults = .standard,
        decoder: JSONDecoder = JSONDecoder()
    ) -> Value? {
        guard let data = userDefaults.data(forKey: key) else { return nil }
        return try? decoder.decode(Value.self, from: data)
    }

    static func saveToUserDefaults<Value: Encodable>(
        _ value: Value,
        key: String,
        userDefaults: UserDefaults = .standard,
        encoder: JSONEncoder = JSONEncoder()
    ) {
        guard let data = try? encoder.encode(value) else { return }
        userDefaults.set(data, forKey: key)
    }

    static func removeUserDefaultsValue(
        for key: String,
        userDefaults: UserDefaults = .standard
    ) {
        userDefaults.removeObject(forKey: key)
    }
}
