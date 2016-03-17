module ArelHash
  class ArelHashFactory
    def initialize(properties)
      @properties = properties
    end

    def create_from_active_record(hash)
      { :and => hash.map { |k, v| name_value_to_arel_hash(k.to_sym, v) } }
    end

    private

    # converts a tuple from a where hash (as in ActiveRecord where) to a valid arel_hash expression
    def name_value_to_arel_hash(attr_name, value)
      case value
      when Array
        arel_hash_for_array_value(attr_name, value)
      when Range
        arel_hash_for_range_value(attr_name, value)
      else
        arel_hash_for_singleton_value(attr_name, value)
      end
    end

    def arel_hash_for_array_value(attr_name, values)
      { or: self.class.make_canonical(values).map do |option|
        { and: option.map do |requirement|
          arel_hash_for_singleton_value(attr_name, requirement)
        end }
      end }
    end

    def arel_hash_for_range_value(attr_name, range)
      { and: [create_arel_hash_tuple(:gteq, attr_name, range.first),
              create_arel_hash_tuple(range.exclude_end? ? :lt : :lt_eq, attr_name, range.end)] }
    end

    def arel_hash_for_singleton_value(attr_name, value)
      create_arel_hash_tuple(:eq, attr_name, value)
    end

    def create_arel_hash_tuple(predication, attr_name, value)
      if @properties.fetch(attr_name.to_s, {})['multivalue']
        { "#{predication}_any".to_sym => { value => attr_name } }
      else
        { predication => { attr_name => value } }
      end
    end

    def self.make_canonical(values)
      values.map { |v| v.is_a?(Array) ? v : [v] }
    end
  end
end
