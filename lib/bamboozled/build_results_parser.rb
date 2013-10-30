require "multi_json"
require "values"

module Bamboozled

  module BuildResultsParser

    def self.parse(json)
      MultiJson.load(json).fetch("results").fetch("result").map do |result|
        BuildResult.new(result.fetch("key"))
      end
    end

    BuildResult = Value.new(:key)

  end

end
