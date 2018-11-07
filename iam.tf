# Ec2 Instance IAM user----------------------------------------------

resource "aws_iam_user" "web_user" {
    name = "web_sys_ad"
}

resource "aws_iam_policy" "ec2_policy" {
    name        = "web_sys_ad-policy"
    description = "A test policy for a web server system administrator"
    policy      = "${file("iam_ec2_policy.json")}"
}

resource "aws_iam_user_policy_attachment" "ec2_test-attach" {
    user       = "${aws_iam_user.web_user.name}"
    policy_arn = "${aws_iam_policy.ec2_policy.arn}"
}

# s3 IAM user--------------------------------------------------------

resource "aws_iam_user" "s3_user" {
    name = "s3_parser"
}

resource "aws_iam_policy" "s3_policy" {
    name        = "s3_parser-policy"
    description = "User that looks at flow files in s3"
    policy      = "${file("iam_ec2_policy.json")}"
}

resource "aws_iam_user_policy_attachment" "s3_test-attach" {
    user       = "${aws_iam_user.s3_user.name}"
    policy_arn = "${aws_iam_policy.s3_policy.arn}"
}
