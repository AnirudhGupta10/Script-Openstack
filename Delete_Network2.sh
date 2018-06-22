source admin-openrc
neutron router-gateway-clear demo-router2 ext-net2
neutron router-interface-delete demo-router2 demo-subnet2
neutron router-delete demo-router2
neutron subnet-delete demo-subnet2
neutron net-delete demo-net2
neutron subnet-delete ext-subnet2
neutron net-delete ext-net2
