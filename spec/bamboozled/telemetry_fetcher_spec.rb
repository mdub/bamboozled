require "bamboozled/telemetry_fetcher"
require "sham_rack"

describe Bamboozled::TelemetryFetcher do

  let(:telemetry_html) do
    <<-HTML
      <!DOCTYPE html>
      <html lang="en">
      <body>
      <div id="wallboard">

            <div class="build">
                <div class="result Successful">
                    <a href="/browse/ALL-GOOD" class="plan-name">It's all good</a>
                    <div class="build-details">
                        <div class="project-name">Fairytales</div>
                        <time datetime="2013-02-21T09:37:51">2 weeks ago</time>
                    </div>
                </div>
            </div>

            <div class="build">
                <div class="result Failed">
                    <a href="/browse/NOT-SO-GOOD" class="plan-name">Not so good</a>
                    <div class="build-details">
                        <div class="project-name">Fairytales</div>
                        <time datetime="2013-03-07T10:48:30">6 minutes ago</time>
                    </div>
                </div>
            </div>

            <div class="build">
                <div class="result Unknown">
                    <a href="/browse/HUH" class="plan-name">Who knows</a>
                    <div class="build-details">
                        <div class="project-name">Fairytales</div>
                        <time datetime="2013-02-04T22:07:18">1 month ago</time>
                    </div>
                </div>
            </div>

            <div class="build">
                <div class="result Unknown">
                    <a href="/browse/NOW-BUILDING" class="plan-name">Now building</a>
                    <div class="build-details">
                        <div id="NOW-BUILDING-indicator" class="indicator building"></div>
                        <time datetime="2013-02-04T22:07:18">1 month ago</time>
                        <div class="project-name">Fairytales</div>
                    </div>
                </div>
            </div>

      </div>
      </body>
      </html>
    HTML
  end

  let(:bamboo_host) { "bamboo.myco.com" }
  let(:bamboo_url) { "http://" + bamboo_host }
  let(:telemetry_url) { bamboo_url + "/telemetry.action" }

  before do
    sham_bamboo = ShamRack.at(bamboo_host).stub
    sham_bamboo.register_resource("/telemetry.action", telemetry_html, "text/html")
  end

  after do
    ShamRack.unmount_all
  end

  let(:fetcher) { Bamboozled::TelemetryFetcher.new(telemetry_url) }

  describe "#fetch" do

    let(:result) do
      fetcher.fetch
    end

    it "returns info for each listed build" do
      result.should have(4).elements
    end

    it "returns the name of each build" do
      result.map(&:name).should eq [
        "Fairytales - It's all good",
        "Fairytales - Not so good",
        "Fairytales - Who knows",
        "Fairytales - Now building"
      ]
    end

    it "returns lastBuildTime for each build" do
      result.first.last_build_time.should eq("2013-02-21T09:37:51")
    end

    it "returns the fully-qualified URL of each build" do
      result.first.url.should eq "#{bamboo_url}/browse/ALL-GOOD"
    end

    def project_info_for(name)
      result.detect do |info|
        info.name == "Fairytales - #{name}"
      end || raise("Can't find #{name.inspect}")
    end

    context "for a successful build" do
      subject { project_info_for("It's all good") }
      its(:status) { should eq("Success") }
    end

    context "for a failure build" do
      subject { project_info_for("Not so good") }
      its(:status) { should eq("Failure") }
    end

    context "for a disabled build" do
      subject { project_info_for("Who knows") }
      its(:status) { should eq("Unknown") }
    end

    context "for an idle build" do
      subject { project_info_for("It's all good") }
      its(:activity) { should eq("Sleeping") }
    end

    context "for an active build" do
      subject { project_info_for("Now building") }
      its(:activity) { should eq("Building") }
    end

  end

end
