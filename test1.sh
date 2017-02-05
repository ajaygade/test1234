me: Create a sandbox instance
  hosts: localhost
  gather_facts: False
  vars:
    key_name: my_keypair
    instance_type: m1.small
    security_group: my_securitygroup
    image: my_ami_id
    region: us-east-1
  tasks:
    - name: Launch instance
      ec2:
         key_name: "{{ keypair }}"
         group: "{{ security_group }}"
         instance_type: "{{ instance_type }}"
         image: "{{ image }}"
         wait: true
         region: "{{ region }}"
         vpc_subnet_id: subnet-29e63245
         assign_public_ip: yes
      register: ec2

    - name: Add new instance to host group
      add_host:
        hostname: "{{ item.public_ip }}"
        groupname: launched
      with_items: "{{ ec2.instances }}"

    - name: Wait for SSH to come up
      wait_for:
        host: "{{ item.public_dns_name }}"
        port: 22
        delay: 60
        timeout: 320
        state: started
      with_items: "{{ ec2.instances }}"

- name: Configure instance(s)
  hosts: launched
  become: True
  gather_facts: True
  roles:
    - my_awesome_role
    - my_awesome_test

- name: Terminate instances
  hosts: localhost
  connection: local
  tasks:
    - name: Terminate instances that were previously launched
      ec2:
        state: 'absent'
        instance_ids: '{{ ec2.instance_ids }}'

# Start a few existing instances, run some tasks
# and stop the instances

- name: Start sandbox instances
  hosts: localhost
  gather_facts: false
  connection: local
  vars:
    instance_ids:
      - 'i-xxxxxx'
      - 'i-xxxxxx'
      - 'i-xxxxxx'
    region: us-east-1
  tasks:
    - name: Start the sandbox instances
      ec2:
        instance_ids: '{{ instance_ids }}'
        region: '{{ region }}'
        state: running
        wait: True
        vpc_subnet_id: subnet-29e63245
        assign_public_ip: yes
  roles:
    - do_neat_stuff
    - do_more_neat_stuff

- name: Stop sandbox instances
  hosts: localhost
  gather_facts: false
  connection: local
  vars:
    instance_ids:
      - 'i-xxxxxx'
      - 'i-xxxxxx'
      - 'i-xxxxxx'
    region: us-east-1
  tasks:
    - name: Stop the sandbox instances
      ec2:
        instance_ids: '{{ instance_ids }}'
        region: '{{ region }}'
        state: stopped
        wait: True
        vpc_subnet_id: subnet-29e63245
        assign_public_ip: yes
