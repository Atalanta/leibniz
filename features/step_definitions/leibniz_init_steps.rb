Given(/^I have a wrapper cookbook called "(.*?)"$/) do |cookbook|
  step "I successfully run `knife cookbook create #{cookbook} -o .`"

end

Given(/^I elect to use the "(.*?)" driver$/) do |driver|
  step "I successfully run `leibniz init --driver dummy`"
end


