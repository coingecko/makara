module Makara
  module Logging

    module Subscriber
      IGNORE_PAYLOAD_NAMES = ["SCHEMA", "EXPLAIN"]

      def sql(event)
        name = event.payload[:name]
        unless IGNORE_PAYLOAD_NAMES.include?(name)
          name = [current_wrapper_name(event), name].compact.join(' ')
          event.payload[:name] = name
        end
        super(event)
      end

      protected

      # Rails 7.2 Compatibility Fix
      #
      # Grabs the adapter used in this event and prepends the connection name
      # to the SQL log, e.g., "[replica/1] User Load (1.3ms) SELECT * FROM users"
      #
      # Rails 7.2 changed the event payload structure:
      # - Rails < 7.2: event.payload[:connection_id] (integer object_id)
      # - Rails >= 7.2: event.payload[:connection] (actual connection object)
      #
      # We check both for backward compatibility. Without this fix, the
      # [replica/1] and [primary/1] prefixes won't appear in logs.
      #
      # See: https://github.com/instacart/makara/commit/ee22087
      def current_wrapper_name(event)
        # Rails 7.2+ provides the connection object directly
        connection = event.payload[:connection]
        # Rails < 7.2 provides the connection's object_id
        connection_object_id = event.payload[:connection_id]

        return nil unless connection || connection_object_id

        # Get the actual adapter object
        adapter = connection || ObjectSpace._id2ref(connection_object_id)

        return nil unless adapter
        return nil unless adapter.respond_to?(:_makara_name)

        "[#{adapter._makara_name}]"
      end
    end

  end
end
