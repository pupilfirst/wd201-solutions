class User < ApplicationRecord
  def to_pleasant_string
    "#{id}. #{name} <#{email}>"
  end
end
