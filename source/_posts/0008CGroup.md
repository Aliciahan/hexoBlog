---
  title: Cgroups in Practice
  categories: Docker
  tags: 
    - cgroup
    - docker
    - virtualization
---


<blockquote class="blockquote-center">Cgroups 是 control groups 的缩写, 最初由google工程师书写, 之后写进Linux内核, 是Docker使用的几大底层基础技术之一. </blockquote> 

# Cgroup Terminology

| Name | Explication | 
|:----------------|:----------------|
|tasks | 任务就是系统的一个进程 |
| control group | 按照某种标准划分的进程. 一个进程可以加入某个控制族群, 也可以从一个组迁移到另一个组.|
| hierarchy | cgroup组成hierarchy, 控制树上面, 有继承的关系 |
| subsystem | 子系统就是资源控制器. subsystem 要附加到hierarchy上面才能起作用. |

**相互之间的关系**: 

1. 每次系统创建一个新的hierarchy, 所有的任务都是此 hierarchy 默认cgroup. called : *root cgroup* 这个cgroup会自动创建. 
2. 一个subsystem最多只能附加到一个hierarchy
3. 一个hierarchy可以有多个子系统
4. 一个Task可以属于不同cgroup, 这些cgroup属于不同hierarhcy
5. 一个Task的子进程, 自动属于父进程的cgroup, 然后可以根据需要 移动到不同的cgroup中. 

![cgroup hierarchy](/uploads/0008cgroup1.png)




# Usage

<a href="https://www.ibm.com/developerworks/cn/linux/1506_cgroup/index.html">Examples Source</a>

Now, we have a java script, running 2 types of threads, one 

**0. Preparation**

~~~java

//开启 4 个用户线程，其中 1 个线程大量占用 CPU 资源，其他 3 个线程则处于空闲状态
public class HoldCPUMain {
    public static class HoldCPUTask implements Runnable{

        @Override
            public void run() {
                // TODO Auto-generated method stub
                while(true){
                    double a = Math.random()*Math.random();//占用 CPU
                    System.out.println(a);
                }
            }

    }

    public static class LazyTask implements Runnable{

        @Override
            public void run() {
                // TODO Auto-generated method stub
                while(true){
                    try {
                        Thread.sleep(1000);
                    } catch (InterruptedException e) {
                        // TODO Auto-generated catch block
                        e.printStackTrace();
                    }//空闲线程
                }
            }

    }


    public static void main(String[] args){
        for(int i=0;i<10;i++){
            new Thread(new HoldCPUTask()).start();
        }
    }
}

~~~

**1. Build Hierarchy**

~~~bash
aliciahan@ubuntu1:~/CgroupTests$ cd /sys/fs/cgroup/
aliciahan@ubuntu1:/sys/fs/cgroup$ ls
blkio  cpu  cpuacct  cpu,cpuacct  cpuset  devices  freezer  hugetlb  memory  net_cls  net_cls,net_prio  net_prio  perf_event  pids  systemd
aliciahan@ubuntu1:/sys/fs/cgroup$ cd cpuset/
aliciahan@ubuntu1:/sys/fs/cgroup/cpuset$ ls
cgroup.clone_children  cpuset.cpu_exclusive   cpuset.effective_mems  cpuset.memory_migrate           cpuset.memory_spread_page  cpuset.sched_load_balance        release_agent
cgroup.procs           cpuset.cpus            cpuset.mem_exclusive   cpuset.memory_pressure          cpuset.memory_spread_slab  cpuset.sched_relax_domain_level  tasks
cgroup.sane_behavior   cpuset.effective_cpus  cpuset.mem_hardwall    cpuset.memory_pressure_enabled  cpuset.mems                notify_on_release
aliciahan@ubuntu1:/sys/fs/cgroup/cpuset$ sudo mkdir helloworld
#OR:
aliciahan@ubuntu1:/sys/fs/cgroup/cpuset/helloworld$ sudo cgcreate -t aliciahan:aliciahan -a aliciahan:aliciahan -g cpuset:/hello
~~~

**2. Check Result**

~~~bash
aliciahan@ubuntu1:/sys/fs/cgroup/cpuset/helloworld$ lscgroup | grep helloworld
cpuset:/helloworld
~~~

**3. Edit Params**

~~~bash 
aliciahan@ubuntu1:/sys/fs/cgroup/cpuset/helloworld$ sudo vim cpuset.cpus
aliciahan@ubuntu1:/sys/fs/cgroup/cpuset/helloworld$ cat ./cpuset.cpus
0
#OR: 
aliciahan@ubuntu1:/sys/fs/cgroup/cpuset/hello$ sudo cgset -r cpuset.cpus=0 hello
aliciahan@ubuntu1:/sys/fs/cgroup/cpuset/hello$ sudo cgset -r cpuset.mems=0 hello
~~~


{% note info %} 

You can see the usage of your CPU cores using top command.

- Open a Terminal.
- Type top. You will see some information about tasks, memory etc.
- Type 1 to show individual CPU usage. You will see something like:

> cpu0 ..................
> cpu1 .................

To start a new process which should execute only in one core, you can use taskset command.

taskset -c 0 executable

{% endnote %} 


**4. Execute Tasks**

There are several ways of executing tasks in cgroup. 

- Adding manually with 
> echo [PID] > /path/To/Cgroup/tasks 
- through cgclassify : 
> cgclassify -g subsystems:path_to_cgroup pidlist
- Using *cgexec* cgexec -g subsystems:path_to_cgroup command arguments


~~~bash
aliciahan@ubuntu1:~/CgroupTests$ cgexec -g cpuset:/hello java HoldCPUMain > log.txt &
[1] 2090
aliciahan@ubuntu1:~/CgroupTests$ top
top - 11:15:28 up 58 min,  1 user,  load average: 1.54, 0.40, 0.13
Tasks: 185 total,   1 running, 184 sleeping,   0 stopped,   0 zombie
%Cpu0  : 40.2 us, 59.8 sy,  0.0 ni,  0.0 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st
%Cpu1  :  0.3 us,  0.3 sy,  0.0 ni, 93.4 id,  0.0 wa,  0.0 hi,  5.9 si,  0.0 st
~~~

All is running at cpu0. 

















