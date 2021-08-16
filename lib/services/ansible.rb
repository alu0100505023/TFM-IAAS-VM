require 'yaml'

module Services

  class Ansible

    def basicVM
      #@vm=`/etc/ansible ansible-playbook vm-basic.yml`
      begin
        #@vm=`ansible -m ping all`
        @vm=`ansible-playbook /etc/ansible/vm-testing.yml`
      rescue
        @vm="Server not found"
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


    def ansible_variable_yml(pool)
      master = pool.master
      slaves = pool.slaves
      name = pool.name

      ips_master = get_ip(master)
      ips_slaves = get_ip(slaves)

      vm = {"vm" => []}

      master.each do |vm|
        vm["vm"].push({"name" => "TDM-MASTER-#{name}", "ip" => ips_master[vm]})
      end

      slaves.each do |vm|
        vm["vm"].push({"name" => "TDM-SLAVES-#{name}", "ip" => ips_slaves[vm]})
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

    #disks:
    #  - name: data
    #    id: myvm_disk_prueba*
    #    size: 10GiB
    #    interface: virtio
#    format: cow
#  with_items: "{{ wn }}"
  end

end
