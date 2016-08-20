SparkleFormation.dynamic(:ec2) do |_name, _config={}|
  parameters do
    set!("#{_name}_image_id".to_sym) do
      type 'String'
      default _config[:image_id]
    end
    set!("#{_name}_instance_type".to_sym) do
      type 'String'
      allowed_values registry!(:instance_types)
      default registry!(:instance_type_default)
    end
    set!("#{_name}_key_name".to_sym) do
      type 'String'
      default _config[:key_name]
    end
    set!("#{_name}_db_user".to_sym) do
      type 'String'
      default 'root'
    end
    set!("#{_name}_db_pass".to_sym) do
      type 'String'
      default 'password'
    end

    set!("#{_name}_max_size".to_sym) do
      type 'Number'
      default _config[:max_size] || '1'
    end
    set!("#{_name}_min_size".to_sym) do
      type 'Number'
      default _config[:min_size] || '1'
    end

    set!("#{_name}_vpc_id") do
      type 'String'
      default _config[:vpc_id]
    end
  end

  dynamic!(:launch_configuration, _name.to_sym) do
    properties do
      associate_public_ip_address _config[:associate_public_ip_address] || 'true'
      block_device_mappings _array(
        -> {
          device_name _config[:device_name] || '/dev/sda1'
          ebs do
            volume_size _config[:volume_size] || '8'
          end
        }
      )
      image_id ref!("#{_name}_image_id".to_sym)        
      instance_type ref!("#{_name}_instance_type".to_sym)
      key_name ref!("#{_name}_key_name".to_sym)
      security_groups _array(
        ref!("#{_name}_ec2_security_group")
      )
      user_data base64!(
        join!(
          "#cloud-config\n",
          "rancher:\n",
          "  services:\n",
          "    app:\n",
          "      image: mikelorant/amaysim-app\n",
          "      environment:\n",
          "        DB_HOST: ", _config[:db_host], "\n",
          "        DB_USER: ", ref!("#{_name}_db_user"), "\n",
          "        DB_PASS: ", ref!("#{_name}_db_pass"), "\n",
          "      ports:\n",
          "        - '80:80'\n",
          "      restart: always\n"
        )
      )
    end
  end

  dynamic!(:auto_scaling_group, _name.to_sym) do
    properties do
      launch_configuration_name ref!("#{_name}_launch_configuration".to_sym)
      load_balancer_names _array(
        _config[:load_balancer_name]
      )
      max_size ref!("#{_name}_max_size".to_sym)
      min_size ref!("#{_name}_min_size".to_sym)
      v_p_c_zone_identifier _config[:subnets]
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
          source_security_group_id _config[:load_balancer_security_group]
        },
        -> {
          from_port 80
          to_port 80
          ip_protocol 'tcp'
          source_security_group_id _config[:load_balancer_security_group]
        }
      )
    end
  end
end
