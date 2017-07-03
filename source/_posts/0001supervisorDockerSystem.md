---
  title: Simple Solutions for Monitoring Docker Containers
  categories: Docker
  tags:
    - docker
    - supervisor
    - monitoring
---


# 1. Introduction

Our but is to supervise the functionality of the native machine running docker daemon, to prevent the insufficient system sources distributed.

## 1.1 The Aims

- Reduce down time
- Extensibility
- Control the Performance
- Ressources Monitoring
- Catch exceptions

## 1.2 The Challenges Monitoring Docker

- It looked like a host machine, but not exactly the same.
- A LOT OF informations
- life circle is SHORT
- have point mort
- Micro Service
- Clustering
- VM Host + Services + Containers + Apps Multi-layers

# 2. Two layers Monitoring

## 2.0 Monitoring on VM

![VM Monitoring](/uploads/0001-vm-monitoring.png)

- Application Layer: Supervise the error in application layer
- Machine Layer: CPU, MEM etc.

## 2.1 The Host Machine

We want to catch the following information:

- System Information : CPU, MEM, Disk IO, Network etc.
- All Containers Names
- Running Containers
- Dead Containers
- Docker Informations : Storage Driver、Data Space Used、Data Space Total、Metadata Space Total、Metadata Space Used、client version、client api version、server version、servier api version

## 2.2 The Containers

In the container, we want to catch :

- Container's information : Name, IP, Image, Command etc.
- The status : Running / Stopped
- CPU
- Memory Usage
- Memory Limit
- Network IO
- Disk

# 3. How to get Container Informations

## 3.1 Basic

- Namespace: Separation here
- cgroup : ressources



### Cpu Memory FS

#### CPU:

/sys/fs/cgroup/{memory,cpuacct,blkio}/system.slice/${docker ps --no-trunc}.scope
> Standard: /sys/fs/cgroup/:cgroup/docker/:container_id
> Systemd:  /sys/fs/cgroup/:cgroup/system.slice/docker-#{id}.scope

#### Memory :

/sys/fs/cgroup/memory/

> looking for memory.stat file.

![Memory Metrics](/uploads/0001-1.png)

# Simple Solutions

## The Original Docker

~~~bash
$ docker stats
CONTAINER           CPU %               MEM USAGE / LIMIT       MEM %               NET I/O             BLOCK I/O           PIDS
7a91dbda43e4        4.20%               52.06 MiB / 15.66 GiB   0.32%               70.7 MB / 3.47 GB   352 kB / 0 B        17
~~~

## The most simple : cAdvisor google


### how to run cAdvisor

~~~bash
sudo docker run \
  --volume=/:/rootfs:ro \
  --volume=/var/run:/var/run:rw \
  --volume=/sys:/sys:ro \
  --volume=/var/lib/docker/:/var/lib/docker:ro \
  --publish=4001:8080 \
  --detach=true \
  --name=cadvisor \
  google/cadvisor
~~~

Then we connect to the

> http://<ip host>:4001

The report graphic is already there.

### Pros and Cons

Simple and fast, but not poorly personalized, restricted in Linux machine.
