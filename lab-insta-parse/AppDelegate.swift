import UIKit
import ParseSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        ParseSwift.initialize(
            applicationId: "fEWa5uRWI8fgzfMbNm5vogNBvQ4FYREUe9Re6wHO",
            clientKey: "RZblMAFdZiHyeLGWw3moKKDEDnxInDMaXXhliKKi",
            serverURL: URL(string: "https://parseapi.back4app.com")!
        )

        var score = GameScore()
        score.playerName = "Kingsley"
        score.points = 13

        score.save { result in
            switch result {
            case .success(let savedScore):
                print(" SAVED: \(savedScore)")
            case .failure(let error):
                print("ERROR: \(error)")
            }
        }

        return true
    }
}

struct GameScore: ParseObject {
    var objectId: String?
    var createdAt: Date?
    var updatedAt: Date?
    var ACL: ParseACL?
    var originalData: Data?

    var playerName: String?
    var points: Int?
}

