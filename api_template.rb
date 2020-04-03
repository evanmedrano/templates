def initial_setup
  run "spring stop"
end

def add_gems
  inject_into_file 'Gemfile', after: "# gem 'rack-cors'\n" do
      <<-RUBY
gem 'jsonapi-resources', '0.9.0'
                RUBY
    end

  # Injects into gems within the :development group
  inject_into_file 'Gemfile', after: "group :development do\n" do
      <<-RUBY
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'pry-rails'
  gem 'spring-commands-rspec'
                            RUBY
  end

  # Injects into gems within the :development, :test group
  inject_into_file 'Gemfile', after: "group :development, :test do\n" do
      <<-RUBY
  gem 'rspec-rails', '~> 4.0.0.beta2'
  gem 'factory_bot_rails', '~> 4.10.0'
  gem 'json_spec', '~> 1.1', '>= 1.1.5'
                                RUBY
  end

  # Injects into gems within the :test group
  inject_into_file 'Gemfile', after: "gem 'spring-watcher-listen', '~> 2.0.0'\n
end\n" do
      <<-RUBY
group :test do
  gem 'shoulda-matchers'
end
                      RUBY
  end
end

# For testing suite setup
def add_testing
  remove_dir "test"
  generate "rspec:install"
  run "bundle exec spring binstub rspec"

  inject_into_file '.rspec', after: "--require spec_helper\n" do
  "--format documentation"
  end

  inject_into_file "config/application.rb", after: "config.api_only = true\n" do
        <<-RUBY
    config.generators do |g|
      g.test_framework :rspec,
      view_specs: false,
      helper_specs: false,
      routing_specs: false
    end
        RUBY
  end

  inject_into_file "spec/rails_helper.rb", after: "RSpec.configure do |config|\n\n" do
    "config.include FactoryBot::Syntax::Methods"
  end

  inject_into_file "spec/rails_helper.rb", after: "# config.filter_gems_from_backtrace(\"gem name\")\nend\n\n" do
    <<-RUBY
Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
    RUBY
  end
end

def add_factories_file
  run "touch spec/factories.rb"

  inject_into_file "spec/factories.rb" do <<-RUBY
FactoryBot.use_parent_strategy = false

FactoryBot.define do

end
    RUBY
  end
end

# Main setup
initial_setup
add_gems

# Finishing touches
after_bundle do
  add_testing
  add_factories_file

  # Migrate
  rails_command "db:create"
  # rails_command "db:reset" # Resolve any potential issues with users factories and devise
  run "rails db:migrate"
  run "rails db:migrate RAILS_ENV=test"
  run "bundle install"

  run "git ctags"
  git :init
  git add: "."
  git commit: %Q{ -m 'Initial commit' }
  run "git flow init"
end
