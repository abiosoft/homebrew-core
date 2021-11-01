class Telegraf < Formula
  desc "Server-level metric gathering agent for InfluxDB"
  homepage "https://www.influxdata.com/"
  url "https://github.com/influxdata/telegraf/archive/v1.20.3.tar.gz"
  sha256 "cf8fd4d38970648281101e8a71b1a48c5765c8aaa9d67619c00272c9192e9057"
  license "MIT"
  head "https://github.com/influxdata/telegraf.git", branch: "master"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_monterey: "7d430403d0554b840fa56a6d1d716fa9aa4015fa569604c3a632ca07ef5cc6a1"
    sha256 cellar: :any_skip_relocation, arm64_big_sur:  "489a39af34f88d5c8f50a99cbcd059bee172b20b0313a483f97827993ce809e1"
    sha256 cellar: :any_skip_relocation, monterey:       "9600b01770417080eb0113292fa272d4bd897f7a47570ae1d257547e28242e4e"
    sha256 cellar: :any_skip_relocation, big_sur:        "fa7758f7e9ff4f1c9711d7bc759ec87d823e0724cc50d27d7c5cdddc24cc8301"
    sha256 cellar: :any_skip_relocation, catalina:       "8667728d8428ca082f0eb49209a46df40e090dcca50663626c15839bf83f92f1"
    sha256 cellar: :any_skip_relocation, mojave:         "eeaf93fdddb62667a3d79ebfc31863154f10ccd1c6298feee1e5b258d2d857cd"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "3096181c311720c730443b60b1393aff05909de2d055e9e7ced4cb8493aa77ff"
  end

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args, "-ldflags", "-X main.version=#{version}", "./cmd/telegraf"
    etc.install "etc/telegraf.conf" => "telegraf.conf"
  end

  def post_install
    # Create directory for additional user configurations
    (etc/"telegraf.d").mkpath
  end

  service do
    run [opt_bin/"telegraf", "-config", etc/"telegraf.conf", "-config-directory", etc/"telegraf.d"]
    keep_alive true
    working_dir var
    log_path var/"log/telegraf.log"
    error_log_path var/"log/telegraf.log"
  end

  test do
    (testpath/"config.toml").write shell_output("#{bin}/telegraf -sample-config")
    system "#{bin}/telegraf", "-config", testpath/"config.toml", "-test",
           "-input-filter", "cpu:mem"
  end
end
