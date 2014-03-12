class Place < ActiveRecord::Base
  include HasRecordProperty
  include OutputPdf
  include OutputCsv

  acts_as_mappable

  has_many :stones
  has_many :attachings, as: :attachable
  has_many :attachment_files, through: :attachings
  has_many :referrings, as: :referable
  has_many :bibs, through: :referrings

end
