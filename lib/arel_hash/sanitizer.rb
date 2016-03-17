module ArelHash
  class Sanitizer
    def initialize(predicates = [], attribute_names = [])
      @predicates = (predicates || [])
      @attribute_names = (attribute_names || [])
    end

    def sanitize(arel_hash)
      operator, operand = ArelHash.singleton_tuple!(arel_hash)
      if operator == :and || operator == :or
        Hash[operator, operand.map { |o| sanitize(o) }]
      else
        sanitize_predication_hash(operator, operand)
      end
    end

    private

    def sanitize_predication_hash(operator, attr_name_value)
      valid = @predicates.empty? || @predicates.include?(operator.to_s)
      valid &&= attr_name_value.flatten.all? do |v|
        (!v.is_a?(Symbol)) || @attribute_names.empty? || @attribute_names.include?(v.to_s)
      end
      valid ? Hash[operator, attr_name_value] : ArelHash::ZERO_RESULTS_HASH
    end
  end
end
