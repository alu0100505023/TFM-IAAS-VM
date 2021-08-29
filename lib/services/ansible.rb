require 'yaml'
require 'net/ping'

module Services

  class Ansible

    def basicVM
      #@vm=`/etc/ansible ansible-playbook vm-basic.yml`
      begin
        @vm = `ansible-playbook #{ANSIBLE_TEMPLATES}vm-testing.yml`
      rescue
        @vm = "Server not found"
      end
    end

    def format_variable_yml
      format = {"vm" => [{"name" => "TDM-SLAVE1-alu0100505023", "ip" => "192.168.151.20"},
                          {"name" => "TDM-MASTER-alu0100505023", "ip" => "192.168.151.21"},
                          {"name" => "TDM-SLAVE2-alu0100505023", "ip" => "192.168.151.22"}]}
      Rails.logger.info format
      Rails.logger.info "\n"
      Rails.logger.info format.to_yaml
    end

    def run_create_machines(user, pool)
      vm_output = "#{ANSIBLE_USERS}/#{user}/#{pool.id}/logs/log"
      cookbooks = Services::Cookbooks.new
      machines = Machine.where(:pool => @pool)
      Rails.logger.info pool.pool_type

      if pool.pool_type == "cluster"
        #ansible_spark_eth_variable(user, pool, machines)
        #
        #
        #

        #Thread.new do
        # execution_context = Rails.application.executor.run!
          # your code here
        # exec("sudo #{ANSIBLE_PLAYBOOK} #{ANSIBLE_USERS}/#{user}/#{pool.id}/create-vm.yml >> #{vm_output}; sleep 10; #{ANSIBLE_PLAYBOOK} -i #{ANSIBLE_USERS}/#{user}/#{pool.id}/cluster-hosts  #{ANSIBLE_USERS}/#{user}/#{pool.id}/get-external-ip.yml >> #{vm_output}")
        # get_external_ip(user, pool, machines)
        # ansible_spark_eth_variable(user, pool, machines)
        # cookbooks.spark_cookbook(user, pool)
        #ensure
        # execution_context.complete! if execution_context
        #end
        #Thread.new do
        # exec("sudo #{ANSIBLE_PLAYBOOK} #{ANSIBLE_USERS}/#{user}/#{pool.id}/create-vm.yml >> #{vm_output}; sleep 10; #{ANSIBLE_PLAYBOOK} -i #{ANSIBLE_USERS}/#{user}/#{pool.id}/cluster-hosts  #{ANSIBLE_USERS}/#{user}/#{pool.id}/get-external-ip.yml >> #{vm_output}")
        # get_external_ip(user, pool, machines)
        # ansible_spark_eth_variable(user, pool, machines)
        # cookbooks.spark_cookbook(user, pool)
        #end

        fork do
          exec("sudo #{ANSIBLE_PLAYBOOK} #{ANSIBLE_USERS}/#{user}/#{pool.id}/create-vm.yml >> #{vm_output}; sleep 10; #{ANSIBLE_PLAYBOOK} -i #{ANSIBLE_USERS}/#{user}/#{pool.id}/cluster-hosts  #{ANSIBLE_USERS}/#{user}/#{pool.id}/get-external-ip.yml >> #{vm_output}")
          get_external_ip(user, pool, machines)
          ansible_spark_eth_variable(user, pool, machines)
          cookbooks.spark_cookbook(user, pool)
          exit
        end
      else
        fork do
          exec("sudo #{ANSIBLE_PLAYBOOK} #{ANSIBLE_USERS}/#{user}/#{pool.id}/create-vm.yml >> #{vm_output}; sleep 10; #{ANSIBLE_PLAYBOOK} -i #{ANSIBLE_USERS}/#{user}/#{pool.id}/cluster-hosts  #{ANSIBLE_USERS}/#{user}/#{pool.id}/get-external-ip.yml >> #{vm_output}")
          exit
        end
      end
    end

    def get_output(user, pool)
      vm_output = "#{ANSIBLE_USERS}/#{user}/#{pool.id}/logs/log"
      Rails.logger.info vm_output
      if File.exist?(vm_output)
        return File.read(vm_output)
      else
        return "Ansible Server Not Found"
      end
    end

    def create_user_directory(user)
      unless File.exist?("#{ANSIBLE_USERS}#{user}")
        Rails.logger.info "#{ANSIBLE_USERS}#{user}"
        `mkdir #{ANSIBLE_USERS}#{user}`
        output = `ls #{ANSIBLE_USERS}#{user}`
        Rails.logger.info output
      end
      "#{ANSIBLE_USERS}#{user}"
    end

    def create_pool_directory(user, pool)
      unless File.exist?("#{ANSIBLE_USERS}#{user}/#{pool.id}")
        `mkdir #{ANSIBLE_USERS}#{user}/#{pool.id}`
      end
      `mkdir #{ANSIBLE_USERS}#{user}/#{pool.id}/external-ip`
      `mkdir #{ANSIBLE_USERS}#{user}/#{pool.id}/logs`
      `touch #{ANSIBLE_USERS}#{user}/#{pool.id}/cluster-hosts`
      `cp #{ANSIBLE_TEMPLATES}login-vars.yml #{ANSIBLE_USERS}#{user}/#{pool.id}`
      `cp -r #{ANSIBLE_TEMPLATES}vm/. #{ANSIBLE_USERS}#{user}/#{pool.id}/`
      `cp -r #{ANSIBLE_TEMPLATES}spark/. #{ANSIBLE_USERS}#{user}/#{pool.id}/`
    end

    def write_vars_template(user,pool,data)
      unless File.exist?("#{ANSIBLE_USERS}#{user}/#{pool.id}/vm-vars.yml")
        `touch #{ANSIBLE_USERS}#{user}/#{pool.id}/vm-vars.yml`
      end
      File.open("#{ANSIBLE_USERS}#{user}/#{pool.id}/vm-vars.yml", "w") { |file| file.write(data.to_yaml) }
    end

    def write_spark_vars_template(user, pool, data)
      unless File.exist?("#{ANSIBLE_USERS}#{user}/#{pool.id}/ext_ip_vars.yml")
        `touch #{ANSIBLE_USERS}#{user}/#{pool.id}/ext_ip_vars.yml`
      end
      File.open("#{ANSIBLE_USERS}#{user}/#{pool.id}/ext_ip_vars.yml", "w") { |file| file.write(data.to_yaml) }
    end

    def ansible_spark_eth_variable(user, pool, machines)
      vm = {"wn_eth" => [], "slaves_eth"=> []}
      storage_domain = pool.storage_domain
      machines.each_with_index do |machine, index|
        if machine.machine_type == "master"
          vm["spark_master"] == machine.ip
        end
        vm["wn_eth"].push{{"name" => "#{storage_domain}-#{machine.machine_type}-#{index}", "ip" => machine.external_ip}}
        if machine.machine_type == "slave"
          vm["slaves_eth"].push{{"name" => "#{storage_domain}-#{machine.machine_type}-#{index}", "ip" => machine.external_ip}}
        end
      end
      Rails.logger.info vm.to_yaml
      write_spark_vars_template(pool.post.email,pool,vm)
    end

    def ansible_variable_yml(user, pool, machines)
      master = pool.masters
      slaves = pool.slaves
      storage_domain = pool.storage_domain
      pool_type = pool.pool_type
      template_machine = Machine.find_by(pool: pool)

      ips_master = get_ip(master)
      ips_slaves = get_ip(slaves)

      vm = {"wn" => []}

      vm["storage-domain"] = pool.storage_domain
      vm["os"] = pool.template
      vm["vm_username"] = template_machine.username
      vm["vm_password"] = template_machine.password
      vm["disk"] = template_machine.disk
      vm["ram"] = template_machine.ram
      vm["cluster"] = pool.cluster
      vm["cpu"] = template_machine.cpu


      machines.each_with_index do |machine, index|
        vm["wn"].push({"name" => "#{storage_domain}-pool#{pool.id}-#{machine.machine_type}-#{index}", "ip" => machine.ip})
        Machine.find_by(id: machine.id).update(name: "#{storage_domain}-pool#{pool.id}-#{machine.machine_type}-#{index}")
      end
      write_vars_template(pool.post.email,pool,vm)


      Rails.logger.info vm
      Rails.logger.info "\n"
      Rails.logger.info vm.to_yaml
      hosts_inventory(user, pool, machines)
    end

    def hosts_inventory(user, pool, machines)
      masters = []
      masters_slaves = []
      slaves = []

      machines.each do |machine|
        masters_slaves.push(machine.ip)
        if machine.machine_type == "master"
          masters.push(machine.ip)
        end

        if machine.machine_type == "slave"
          slaves.push(machine.ip)
        end
      end

      open("#{ANSIBLE_USERS}#{user}/#{pool.id}/cluster-hosts", 'a') { |f|
        f << "[masters-slaves]\n"
        masters_slaves.each do |machine|
          f << "#{machine}\n"
        end
        f << "\n"
        f << "[masters]\n"
        masters.each do |machine|
          f << "#{machine}\n"
        end
        f << "\n"
        f << "[slaves]\n"
        slaves.each do |machine|
          f << "#{machine}\n"
        end
      }
    end

    def get_ip(machines)
      #some stuff to return ip availables
      #
      return ["192.168.151.21","192.168.151.22","192.168.151.23"]
    end
    require 'net/ping'

    def up?(host)
      check = Net::Ping::External.new(host)
      check.ping?
    end

    def get_external_ip(user, pool, machines)
      machines.each do |machine|
        if machine.external_ip == nil
          if File.exist?("#{ANSIBLE_USERS}#{user}/#{pool.id}/external-ip/#{machine.ip}")
            ip = File.read("#{ANSIBLE_USERS}#{user}/#{pool.id}/external-ip/#{machine.ip}")
            Machine.find_by(id: machine.id).update(external_ip: ip)
          end
        end
      end
    end
    #disks:
    #  - name: data
    #    id: myvm_disk_prueba*
    #    size: 10GiB
    #    interface: virtio
#    format: cow
#  with_items: "{{ wn }}"
  end

end
