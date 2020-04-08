# VPC
resource "alicloud_vpc" "vpc" {

  name       = "tf_test_foo"
  cidr_block =  var.vpc_cidr

}

# 交换机
resource "alicloud_vswitch" "vsw" {
  
  vpc_id            = alicloud_vpc.vpc.id
  cidr_block        =  var.subnets_cidr
  availability_zone =  var.azs
}


# 安全组
resource "alicloud_security_group" "default" {
  name = "tftestfoo"
  vpc_id = alicloud_vpc.vpc.id
}


resource "alicloud_security_group_rule" "allow_all_tcp" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "1/65535"
  priority          = 1
  security_group_id = alicloud_security_group.default.id
  cidr_ip           = "0.0.0.0/0"
}


# 负载均衡

resource "alicloud_slb" "slb" {
  name       = "test-slb-tf"
  vswitch_id = alicloud_vswitch.vsw.id
  address_type = "internet"
}
resource "alicloud_slb_listener" "http" {
  load_balancer_id = alicloud_slb.slb.id
  backend_port = 8000
  frontend_port = 80
  bandwidth = 10
  protocol = "http"
  sticky_session = "on"
  sticky_session_type = "insert"
  cookie = "testslblistenercookie"
  cookie_timeout = 86400
  health_check="on"
  health_check_type = "http"
  health_check_connect_port = 8000
}

## 自动扩容
resource "alicloud_ess_scaling_group" "scaling" {
  min_size = 2
  max_size = 10
  scaling_group_name = "tf-scaling"
  vswitch_ids = alicloud_vswitch.vsw.*.id
  loadbalancer_ids = alicloud_slb.slb.*.id
  removal_policies   = ["OldestInstance", "NewestInstance"]
  #removal_policies   = ["OldestScalingConfiguration", "OldestInstance"]
  multi_az_policy    = "BALANCE"
}

resource "alicloud_ess_scaling_configuration" "config" {
  scaling_group_id = alicloud_ess_scaling_group.scaling.id
  image_id = "centos_7_03_64_20G_alibase_20170818.vhd"
  instance_type = "ecs.sn1ne.large"
  security_group_id = alicloud_security_group.default.id
  active= true
  enable= true
  #password = var.ecs_password
  key_name = alicloud_key_pair.publickey.key_name
  user_data = data.template_file.user_data.rendered
  internet_max_bandwidth_in =10
  internet_max_bandwidth_out =10
  internet_charge_type = "PayByTraffic"
  force_delete= true
  tags        = var.instance_tags

  lifecycle {
    ignore_changes = [user_data]
  }

}


# ---------------
# Scaling rules & alarms
# ---------------
resource "alicloud_ess_scaling_rule" "add-instance" {
 
  scaling_group_id = alicloud_ess_scaling_group.scaling.id
  adjustment_type  = "QuantityChangeInCapacity"
  adjustment_value = 1
}

resource "alicloud_ess_scaling_rule" "remove-instance" {
  scaling_group_id = alicloud_ess_scaling_group.scaling.id
  adjustment_type  = "QuantityChangeInCapacity"
  adjustment_value = -1
}

resource "alicloud_ess_alarm" "alarm-1-add-instance" {
  name                = "alarm-1-add-instance"
  description         = "Add 1 instance when CPU usage >70%"
  alarm_actions       = [alicloud_ess_scaling_rule.add-instance.ari]
  scaling_group_id    = alicloud_ess_scaling_group.scaling.id
  metric_type         = "system"
  metric_name         = "CpuUtilization"
  period              = 60
  statistics          = "Average"
  threshold           = 70
  comparison_operator = ">="
  evaluation_count    = 2
}

resource "alicloud_ess_alarm" "alarm-2-remove-instance" {
  name                = "alarm-2-remove-instance"
  description         = "Remove 1 instance when CPU usage <10%"
  alarm_actions       = [alicloud_ess_scaling_rule.remove-instance.ari]
  scaling_group_id    = alicloud_ess_scaling_group.scaling.id
  metric_type         = "system"
  metric_name         = "CpuUtilization"
  period              = 60
  statistics          = "Average"
  threshold           = 10
  comparison_operator = "<="
  evaluation_count    = 2
}


# ---------------
# Queries & outputs
# ---------------
data "template_file" "user_data" {
  template = file("${path.module}/user-data.conf")
}


