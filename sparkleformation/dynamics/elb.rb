SparkleFormation.dynamic(:elb) do |_name, _config={}|
  parameters do
    set!("#{_name}_vpc_id") do
      type 'String'
      default _config[:vpc_id]
    end
    set!("#{_name}_hosted_zone_name") do
      type 'String'
      default _config[:hosted_zone_name]
    end
    set!("#{_name}_record") do
      type 'String'
      default _config[:record]
    end
  end

  dynamic!(:load_balancer, _name.to_sym) do
    properties do
      health_check do
        healthy_threshold '2'
        interval '5'
        target 'HTTP:80/'
        timeout '2'
        unhealthy_threshold '2'
      end
      listeners _array(
        -> {
          instance_port '80'
          instance_protocol 'http'
          load_balancer_port '80'
          protocol 'http'
        },
        -> {
          instance_port '22'
          instance_protocol 'tcp'
          load_balancer_port '22'
          protocol 'tcp'
        },
      )
      scheme 'internet-facing'
      security_groups _array(
        ref!("#{_name}_ec2_security_group")
      )
      subnets _config[:subnets]
    end
  end

  dynamic!(:ec2_security_group, _name.to_sym) do
    properties do
      group_description "#{_name} security group"
      vpc_id ref!("#{_name}_vpc_id".to_sym)
      security_group_ingress _array(
        -> {
          from_port 22
          to_port 22
          ip_protocol 'tcp'
          cidr_ip '0.0.0.0/0'
        },
        -> {
          from_port 80
          to_port 80
          ip_protocol 'tcp'
          cidr_ip '0.0.0.0/0'
        }
      )
    end
  end

  dynamic!(:record_set, _name.to_sym) do
    properties do
      hosted_zone_name join!(ref!("#{_name}_hosted_zone_name".to_sym), '.')
      name join!(
        ref!("#{_name}_record"),
        '.',
        ref!("#{_name}_hosted_zone_name"),
      )
      type 'CNAME'
      t_t_l '60'
      resource_records _array(
        attr!(:"#{_name}_load_balancer", :"DNSName")
      )
    end
  end
end
