# frozen_string_literal: true

require "active_record"
require "erb"

class Connection
  def initialize
    db_config = setup_db_config
    ActiveRecord::Base.establish_connection(adapter: db_config["adapter"], database: db_config["database"])
  end

  def setup_db_config
    defined?(Rails) && defined?(Rails.env) ? rails_db_config : non_rails_db_config
  end

  def rails_db_config
    Rails.application.config.database_configuration[Rails.env]
  end

  def non_rails_db_config
    # TODO: use current database instead of development
    YAML.safe_load(ERB.new(File.read("./config/database.yml")).result, aliases: true)["development"]
  end
end
