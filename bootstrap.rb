require "rubygems"
require "neo4j"
require "models/user"

# user = User.load('cpetersen')
Neo4j::Transaction.run do
  User.load('10456332')
end
