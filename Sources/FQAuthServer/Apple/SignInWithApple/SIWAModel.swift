import Fluent
import FluentPostgresDriver
import Crypto
import Foundation

final class SiwaModel: Model {
  static let schema = "siwa"

  @ID(key: .id)
  var id: UUID?

  @Field(key: "email")
  var email: String?

  @Parent(key: "user_id")
  var user: UserModel

  @Field(key: "apple_user_id")
  var appleUserId: String

  @Field(key: "encrypted_apple_refresh_token")
  var encryptedAppleRefreshToken: String?

  @Field(key: "created_at")
  var createdAt: Date

  @Field(key: "updated_at")
  var updatedAt: Date

  @Field(key: "attempted_refresh_at")
  var attemptedRefreshAt: Date?

  @Enum(key: "attempted_refresh_result")
  var attemptedRefreshResult: AttemptedRefreshResult

  enum AttemptedRefreshResult: String, Codable {
    case initial
    case success
    case failure
  }

  init() { }

  var isActive: Bool {
    guard encryptedAppleRefreshToken != nil else {
      return false
    }
    switch attemptedRefreshResult {
    case .initial, .success:
      return true
    case .failure:
      return false
    }
  }

  func unsealedAppleRefreshToken() -> String? {
    guard let encryptedAppleRefreshToken = encryptedAppleRefreshToken else {
      return nil
    }

    return DB.unseal(string: encryptedAppleRefreshToken)
  }

  func sealNewAppleRefreshToken(_ string: String) {
    self.encryptedAppleRefreshToken = DB.seal(string: string)
  }

  func shouldAttemptRefresh(now: Date = Date()) -> Bool {
    switch attemptedRefreshResult {

    case .initial:
      return Date(timeInterval: .oneDay, since: createdAt) < now

    case .success, .failure:
      guard let attemptedRefreshAt = attemptedRefreshAt else {
        return true
      }

      return Date(timeInterval: .oneDay, since: attemptedRefreshAt) < now
    }
  }
}
