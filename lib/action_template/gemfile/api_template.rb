def add_gems
  add_default_group_gems
  add_development_group_gems
  add_development_and_test_group_gems
  add_test_group_gems
end

def add_default_group_gems
  inject_into_file 'Gemfile', after: "# gem 'rack-cors'\n" do
      <<-RUBY
gem 'active_model_serializers'
gem 'faker', :git => 'https://github.com/faker-ruby/faker.git', :branch => 'master'
gem 'omniauth'
gem 'rubocop', require: false
gem 'gem-ctags'
      RUBY
    end
end

def add_development_group_gems
  inject_into_file 'Gemfile', after: "group :development do\n" do
      <<-RUBY
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'pry-rails'
  gem 'spring-commands-rspec'
      RUBY
  end
end

def add_development_and_test_group_gems
  inject_into_file 'Gemfile', after: "group :development, :test do\n" do
      <<-RUBY
  gem 'rspec-rails', '~> 4.0.0.beta2'
  gem 'factory_bot_rails', '~> 4.10.0'
  gem 'json_spec', '~> 1.1', '>= 1.1.5'
      RUBY
  end
end

def add_test_group_gems
  inject_into_file 'Gemfile', after: "'spring-watcher-listen', '~> 2.0.0'\nend\n" do
      <<-RUBY

group :test do
  gem 'shoulda-matchers'
end
      RUBY
  end
end
