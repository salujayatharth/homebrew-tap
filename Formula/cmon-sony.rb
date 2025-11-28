class CmonSony < Formula
  desc "Turn Sony headphone play/pause into universal mute toggle"
  homepage "https://github.com/salujayatharth/cmon-sony"
  url "https://github.com/salujayatharth/cmon-sony/archive/refs/tags/v1.1.0.tar.gz"
  sha256 "8e7da3fc4240a4c0ed2f56fd933172c67d3f092aec3511c8962465508780e0c9"
  license "MIT"

  depends_on :macos
  depends_on "python@3.12"

  def install
    venv = virtualenv_create(libexec, "python3.12")
    venv.pip_install "pyobjc-framework-MediaPlayer>=10.0"
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
