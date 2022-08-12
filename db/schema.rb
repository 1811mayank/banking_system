# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2022_08_12_071812) do

  create_table "accounts", force: :cascade do |t|
    t.integer "user_id"
    t.bigint "number"
    t.string "type_of_account"
    t.integer "branch_id"
    t.decimal "balance"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["branch_id"], name: "index_accounts_on_branch_id"
    t.index ["user_id"], name: "index_accounts_on_user_id"
  end

  create_table "atms", force: :cascade do |t|
    t.bigint "number"
    t.integer "cvv"
    t.date "expiry_date"
    t.integer "account_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["account_id"], name: "index_atms_on_account_id"
  end

  create_table "branches", force: :cascade do |t|
    t.string "name"
    t.string "city"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "loan_types", force: :cascade do |t|
    t.string "name"
    t.integer "interest"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "loans", force: :cascade do |t|
    t.integer "duration"
    t.integer "loan_type_id"
    t.integer "account_id"
    t.bigint "amount"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["account_id"], name: "index_loans_on_account_id"
    t.index ["loan_type_id"], name: "index_loans_on_loan_type_id"
  end

  create_table "transactions", force: :cascade do |t|
    t.string "type_of_transaction"
    t.string "medium"
    t.integer "account_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.decimal "amount"
    t.string "from"
    t.string "where"
    t.string "remark"
    t.decimal "balance"
    t.index ["account_id"], name: "index_transactions_on_account_id"
  end

# Could not dump table "users" because of following StandardError
#   Unknown type 'inlet' for column 'current_sign_in_ip'

  add_foreign_key "accounts", "branches"
  add_foreign_key "accounts", "users"
  add_foreign_key "atms", "accounts"
  add_foreign_key "loans", "accounts"
  add_foreign_key "loans", "loan_types"
  add_foreign_key "transactions", "accounts"
end
