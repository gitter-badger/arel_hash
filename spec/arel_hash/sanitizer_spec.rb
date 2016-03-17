require 'spec_helper'
module ArelHash
  describe Sanitizer do
    it 'does not sanitize if predicates and attribute_names are set to nil' do
      expect(Sanitizer.new.sanitize(eq: { x: 1 })).to eq(eq: { x: 1 })
    end
    it 'sanitizes base on given predicates' do
      expect(Sanitizer.new([ 'not_eq'], [1]).sanitize(eq: { x: 1 })).to eq(ZERO_RESULTS_HASH)
    end
    it 'sanitizes based on given attribute_names' do
      expect(Sanitizer.new(['eq'], [ 'y' ]).sanitize(eq: { x: 1 })).to eq(ZERO_RESULTS_HASH)
    end
    it 'sanitizes deeply' do
      expect(Sanitizer.new(['eq'], ['y']).sanitize(or: [or: [eq: { x: 1 }]])).to eq(or: [or: [ZERO_RESULTS_HASH]])
    end
    it 'sanitizes based on operand type' do
      expect(Sanitizer.new([], %w(x)).sanitize(eq: {1 => :x})).to eq(eq: {1 => :x})
    end
  end
end
