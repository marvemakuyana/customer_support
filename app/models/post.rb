class Post < ApplicationRecord
  belongs_to :conversation
  belongs_to :author, polymorphic: true
  has_rich_text :body

  broadcasts_to :conversation

  validates :body, presence: true
end
