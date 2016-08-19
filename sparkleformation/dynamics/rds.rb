SparkleFormation.dynamic(:rds) do |_name, _config={}|
  parameters do
    set!("#{_name}_vpc_id") do
      type 'String'
      default _config[:vpc_id]
    end
  end

  dynamic!(:d_b_instance, _name.to_sym) do
    properties do
      allocated_storage '5'
      d_b_instance_class 'db.t2.micro'
      d_b_subnet_group_name ref!("#{_name}_d_b_subnet_group")
      engine 'mysql'
      master_username 'root'
      master_user_password 'password'
      multi_a_z 'true'
      v_p_c_security_groups _array(
        ref!("#{_name}_ec2_security_group")
      )
    end
  end

  dynamic!(:d_b_subnet_group, _name.to_sym) do
    properties do
      d_b_subnet_group_description "#{_name} security group"
      subnet_ids _config[:subnets]
    end
  end

  dynamic!(:ec2_security_group, _name.to_sym) do
    properties do
      group_description "#{_name} security group"
      vpc_id ref!("#{_name}_vpc_id".to_sym)
      security_group_ingress _array(
        -> {
          from_port 3306
          to_port 3306
          ip_protocol 'tcp'
          source_security_group_id _config[:app_security_group]
        }
      )
    end
  end
end
