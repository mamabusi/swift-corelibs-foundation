import Foundation

func test_func() {
let storage = HTTPCookieStorage.shared
let simpleCookie0 = HTTPCookie(properties: [   //no expiry date
            .name: "TestCookie1",
            .value: "Test @#$%^$&*99",
            .path: "/",
            .domain: "swift.org",
            ])!
let rawValue = getenv("XDG_CONFIG_HOME")        
let xdg_config_home = String(utf8String: rawValue!)
print("Accessing environment variable")
print(xdg_config_home)
for (key, value) in ProcessInfo.processInfo.environment {
           print("\(key): \(value)")
       }
storage.setCookie(simpleCookie0)

let fm = FileManager.default
let destPath = "/root/mamatha/.cookies-TestCookie1"
var isDir = false
let exists = fm.fileExists(atPath: destPath, isDirectory: &isDir) 

print("Created Cookie false. File exists: \(exists)")
}

test_func()
