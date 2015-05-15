class User < ActiveRecord::Base
  require 'phone'
  Phoner::Phone.default_country_code = '1'

  before_create :add_verification_code, :format_phone_number

  def first_name
    name.split.first.capitalize
  end

  def pretty_cell_phone
    Phoner::Phone.parse(cell_phone).format(:us)
  end

  private

  def format_phone_number
    unformatted_number = self.cell_phone
    self.cell_phone = Phoner::Phone.parse(unformatted_number)
  end

  def add_verification_code
    self.verification_code = loop do
      random_code = (Random.new.rand * 1000000).round
      break random_code unless self.class.exists?(verification_code: random_code)
    end
  end
end