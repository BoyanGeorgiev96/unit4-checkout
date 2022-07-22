# frozen_string_literal: true

require "active_record"
require "erb"

# creates the connection for both Rails and non-Rails applications
class Connection
  def initialize
    db_config = setup_db_config
    ActiveRecord::Base.establish_connection(adapter: db_config["adapter"], database: db_config["database"])
  end

  def setup_db_config
    # decide whether the application that uses the gem is a Rails one or a plain Ruby
    defined?(Rails) && defined?(Rails.env) ? rails_db_config : non_rails_db_config
  end

  def rails_db_config
    Rails.application.config.database_configuration[Rails.env]
  end

  def non_rails_db_config
    # plain Ruby doesn't really have a sense of environments (unless a custom one has been set up)
    # the development key will most likely be changed when the gem is used by a plain Ruby application
    # the database db and config used here are samples from a Rails application, but this works with plain Ruby too
    # Future work: test thoroughly on plain Ruby applications
    YAML.safe_load(ERB.new(File.read("./config/database.yml")).result, aliases: true)["development"]
  end
end
