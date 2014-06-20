class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable
  validates :username, :expertise, :tags, :presence => true, :if => :active_or_username?
  validates :username, :uniqueness => true, :if => :active_or_username?
  validates :mobile_number, :zipcode, :presence => true, :if => :active_or_mobile_number?
  validates :mobile_number, :phony_plausible => true, :if => :active_or_mobile_number?
  phony_normalize :mobile_number, :default_country_code => 'US'


  def active?
    status == 'active'
  end

  def active_or_username?
    status.include?('username') || active?
  end

  def active_or_mobile_number?
    status.include?('mobile_number') || active?
  end

  def self.search(query)
    query = query.gsub(" ","|")
    query = query.gsub("?","")
    where("tags @@ '#{query}'::tsquery")
  end
end
