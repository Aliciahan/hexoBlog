---
  title: The Basic String Operations in Bash Shell
  categories: Shell
  tags:
    - bash
    - string
---


# 1. 一些老司机才知道的 *原来还可以这样*的操作.

 | Expression  | Meaning |
 |:----------------:|:----------------:|
 |${var}| 单纯的取值没什么特别的|
 |${var-$var2}| 如果var不存在, 那就返回var2的值|
 |${var:-$var2}| 如果var不存在, 或者为空, 那就返回var2的值这个主要是把空的字符串当做不存在. |
 |${var1=$var2}| 如果var1不存在, 把var2赋值给var1, 然后返回var2的值 |
 |${var1:=$var2}| 如果var1不存在, 或者var1为空, 把var2赋值给var1, 然后返回var2的值 |
 |${var1+$var2} | 如果var1不存在, 输出 null, 如果存在输出var2, 这里var1的值不变|
 |${var1:+$var2} | 如果var1不存在或者为空, 则输出null, 否则输出var2的值, var1的值不会变 |
 |${!var*} / ${!var@} | 匹配以var开头声明的变量, 注意返回的是变量名 |

~~~bash
####聚个栗子
var2=helloworld
echo ${var-$var2}
#返回 helloworld
var=""
echo ${var-$var2}
#return : ""
echo ${var:-$var2}
#return helloworld
#-------------------------------------
#$var1 do not exist
echo ${var1=$var2}
#return helloworld
echo ${var1}
#return helloworld
#-----------------------------------
> var2="helloworld"
> var1=""
> echo ${var1:=$var2}
helloworld
> echo $var1
helloworld
#-----------------------------------
> var1=""
> echo ${var1+$var2}
helloworld
> echo $var1

> var1="kkk"
> echo ${var1+$var2}
helloworld
> echo $var1
kkk
> echo ${var3+$var2}

#var3 does not exist,  the output is null.
#-----------------------------------------
> ErrorMessage="\033[31m [Error] \033[0m The Variable Does not Existe"
> echo -e ${var4:-$ErrorMessage}
 [Error]  The Variable Does not Existe
#这样达到了, 如果这个值不存在或者是空, 返回错误消息.

#------------------------------------------
#匹配所有以var开头的变量名
> echo ${!var@}
var1 var2
> echo ${!var*}
var1 var2
~~~


# 2 字符串的长度读取和替换

## 2.1 字符串的长度

~~~bash
> var3="1234567"
> echo ${#var3}
7
~~~

## 2.2 截取第x位之后的字符

~~~bash
> echo ${var3:3}
4567
~~~

## 2.3 定位子串的位置

~~~bash

> str=abcdefgab
> expr index $str "a"
1
> expr index $str "x"
0
~~~

## 2.4 截取其中的一部分

~~~bash
> sample=1234567890
> echo ${sample:3:3}
456
# 也可以逆向操作
> str=abcdefgab
> echo ${str:(-3):2}
ga

~~~


## 2.5 加入一点点正则表达式的CUT!

两种情况 (使用正则表达式的时候)

- 截取最短匹配 :一个符号 \#
- 截取最长匹配 :两个符号 \#\#

有关符号的记忆方法:

- \# 是从前面开始数, 键盘上\#也是在%的前面的
- % 是从后面开始数. 键盘layout上面%是在#后面的


~~~bash
> sample=123123456456789789123
> echo ${sample#123}
123456456789789123

> echo ${sample#12*56}
456789789123
> echo ${sample##12*56}
789789123

> str="abbc,def,ghi,abcjkl"
> echo ${str#d*f}
abbc,def,ghi,abcjkl
> echo ${str#*d*f}
,ghi,abcjkl
> echo ${str%a*l}
abbc,def,ghi,
> echo ${str%%a*l}

>
~~~



## 2.6 简单的字符替换

~~~bash
str="apple, tree, apple tree"
echo ${str/apple/APPLE}   # 替换第一次出现的apple
echo ${str//apple/APPLE}  # 替换所有apple
echo ${str/#apple/APPLE}  # 如果字符串str以apple开头，则用APPLE替换它
echo ${str/%apple/APPLE}  # 如果字符串str以apple结尾，则用APPLE替换它

> str="apple, tree, apple tree"
> echo ${str/apple/Apple}
Apple, tree, apple tree
> echo ${str//apple/ApplePie}
ApplePie, tree, ApplePie tree
> echo ${str/#apple/ApplePie}
ApplePie, tree, apple tree
> echo ${str/%tree/ApplePie}
apple, tree, apple ApplePie

~~~

## 2.7 比较

~~~bash
1.[[ "a.txt" == a* ]]        # 逻辑真 (pattern matching)
2.[[ "a.txt" =~ .*\.txt ]]   # 逻辑真 (regex matching)
3.[[ "abc" == "abc" ]]       # 逻辑真 (string comparision)
4.[[ "11" < "2" ]]           # 逻辑真 (string comparision), 按ascii值比较
~~~
