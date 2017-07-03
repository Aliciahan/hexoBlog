---
  title: Namespace and Cgroup in Docker
  categories: Docker
  tags:
    - docker
    - supervisor
    - monitoring
---

# 1 Linux Namespace

<a href="https://lwn.net/Articles/531114/">Ref: Namespaces in operation</a>

To be independent one and another, the VM solution is to virtualize CPU, MEM etc. The answer of *LXC* is **container**. Precisely speaking : <strong><font color="magenta">kernel namespace</font></strong> including:

 | Namespace | Parameter | isolated Content |
 |:----------------|:----------------|:--------:|
 | pid namespace | CLONE_NEWPID | Process ID |
 | net namespace | CLONE_NEWNET | Network, port |
 | ipc namespace | CLONE_NEWIPC | 信号量, 消息队列, 共享内存 |
 | mnt namespace | CLONE_NEWNS | file system Mount |
 | uts namespace | CLONE_NEWUTS | host and DNS |
 | user namespace | CLONE_NEWUSER | User and group |

In fact the purpose of **namespace** is to provide a basic light virtualization, the components in the same namespace know each other, but having 0 information out of the current namespace.

# 2 API of namespace

The API of namespace includes:

- clone()
- setns()
- unshare()
- some files in */proc*

To make sure, which type of namespace we want to operate with, we will use the parameters listed in the above table: CLONE_NEWIPC、CLONE_NEWNS、CLONE_NEWNET、CLONE_NEWPID、CLONE_NEWUSER and CLONE_NEWUTS.

## 2.1 What is clone() looked like

~~~cpp
int clone(int (*child_func)(void *), void *child_stack, int flags, void *arg);
~~~

- child_func : indicate where is the main function of child function
- child_stack : the stack which will be used by a child function.
- flags: which CLONE_* are used?
- args : the user's parameters


## 2.2 /proc/[pid]/ns

~~~bash
root@mo-e33e22ea6:/proc/57/ns# ls
cgroup  ipc  mnt  net  pid  user  uts

root@mo-e33e22ea6:/proc/57/ns# ls -l
total 0
lrwxrwxrwx 1 root root 0 Jul  3 15:43 cgroup -> cgroup:[4026531835]
lrwxrwxrwx 1 root root 0 Jul  3 15:43 ipc -> ipc:[4026531839]
lrwxrwxrwx 1 root root 0 Jul  3 15:43 mnt -> mnt:[4026531840]
lrwxrwxrwx 1 root root 0 Jul  3 15:43 net -> net:[4026531957]
lrwxrwxrwx 1 root root 0 Jul  3 15:43 pid -> pid:[4026531836]
lrwxrwxrwx 1 root root 0 Jul  3 15:43 user -> user:[4026531837]
lrwxrwxrwx 1 root root 0 Jul  3 15:43 uts -> uts:[4026531838]
~~~

If two pids pointed to the same series number, means that they are in the same namespace.

一旦文件被打开, 如果打开的文件描述符fd存在, 那么, 即使pid里面的进程全部都结束了, 这个namespace也会一直存在. 那么, 如何打开文件描述符?

~~~bash
touch ~/uts
mount --bind /proc/27514/ns/uts ~/uts
~~~

## 2.3 Join a namespace with setns()

From 2.2, we can see that with **mount** operation, we can keep a namespace living. We can join this living namespace with function **setns()**

~~~cpp
int setns(int fd, int nstype);
~~~

- int fd: the fd of namespace we want to join. this is something pointed to /proc/[pid]/ns
- int nstype: check if the namespace pointed by fd respect our needs. 0 = ignore the check.

~~~go
fd = open(argv[1], O_RDONLY);   /* 获取namespace文件描述符 */
setns(fd, 0);                   /* 加入新的namespace */
execvp(argv[2], &argv[2]);      /* 执行程序 */
~~~

execvp() can execute the command from user. Assume the programme has a name of setns :

~~~bash
./setns ~/uts /bin/bash
~~~

This will allow us running bash commands in the namespace indicated.

## 2.4 Using unshare()

~~~cpp
int unshare(int flags);
~~~
不启动新进程, 然后使用这个来达到一个隔离的效果. In Linux there is a **unshare** command, it is originated from the unshare() function.

## 2.5 fork()

这里是作为一个区分, 事实上fork并不属于namespace的API, 但是当被调用的时候, 确实创建一个一个新的进程, 然后把原来的进程复制到新的进程之中.  相当于克隆了一个自己.

fork的特点是:*被调用一次, 但是返回两次*. 父进程一次, 子进程一次, 通过返回值的不同, 可以进行区分. 它有三种不同的返回值:

1. 在父进程中,fork返回子进程的进程ID
2. 子进程之中, fork返回0
3. 如果出现错误, fork返回一个负值.

~~~cpp
#include <unistd.h>
#include <stdio.h>
int main (){
    pid_t fpid; //fpid表示fork函数返回的值
    int count=0;
    fpid=fork();
    if (fpid < 0)printf("error in fork!");
    else if (fpid == 0) {
        printf("I am child. Process id is %d/n",getpid());
    }
    else {
        printf("i am parent. Process id is %d/n",getpid());
    }
    return 0;
}

root@local:~# gcc -Wall fork_example.c && ./a.out
I am parent. Process id is 28365
I am child. Process id is 28366
~~~


# 3 Six types Namespace

## 3.1 UTS Unix Time-sharing System Namespace


~~~cpp
#define _GNU_SOURCE
#include <sys/types.h>
#include <sys/wait.h>
#include <stdio.h>
#include <sched.h>
#include <signal.h>
#include <unistd.h>

#define STACK_SIZE (1024 * 1024)

static char child_stack[STACK_SIZE];
char* const child_args[] = {
        "/bin/bash",
        NULL
};

int child_main(void* args) {
        printf("In the Child Process!\n");
        sethostname("Changed Namespace",12);
        execv(child_args[0], child_args);
        return 1;
}

int main() {
        printf("In the parent Process, BEGIN! \n");
        int child_pid = clone(child_main, child_stack + STACK_SIZE, CLONE_NEWUTS | SIGCHLD, NULL);
        waitpid(child_pid, NULL, 0);
        printf("Over\n");
        return 0;
}
~~~

~~~bash
root@mo-e33e22ea6:/home/i340738/NameSpaceLearning# gcc -Wall uts.c -o utsNamespace
root@mo-e33e22ea6:/home/i340738/NameSpaceLearning# ls
uts.c  utsNamespace
root@mo-e33e22ea6:/home/i340738/NameSpaceLearning# ./utsNamespace
In the parent Process, BEGIN!
In the Child Process!
root@Changed Name:/home/i340738/NameSpaceLearning# exit
exit
Over
~~~

通过上面的实验已经可以看出, 主机名在子进程之中已经被改变了. Docker 中每一个镜像都有自己的主机名, 也就是依据这个原理.

# Reference

## Links :
<a href="http://www.infoq.com/cn/articles/docker-kernel-knowledge-namespace-resource-isolation">Namespace Isolation</a>
<a href="http://www.infoq.com/cn/articles/docker-kernel-knowledge-cgroups-resource-isolation">Cgroup resource isolation</a>

## Code

### Join

~~~cpp
/* ns_exec.c

   Copyright 2013, Michael Kerrisk
   Licensed under GNU General Public License v2 or later

   Join a namespace and execute a command in the namespace
*/
#define _GNU_SOURCE
#include <fcntl.h>
#include <sched.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>

/* A simple error-handling function: print an error message based
   on the value in 'errno' and terminate the calling process */

#define errExit(msg)    do { perror(msg); exit(EXIT_FAILURE); \
                        } while (0)

int main(int argc, char *argv[])
{
    int fd;

    if (argc < 3) {
        fprintf(stderr, "%s /proc/PID/ns/FILE cmd [arg...]\n", argv[0]);
        exit(EXIT_FAILURE);
    }

    fd = open(argv[1], O_RDONLY);   /* Get descriptor for namespace */
    if (fd == -1)
        errExit("open");

    if (setns(fd, 0) == -1)         /* Join that namespace */
        errExit("setns");

    execvp(argv[2], &argv[2]);      /* Execute a command in namespace */
    errExit("execvp");
}
~~~
