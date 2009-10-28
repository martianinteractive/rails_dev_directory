Given /^primary services "([^\"]*)"$/ do |types|
  types = types.split(',')
  types.each do |type|
    Service.make(:name => type)
  end
end

Given /^secondary services "([^\"]*)"$/ do |types|
  types = types.split(',')
  types.each do |type|
    Service.make(:name => type)
  end
end

Given /^pre checked services "([^\"]*)"$/ do |types|
  types = types.split(',')
  types.each do |type|
    Service.make(:name => type, :checked => true)
  end
end

Given /there are no services/ do
  Service.destroy_all
end