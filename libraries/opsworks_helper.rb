
require 'chef/node'

class Chef::ResourceDefinitionList::OpsWorksHelper

  # true if we're on opsworks, false otherwise
  def self.opsworks?(node)
    node['opsworks'] != nil
  end

  # return Chef Nodes for this replicaset / layer
  def self.replicaset_members(node)
    members = []
    # FIXME -> this is bad, we're assuming replicaset instances use a single layer
    replicaset_layer_slug_name = node['opsworks']['instance']['layers'].first
    instances = node['opsworks']['layers'][replicaset_layer_slug_name]['instances']
    instances.each do |name, instance|
      if instance['status'] == 'online'
        member = Chef::Node.new
        member.name(name)
        member.default['fqdn'] = instance['private_dns_name']
        member.default['ipaddress'] = instance['private_ip']
        member.default['hostname'] = name
        mongodb_attributes = {
          'config' => {
            'port' => node['mongodb']['config']['port'],
          },
          'replica_arbiter_only' => node['mongodb']['replica_arbiter_only'],
          'replica_build_indexes' => node['mongodb']['replica_build_indexes'],
          'replica_hidden' => node['mongodb']['replica_hidden'],
          'replica_slave_delay' => node['mongodb']['replica_slave_delay'],
          'replica_priority' => node['mongodb']['replica_priority'],
          'replica_tags' => node['mongodb']['replica_tags'],
          'replica_votes' => node['mongodb']['replica_votes']
        }
        member.default['mongodb'] = mongodb_attributes
        members << member
      end
    end
    members
  end

end
