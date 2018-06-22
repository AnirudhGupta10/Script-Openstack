




neutron net-create ext-net1 --router:external True --provider:physical_network physnet1 --provider:network_type flat
neutron subnet-create ext-net1 --name ext-subnet1 --allocation-pool start=172.19.53.200,end=172.19.53.229 --disable-dhcp --gateway 172.19.53.1  172.19.53.0/24
neutron net-create demo-net1 --tenant-id cc94c7c8cc48458d96acab08c8022e1d --provider:network_type vxlan
neutron subnet-create demo-net1 --name demo-subnet1 --gateway 20.20.20.1 20.20.20.0/24
neutron router-create demo-router1
neutron router-interface-add demo-router1 demo-subnet1
neutron router-gateway-set demo-router1 ext-net1
ip netns
neutron router-port-list demo-router1
