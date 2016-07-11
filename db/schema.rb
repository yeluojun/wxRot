# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160711080419) do

  create_table "auto_replies", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin" do |t|
    t.string   "wxuin"
    t.integer  "friend_id"
    t.string   "flag_string"
    t.string   "content"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "friends", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin" do |t|
    t.string   "wxuin"
    t.string   "Uin"
    t.string   "UserName"
    t.string   "NickName"
    t.string   "HeadImgUrl"
    t.string   "ContactFlag"
    t.string   "MemberCount"
    t.string   "RemarkName"
    t.string   "HideInputBarFlag"
    t.string   "Sex"
    t.string   "Signature"
    t.string   "VerifyFlag"
    t.string   "OwnerUin"
    t.string   "PYInitial"
    t.string   "PYQuanPin"
    t.string   "RemarkPYInitial"
    t.string   "StarFriend"
    t.string   "AppAccountFlag"
    t.string   "Statues"
    t.string   "AttrStatus"
    t.string   "Province"
    t.string   "City"
    t.string   "Alias"
    t.string   "SnsFlag"
    t.string   "UniFriend"
    t.string   "DisplayName"
    t.string   "ChatRoomId"
    t.string   "KeyWord"
    t.string   "EncryChatRoomId"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin" do |t|
    t.string   "name"
    t.string   "password"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "weixin_tickets", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin" do |t|
    t.string   "wxuin"
    t.text     "json_data",  limit: 65535
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "weixins", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin" do |t|
    t.string   "name"
    t.string   "encry_name"
    t.string   "wxuin"
    t.integer  "status",     default: 0
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

end
