---
  title: Chef Study 1 - Installation
  categories: Cloud
  tags: 
    - Chef
    - Cloud-Computing
---

# Installation of Chef 


1. Download Chef in <a href="https://downloads.chef.io/">Official Download Page</a>

2. Install according to the version of Linux/Windows/Mac 

> rpm -Uvh ./chefdk-2.3.4-1.el7.x86_64.rpm
> dpkg -i chefdk.deb

Often, it will install the Chef and Ruby to /opt/chefdk/embedded we should add this to the PATH. 

~~~bash
echo 'eval "$(chef shell-init bash)"' >> ~/.bash_profile
echo 'export PATH="/opt/chefdk/embedded/bin:$PATH"' >> ~/.bash_profile
source ~/.bash_profile
~~~

3. Check Installation

> which ruby


# Ruby Introduction

## Comments

Ruby use # as comment 

## Variables

~~~ruby
a=1
b="hello"
c=Object.new
~~~

## Calculation, String

Nothing to say.

## Here Doc Presentation

~~~ruby
<< HERE_IS_DOC
blablabla 

sdjfijsidfj

HERE_IS_DOC
~~~

## Array 

types = ['crispy', 'raw', 'crunchy']
types.length
types.size
types.push 'smoked'
types << 'deep fried'

types[0]
types.last
types.first

## Hash

prices = { oscar: 4.55, boars: 5.23}
prices[:oscar]
prices.values

instead of :, the => is often used. 


## RegExp

*=~*

"Bacon is good" =~ /lie/ #=> nil
"Bacon is good" =~ /bacon/ #=> 0
"Bacon is good" !~ /lie/ #=> true





