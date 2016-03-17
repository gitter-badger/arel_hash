require 'spec_helper'

module ArelHash
  describe Optimizer do
    let(:optimizer) { Optimizer.new(%w(eq in)) }
    it 'removes AND nodes with single operands' do
      expect(optimizer.optimize(and: [{ eq: { x: 1 } }])).to eq(eq: { x: 1 })
    end
    it 'removes OR nodes with single operands' do
      expect(optimizer.optimize(or: [{ eq: { x: 1 } }])).to eq(eq: { x: 1 })
    end
    it 'maintains AND nodes without operands' do
      expect(optimizer.optimize(and: [])).to eq(and: [])
    end
    it 'maintains OR nodes without operands' do
      expect(optimizer.optimize(or: [])).to eq(or: [])
    end
    it 'removes duplicate nodes' do
      expect(optimizer.optimize(and: [{ eq: { x: 1 } }, { eq: { x: 1 } }])).to eq(eq: { x: 1 })
    end
    describe 'ZERO_RESULTS_HASH' do
      it 'eats other AND operands' do
        expect(optimizer.optimize(and: [ZERO_RESULTS_HASH, { eq: { x: 1 } }])).to eq ZERO_RESULTS_HASH
      end
      it 'gets eaten by other OR operands' do
        expect(optimizer.optimize(or: [ZERO_RESULTS_HASH, { eq: { x: 1 } }])).to eq(eq: { x: 1 })
      end
    end
    describe 'NO_FILTER_HASH' do
      it 'eats other OR operands' do
        expect(optimizer.optimize(or: [NO_FILTER_HASH, { eq: { x: 1 } }])).to eq NO_FILTER_HASH
      end
      it 'gets eaten by other AND operands' do
        expect(optimizer.optimize(and: [NO_FILTER_HASH, { eq: { x: 1 } }])).to eq(eq: { x: 1 })
      end
    end
    it 'combines EQ and IN for OR' do
      expected = { in: { amount: [5, 6, 7, 8] } }
      expect(optimizer.optimize(or: [{ eq: { amount: 5 } }, { eq: { amount: 6 } }, { in: { amount: [7, 8] } }])).to eq expected
    end
    it 'returns zero results for AND of EQ with same attribute and different values' do
      expect(optimizer.optimize(and: [{ eq: { amount: 5 } }, { eq: { amount: 6 } }])).to eq ZERO_RESULTS_HASH
    end

  end
end
