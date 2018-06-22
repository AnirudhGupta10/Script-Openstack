source admin-openrc
neutron router-gateway-clear demo-router1 ext-net1
neutron router-interface-delete demo-router1 demo-subnet1
neutron router-delete demo-router1
neutron subnet-delete demo-subnet1
neutron net-delete demo-net1
neutron subnet-delete ext-subnet1
neutron net-delete ext-net1

