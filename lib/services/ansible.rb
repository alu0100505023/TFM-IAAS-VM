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


  end

end
