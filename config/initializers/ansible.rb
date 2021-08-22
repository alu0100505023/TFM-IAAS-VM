ANSIBLE_CONFIG = YAML.load_file("#{Rails.root}/config/ansible.yml")
ANSIBLE_TEMPLATES = ANSIBLE_CONFIG["ansible"]["templates-path"]
ANSIBLE_USERS = ANSIBLE_CONFIG["ansible"]["users-path"]
ANSIBLE_PATH = ANSIBLE_CONFIG["ansible"]["default-path"]