poise_service_user node['consul']['service_user'] do
  group node['consul']['service_group']
end

config = consul_config node['consul']['service_name'] do |r|
  owner node['consul']['service_user']
  group node['consul']['service_group']

  node['consul']['config'].each_pair { |k, v| r.send(k, v) }
end
