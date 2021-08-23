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
      #`sudo /usr/bin/ansible-playbook #{ANSIBLE_USERS}/#{user}/#{pool.id}/create-vm.yml`
      fork { exec("sudo /usr/bin/ansible-playbook #{ANSIBLE_USERS}/#{user}/#{pool.id}/create-vm.yml") }
      #system("sudo /usr/bin/ansible-playbook #{ANSIBLE_USERS}/#{user}/#{pool.id}/create-vm.yml")
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
        `cp #{ANSIBLE_TEMPLATES}login-vars.yml #{ANSIBLE_USERS}#{user}/#{pool.id}`
        `cp #{ANSIBLE_TEMPLATES}create-vm.yml #{ANSIBLE_USERS}#{user}/#{pool.id} `
      end
      `cp #{ANSIBLE_TEMPLATES}login-vars.yml #{ANSIBLE_USERS}#{user}/#{pool.id}`
      `cp #{ANSIBLE_TEMPLATES}create-vm.yml #{ANSIBLE_USERS}#{user}/#{pool.id} `
    end

    def write_vars_template(user,pool,data)
      unless File.exist?("#{ANSIBLE_USERS}#{user}/#{pool.id}/vm-vars.yml")
        `touch #{ANSIBLE_USERS}#{user}/#{pool.id}/vm-vars.yml`
      end
      File.open("#{ANSIBLE_USERS}#{user}/#{pool.id}/vm-vars.yml", "w") { |file| file.write(data.to_yaml) }
    end

    def ansible_variable_yml(pool, machines)
      master = pool.masters
      slaves = pool.slaves
      storage_domain = pool.storage_domain
      pool_type = pool.pool_type

      ips_master = get_ip(master)
      ips_slaves = get_ip(slaves)

      vm = {"wn" => []}

      if pool_type == "cluster"
        machines.each_with_index do |machine, index|
          vm["wn"].push({"name" => "#{storage_domain}-#{machine.machine_type}-#{index}", "ip" => machine.ip})
          #machine.update(:name => "#{storage_domain}-#{machine.machine_type}-#{index}")
          #machine.save!
          Machine.find_by(id machine.id).update(name: "#{storage_domain}-#{machine.machine_type}-#{index}")
        end

        #slaves.each do |vm|
        # vm["vm"].push({"name" => "#{storage_domain}-SLAVES-#{name}", "ip" => machine.ip})
        #end
      else
        machines.each_with_index do |machine, index|
          vm["wn"].push({"name" => "#{storage_domain}-pool#{pool.id}-#{machine.machine_type}-#{index}", "ip" => machine.ip})
          Machine.find_by(id: machine.id).update(name: "#{storage_domain}-pool#{pool.id}-#{machine.machine_type}-#{index}")
        end
        write_vars_template(pool.post.email,pool,vm)
      end

      Rails.logger.info vm
      Rails.logger.info "\n"
      Rails.logger.info vm.to_yaml
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

    #disks:
    #  - name: data
    #    id: myvm_disk_prueba*
    #    size: 10GiB
    #    interface: virtio
#    format: cow
#  with_items: "{{ wn }}"
  end

end
