module Services

  class MachinesController
    BASE_IP_START = '192.168.151.10'

    def get_last_ip
      last_machine = Machine.last
      if last_machine != nil
        return last_machine.ip
      else
        return BASE_IP_START
      end
    end

    def new_ip
      last_ip = get_last_ip
      ip_list = last_ip.split(".")
      subfix = ip_list.pop()
      subfix = (subfix.to_i + 1).to_s
      ip_list.push(subfix)
      new_ip = ip_list.join(".")
    end

    def create_machine(machine_params, ip, machine_type, pool)
      machine = Machine.create(:ip => ip, :cpu => machine_params["cpu"], :ram => machine_params["ram"], :disk => machine_params["disk"], :username => machine_params["username"],
                               :username => machine_params["password"], :machine_type => machine_type, :pool => pool)
    end

    def create_machine_pool(machine_params, pool_type, pool)

      if pool_type == "simple"

        (1 .. pool.slaves).each do |machine|
          create_machine(machine_params, new_ip, "simple", pool)
        end
      end

      if pool_type == "cluster"

      end
    end

  end
end