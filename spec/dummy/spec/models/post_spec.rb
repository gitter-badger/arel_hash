require 'rails_helper'

RSpec.describe 'Post', type: :model do
  it 'supports arel_hash in where expressions' do
    sql ="SELECT \"posts\".* FROM \"posts\" WHERE \"posts\".\"title\" = 'job interview'"
    expect(Post.where(ArelHash.create_node(Post.arel_table, eq: {title: 'job interview'})).to_sql).to eq sql
  end
end
