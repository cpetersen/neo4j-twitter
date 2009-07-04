require "rubygems"
require "neo4j"
# require "neo4j/auto_tx"
require "twitter"

Neo4j::Config[:storage_path] = 'tmp/neo4j'
Lucene::Config[:store_on_file] = true
Lucene::Config[:storage_path] = 'tmp/lucene'

class Friend
  include Neo4j::RelationshipMixin
end

class Follower
  include Neo4j::RelationshipMixin
end
      
class User
	include Neo4j::NodeMixin

	# define Neo4j properties
	property :screen_name, :name, :twitter_id

	# define an one way relationship to any other node
	has_n(:friends).to(User).relationship(Friend)
	has_n(:followers).from(User, :friends).relationship(Follower)
  
	# adds a lucene index on the following properties
	index :screen_name, :name, :twitter_id
	
	def self.get(twitter_id)
    User.find(:twitter_id => twitter_id).first
  end	
  
	def self.load(twitter_id, depth=0)
	  break if depth >= 3
	  start_time = Time.now
    puts "Starting Transaction"
    # Neo4j::Transaction.run do
      puts "Started Transaction"
      user = User.get(twitter_id) || User.new
      twitter_user = Twitter.user(twitter_id)
      user.twitter_id = twitter_user.id
      user.name = twitter_user.name
      user.screen_name = twitter_user.screen_name
      puts "Getting Friends"
      Twitter.friend_ids(twitter_id).each do |tfriend|
        puts "Friend [#{tfriend}]"
        begin
          user.friends << User.load(tfriend, depth+1)
        rescue
          puts "Error loading friend [#{tfriend}]"
        end
      end
      puts "Getting Follower"
      Twitter.follower_ids(twitter_id).each do |tfollower|
        puts "Friend [#{tfollower}]"
        begin
          user.followers << User.load(tfollower, depth+1)
        rescue
          puts "Error loading follower [#{tfollower}]"
        end
      end
  	  end_time = Time.now
  	  puts "Load [#{twitter_id}] depth of [#{depth}] took [#{end_time - start_time}]"
      return user
    # end
  end
end