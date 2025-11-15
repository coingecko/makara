require 'active_record/connection_adapters/makara_abstract_adapter'
require 'active_record/connection_adapters/postgresql_adapter'

if ActiveRecord::VERSION::MAJOR >= 4

  module ActiveRecord
    module ConnectionHandling
      def postgresql_makara_connection(config)
        ActiveRecord::ConnectionAdapters::MakaraPostgreSQLAdapter.new(config)
      end
    end
  end

else

  module ActiveRecord
    class Base
      def self.postgresql_makara_connection(config)
        ActiveRecord::ConnectionAdapters::MakaraPostgreSQLAdapter.new(config)
      end
    end
  end

end

module ActiveRecord
  module ConnectionAdapters
    class MakaraPostgreSQLAdapter < ActiveRecord::ConnectionAdapters::MakaraAbstractAdapter

      # Rails 7.2 Compatibility Fix
      #
      # In Rails 7.2, several quoting methods (quote_table_name, quote_column_name, etc.)
      # were moved from instance methods to class methods to allow quoting without requiring
      # an active database connection.
      #
      # See: https://github.com/rails/rails/commit/0016280f
      #
      # Since MakaraPostgreSQLAdapter wraps PostgreSQLAdapter, it needs these class methods too.
      # Instead of manually delegating each method (which would break whenever Rails adds new ones),
      # we extend the PostgreSQL::Quoting::ClassMethods module to automatically inherit all of them.
      #
      # This gives us:
      # - quote_table_name - safely quotes table names (e.g., "users" or "public.users")
      # - quote_column_name - safely quotes column names (e.g., "email")
      # - column_name_matcher - regex for matching column names in SQL
      # - column_name_with_order_matcher - regex for matching columns with ORDER BY clauses
      extend ActiveRecord::ConnectionAdapters::PostgreSQL::Quoting::ClassMethods

      class << self
        def visitor_for(*args)
          ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.visitor_for(*args)
        end
      end

      protected

      # Rails 7.2 changed adapter instantiation from using Base.postgresql_connection(config)
      # to directly instantiating the adapter class with PostgreSQLAdapter.new(config).
      # This is the recommended approach for creating adapter instances in Rails 7.2+.
      #
      # See: https://github.com/rails/rails/commit/009c7e7411
      def active_record_connection_for(config)
        ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.new(config)
      end

    end
  end
end
