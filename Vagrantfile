#require 'puppet'
#require 'vagrant-env'
#require 'vagrant-hostmanager'
#require 'vagrant-puppet-install'
#require 'vagrant-share'
#require 'vagrant-vbguest'

$hostnamepuppetserver = "xpuakhaw0014t3.kyiv.epam.com"
$ipaddresspuppetserver = "192.168.99.103"
$hostnamepuppetagent = "xpuakhaw0014t4.kyiv.epam.com"
$ipaddresspuppetagent = "192.168.99.104"
Vagrant.configure(2) do |config|
  config.vm.box = "centos/7"
  config.vm.synced_folder "templates", "/tmp/vagrant-puppet/templates"
  config.vm.define "puppetserver" do |puppetserver|
    puppetserver.vm.hostname = $hostnamepuppetserver
    puppetserver.vm.network "private_network", ip: $ipaddresspuppetserver
    puppetserver.vm.provider "virtualbox" do |vb|
      vb.name = "puppetserver"
      vb.cpus = 2
      vb.memory = "3096"
    end
  puppetserver.vm.provision "shell", :inline => <<-SHELL
    rpm -ivh https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm
    yum update
    yum -y install puppetserver ntpdate
    timedatectl set-timezone Europe/Kiev
    ntpdate 0.ua.pool.ntp.org
    echo "*.kyiv.epam.com" >> /etc/puppetlabs/puppet/autosign.conf
    echo """
dns_alt_names = #{$hostnamepuppetserver},server
autosign = /etc/puppetlabs/puppet/autosign.conf
[main]
certname = #{$hostnamepuppetserver}
server = #{$hostnamepuppetserver}
environment = production
runinterval = 2m
""" >> /etc/puppetlabs/puppet/puppet.conf
systemctl start puppetserver
systemctl enable puppetserver
/opt/puppetlabs/bin/puppet module install puppetlabs-ntp --version 6.3.0
SHELL
#  ntp.vm.synced_folder ".", "/etc/puppetlabs/modules"
  puppetserver.vm.provision :puppet do |puppet|
    puppet.manifests_path = "manifests"
    puppet.manifest_file = "default.pp"
    puppet.module_path  = "modules"
    # puppet.facter = {
    #      "customfact1" => "value1",
    #      "customfact2" => "value2"
    # }
    puppet.options = "--verbose --debug"
  end
  end
  ###################################################
  config.vm.define "puppetagent" do |puppetagent|
    puppetagent.vm.hostname = $hostnamepuppetagent
    puppetagent.vm.network "private_network", ip: $ipaddresspuppetagent
    puppetagent.vm.provider :virtualbox do |agent|
      agent.name = "PuppetAgent1"
      agent.memory = 1024
      agent.cpus = 2
    end
    puppetagent.vm.provision "shell", inline: <<-SHELL
      yum update
      yum install -y ntpdate mc
      timedatectl set-timezone Europe/Kiev
      ntpdate 0.ua.pool.ntp.org
      rpm -ivh https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm
      yum -y install puppet-agent
      echo "#{$ipaddresspuppetserver} #{$hostnamepuppetserver}" >> /etc/hosts
      if  grep -Fxq "[main]" /etc/puppetlabs/puppet/puppet.conf
      then
      echo "Already configured"
      else
      echo """
[main]
certname = #{puppetagent.vm.hostname}
server = #{$hostnamepuppetserver}
environment = production
runinterval = 2m
""" >> /etc/puppetlabs/puppet/puppet.conf
      fi
      /opt/puppetlabs/bin/puppet resource service puppet ensure=running enable=true
#      /opt/puppetlabs/bin/puppet agent --test
SHELL
  end
end
