require 'active_record/connection_adapters/makara_abstract_adapter'

class FakeConnection < Struct.new(:config, keyword_init: false)

  # Ruby 3.x compatibility: Accept both positional hash and keyword arguments
  def initialize(config_or_keywords = nil, **keywords)
    if config_or_keywords.nil? && keywords.any?
      # Called with keyword arguments: FakeConnection.new(something: 'a')
      super(keywords)
    else
      # Called with positional argument or no args
      super(config_or_keywords)
    end
  end

  def ping
    'ping!'
  end

  def irespondtothis
    'hey!'
  end

  def query(content)
    config[:name]
  end

  def active?
    true
  end

  def disconnect!
    true
  end

  def something
    (config || {})[:something]
  end
end

class FakeDatabaseAdapter < Struct.new(:config)

  def execute(sql, name = nil)
    []
  end

  def exec_query(sql, name = 'SQL', binds = [])
    []
  end

  def select_rows(sql, name = nil)
    []
  end

  def active?
    true
  end

end

class FakeProxy < Makara::Proxy

  send_to_all :ping
  hijack_method :execute

  def connection_for(config)
    FakeConnection.new(config)
  end

  def needs_master?(method_name, args)
    return false if args.first =~ /^select/
    true
  end
end

class FakeAdapter < ::ActiveRecord::ConnectionAdapters::MakaraAbstractAdapter
  def connection_for(config)
    FakeDatabaseAdapter.new(config)
  end
end
