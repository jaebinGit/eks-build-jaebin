# resource "aws_iam_role" "ecom-role-ec2cli" {
#   name = "ecom-role-ec2cli"
#
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Sid    = ""
#         Principal = {
#           Service = "ec2.amazonaws.com"
#         }
#       }
#     ]
#   })
# }
#
# resource "aws_iam_role_policy_attachment" "ssm" {
#   role       = aws_iam_role.ecom-role-ec2cli.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
# }
#
# resource "aws_iam_role_policy_attachment" "ecr" {
#   role       = aws_iam_role.ecom-role-ec2cli.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
# }
#
# ######################################################################################################################
# # IAM Policy 설정
# ######################################################################################################################
# data "http" "iam_policy" {
#   url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.6.2/docs/install/iam_policy.json"
# }
#
# resource "aws_iam_role_policy" "eks-controller" {
#   name_prefix = "AWSLoadBalancerControllerIAMPolicy"
#   role        = module.lb_controller_role.iam_role_name
#   policy      = data.http.iam_policy.response_body
# }

resource "aws_iam_role" "ecom-role-ec2cli" {
  name = "ecom-role-ec2cli"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ecom-role-ec2cli.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ecr" {
  role       = aws_iam_role.ecom-role-ec2cli.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
}

######################################################################################################################
# IAM Policy 설정
######################################################################################################################
data "http" "iam_policy" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.6.2/docs/install/iam_policy.json"
}

resource "aws_iam_policy" "load_balancer_controller" {
  name        = "AWSLoadBalancerControllerIAMPolicy"
  path        = "/"
  description = "IAM policy for AWS Load Balancer Controller"

  policy = data.http.iam_policy.response_body
}

resource "aws_iam_role_policy_attachment" "load_balancer_controller" {
  policy_arn = aws_iam_policy.load_balancer_controller.arn
  role       = module.lb_controller_role.iam_role_name
}