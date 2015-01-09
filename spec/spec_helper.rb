$LOAD_PATH << File.expand_path('./lib')

RSpec.configure do |config|
  # ...
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
