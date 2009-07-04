require "rubygems"
require "neo4j"
require 'models/user'

Neo4j::Transaction.run do
  user = User.get('10075252')
  puts ">>>>>>>>>>>>>>>>> #{user.screen_name}"
end
