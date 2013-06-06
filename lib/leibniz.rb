require "leibniz/version"

require 'kitchen'
require 'forwardable'

module Kitchen
  class Config
    def new_instance_logger(index)
      level = Util.to_logger_level(self.log_level)

      lambda do |name|
        logfile = File.join(log_root, "#{name}.log")

        Logger.new(:logdev => logfile,
          :level => level, :progname => name)
      end
    end
  end
end

module Leibniz

  def self.build(specification)
    loader = KitchenLoader.new(specification)
    config = Kitchen::Config.new(:loader => loader)
    Infrastructure.new(config.instances)
  end

  class Infrastructure

    def initialize(instances)
      @nodes = Hash.new
      instances.each do |instance|
        @nodes[instance.name.sub(/^leibniz-/, '')] = Node.new(instance)
      end
    end

    def [](name)
      @nodes[name]
    end

    def converge
      @nodes.each_pair { |name, node| node.converge }
    end

    def destroy
      @nodes.each_pair { |name, node| node.destroy }
    end

  end

  class Node

    extend Forwardable

    def_delegators :@instance, :create, :converge, :setup, :verify, :destroy, :test

    def initialize(instance)
      @instance = instance
    end
 
    def ip
      instance.driver[:ipaddress]
    end

    private

    attr_reader :instance
  end

  class KitchenLoader

    def initialize(specification)
      @last_octet = 11
      @platforms = specification.hashes.map do |spec|
        create_platform(spec)
      end
    end

    def read
      {
        :driver_plugin => "vagrant",
        :platforms => platforms,
        :suites => [ { :name => "leibniz", :run_list => [] } ]
      }
    end

    private

    attr_reader :platforms

    def create_platform(spec)
      distro = "#{spec['Operating System']}-#{spec['Version']}"
      ipaddress = "10.2.3.#{@last_octet}"
      @last_octet += 1
      platform = Hash.new
      platform[:name] = spec["Server Name"]
      platform[:driver_config] = Hash.new
      platform[:driver_config][:box] = "opscode-#{distro}"
      platform[:driver_config][:box_url] = "https://opscode-vm.s3.amazonaws.com/vagrant/opscode_#{distro}_provisionerless.box"
      platform[:driver_config][:network] = [["private_network", {:ip => ipaddress}]]
      platform[:driver_config][:require_chef_omnibus] = spec["Chef Version"] || true
      platform[:driver_config][:ipaddress] = ipaddress
      platform[:run_list] = Array(spec["Run List"])
      platform
    end
  end
end

