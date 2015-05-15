DataMapper.setup(:default, ENV['DATABASE_URL'] || 'postgres://localhost/lunchmeet')

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
  property :first_name, 	String, :required => true    
  property :last_name,  	String, :required => true
  property :cell_phone,		String, :required => true    
end

DataMapper.finalize.auto_upgrade!