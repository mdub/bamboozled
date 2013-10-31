require "multi_json"
require "ostruct"

module Bamboozled

  module BuildResultsParser

    extend self

    def parse(json)
      MultiJson.load(json).fetch("results").fetch("result").map do |result_data|
        OpenStruct.new.tap do |result|
          result.key = result_data.fetch("key")
          result.number = result_data.fetch("number")
          result.status = extract_status(result_data)
          result.stages = result_data.fetch("stages").fetch("stage").map do |stage_data|
            OpenStruct.new.tap do |stage|
              stage.name = stage_data.fetch("name")
              stage.status = extract_status(stage_data)
            end
          end
        end
      end
    end

    def extract_status(thing_with_state)
      status = thing_with_state["lifeCycleState"]
      status = thing_with_state["state"] if status == "Finished"
      status.downcase.to_sym
    end

  end

end
