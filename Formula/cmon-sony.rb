class CmonSony < Formula
  desc "Turn Sony headphone play/pause into universal mute toggle"
  homepage "https://github.com/salujayatharth/cmon-sony"
  url "https://github.com/salujayatharth/cmon-sony/archive/refs/tags/v1.1.0.tar.gz"
  sha256 "8e7da3fc4240a4c0ed2f56fd933172c67d3f092aec3511c8962465508780e0c9"
  license "MIT"

  depends_on :macos
  depends_on "python@3.12"

  resource "pyobjc-core" do
    url "https://files.pythonhosted.org/packages/44/70/becb7c8cba5340869c6e5d18f14e651f3d03a6da94b270d97986543a8c2a/pyobjc_core-10.3.2.tar.gz"
    sha256 "a3edf9a5e992c5a41bec1ff68ce98912ff71d0adbfc830308343167b96a3622a"
  end

  resource "pyobjc-framework-Cocoa" do
    url "https://files.pythonhosted.org/packages/d5/7f/88c81da99fd46b8afe3f284d89ad241a91ee62a0cef45e24a2e6e29d9114/pyobjc_framework_cocoa-10.3.2.tar.gz"
    sha256 "572c67f77cb27d5fd7fb4e4c9f6d2a9ec7f72a506db9a7e8d17c1332a2fc8015"
  end

  resource "pyobjc-framework-MediaPlayer" do
    url "https://files.pythonhosted.org/packages/59/e6/ddd4c9f76dbd10e63a76a2addf400effdfe4e13ddc3db1e1f66ce62b8ab9/pyobjc_framework_mediaplayer-10.3.2.tar.gz"
    sha256 "b3693c65ea809f49f2695c362b0c19dc9a2d179cfb35f0c8c3ef864c81d21de3"
  end

  def install
    venv = virtualenv_create(libexec, "python3.12")
    venv.pip_install resources
    libexec.install "avrcp_daemon.py"

    (bin/"cmon-sony").write <<~EOS
      #!/bin/bash
      exec "#{libexec}/bin/python" "#{libexec}/avrcp_daemon.py" "$@"
    EOS
  end

  service do
    run [opt_bin/"cmon-sony"]
    keep_alive true
    log_path var/"log/cmon-sony.log"
    error_log_path var/"log/cmon-sony.log"
  end

  def caveats
    <<~EOS
      To start cmon-sony:
        brew services start cmon-sony

      You must grant Accessibility permission for Zoom mute to work:
        System Settings > Privacy & Security > Accessibility
        Enable the terminal app or add #{opt_bin}/cmon-sony
    EOS
  end

  test do
    assert_match "cmon-sony", shell_output("#{bin}/cmon-sony --help 2>&1", 2)
  end
end
