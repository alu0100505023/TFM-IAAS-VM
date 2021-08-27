require 'yaml'

module Cookbooks

  class Ansible

    def spark_cookbook(user, pool)
      java_spark(user, pool)
      jupyter_master(user, pool)
      scala_miniconda(user, pool)
      spark_masters_slaves(user, pool)
      copy_idrsa_master_slaves(user, pool)
      spark_masters(user, pool)
      run_spark(user, pool)
    end

    def java_spark(user, pool)
      `#{ANSIBLE_PLAYBOOK} -i #{ANSIBLE_USERS}#{user}/#{pool.id}/cluster-hosts #{ANSIBLE_USERS}#{user}/#{pool.id}/java_spark.yml`
    end

    def jupyter_master(user, pool)
      `#{ANSIBLE_PLAYBOOK} -i #{ANSIBLE_USERS}#{user}/#{pool.id}/cluster-hosts #{ANSIBLE_USERS}#{user}/#{pool.id}/jupyter_master.yml`
    end

    def scala_miniconda(user, pool)
      `#{ANSIBLE_PLAYBOOK} -i #{ANSIBLE_USERS}#{user}/#{pool.id}/cluster-hosts #{ANSIBLE_USERS}#{user}/#{pool.id}/scala_miniconda.yml`
    end

    def spark_masters_slaves(user, pool)
      `#{ANSIBLE_PLAYBOOK} -i #{ANSIBLE_USERS}#{user}/#{pool.id}/cluster-hosts #{ANSIBLE_USERS}#{user}/#{pool.id}/spark_masters_slaves.yml`
    end

    def copy_idrsa_master_slaves(user, pool)
      `#{ANSIBLE_PLAYBOOK} -i #{ANSIBLE_USERS}#{user}/#{pool.id}/cluster-hosts #{ANSIBLE_USERS}#{user}/#{pool.id}/spark-copy-idrsa.yml`
    end

    def spark_masters(user, pool)
      `#{ANSIBLE_PLAYBOOK} -i #{ANSIBLE_USERS}#{user}/#{pool.id}/cluster-hosts #{ANSIBLE_USERS}#{user}/#{pool.id}/run-spark.yml`
    end

    def run_spark(user, pool)
      `#{ANSIBLE_PLAYBOOK} -i #{ANSIBLE_USERS}#{user}/#{pool.id}/cluster-hosts #{ANSIBLE_USERS}#{user}/#{pool.id}/spark_masters.yml`
      "/usr/bin/ansible-playbook -i /home/usuario/ansible/users/example@gmail.com/9/cluster-hosts /home/usuario/ansible/users/example@gmail.com/9/run-spark.yml"
    end

    def get_external_ip()

    end


  end

end