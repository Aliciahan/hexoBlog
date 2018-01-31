---
  title: Java 8 简介
  categories: Java
  tags:
    - java 8
---


# Java8的新功能

- Stream: 新并行, 某种程度上可以避免用synchronized方式编写代码.
- 向方法传递代码: Lambda, 方法引用
- 接口中的默认方法

## 流处理

类似Unix系统里面的stdin stdout, 可以用pipe进行操作. 所以Java在 *java.util.stream* 里面增加了 **Stream API**. Java 透明地把输入的布线管的部分拿到几个CPU上面去执行你的Stream操作流水线. 就不用自己搞Thread了.

![Linux pipe](uploads/11-0.png)

## 行为参数化

貌似其实就是可以把一个行为, 或者说是function,作为argument丢进去.

![throw function into sort](uploads/11-1.png)

## 并行 and 共享的 可变数据

不是很懂....

# Java 里面的 函数

## 方法 和 Lambda作为一等公民

把方法作为一等值, 好处就是可以大大的扩充程序员的工具库. 比如Java就没有eval这个js函数.

~~~java
public void printDir(){
    File[] dirFiles = new File(".").listFiles(File::isDirectory);
    for(File f:dirFiles){
        System.out.println("The Dirs : "+ f);
    }
}
~~~

## Lambda 表达式


## 传递代码
