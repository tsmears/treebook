class UserFriendship < ActiveRecord::Base
  belongs_to :user
  belongs_to :friend, class_name: 'User', foreign_key: 'friend_id'

  attr_accessible :user_id, :friend_id, :user, :friend, :state

  state_machine :state, initial: :pending do	
  	
  	after_transition on: :accept, do: :send_accpetance_email

  	state :requested

  	event :accept do
  		transition any => :accepted
  	end
  end


  def self.request(user1, user2)
  	transaction do
	  	friendship1 = create!(user: user1, friend: user2, state: 'pending')
	  	friendship2 = create!(user: user2, friend: user1, state: 'requested')

	  	friendship1.send_request_email
	  	friendship1
	end
  end

  def send_request_email
  	UserNotifier.friend_requested(id).deliver
  end
  
  def send_accpetance_email
  	UserNotifier.friend_request_accepted(id).deliver
  end

end
