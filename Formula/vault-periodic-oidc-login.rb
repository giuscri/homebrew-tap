class VaultPeriodicOidcLogin < Formula
  desc "Run `vault login -method=oidc` periodically."
  homepage "github.com/giuscri/vault-periodic-oidc-login"
  version "0.0.2"
  license "MIT"

  if OS.mac? && Hardware::CPU.arm?
      url "https://github.com/giuscri/vault-periodic-oidc-login/releases/download/0.0.2/vault-periodic-oidc-login_0.0.2_darwin_arm64.tar.gz"
      sha256 "c04311aad266b2fb1816ea250a1d917dccc8adb8c92d7e8baef086d95d684f04"
  end

  def install
    bin.install "vault-periodic-oidc-login"
  end

  def post_install
    (etc/"vault-periodic-oidc-login").mkpath

    File.open(etc/"vault-periodic-oidc-login/config.yaml", "w") do |file|
      file.write <<~EOS
        # vault-periodic-oidc-login configuration file

        minTTL: 72h
        tokenPath: "$HOME/.vault-token"
        vaultAddr: https://vault.acme.com
      EOS
    end
  end

  test do
    system bin/"vault-periodic-oidc-login --help"
  end

  service do
    run [bin/"vault-periodic-oidc-login", "--config-file=#{etc}/vault-periodic-oidc-login/config.yaml"]
    run_type :interval
    interval 300
    environment_variables PATH: std_service_path_env
    log_path var/"log/vault-periodic-oidc-login.log"
    error_log_path var/"log/vault-periodic-oidc-login.log"
  end

  def caveats
    <<~EOS
      The service uses a configuration file that you must customize before running:
        #{etc}/vault-periodic-oidc-login/config.yaml
    EOS
  end
end
