module Fresh
  module CoreExtensions
    # Validates that the given hash includes the required keys.
    # If any keys are missing, ArgumentError will be raised.
    #
    # @param [Hash] hash the hash to validate
    # @param [Array<Symbol>] required_keys the list of keys
    # @raise [ArgumentError]
    def require_keys(hash, *required_keys)
      missing_keys = required_keys - hash.keys
      raise ArgumentError, "Missing required key(s): #{missing_keys.join(', ')}" unless missing_keys.empty?
    end

    # Returns the values of required keys in the given hash
    #
    # @param [Hash] hash the hash to validate
    # @param [Array<Symbol>] required_keys the list of keys
    # @raise [ArgumentError] (see Rose::CoreExtensions#require_keys)
    def required_values(hash, *required_keys)
      require_keys(hash, *required_keys)
      values = required_keys.inject([]) do |values, key|
        values << hash[key]
      end
      required_keys.length == 1 ? values.first : values
    end

    module Hash
      def -(other)
        diffed = {}
        each do |key, value|
          diffed[key] = value if other[key].nil?
        end
        diffed
      end

      def =~(other)
        diffed = {}
        each do |key, value|
          next unless other_value = other[key]
          diffed[key] = {value => other_value} if value != other_value
        end
        diffed
      end
    end
  end
end

class Hash
  include Fresh::CoreExtensions::Hash
end