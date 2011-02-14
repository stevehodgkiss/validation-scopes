$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'validation_scopes'
require 'bundler/setup'
require 'rspec'

RSpec.configure do |config|
  
end