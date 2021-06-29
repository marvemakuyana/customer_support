class Contact < ApplicationRecord
    has_many :conversations 
    has_many :posts, as: :author
end
