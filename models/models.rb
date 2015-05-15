DataMapper.setup(:default, 'postgres://localhost/lunchmeet')

class UserType
include DataMapper::Resource

  belongs_to :user

  property :id,     Serial    
  property :name, 	String    

end

class User
include DataMapper::Resource

	has 1, :UserType

  property :id,         	Serial    
  property :first_name, 	String    
  property :last_name,  	String
  property :cell_phone,		String    
end

DataMapper.finalize.auto_upgrade!