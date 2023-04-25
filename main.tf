provider "aws" {
  region = "us-east-1"
}
resource "aws_sfn_state_machine" "ec2_state_watcher" {
  name     = "EC2StateWatcher"
  role_arn = aws_iam_role.state_machine.arn

  definition = jsonencode({
    "StartAt": "What Happened?",
    "States": {
      "It's Gone": {
        "End": true,
        "Type": "Pass"
      },
      "It's Running": {
        "End": true,
        "Type": "Pass"
      },
      "It's Stopped": {
        "End": true,
        "Type": "Pass"
      },
      "What Happened?": {
        "Choices": [
          {
            "Next": "It's Running",
            "StringEquals": "running",
            "Variable": "$.state"
          },
          {
            "Next": "It's Stopped",
            "StringEquals": "stopped",
            "Variable": "$.state"
          },
          {
            "Next": "It's Gone",
            "StringEquals": "terminated",
            "Variable": "$.state"
          }
        ],
        "Type": "Choice"
      }
    }
  })

  tags = {
    Name = "EC2StateWatcher"
  }
}

resource "aws_iam_role" "state_machine" {
  name = "EC2StateMachineRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "states.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "state_machine_logs" {
  name       = "EC2StateMachineLogs"
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
  roles      = [aws_iam_role.state_machine.name]
}

resource "aws_iam_role" "EventBridgeRole" {
  assume_role_policy = <<POLICY1
{
  "Version" : "2012-10-17",
  "Statement" : [
    {
      "Effect" : "Allow",
      "Principal" : {
        "Service" : "events.amazonaws.com"
      },
      "Action" : "sts:AssumeRole"
    }
  ]
}
POLICY1
}

resource "aws_iam_policy" "EventBridgePolicy" {
  policy = <<POLICY3
{
  "Version" : "2012-10-17",
  "Statement" : [
    {
      "Effect" : "Allow",
      "Action" : [
        "states:StartExecution"
      ],J
      "Resource" : "${aws_sfn_state_machine.ec2_state_watcher.arn}"
    }
  ]
}
POLICY3
}
resource "aws_iam_role_policy_attachment" "EventBridgePolicyAttachment" {
  role       = aws_iam_role.EventBridgeRole.name
  policy_arn = aws_iam_policy.EventBridgePolicy.arn
}


resource "aws_cloudwatch_event_rule" "Stepfunction" {
  name        = "step_function_role"
  description = "Capture change in ec2 state instance"

  event_pattern = jsonencode({
    source = ["aws.ec2"]
    detail = {
      state = ["running", "stopped", "terminated"]
    }
  })
}
resource "aws_cloudwatch_event_target" "Step_function" {
  rule      = aws_cloudwatch_event_rule.Stepfunction.name
  target_id = "StepFunction"
  arn      = aws_sfn_state_machine.ec2_state_watcher.arn
  role_arn = aws_iam_role.EventBridgeRole.arn
  input_path = "$.detail"
}



