vcenter_vrouter_map { 'test' :
  ensure       => 'absent',
  path         => '/tmp/test.txt',
  username     => 'test_user',
  password     => 'test_pass',
  vcenter_host => 'my_host',
  ips          => ['192.168.0.1','192.168.0.2'],
}
