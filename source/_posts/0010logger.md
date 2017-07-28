---
  title: Using Logger
  categories: Java
  tags:
    - logger
---


<blockquote class="blockquote-center">Today I was told by my prof Professor at SAP using the Logger instead of System.out.println() in my code. And ..... What's that????!</blockquote>


# Create Logger Object

要使用J2SE的Logger功能 首先要取得 java.util.logging.Logger实例. 这个可以通过两个方法做到:

~~~java
//查找或者创建一个Logger
  static Logger getLogger(String name);
//为子系统查找或者创建一个Logger
  static Logger = getLogger(String name, String resourceBundleName);
~~~


**Example**:

~~~java
import java.util.logging.Logger;
public class Ex20Logger {

    public static void main(String [] args ){
        Logger logger = Logger.getLogger("demo");
        try{
            System.out.println(args[0]);
        } catch (ArrayIndexOutOfBoundsException e){
            logger.warning("No args Founded");
        }
    }

}
~~~

Output:

~~~bash
juil. 28, 2017 4:32:45 PM Ex20Logger main
WARNING: No args Founded
~~~

# Level of Logger

The levels are defined in <i><font color="violet">java.util.logging.Level</font></i>. From the most important to less :

> SEVERE > WARNING > INFO > CONFIG > FINE > FINER > FINEST


## Default Level

**Default print level is INFO, the messages less important than INFO will not be printed to screen.** The default value can be setup in repository jre/lib

~~~bash
# Limit the message that are printed on the console to INFO and above.
java.util.logging.ConsoleHandler.level = INFO
~~~

**Example:**

Adding this to the previous example:

~~~java
logger.severe("Severe Warning");
logger.warning("just warning");
logger.info("Normal Info Msg");
logger.config("Config  Msg");
logger.fine("Fine Msg");
logger.finer("Finer Msg");
logger.finest ("Finest Msg");
~~~

**The result is **

~~~bash

juil. 28, 2017 4:43:25 PM Ex20Logger main
WARNING: No args Founded
juil. 28, 2017 4:43:25 PM Ex20Logger main
SEVERE: Severe Warning
juil. 28, 2017 4:43:25 PM Ex20Logger main
WARNING: just warning
juil. 28, 2017 4:43:25 PM Ex20Logger main
INFO: Normal Info Msg
~~~

## Logger Handler

The default handler is java.util.logging.ConsolerHandler. A Logger may have several different handler, each of them has their own level control. Let's see how to set it up.

Adding to the previous Demo program:

~~~java
//Show all Message, simplely with this will not work.
logger.setLevel(Level.ALL);

//Add Handler + set Level to ALL
ConsoleHandler consoleHandler = new ConsoleHandler();
consoleHandler.setLevel(Level.ALL);

//make consoleHandler the Handler of logger
logger.addHandler(consoleHandler);
~~~

Then we have all the warning here:

~~~bash
juil. 28, 2017 4:55:22 PM Ex20Logger main
WARNING: No args Founded
juil. 28, 2017 4:55:22 PM Ex20Logger main
WARNING: No args Founded
juil. 28, 2017 4:55:22 PM Ex20Logger main
SEVERE: Severe Warning
juil. 28, 2017 4:55:22 PM Ex20Logger main
SEVERE: Severe Warning
juil. 28, 2017 4:55:22 PM Ex20Logger main
WARNING: just warning
juil. 28, 2017 4:55:22 PM Ex20Logger main
WARNING: just warning
juil. 28, 2017 4:55:22 PM Ex20Logger main
INFO: Normal Info Msg
juil. 28, 2017 4:55:22 PM Ex20Logger main
INFO: Normal Info Msg
juil. 28, 2017 4:55:22 PM Ex20Logger main
CONFIG: Config  Msg
juil. 28, 2017 4:55:22 PM Ex20Logger main
FINE: Fine Msg
juil. 28, 2017 4:55:22 PM Ex20Logger main
FINER: Finer Msg
juil. 28, 2017 4:55:22 PM Ex20Logger main
FINEST: Finest Msg
~~~

## Another Quick Approche

~~~java
Logger logger = Logger.getLogger("LoggingDemo");
logger.log(Level.SEVERE, "Important");
~~~

# Detail on handlers

1. java.util.logging.ConsoleHandler : System.err
2. java.util.logging.FileHandler: output to file
3. java.util.logging.StreamHandler: to Stream
4. java.util.logging.SocketHandler: to Socket
5. java.util.logging.MemoryHandler: temporarily in MEM


Example "To File"

~~~java
public class LoggingDemo {
    public static void main(String[] args){
        Logger logger = Logger.getLogger("LoggingDemo");

        try {
            FileHandler fileHandler = new FileHandler("D:\\test/3.txt");
            logger.addHandler(fileHandler);
            logger.info("测试信息");
        } catch (SecurityException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

}
~~~

We'll see that the txt is in format XML

# Formatter

Two important Formatter :

- java.util.logging.SimpleFormatter:
> 2004-12-20 23:08:52 org.apache.coyote.http11.Http11Protocol init
> 信息: Initializing Coyote HTTP/1.1 on http-8080
- java.util.logging.XMLFormatter


从上一节的例子可知，FileHandler的默认格式是java.util.logging.XMLFormatter，而ConsolerHandler的默认格式是java.util.logging.SimpleFormatter，可以使用Handler实例的setFormatter()方法来设定信息的输出格式。例如：

fileHandler.setFormatter(new SimpleFormatter());

Example:

~~~java
try {
    FileHandler fileHandler = new FileHandler("./logger.log");
    logger.addHandler(fileHandler);
    fileHandler.setFormatter(new SimpleFormatter()); // or new XMLFormatter()
} catch(SecurityException e){
    e.printStackTrace();
} catch (IOException e){
    e.printStackTrace();
}
~~~

# Personalize

## Handler:

Rewrite :

- publish：主要方法，把日志记录写入你需要的媒介。
- flush：清除缓冲区并保存数据。
- close：关闭控制器。

## Formatter

除了XMLFormatter与SimpleFormatter之外，也可以自定义日志的输出格式，只要继承抽象类Formatter，并重新定义其format()方法即可。format()方法会传入一个java.util.logging.LogRecord对象作为参数，可以使用它来取得一些与程序执行有关的信息。


## Level

 | Type | Iteger |
 |:----------------:|:----------------:|
 | OFF |        最大整数（ Integer. MAX_VALUE）|
 | SEVERE |    1000 |
 | WARNING |  900 |
 | INFO    |     800 |
 | CONFIG  |    700 |
 | FINE   |       500 |
 | FINER   |     400 |
 | FINEST   |   300 |
 | ALL     |      最小整数（Integer. MIN_VALUE）|

Example :

~~~java
public class AlertLevel extends Level{

    /**
     * @param name
     * @param value
     */
    protected AlertLevel(String name, int value) {
        super(name,value);
    }

    public static void main(String[] args){
        Logger logger = Logger.getAnonymousLogger();
        //低于INFO（800），显示不出来，因为默认的配置 java.util.logging.ConsoleHandler.level = INFO
        logger.log(new AlertLevel("ALERT",950), "自定义 lever!");
    }
}
~~~

# Hierarchy of Logger

在使用Logger的静态getLogger()方法取得Logger实例时，给getLogger()方法的名称是有意义的。如果给定a，实际上将从根(Root)logger继承一些特性，像日志级别（Level）以及根logger的输出媒介控制器。如果再取得一个Logger实例，并给定名称a.b，则这次取得的Logger将继承pku这个Logger上的特性。从以下范例可以看出Logger在名称上的继承关系：

~~~java
public class LoggerHierarchyDemo {
    public static void main(String[] args){
        Logger onlyfunLogger = Logger.getLogger("a");
        Logger caterpillarLogger = Logger.getLogger("a.b");
        System.out.println("root logger:"+onlyfunLogger.getParent());
        System.out.println("onlyfun logger:" + caterpillarLogger.getParent().getName());
        System.out.println("caterpillar Logger:" + caterpillarLogger.getName() + "\n");
        onlyfunLogger.setLevel(Level.WARNING);
        caterpillarLogger.info("caterpillar ' info");
        caterpillarLogger.setLevel(Level.INFO);
        caterpillarLogger.info("caterpillar ' info");
    }
}
~~~

以上从xingele9017那里转载的.
