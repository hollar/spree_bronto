module Spree
  class BrontoConfiguration

    def self.account
      bronto_yml=File.join(Rails.root,'config/bronto.yml')
      if File.exist? bronto_yml
        bronto_yml=ERB.new(IO.read bronto_yml).result
        YAML.load(bronto_yml)
      end
    end
  end
end
