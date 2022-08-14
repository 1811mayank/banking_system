CREATE TABLE IF NOT EXISTS "schema_migrations" ("version" varchar NOT NULL PRIMARY KEY);
CREATE TABLE IF NOT EXISTS "ar_internal_metadata" ("key" varchar NOT NULL PRIMARY KEY, "value" varchar, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL);
CREATE TABLE sqlite_sequence(name,seq);
CREATE TABLE IF NOT EXISTS "users" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "email" varchar DEFAULT '' NOT NULL, "encrypted_password" varchar DEFAULT '' NOT NULL, "reset_password_token" varchar, "reset_password_sent_at" datetime, "remember_created_at" datetime, "first_name" varchar, "last_name" varchar, "city" varchar, "dob" datetime, "admin" boolean DEFAULT 0, "sign_in_count" integer DEFAULT 0 NOT NULL, "current_sign_in_at" datetime, "last_sign_in_at" datetime, "current_sign_in_ip" varchar, "last_sign_in_ip" varchar, "provider" varchar DEFAULT 'email' NOT NULL, "uid" varchar DEFAULT '' NOT NULL, "tokens" text, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL);
CREATE UNIQUE INDEX "index_users_on_email" ON "users" ("email");
CREATE UNIQUE INDEX "index_users_on_reset_password_token" ON "users" ("reset_password_token");
CREATE TABLE IF NOT EXISTS "branches" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar, "city" varchar, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL);
CREATE TABLE IF NOT EXISTS "transactions" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "type_of_transaction" varchar, "medium" varchar, "account_id" integer, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, "amount" decimal, "from" varchar, "where" varchar, "balance" decimal, "remark" varchar, CONSTRAINT "fk_rails_01f020e267"
FOREIGN KEY ("account_id")
  REFERENCES "accounts" ("id")
);
CREATE INDEX "index_transactions_on_account_id" ON "transactions" ("account_id");
CREATE TABLE IF NOT EXISTS "accounts" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "number" bigint, "type_of_account" varchar, "branch_id" integer, "balance" decimal, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_b1e30bebc8"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
, CONSTRAINT "fk_rails_d72169e1fc"
FOREIGN KEY ("branch_id")
  REFERENCES "branches" ("id")
);
CREATE INDEX "index_accounts_on_user_id" ON "accounts" ("user_id");
CREATE INDEX "index_accounts_on_branch_id" ON "accounts" ("branch_id");
CREATE TABLE IF NOT EXISTS "atms" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "number" bigint, "cvv" integer, "expiry_date" date, "account_id" integer, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_c3d71ebd8c"
FOREIGN KEY ("account_id")
  REFERENCES "accounts" ("id")
);
CREATE INDEX "index_atms_on_account_id" ON "atms" ("account_id");
CREATE TABLE IF NOT EXISTS "loan_types" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar, "interest" integer, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL);
CREATE TABLE IF NOT EXISTS "loans" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "duration" integer, "loan_type_id" integer, "account_id" integer, "amount" bigint, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_ca31e8411c"
FOREIGN KEY ("loan_type_id")
  REFERENCES "loan_types" ("id")
, CONSTRAINT "fk_rails_2ffcc5bc34"
FOREIGN KEY ("account_id")
  REFERENCES "accounts" ("id")
);
CREATE INDEX "index_loans_on_loan_type_id" ON "loans" ("loan_type_id");
CREATE INDEX "index_loans_on_account_id" ON "loans" ("account_id");
INSERT INTO "schema_migrations" (version) VALUES
('20220813130850'),
('20220813132224');


