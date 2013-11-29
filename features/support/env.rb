require 'aruba/cucumber'
require 'leibniz'
require 'coveralls'
Coveralls.wear!

Before do
  @aruba_timeout_seconds = 15
end
