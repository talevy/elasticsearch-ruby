require 'test_helper'

module Elasticsearch
  module Test
    class UtilsTest < ::Test::Unit::TestCase
      include Elasticsearch::API::Utils

      context "Utils" do

        context "__listify" do

          should "create a list from single value" do
            assert_equal 'foo', __listify('foo')
          end

          should "create a list from an array" do
            assert_equal 'foo,bar', __listify(['foo', 'bar'])
          end

          should "create a list from multiple arguments" do
            assert_equal 'foo,bar', __listify('foo', 'bar')
          end

          should "ignore nil values" do
            assert_equal 'foo,bar', __listify(['foo', nil, 'bar'])
          end

        end

        context "__pathify" do

          should "create a path from single value" do
            assert_equal 'foo', __pathify('foo')
          end

          should "create a path from an array" do
            assert_equal 'foo/bar', __pathify(['foo', 'bar'])
          end

          should "ignore nil values" do
            assert_equal 'foo/bar', __pathify(['foo', nil, 'bar'])
          end

          should "ignore empty string values" do
            assert_equal 'foo/bar', __pathify(['foo', '', 'bar'])
          end

        end

        context "__bulkify" do

          should "convert the Array payload to string" do
            result = Elasticsearch::API::Utils.__bulkify [
              { :index =>  { :_index => 'myindexA', :_type => 'mytype', :_id => '1', :data => { :title => 'Test' } } },
              { :update => { :_index => 'myindexB', :_type => 'mytype', :_id => '2', :data => { :doc => { :title => 'Update' } } } },
              { :delete => { :_index => 'myindexC', :_type => 'mytypeC', :_id => '3' } }
            ]

            if RUBY_1_8
              lines = result.split("\n")

              assert_equal 5, lines.size
              assert_match /\{"index"\:\{/, lines[0]
              assert_match /\{"title"\:"Test"/, lines[1]
              assert_match /\{"update"\:\{/, lines[2]
              assert_match /\{"doc"\:\{"title"/, lines[3]
            else
              assert_equal <<-PAYLOAD.gsub(/^\s+/, ''), result
                {"index":{"_index":"myindexA","_type":"mytype","_id":"1"}}
                {"title":"Test"}
                {"update":{"_index":"myindexB","_type":"mytype","_id":"2"}}
                {"doc":{"title":"Update"}}
                {"delete":{"_index":"myindexC","_type":"mytypeC","_id":"3"}}
              PAYLOAD
            end
          end

        end

      end
    end
  end
end