require "active_record"

def connect_db!
  ActiveRecord::Base.establish_connection(
    host: "localhost",
    adapter: "postgresql",
    database: ENV["PG_DATABASE"],
    user: ENV["PG_USER"],
    password: ENV["PG_PASSWORD"],
  )
end
