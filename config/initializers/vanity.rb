VANITY_ENVIRONMENTS = %w{development production test}

def vanity_tables_exist?
  ActiveRecord::Base.connection.table_exists?('vanity_experiments')
end

def vanity_environment?
  VANITY_ENVIRONMENTS.include?(Rails.env)
end

Vanity.playground.collecting = vanity_tables_exist? and vanity_environment?