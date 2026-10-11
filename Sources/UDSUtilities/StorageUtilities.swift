import Foundation

public enum UDSStorage {
    public static func set<Value: Encodable>(_ value: Value, forKey key: String, in defaults: UserDefaults = .standard) throws {
        defaults.set(try JSONEncoder().encode(value), forKey: key)
    }

    public static func value<Value: Decodable>(forKey key: String, as type: Value.Type = Value.self, in defaults: UserDefaults = .standard) throws -> Value? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try JSONDecoder().decode(type, from: data)
    }

    public static func removeValue(forKey key: String, in defaults: UserDefaults = .standard) {
        defaults.removeObject(forKey: key)
    }
}

public actor UDSMemoryCache<Value: Sendable> {
    private struct Entry: Sendable {
        let value: Value
        let expiration: Date?
    }
    private var values: [String: Entry] = [:]
    public init() {}
    public func value(forKey key: String) -> Value? {
        guard let entry = values[key] else { return nil }
        if let expiration = entry.expiration, expiration <= Date() {
            values[key] = nil
            return nil
        }
        return entry.value
    }
    public func insert(_ value: Value, forKey key: String, expiresAfter duration: TimeInterval? = nil) {
        let expiration = duration.map { Date().addingTimeInterval(max(0, $0)) }
        values[key] = Entry(value: value, expiration: expiration)
    }
    public func removeValue(forKey key: String) { values[key] = nil }
    public func removeAll() { values.removeAll() }
}

/// Short name for the actor-isolated in-memory cache.
public typealias UDSCache<Value: Sendable> = UDSMemoryCache<Value>

public enum UDSTemporaryFiles {
    public static func write(_ data: Data, named name: String, fileExtension: String? = nil) throws -> URL {
        let safeName = URL(fileURLWithPath: name).lastPathComponent
        let identifier = UUID().uuidString
        let suffix = fileExtension.map { ext in
            let safeExtension = String(ext.filter { $0.isLetter || $0.isNumber })
            return safeExtension.isEmpty ? "" : ".\(safeExtension)"
        } ?? ""
        let filename = "\(safeName)-\(identifier)\(suffix)"
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("UDSUtilities", isDirectory: true)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        let url = root.appendingPathComponent(filename, isDirectory: false)
        try data.write(to: url, options: .atomic)
        return url
    }

    public static func remove(_ url: URL) throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("UDSUtilities", isDirectory: true).standardizedFileURL
        let target = url.standardizedFileURL
        guard target.deletingLastPathComponent() == root else { throw StorageError.invalidLocation }
        try FileManager.default.removeItem(at: target)
    }

    public static func cleanup(olderThan age: TimeInterval, now: Date = Date()) throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("UDSUtilities", isDirectory: true)
        guard FileManager.default.fileExists(atPath: root.path) else { return }
        let cutoff = now.addingTimeInterval(-max(0, age))
        for url in try FileManager.default.contentsOfDirectory(
            at: root,
            includingPropertiesForKeys: [.contentModificationDateKey, .isRegularFileKey]
        ) {
            let values = try url.resourceValues(forKeys: [.contentModificationDateKey, .isRegularFileKey])
            guard values.isRegularFile == true,
                  let modified = values.contentModificationDate,
                  modified < cutoff else { continue }
            try FileManager.default.removeItem(at: url)
        }
    }
}

public enum UDSFileStorage {
    public enum Directory: Sendable { case documents, caches, applicationSupport }

    public static func write<Value: Encodable>(_ value: Value, named name: String, in directory: Directory = .applicationSupport) throws {
        let url = try fileURL(named: name, in: directory)
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try JSONEncoder().encode(value).write(to: url, options: .atomic)
    }

    public static func read<Value: Decodable>(_ type: Value.Type = Value.self, named name: String, in directory: Directory = .applicationSupport) throws -> Value? {
        let url = try fileURL(named: name, in: directory)
        guard FileManager.default.fileExists(atPath: url.path) else { return nil }
        return try JSONDecoder().decode(type, from: Data(contentsOf: url))
    }

    public static func remove(named name: String, in directory: Directory = .applicationSupport) throws {
        let url = try fileURL(named: name, in: directory)
        guard FileManager.default.fileExists(atPath: url.path) else { return }
        try FileManager.default.removeItem(at: url)
    }

    private static func fileURL(named name: String, in directory: Directory) throws -> URL {
        let safeName = URL(fileURLWithPath: name).lastPathComponent
        guard !safeName.isEmpty, safeName != ".", safeName != ".." else { throw StorageError.invalidLocation }
        let base: URL
        let searchPath: FileManager.SearchPathDirectory
        switch directory {
        case .documents: searchPath = .documentDirectory
        case .caches: searchPath = .cachesDirectory
        case .applicationSupport: searchPath = .applicationSupportDirectory
        }
        base = try FileManager.default.url(
            for: searchPath,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        return base.appendingPathComponent("UDSUtilities", isDirectory: true).appendingPathComponent(safeName, isDirectory: false)
    }
}

public enum StorageError: Error, Sendable { case invalidLocation }

#if canImport(Security)
import Security

public enum UDSKeychain {
    public enum KeychainError: Error, Sendable { case operationFailed(status: Int32) }

    public static func setThrowing(_ data: Data, forKey key: String, service: String = Bundle.main.bundleIdentifier ?? "UDS") throws {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrService as String: service,
                                    kSecAttrAccount as String: key]
        let status = SecItemCopyMatching(query as CFDictionary, nil)
        if status == errSecSuccess {
            let updateStatus = SecItemUpdate(query as CFDictionary, [kSecValueData as String: data] as CFDictionary)
            guard updateStatus == errSecSuccess else { throw KeychainError.operationFailed(status: updateStatus) }
        } else if status == errSecItemNotFound {
            var insert = query
            insert[kSecValueData as String] = data
            let addStatus = SecItemAdd(insert as CFDictionary, nil)
            guard addStatus == errSecSuccess else { throw KeychainError.operationFailed(status: addStatus) }
        } else {
            throw KeychainError.operationFailed(status: status)
        }
    }

    public static func dataThrowing(forKey key: String, service: String = Bundle.main.bundleIdentifier ?? "UDS") throws -> Data? {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrService as String: service,
                                    kSecAttrAccount as String: key,
                                    kSecReturnData as String: true,
                                    kSecMatchLimit as String: kSecMatchLimitOne]
        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        if status == errSecItemNotFound { return nil }
        guard status == errSecSuccess, let data = result as? Data else {
            throw KeychainError.operationFailed(status: status)
        }
        return data
    }

    public static func removeThrowing(forKey key: String, service: String = Bundle.main.bundleIdentifier ?? "UDS") throws {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrService as String: service,
                                    kSecAttrAccount as String: key]
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.operationFailed(status: status)
        }
    }

    @discardableResult
    public static func set(_ data: Data, forKey key: String, service: String = Bundle.main.bundleIdentifier ?? "UDS") -> Bool {
        do {
            try setThrowing(data, forKey: key, service: service)
            return true
        } catch {
            return false
        }
    }

    public static func data(forKey key: String, service: String = Bundle.main.bundleIdentifier ?? "UDS") -> Data? {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrService as String: service,
                                    kSecAttrAccount as String: key,
                                    kSecReturnData as String: true,
                                    kSecMatchLimit as String: kSecMatchLimitOne]
        var result: CFTypeRef?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess else { return nil }
        return result as? Data
    }

    @discardableResult
    public static func removeValue(forKey key: String, service: String = Bundle.main.bundleIdentifier ?? "UDS") -> Bool {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrService as String: service,
                                    kSecAttrAccount as String: key]
        return SecItemDelete(query as CFDictionary) == errSecSuccess
    }
}
#endif
