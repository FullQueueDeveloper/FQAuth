import FluentPostgresDriver
import Vapor

extension UserModel {
  static func findByEmail(_ email: String, registrationMethod: RegistrationMethod, db: Database) -> EventLoopFuture<UserModel?> {
    switch registrationMethod {
    case .siwa:
      return UserModel.query(on: db)
        .filter(\UserModel.$registrationMethod == registrationMethod)
        .join(SiwaModel.self, on: \SiwaModel.$user.$id == \UserModel.$id)
        .filter(SiwaModel.self, \SiwaModel.$email == email)
        .first()
    }
  }

  static func findByAppleUserId(_ identifier: String, db: Database) -> EventLoopFuture<UserModel?> {
    UserModel.query(on: db)
      .join(SiwaModel.self, on: \SiwaModel.$user.$id == \UserModel.$id)
      .filter(SiwaModel.self, \SiwaModel.$appleUserId == identifier)
      .with(\UserModel.$siwa)
      .first()
  }
}