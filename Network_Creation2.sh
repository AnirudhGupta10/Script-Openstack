


neutron net-create ext-net2 --router:external True --provider:physical_network physnet2 --provider:network_type flat
neutron subnet-create ext-net2 --name ext-subnet2 --allocation-pool start=172.19.63.30,end=172.19.63.40 --disable-dhcp --gateway 172.19.63.1  172.19.63.0/24
neutron net-create demo-net2 --tenant-id cc94c7c8cc48458d96acab08c8022e1d --provider:network_type vxlan
neutron subnet-create demo-net2 --name demo-subnet2 --gateway 30.30.30.1 30.30.30.0/24
neutron router-create demo-router2
neutron router-interface-add demo-router2 demo-subnet2
neutron router-gateway-set demo-router2 ext-net2
ip netns
neutron router-port-list demo-router2
