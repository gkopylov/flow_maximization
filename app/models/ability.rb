class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new 

    can :read, :all
    
    if user.persisted?
      can :create, Project

      can :manage, User, :id => user.id

      can :manage, Project, :user_id => user.id

      can :manage, Node do |node|
        node.project.user == user
      end

      can :manage, Request do |request|
        request.project.user == user
      end

      can :manage, Connection do |connection|
        (connection.source.project.user == user) && (connection.target.project.user == user)
      end
    end
  end
end
