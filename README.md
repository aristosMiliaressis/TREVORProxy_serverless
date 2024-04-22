TREVORproxy_serverless
==

<br/>

Sets up an autoscaling cluster of SOCKS proxies to use along with [TREVORproxy](https://github.com/blacklanternsecurity/TREVORproxy).

- `trevorproxy_serverless` uses an SQS queue to control the autoscaling of the proxy cluster
- as long as there is a `proxy-intent` message in the queue the cluster will stay up.
- when running the cli it adds a message to the queue to signal it needs a running cluster of proxies
- when the cli terminates gracefully it removes the message from the queue
- if the cli is terminated non gracefully, the message will remain in the queue until the message retention period of the queue passes
- while the cli is running it is using a sliding window approach to ensure the proxy intent message will not expire while the cli is running.

the proxy count can be adjusted trough [terraform variables](https://github.com/aristosMiliaressis/TREVORproxy_serverless/blob/master/infra/variables.tf).

<p align="center">
  <img src="https://github.com/aristosMiliaressis/TREVORproxy_serverless/blob/master/img/demo.png?raw=true">
</p>

<br/>

**Dependencies for infra.sh**
- aws cli (configured with enough permissions)
- terraform
- docker
- jq

<br/>

**trevorproxy_serverless Installation**
```bash
$ pip install trevorproxy_serverless
```

<br/>

**Notes**

Cost of one proxy instance running for an hour is 0,012$.

PS: Fargate bills per minute spent so if you spin up 100 servers for 30 minutes it will cost 0,012 * 100 / 2 = 0,60$

PS: Spin up time can take a few minutes because SQS pushes metrics to cloudwatch on an interval of 1 or 5 minues, the following aws regions support [1 minute metrics](https://aws.amazon.com/about-aws/whats-new/2019/12/amazon-sqs-now-supports-1-minute-cloudwatch-metrics/), so they are recommended:
US East (Ohio), 
EU (Ireland), 
EU (Stockholm), 
Asia Pacific (Tokyo)

<p align="center">
  <img src="https://github.com/aristosMiliaressis/TREVORproxy_serverless/blob/master/img/cost_calc.png?raw=true">
</p>
