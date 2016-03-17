module ArelHash
  class Optimizer
    def initialize(predicates = [])
      @predicates = predicates
    end

    def optimize(arel_hash)
      operator, value = ArelHash.singleton_tuple!(arel_hash)
      (%i(and or).include?(operator)) ? optimize_collection_node(operator, value) : arel_hash
    end

    private

    def optimize_collection_node(operator, children)
      children = children.map { |h| optimize(h) }.uniq
      arel_hash = shallow_optimize_collection_node(operator, children)
      children = ArelHash.singleton_tuple!(arel_hash).last
      (children.length == 1) ? children.first : arel_hash
    end

    def shallow_optimize_collection_node(operator, children)
      if operator == :or
        Hash[operator, optimize_or_nodes(children)]
      elsif operator == :and
        Hash[operator, optimize_and_nodes(children)]
      end
    end

    def optimize_or_nodes(nodes)
      nodes.delete_if { |n| n == ArelHash::ZERO_RESULTS_HASH && nodes.length > 1 }
      nodes = optimize_eqs_and_ins(nodes) if @predicates.include?('in') && @predicates.include?('eq')
      nodes.include?(ArelHash::NO_FILTER_HASH) ? [ArelHash::NO_FILTER_HASH] : nodes
    end

    def optimize_and_nodes(nodes)
      nodes.delete_if { |n| n == ArelHash::NO_FILTER_HASH && nodes.length > 1 }
      nodes = optimize_duplicate_eqs(nodes)
      nodes.include?(ArelHash::ZERO_RESULTS_HASH) ? [ArelHash::ZERO_RESULTS_HASH] : nodes
    end

    def optimize_duplicate_eqs(nodes)
      eqs, other = partition_by_keys(nodes, 'eq')
      values_per_attribute(eqs).map do |attr_name, values|
        (values.length > 1) ? ArelHash::ZERO_RESULTS_HASH : { eq: Hash[attr_name, values.first] }
      end.concat(other)
    end

    # @return [Array<Hash>] an array of predicate arelHashes
    def optimize_eqs_and_ins(nodes)
      ins_or_eqs, other = partition_by_keys(nodes, *%w(eq in))
      values_per_attribute(ins_or_eqs).map do |attr_name, value|
        (value.length > 1) ? { in: Hash[attr_name, value] } : { eq: Hash[attr_name, value.first] }
      end.concat(other)
    end

    # @param [Array<Hash<Symbol, Hash<Symbol, Object>>>] nodes
    # @return [Hash<Symbol, Array<String>>] attribute_name/value pair, with value being an Array
    def values_per_attribute(nodes)
      nodes.each_with_object({}) do |arel_hash, m|
        name_value_pair = ArelHash.singleton_tuple!(arel_hash).last
        attr_name, value = ArelHash.singleton_tuple!(name_value_pair)
        m[attr_name] = (m[attr_name]||[]).concat(Array(value)).uniq
      end
    end

    def partition_by_keys(hash_collection, *keys)
      hash_collection.partition do |h|
        keys.include?(ArelHash.singleton_tuple!(h).first.to_s)
      end
    end
  end
end
