class Pool < ApplicationRecord
  belongs_to :post
  has_many :machines, dependent: :destroy
end