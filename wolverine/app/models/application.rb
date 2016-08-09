class Application < ActiveRecord::Base
  has_many :contents
  has_many :content_details
end
