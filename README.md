## Object
This terraform file creates a serverless application pattern that uses AWS EventBridge and AWS Step Functions to monitor and respond to changes in the state of an Amazon instance.The file defines a single resource, a Serverless State Machine called "EC2StateWatcher". The State Machine has a set of States that are defined using AWS Step Functions' JSON-based state language. The States include a Choice state, "What Happened?", that is used to determine the next state to transition to based on the state of the EC2 instance. The States also include three Pass states, "It's Running", "It's Stopped", and "It's Gone", that are used to represent the end states of the State Machine.
The State Machine is triggered by an AWS EventBridge rule called "StateChange". The rule is configured to listen for events on the default event bus for EC2 instances that have changed state to "running", "stopped", or "terminated". The input to the State Machine is set using the "InputPath" property of the EventBridge rule, which selects the "detail" field of the event object.

## Steps
first navigate to file where main.tf is present and perform below command. it performs backend initialization, and plugin installation.
```t
terraform init
```
then, use need to use the below command to validate the file
```t
terraform validate
```
and terraform plan will generate execution plan, showing you what actions will be taken without actuallay performing planned actions.
```t
terraform plan
```
after perform below command to deploy the application in aws and '--auto-approve' applying changes without having to interactively type 'yes' to the plan.
```t
terraform apply --auto-approve, it will create the resources as shown in image.

![Screenshot (82)](https://user-images.githubusercontent.com/120295902/234189640-3a32cbc7-de6b-4649-a83d-688a3d699769.png)

## Validation steps
The instance which is showing here in a stopped state.
<img width="842" alt="instance_stopped state" src="https://user-images.githubusercontent.com/120295902/234184046-3fa98c3e-3336-4bf1-ab28-d1139b1ff95c.png">

After starting instance go to state machine executions, check the status, it has to running status.
![Screenshot (48)](https://user-images.githubusercontent.com/120295902/234185255-eae6f782-1337-40ec-b881-424b8530e257.png)

and again i stopped the instance, and the status is as shown in below image.

![Screenshot (81)](https://user-images.githubusercontent.com/120295902/234187374-b88ddd5f-5702-45a2-b010-e79755ac7f91.png)

To destroy the application
```t
terraform destroy --auto-approve
```
