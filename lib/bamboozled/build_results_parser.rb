require "multi_json"
require "ostruct"

module Bamboozled

  module BuildResultsParser

    def self.parse(json)
      MultiJson.load(json).fetch("results").fetch("result").map do |result|
        OpenStruct.new.tap do |build_result|
          build_result.key = result.fetch("key")
          build_result.status = result.fetch("state").downcase.to_sym
        end
      end
    end

  end

end
