# # resource "aws_elb" "main" {
# #   name               = "foobar-terraform-elb"
# #   availability_zones = ["us-east-1c"]

# #   listener {
# #     instance_port     = 80
# #     instance_protocol = "http"
# #     lb_port           = 80
# #     lb_protocol       = "http"
# #   }
# # }

# resource "aws_route53_record" "mopicfct" {
#   zone_id = aws_route53_zone.primary.zone_id
#   name    = "mopicfct.com"
#   type    = "A"

#   alias {
#     name                   = data.aws_lb.mopic-alb.name
#     zone_id                = data.aws_lb.mopic-alb.zone_id
#     evaluate_target_health = true
#   }
# }

# resource "aws_route53_zone" "primary" {
#   name = "mopicfct.com"
# }
