
## Running Apache Bench on Nginx directly

This is executed on the Client instance, pointing to Nginx on WebSvr instance: 

```
$ ab -n 1000000 -c 100 http://ip-200-10-1-149.ec2.internal:80/
This is ApacheBench, Version 2.3 <$Revision: 1879490 $>
Copyright 1996 Adam Twiss, Zeus Technology Ltd, http://www.zeustech.net/
Licensed to The Apache Software Foundation, http://www.apache.org/

Benchmarking ip-200-10-1-149.ec2.internal (be patient)
Completed 100000 requests
Completed 200000 requests
Completed 300000 requests
Completed 400000 requests
Completed 500000 requests
Completed 600000 requests
Completed 700000 requests
Completed 800000 requests
Completed 900000 requests
Completed 1000000 requests
Finished 1000000 requests


Server Software:        nginx/1.18.0
Server Hostname:        ip-200-10-1-149.ec2.internal
Server Port:            80

Document Path:          /
Document Length:        20 bytes

Concurrency Level:      100
Time taken for tests:   48.477 seconds
Complete requests:      1000000
Failed requests:        0
Total transferred:      251000000 bytes
HTML transferred:       20000000 bytes
Requests per second:    20628.33 [#/sec] (mean)
Time per request:       4.848 [ms] (mean)
Time per request:       0.048 [ms] (mean, across all concurrent requests)
Transfer rate:          5056.36 [Kbytes/sec] received

Connection Times (ms)
              min  mean[+/-sd] median   max
Connect:        0    2   0.4      2       7
Processing:     0    3   0.7      3      15
Waiting:        0    2   0.8      2      15
Total:          1    5   0.5      5      15

Percentage of the requests served within a certain time (ms)
  50%      5
  66%      5
  75%      5
  80%      5
  90%      5
  95%      6
  98%      6
  99%      6
 100%     15 (longest request)
```

```
$ ab -n 500000 -c 5000 http://ip-172-16-1-21.ec2.internal:9080/

```
