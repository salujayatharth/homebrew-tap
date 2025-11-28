class CmonSony < Formula
  desc "Turn Sony headphone play/pause into universal mic mute toggle"
  homepage "https://github.com/salujayatharth/cmon-sony"
  url "https://github.com/salujayatharth/cmon-sony/archive/refs/tags/v1.2.0.tar.gz"
  sha256 "6acb4377e76db99e56182c5d81679ee21461cd7606207d027be5e5085ae40054"
  license "MIT"

  depends_on :macos
  depends_on "python"

  def install
    libexec.install "avrcp_daemon.py"

    (bin/"cmon-sony").write <<~EOS
      #!/bin/bash
      exec "#{HOMEBREW_PREFIX}/bin/python3" "#{libexec}/avrcp_daemon.py" "$@"
    EOS
  end

  def post_install
    system "#{HOMEBREW_PREFIX}/bin/pip3", "install", "--break-system-packages", "-q",
           "pyobjc-framework-MediaPlayer>=10.0"
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
    system "true"
  end
end
