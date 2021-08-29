require 'yaml'

module Services

  class Cookbooks

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
      vm_output = "#{ANSIBLE_USERS}/#{user}/#{pool.id}/logs/log"
      exec("#{ANSIBLE_PLAYBOOK} -i #{ANSIBLE_USERS}#{user}/#{pool.id}/cluster-hosts #{ANSIBLE_USERS}#{user}/#{pool.id}/java_spark.yml` >> #{vm_output}")
    end

    def jupyter_master(user, pool)
      vm_output = "#{ANSIBLE_USERS}/#{user}/#{pool.id}/logs/log"
      exec("#{ANSIBLE_PLAYBOOK} -i #{ANSIBLE_USERS}#{user}/#{pool.id}/cluster-hosts #{ANSIBLE_USERS}#{user}/#{pool.id}/jupyter_master.yml >> #{vm_output}")
    end

    def scala_miniconda(user, pool)
      vm_output = "#{ANSIBLE_USERS}/#{user}/#{pool.id}/logs/log"
      exec("#{ANSIBLE_PLAYBOOK} -i #{ANSIBLE_USERS}#{user}/#{pool.id}/cluster-hosts #{ANSIBLE_USERS}#{user}/#{pool.id}/scala_miniconda.yml >> #{vm_output}")
    end

    def spark_masters_slaves(user, pool)
      vm_output = "#{ANSIBLE_USERS}/#{user}/#{pool.id}/logs/log"
      exec("#{ANSIBLE_PLAYBOOK} -i #{ANSIBLE_USERS}#{user}/#{pool.id}/cluster-hosts #{ANSIBLE_USERS}#{user}/#{pool.id}/spark_masters_slaves.yml >> #{vm_output}")
    end

    def copy_idrsa_master_slaves(user, pool)
      vm_output = "#{ANSIBLE_USERS}/#{user}/#{pool.id}/logs/log"
      exec("#{ANSIBLE_PLAYBOOK} -i #{ANSIBLE_USERS}#{user}/#{pool.id}/cluster-hosts #{ANSIBLE_USERS}#{user}/#{pool.id}/spark-copy-idrsa.yml >> #{vm_output}")
    end

    def spark_masters(user, pool)
      vm_output = "#{ANSIBLE_USERS}/#{user}/#{pool.id}/logs/log"
      exec("#{ANSIBLE_PLAYBOOK} -i #{ANSIBLE_USERS}#{user}/#{pool.id}/cluster-hosts #{ANSIBLE_USERS}#{user}/#{pool.id}/spark_masters.yml >> #{vm_output}")
    end

    def run_spark(user, pool)
      vm_output = "#{ANSIBLE_USERS}/#{user}/#{pool.id}/logs/log"
      exec("#{ANSIBLE_PLAYBOOK} -i #{ANSIBLE_USERS}#{user}/#{pool.id}/cluster-hosts #{ANSIBLE_USERS}#{user}/#{pool.id}/run-spark.yml >> #{vm_output}")
    end

    def get_external_ip(user, pool)
      Rails.logger.info ANSIBLE_CONFIG
      Rails.logger.info "#{ANSIBLE_PLAYBOOK} -i #{ANSIBLE_USERS}#{user}/#{pool.id}/cluster-hosts #{ANSIBLE_USERS}#{user}/#{pool.id}/get-external-ip.yml"
      `#{ANSIBLE_PLAYBOOK} -i #{ANSIBLE_USERS}#{user}/#{pool.id}/cluster-hosts #{ANSIBLE_USERS}#{user}/#{pool.id}/get-external-ip.yml`
    end


  end

end