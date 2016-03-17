module ArelHash
  class NodeFactory
    # @param [Arel::Table] table the arel table to work on
    def initialize(table)
      @table = table
    end

    # @param [Hash<Symbol, Hash<Symbol, Object>>] hash a hash, which is a serialization of an Arel::Node
    def create_node(hash)
      operator, value = ArelHash.singleton_tuple!(hash)
      do_create_node(operator, value)
    end

    private

    def do_create_node(operator, value)
      if %i(or and).include?(operator)
        create_collection_node(operator, value)
      else
        create_predication_node(operator, value)
      end
    end

    def create_collection_node(operator, value)
      if operator == :or
        create_or_node(value)
      elsif operator == :and
        create_and_node(value)
      end
    end

    def create_predication_node(predicate, attribute_value_hash)
      first, last = ArelHash.singleton_tuple!(attribute_value_hash).map { |v| wrap_operand(v) }
      first.send(*expand_meta_predicates(predicate, last))
    end

    def expand_meta_predicates(predicate, value)
      # TODO: support ALL
      if (predicate=predicate.to_s).end_with?('_any') && value.is_a?(Arel::Attributes::Attribute)
        predicate = predicate[0...-4]
        value = Nodes::Any.new(value)
      end
      return predicate.to_sym, value
    end

    def wrap_operand(operand)
      case operand
      when Symbol then
        @table[operand]
      when Array then
        operand.map { |o| wrap_operand(o) }
      else
        Nodes::build_quoted(operand).extend Arel::Predications
      end
    end

    def create_and_node(values)
      join_nodes(create_node_collection(values), :and)
    end

    def create_or_node(values)
      join_nodes(create_node_collection(values), :or) || ZERO_RESULTS_NODE
    end

    def join_nodes(node_collection, operator)
      node_collection.reduce(nil) do |m, node|
        (m && node) ? m.send(operator, node) : node
      end
    end

    def create_node_collection(values)
      values.map { |v| create_node(v) }.uniq
    end
  end
end