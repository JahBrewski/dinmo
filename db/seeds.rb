# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
#Number.create(number: "+17792038833")
User.create! :username => 'jonmcewen', :email => 'jon@myexperts.co', :password => 'sunset11', :mobile_number => '662-549-7734', :mobile_number_normalized => "+16625497734", :first_name => 'Jon', :last_name => 'McEwen', :expertise => 'My Experts', tags: 'networking, dinmo, myexperts, craft beer, pizza, food, restaurants, nashville'
Number.create! :number => "+12526487265"
Number.create! :number => "+14233539072"
Number.create! :number => "+12525090502"
Number.create! :number => "+14198276161"
Number.create! :number => "+14198693222"
Number.create! :number => "+13168544139"
