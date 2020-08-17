module Services

  class Ansible

    def basicVM
      #@vm=`/etc/ansible ansible-playbook vm-basic.yml`
      @vm=`/etc/ansible ansible -m ping all`
    end

  end

end
