import FluentPostgresDriver

final class CreateUserMigration: PostgresScriptMigration {

  let up = [
    #"CREATE TYPE user_registration_method AS ENUM ('siwa')"#,
    #"CREATE TYPE user_status AS ENUM ('active', 'deactivated')"#,
    #"""
    CREATE TABLE "user" (
      id uuid PRIMARY KEY DEFAULT uuid_generate_v4 (),
      first_name TEXT,
      last_name TEXT,
      status user_status NOT NULL DEFAULT 'active',
      registration_method user_registration_method NOT NULL,
      created_at timestamp WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
      updated_at timestamp WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL
    );
    """#,
    #"""
    CREATE TRIGGER user_updated_at_timestamp
    BEFORE UPDATE ON "user" FOR EACH ROW
    EXECUTE PROCEDURE updated_at_timestamp()
    """#
  ]

  let down = [
    #"DROP TABLE IF EXISTS "user""#,
    #"DROP TYPE IF EXISTS user_status"#,
    #"DROP TYPE IF EXISTS user_registration_method"#
  ]
}
