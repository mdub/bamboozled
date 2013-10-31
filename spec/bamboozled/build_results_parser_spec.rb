require "bamboozled/build_results_parser"

describe Bamboozled::BuildResultsParser do

  def fixtures
    File.expand_path("../../fixtures", __FILE__)
  end

  def load_fixture(path)
    File.read("#{fixtures}/#{path}")
  end

  let(:results) { Bamboozled::BuildResultsParser.parse(results_json) }

  context "with results for a plan" do

    let(:results_json) { load_fixture("results-PROJECT-PLAN.json") }

    context "for each build" do

      it "extracts an entry" do
        expect(results.map(&:key)).to eq [
          "PROJECT-PLAN-12",
          "PROJECT-PLAN-11",
          "PROJECT-PLAN-10",
          "PROJECT-PLAN-9",
          "PROJECT-PLAN-8"
        ]
      end

      let(:first_result) { results.first }

      it "extracts the status" do
        expect(first_result.status).to eq(:failed)
      end

      it "extracts the number" do
        expect(first_result.number).to eq(12)
      end

      context "for each stage" do

        it "extracts an entry" do
          expect(first_result.stages.map(&:name)).to eq [
            "Aminate",
            "Certify Init",
            "Certify Warmup",
            "Certify Test",
            "Certify Tagging",
            "Publish",
            "Promote to Staging",
            "Promote to Production"
          ]
        end

        let(:first_result) { results.first }

        it "extracts the status" do
          expect(first_result.stages.map(&:status)).to eq [
            :successful,
            :successful,
            :successful,
            :failed,
            :notbuilt,
            :notbuilt,
            :notbuilt,
            :notbuilt
          ]
        end

      end

    end

  end

  describe ".extract_status" do

    def extract_status(lifecycle_state, state)
      input = {
        "state" => state,
        "lifeCycleState" => lifecycle_state
      }
      Bamboozled::BuildResultsParser.extract_status(input)
    end

    context "usually" do

      it "returns the lifeCycleState" do
        expect(extract_status("InProgress", "Unknown")).to eq(:inprogress)
        expect(extract_status("Pending", "Unknown")).to eq(:pending)
        expect(extract_status("NotBuilt", "Unknown")).to eq(:notbuilt)
      end

    end

    context "when build is Finished" do

      it "returns the state" do
        expect(extract_status("Finished", "Successful")).to eq(:successful)
        expect(extract_status("Finished", "Failed")).to eq(:failed)
      end

    end

  end

end
