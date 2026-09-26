import Cocoa
import WebKit

let app = NSApplication.shared
let path = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "Blocker/blockerList.json"
let json = try String(contentsOfFile: path, encoding: .utf8)
let rules = try JSONSerialization.jsonObject(with: Data(json.utf8)) as! [[String: Any]]
let filters = rules.compactMap { rule -> NSRegularExpression? in
    guard let action = rule["action"] as? [String: Any], action["type"] as? String == "block",
          let trigger = rule["trigger"] as? [String: Any], let pattern = trigger["url-filter"] as? String else { return nil }
    precondition(trigger["load-type"] as? [String] == ["third-party"])
    return try! NSRegularExpression(pattern: pattern, options: .caseInsensitive)
}
func matches(_ url: String) -> Bool {
    filters.contains { $0.firstMatch(in: url, range: NSRange(url.startIndex..., in: url)) != nil }
}
for url in ["https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js", "https://ad.doubleclick.net/ad.js", "https://ads.pubmatic.com:443/ad", "https://www.google-analytics.com/collect", "https://securepubads.g.doubleclick.net/tag/js/gpt.js", "https://s2.mdznads.com/webtekno.com.js", "https://an.yandex.ru/system/context.js"] {
    precondition(matches(url), "Missed ad URL: \(url)")
}
for url in ["https://example.com/?next=doubleclick.net/ad", "https://notdoubleclick.net/a", "https://doubleclick.net.example.com/a", "https://www.google.com/search?q=hello", "https://cdn.example.com/image.jpg", "https://www.webtekno.com/", "https://yandex.ru/search"] {
    precondition(!matches(url), "Incorrectly matched: \(url)")
}
let id = "SadeBlock.validation.\(UUID().uuidString)"
WKContentRuleListStore.default().compileContentRuleList(forIdentifier: id, encodedContentRuleList: json) { result, error in
    guard result != nil, error == nil else {
        fputs("WebKit compile failed: \(String(describing: error))\n", stderr)
        exit(1)
    }
    WKContentRuleListStore.default().removeContentRuleList(forIdentifier: id) { error in
        guard error == nil else { exit(1) }
        print("PASS: \(rules.count) rules compiled by WebKit; 14 positive/negative URL cases passed.")
        exit(0)
    }
}
DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
    fputs("WebKit validation timed out\n", stderr)
    exit(1)
}
app.run()
