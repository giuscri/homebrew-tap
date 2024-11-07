class VaultPeriodicOidcLogin < Formula
  desc "Run `vault login -method=oidc` periodically."
  homepage "github.com/giuscri/vault-periodic-oidc-login"
  version "0.0.3"
  license "MIT"

  if OS.mac? && Hardware::CPU.arm?
      url "https://github.com/giuscri/vault-periodic-oidc-login/releases/download/0.0.3/vault-periodic-oidc-login_0.0.3_darwin_arm64.tar.gz"
      sha256 "4f797d82dfc23c797ce7485c6400a1c28fcab37e20c8942ba398aa62dbc36580"
  end
  if OS.mac? && Hardware::CPU.intel?
      url "https://github.com/giuscri/vault-periodic-oidc-login/releases/download/0.0.3/vault-periodic-oidc-login_0.0.3_darwin_amd64.tar.gz"
      sha256 "7bd906118ada90a2a6cfe867f7ba644da1bf5714a53ffadfeb29552f49d5339e"
  end

  def install
    bin.install "vault-periodic-oidc-login"
  end

  def post_install
    (etc/"vault-periodic-oidc-login").mkpath

    unless File.exist?(config_file)
      File.open(etc/"vault-periodic-oidc-login/config.yaml", "w") do |file|
        file.write <<~EOS
          # vault-periodic-oidc-login configuration file

          minTTL: 72h
          tokenPath: "$HOME/.vault-token"
          vaultAddr: https://vault.acme.com
        EOS
      end
    end
  end

  test do
    system bin/"vault-periodic-oidc-login --help"
  end

  service do
    run [bin/"vault-periodic-oidc-login", "--config-file=#{etc}/vault-periodic-oidc-login/config.yaml"]
    environment_variables PATH: std_service_path_env
    log_path var/"log/vault-periodic-oidc-login.log"
    error_log_path var/"log/vault-periodic-oidc-login.log"

    # from "man launchd.plist":
    # "Unlike cron which skips job invocations when the computer is asleep, launchd
    # will start the job the next time the computer wakes up. If multiple
    # intervals transpire before the computer is woken, those events will be
    # coalesced into one event upon wake from sleep."
    run_type :cron
    cron "@hourly"
  end

  def caveats
    <<~EOS
      The service uses a configuration file that you must customize before running:
        #{etc}/vault-periodic-oidc-login/config.yaml
    EOS
  end
end
