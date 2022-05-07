# -*- mode: ruby -*-
# vi: set ft=ruby :

nodes = [
  { :hostname => 'k3-control',  :ip => '192.168.56.30', :ram => '1000', :cpus => '1' }, # Control Node
  { :hostname => 'k3-master-1', :ip => '192.168.56.31', :ram => '2000', :cpus => '2' }, # Master
  { :hostname => 'k3-worker-1', :ip => '192.168.56.32', :ram => '2000', :cpus => '2' }, # Worker 1
  { :hostname => 'k3-worker-2', :ip => '192.168.56.33', :ram => '2000', :cpus => '2' }  # Worker 2
]


Vagrant.configure("2") do |config|

  # Provision swarm nodes
  nodes.each do |node|
    config.vm.define node[:hostname] do |nodeconfig|
      
      nodeconfig.vm.box = "ubuntu/jammy64"
      nodeconfig.vm.box_version = "20220423.0.0"
      
      nodeconfig.vm.hostname = node[:hostname] + ".box"
      nodeconfig.vm.network :private_network, ip: node[:ip]
          
      memory = node[:ram]
      cpus = node[:cpus]
      
      nodeconfig.ssh.insert_key = FALSE
      
      nodeconfig.vm.provider "virtualbox" do |vb|
        vb.memory = memory
        vb.cpus = cpus
      end
      

      if node[:hostname] == "k3-master-1"

            # Kubernetes API Access for server
            # nodeconfig.vm.network "forwarded_port", guest: 6443, host: 6443

            # forward port range used for k3s services to host - probably want to figure out how to use traefik
            for p in 30000..30100
                nodeconfig.vm.network "forwarded_port", guest: p, host: p, protocol: "tcp"
            end
      end 

      # parallel ansible trick - runs when you hit the last vm, but scoped to all
      if node[:hostname] == 'k3-worker-2'
	      nodeconfig.vm.provision "ansible" do |ansible|   
            
            # Disable default limit to connect to all the machines        
            ansible.limit = "all" 
		    ansible.playbook = "provisioning/playbook.yml"  
		    ansible.inventory_path = "provisioning/hosts"
      
        end # ansible
      end # last node if
    end  # nodeconfig
  end # each node
end # config
