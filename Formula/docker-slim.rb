class DockerSlim < Formula
  desc "Minify and secure Docker images"
  homepage "https://dockersl.im"
  url "https://github.com/docker-slim/docker-slim/archive/1.31.0.tar.gz"
  sha256 "1088437116f752203001ab21d355ee4b3f781d716a4068c4e3a13697520fc67c"
  license "Apache-2.0"

  bottle do
    cellar :any_skip_relocation
    sha256 "3d384fbdcff0c687e8fb6330c7557792657bb29ba51f1001a40117e3eef51b64" => :catalina
    sha256 "3d384fbdcff0c687e8fb6330c7557792657bb29ba51f1001a40117e3eef51b64" => :mojave
    sha256 "3d384fbdcff0c687e8fb6330c7557792657bb29ba51f1001a40117e3eef51b64" => :high_sierra
  end

  depends_on "go" => :build

  skip_clean "bin/docker-slim-sensor"

  def install
    ENV["CGO_ENABLED"] = "0"
    ldflags = "-s -w -X github.com/docker-slim/docker-slim/pkg/version.appVersionTag=#{version}"
    system "go", "build", "-trimpath", "-ldflags=#{ldflags}", "-o",
           bin/"docker-slim", "./cmd/docker-slim"

    # docker-slim-sensor is a Linux binary that is used within Docker
    # containers rather than directly on the macOS host.
    ENV["GOOS"] = "linux"
    system "go", "build", "-trimpath", "-ldflags=#{ldflags}", "-o",
           bin/"docker-slim-sensor", "./cmd/docker-slim-sensor"
    (bin/"docker-slim-sensor").chmod 0555
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/docker-slim --version")
    system "test", "-x", bin/"docker-slim-sensor"
  end
end
