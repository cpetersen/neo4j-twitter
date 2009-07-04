require 'models/user'

Neo4j::Transaction.run do
  users = User.get('10456332')
  users.each do |user|
    puts ">>>>>>>>>>>>>>>>> #{user.inspect}"
  end
end