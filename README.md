TREVORproxy-serverless
==

<br/>

Sets up an autoscaling fargate cluster of SOCKS proxies to use along with [TREVORproxy](https://github.com/blacklanternsecurity/TREVORproxy).

the `proxy.sh` command puts a `proxy-intent` message in an sqs queue which causes the proxy cluster to scale up if it is not already up.

when stopped `proxy.sh` deletes the `proxy-intent` message to signal that it does not need the proxies anymore.

the sqs queue has a message retention limit which acts as a hard timeout to prevent proxies from running too long.

the message retention & proxy count can be adjusted trough [terraform variables](https://github.com/aristosMiliaressis/TREVORproxy-serverless/blob/master/infra/variables.tf).

<br/>

**Dependencies for infra.sh**
- aws cli (configured with enough permissions)
- terraform
- docker
- jq

**Dependencies for proxy.sh**
- [TREVORproxy](https://github.com/blacklanternsecurity/TREVORproxy).
- aws cli (configured with enough permissions)
- jq


<p align="center">
  <img src="https://github.com/aristosMiliaressis/TREVORproxy-serverless/blob/master/img/demo.png?raw=true">
</p>

Cost of one proxy instance running for an hour is 0,012$.

PS: Fargate bills per minute spent so if you spin up 100 servers for 30 minutes it will cost 0,012 * 100 / 2 = 0,60$

<p align="center">
  <img src="https://github.com/aristosMiliaressis/TREVORproxy-serverless/blob/master/img/cost_calc.png?raw=true">
</p>
