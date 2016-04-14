begin
  gem('rails')
  require 'rails_helper'

  RSpec.describe Post, type: :model do
    pending "add some examples to (or delete) #{__FILE__}"
  end
rescue Gem::LoadError
  puts "executing non-rails tests only"
end
