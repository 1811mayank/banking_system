class User < ApplicationRecord
            # Include default devise modules.
           
  has_many :accounts
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable

  # devise :database_authenticatable, :registerable,
  #        :recoverable, :rememberable, :validatable
  #       #  include DeviseTokenAuth::Concerns::User
  #       # include DeviseTokenAuth::Concerns::ActiveRecordSupport
  #       include DeviseTokenAuth::Concerns::User
          #added this line to extend devise model
         # Include default devise modules. Others available are:
         # :confirmable, :lockable, :timeoutable and :omniauthable
        #  extend Devise::Models #added this line to extend devise model
         # Include default devise modules. Others available are:
         # :confirmable, :lockable, :timeoutable and :omniauthable
         devise :database_authenticatable, :registerable,:recoverable, :rememberable, :trackable, :validatable
         include DeviseTokenAuth::Concerns::User
         
        
         #  devise :database_authenticatable, :registerable,:recoverable, :rememberable, , :validatable
         
  def self.search(param)
    param.strip!
    (first_name_matches(param) + last_name_matches(param) + email_matches(param)).uniq
  end

  def self.first_name_matches(param)
    matches('first_name', param)
  end

  def self.last_name_matches(param)
    matches('last_name', param)
  end

  def self.email_matches(param)
    matches('email', param)
  end

  def self.matches(field_name, param)
    where("#{field_name} like ?", "%#{param}%")
  end
end
