import Foundation

func timestamp() -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm:ss"
    return formatter.string(from: Date())
}

func log(_ message: String) {
    print("[\(timestamp())] \(message)")
}

func run(
    name: String,
    launchPath: String,
    arguments: [String]
) -> [String] {

    log("START -> \(name)")
    log("COMMAND -> \(launchPath) \(arguments.joined(separator: " "))")

    let start = Date()

    let process = Process()
    process.executableURL = URL(fileURLWithPath: launchPath)
    process.arguments = arguments

    let stdoutPipe = Pipe()
    let stderrPipe = Pipe()

    process.standardOutput = stdoutPipe
    process.standardError = stderrPipe

    do {
        try process.run()
    } catch {
        log("FAILED -> \(name)")
        log("ERROR -> \(error.localizedDescription)")
        return ["FAILED: \(error.localizedDescription)"]
    }

    process.waitUntilExit()

    let duration = Date().timeIntervalSince(start)

    let stdoutData =
        stdoutPipe.fileHandleForReading.readDataToEndOfFile()

    let stderrData =
        stderrPipe.fileHandleForReading.readDataToEndOfFile()

    let stdout =
        String(data: stdoutData, encoding: .utf8) ?? ""

    let stderr =
        String(data: stderrData, encoding: .utf8) ?? ""

    if !stderr.isEmpty {
        log("STDERR -> \(stderr)")
    }

    let lines = stdout
        .split(separator: "\n")
        .map { String($0) }

    log("END -> \(name)")
    log("EXIT CODE -> \(process.terminationStatus)")
    log("OUTPUT LINES -> \(lines.count)")
    log(String(format: "DURATION -> %.2f sec", duration))
    log("--------------------------------------")

    return lines
}

let commands: [(String, String, [String])] = [
    (
        "find_apps",
        "/usr/bin/find",
        [
            "/Applications",
            "\(NSHomeDirectory())/Applications",
            "-name", "*.app",
            "-type", "d"
        ]
    ),
    (
        "brew_cask",
        "/opt/homebrew/bin/brew",
        ["list", "--cask"]
    ),
    (
        "brew_formula",
        "/opt/homebrew/bin/brew",
        ["list"]
    ),
    (
        "mas_receipts",
        "/usr/bin/find",
        ["/Applications", "-path", "*/Contents/_MASReceipt/receipt"]
    ),
    (
        "mas_list",
        "/opt/homebrew/bin/mas",
        ["list"]
    ),
    (
        "system_extensions",
        "/usr/bin/systemextensionsctl",
        ["list"]
    ),
    (
        "brew_taps",
        "/opt/homebrew/bin/brew",
        ["tap"]
    ),
    (
        "git_extensions",
        "/usr/bin/find",
        [
            "/usr/local/bin",
            "/opt/homebrew/bin",
            "-name", "git-*",
            "-type", "f"
        ]
    ),
    (
        "zsh_omz_plugins",
        "/usr/bin/find",
        [
            "\(NSHomeDirectory())/.oh-my-zsh/plugins",
            "\(NSHomeDirectory())/.oh-my-zsh/custom/plugins",
            "-type", "d",
            "-maxdepth", "1"
        ]
    ),
    (
        "zsh_zplug_plugins",
        "/usr/bin/find",
        [
            "\(NSHomeDirectory())/.zplug/repos",
            "-type", "d",
            "-maxdepth", "2"
        ]
    ),
]

var results: [String: [String]] = [:]

log("STARTING MACOS INVENTORY SCAN")
log("TOTAL COMMANDS -> \(commands.count)")
log("======================================")

for (name, path, args) in commands {
    results[name] = run(
        name: name,
        launchPath: path,
        arguments: args
    )
}

log("ENCODING JSON OUTPUT")

let encoder = JSONEncoder()
encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

if let data = try? encoder.encode(results),
   let json = String(data: data, encoding: .utf8) {

    print(json)

    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/pbcopy")
    let pipe = Pipe()
    process.standardInput = pipe
    try? process.run()
    pipe.fileHandleForWriting.write(Data(json.utf8))
    pipe.fileHandleForWriting.closeFile()
    process.waitUntilExit()

    log("App list is copied to your clipboard.")
} else {
    log("FAILED TO ENCODE JSON")
}
