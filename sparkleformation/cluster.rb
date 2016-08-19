SparkleFormation.new(:compute, :provider => :aws).load(:base).overrides do
  vpc_id = 'vpc-6bb0b10e'

  public_subnets = [
    'subnet-f95a979d',
    'subnet-37e60e41',
    'subnet-97de2ace'
  ]

  private_subnets = [
    'subnet-fa5a979e',
    'subnet-34e60e42',
    'subnet-96de2acf'
  ]

  dynamic!(:ec2, :app,
    :subnets => private_subnets,
    :image_id => 'ami-fc577c9f',
    :key_name => 'michael.lorant',
    :vpc_id => vpc_id,
    :max_size => 3,
    :min_size => 3,
    :load_balancer_name => ref!(:lb_load_balancer),
    :load_balancer_security_group => ref!(:lb_ec2_security_group),
    :db_host => attr!(:db_d_b_instance, :'Endpoint.Address')
  )

  dynamic!(:elb, :lb,
    :subnets => public_subnets,
    :vpc_id => vpc_id,
    :hosted_zone_name => 'playground.amaysim.net',
    :record => 'app'
  )

  dynamic!(:rds, :db,
    :subnets => private_subnets,
    :vpc_id => vpc_id,
    :app_security_group => ref!(:app_ec2_security_group),
  )
end
