module Services

  class Ansible

    def basicVM
      #@vm=`/etc/ansible ansible-playbook vm-basic.yml`
      begin
        @vm=`/etc/ansible ansible -m ping all`
      rescue
        @vm="Server not found"
      end
    end


  end

end
