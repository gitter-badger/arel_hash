require 'arel_hash/version'
require 'arel'
require 'arel_hash/arel/nodes/casted'
require 'arel/nodes/any_node'
require 'arel/nodes/contains_node'
require 'arel_hash/node_factory'
require 'arel_hash/sanitizer'
require 'arel_hash/optimizer'
require 'arel_hash/arel_hash_factory'

module ArelHash
  Nodes = Arel::Nodes
  Equality = Nodes::Equality

  ZERO_RESULTS_NODE = Equality.new(Nodes::build_quoted('f'), Nodes::build_quoted('t'))
  ZERO_RESULTS_HASH = { or: [] }
  NO_FILTER_HASH = { and: [] }

  def self.create_node(table, hash)
    NodeFactory.new(table).create_node(hash)
  end

  def self.singleton_tuple!(hash)
    raise "#{hash}: only hashes with maximum one key are supported" unless hash.length == 1
    return hash.keys.first, hash.values.first
  end

  def self.create_from_active_record(hash, properties)
    ArelHashFactory.new(properties).create_from_active_record(hash)
  end
end