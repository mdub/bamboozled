require "multi_json"
require "ostruct"

module Bamboozled

  module BuildResultsParser

    def self.parse(json)
      MultiJson.load(json).fetch("results").fetch("result").map do |result_data|
        OpenStruct.new.tap do |result|
          result.key = result_data.fetch("key")
          result.status = result_data.fetch("state").downcase.to_sym
          result.stages = result_data.fetch("stages").fetch("stage").map do |stage_data|
            OpenStruct.new.tap do |stage|
              stage.name = stage_data.fetch("name")
              stage.status = stage_data.fetch("state").downcase.to_sym
            end
          end
        end
      end
    end

  end

end
