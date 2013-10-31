require "time"
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
          result.started_at = parse_timestamp(result_data["buildStartedTime"])
          result.finished_at = parse_timestamp(result_data["buildCompletedTime"])
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

    def parse_timestamp(input)
      return nil if input == nil
      return nil if input == ""
      Time.parse(input)
    end

  end

end
