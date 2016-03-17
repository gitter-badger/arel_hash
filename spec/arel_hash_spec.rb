require 'spec_helper'

module ArelHash
  describe '.create_node' do
    let(:table) { Arel::Table.new(:test) }
    let(:result) { double }
    describe 'predication node' do
      it 'is supported' do
        expected = Equality.new(table[:amount], Nodes::build_quoted(5))
        expect(ArelHash.create_node(table, eq: { amount: 5 })).to eq expected
      end
      it 'does support inverted operand orders' do
        expected = Equality.new(Nodes::build_quoted(5), table[:amount])
        expect(ArelHash.create_node(table, eq: { 5 => :amount })).to eq expected
      end
      it 'does not support multi column hashes' do
        multi_column_hash = { age: 4, amount: 50 }
        expect do
          ArelHash.create_node(table, eq: multi_column_hash)
        end.to raise_exception "#{multi_column_hash}: only hashes with maximum one key are supported"
      end
    end

    describe 'AND' do
      it 'returns nil if no operands' do
        expect(ArelHash.create_node(table, and: [])).to eq nil
      end
      it 'ignores the AND if only one operand' do
        expected = Equality.new(table[:age], Nodes::build_quoted(4))
        expect(ArelHash.create_node(table, and: [eq: { age: 4 }])).to eq expected
      end
      it 'properly builds a node for 2 operands' do
        expected = Nodes::LessThanOrEqual.new(table[:age], Nodes::build_quoted(6))
                     .and(Nodes::GreaterThanOrEqual.new(table[:age], Nodes::build_quoted(4)))
        expect(ArelHash.create_node(table, and: [{ lteq: { age: 6 } }, { gteq: { age: 4 } }])).to eq expected
      end
      it 'does not support multi predicate hashes' do
        multi_predicate_hash = { lteq: { age: 6 }, gteq: { age: 4 } }
        expect do
          ArelHash.create_node(table, and: [multi_predicate_hash])
        end.to raise_exception "#{multi_predicate_hash}: only hashes with maximum one key are supported"
      end
      it 'handles empty operands' do
        expect(ArelHash.create_node(table, and: [])).to eq(nil)
      end
    end

    describe 'OR' do
      it 'returns zero result if no operands' do
        expect(ArelHash.create_node(table, or: [])).to eq ArelHash::ZERO_RESULTS_NODE
      end
      it 'ignores the OR if only one operand' do
        expected = Equality.new(table[:amount], Nodes::build_quoted(5))
        expect(ArelHash.create_node(table, or: [eq: { amount: 5 }])).to eq expected
      end
      it 'properly builds a node for 2 operands' do
        expected = Equality.new(table[:amount], Nodes::build_quoted(5))
                     .or(Equality.new(table[:age], Nodes::build_quoted(4)))
        expect(ArelHash.create_node(table, or: [{ eq: { amount: 5 } }, { eq: { age: 4 } }])).to eq expected
      end
      it 'properly builds a node for 3 operands' do
        expected = Equality.new(table[:amount], Nodes::build_quoted(5))
                     .or(Equality.new(table[:age], Nodes::build_quoted(4)))
                     .or(Equality.new(table[:shoe_size], Nodes::build_quoted(3)))
        expect(ArelHash.create_node(table, or: [{ eq: { amount: 5 } }, { eq: { age: 4 } }, { eq: { shoe_size: 3 } }])).to eq expected
      end
      it 'does not support multi predicate hashes' do
        multi_predicate_hash = { lteq: { age: 4 }, gteq: { age: 6 } }
        expect do
          ArelHash.create_node(table, or: [multi_predicate_hash])
        end.to raise_exception "#{multi_predicate_hash}: only hashes with maximum one key are supported"
      end
      it 'squashes ORs with identical operands' do
        expected = Equality.new(table[:amount], Nodes::build_quoted(5))
        expect(ArelHash.create_node(table, or: [{ eq: { amount: 5 } }, { eq: { amount: 5 } }])).to eq expected
      end
    end

    describe 'any' do
      it 'builds regular any nodes' do
        expected = table[:amount].eq_any([Nodes::build_quoted(1), Nodes::build_quoted(2)])
        expect(ArelHash.create_node(table, eq_any: { amount: [1, 2] })).to eq expected
      end
      it 'creates ANY nodes if second operand is a symbol' do
        # TODO: not sure if we have to break down [[],[]] into ORs and ANDs of eq_any
        expected = Equality.new(Nodes::build_quoted(1), Nodes::Any.new(table[:amount]))
        expect(ArelHash.create_node(table, eq_any: { 1 => :amount })).to eq expected
      end
    end
  end
end
