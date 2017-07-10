---
  title: Vim 的私人定制
  categories: Vim
  tags:
    - vim
    - editor
---

<blockquote class="blockquote-center">本来想要是小清新的Vim, 后来终于在经常要远端ssh工作的动力之下, 忍不住想要对Vim动手了...</blockquote>

# 1. 安装插件管理系统 Bundle

第一步, 肯定是先要下载啦!

~~~bash
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
~~~

第二部, 对 **.vimrc** 进行编辑

我的vim.rc参考设置:

<a href="https://github.com/Aliciahan/Snippets">Alicia's GitHub Snippets</a>


完成啦....

# 2. 插件的列表哪里找?

<a href="http://vim-scripts.org/vim/scripts.html">山东蓝翔在青岛...</a>

# 3. 必要的插件们

## 3.1 目录树

** vim-script/The-NERD-tree

具体的用法可以参照 <a href="https://my.oschina.net/VASKS/blog/388907">这个</a>来搞 简单地转载一下:

### 3.1.1 打开方式

安装好后，命令行中输入vim，打开vim后，在vim中输入:NERDTree，你就可以看到NERDTree的效果了。

为了方便起见，我们设置一下快捷键，在~/.vimrc 文件中添加下面内容， 我的centos6.6还是没有这个~/.vimrc，没关系，创建一个，直接 vim ~/.vimrc 然后添加

> " NERDTree map <F10> :NERDTreeToggle<CR>

这样打开vim后，只要按键盘上的F10就可以显示和隐藏NERDTree的文件浏览了.

### 3.1.2 一些玩儿法

- t: 在新tab中打开
- Ctrl+w+w : 切换Tab

其实这两个就够玩儿了. 再加上

- tabp: tab Previous
- tabn: tab Next

~~~bash
ctrl + w + h    光标 focus 左侧树形目录
ctrl + w + l    光标 focus 右侧文件显示窗口
ctrl + w + w    光标自动在左右侧窗口切换
ctrl + w + r    移动当前窗口的布局位置
o       在已有窗口中打开文件、目录或书签，并跳到该窗口
go      在已有窗口 中打开文件、目录或书签，但不跳到该窗口
t       在新 Tab 中打开选中文件/书签，并跳到新 Tab
T       在新 Tab 中打开选中文件/书签，但不跳到新 Tab
i       split 一个新窗口打开选中文件，并跳到该窗口
gi      split 一个新窗口打开选中文件，但不跳到该窗口
s       vsplit 一个新窗口打开选中文件，并跳到该窗口
gs      vsplit 一个新 窗口打开选中文件，但不跳到该窗口
!       执行当前文件
O       递归打开选中 结点下的所有目录
x       合拢选中结点的父目录
X       递归 合拢选中结点下的所有目录
e       Edit the current dif
双击    相当于 NERDTree-o
中键    对文件相当于 NERDTree-i，对目录相当于 NERDTree-e
D       删除当前书签
P       跳到根结点
p       跳到父结点
K       跳到当前目录下同级的第一个结点
J       跳到当前目录下同级的最后一个结点
k       跳到当前目录下同级的前一个结点
j       跳到当前目录下同级的后一个结点
C       将选中目录或选中文件的父目录设为根结点
u       将当前根结点的父目录设为根目录，并变成合拢原根结点
U       将当前根结点的父目录设为根目录，但保持展开原根结点
r       递归刷新选中目录
R       递归刷新根结点
m       显示文件系统菜单
cd      将 CWD 设为选中目录
I       切换是否显示隐藏文件
f       切换是否使用文件过滤器
F       切换是否显示文件
B       切换是否显示书签
q       关闭 NerdTree 窗口
?       切换是否显示 Quick Help

------------
:tabnew [++opt选项] ［＋cmd］ 文件      建立对指定文件新的tab
:tabc   关闭当前的 tab
:tabo   关闭所有其他的 tab
:tabs   查看所有打开的 tab
:tabp   前一个 tab
:tabn   后一个 tab

~~~

在 vim 启动的时候默认开启 NERDTree（autocmd 可以缩写为 au）

> autocmd VimEnter * NERDTree

按下 F2 调出/隐藏

> NERDTree map :silent! NERDTreeToggle

" 将 NERDTree 的窗口设置在 vim 窗口的右侧（默认为左侧）

> let NERDTreeWinPos="right"

" 当打开 NERDTree 窗口时，自动显示 Bookmarks

> let NERDTreeShowBookmarks=1


## 3.2 重头戏 YCM自动补全

YouCompleteMe是Google里面一个大神搞的. 超级麻烦的一个东西,  Git在 <a href="https://github.com/Valloric/YouCompleteMe">这里</a> 插件名称: 'Valloric/YouCompleteMe'

安装时后, 需要的vim版本很高, 可以用brew或者port来安装, 装好了之后, 不需要动系统自带的vim, 也不用做ln, 直接alias就行:

放到.bash_profile里面就了事儿.

~~~bash
alias vim='/opt/local/bin/vim'
~~~

然后还要编译?! 真他喵的高端啊....

反正按照上面做就行了 以下几点注意

- CMake 要安装, brew install cmake 搞定
- python 需要有
- clang貌似是肯定要.

### 3.2.1 For Linux

~~~bash
# Install Vundle Then
# Plgin 'Valloric/YouCompleteMe'
# :PluginInstall

sudo apt-get install build-essential cmake
sudo apt-get install python-dev python3-dev
cd ~/.vim/bundle/YouCompleteMe
./install.py --clang-completer

~~~

### 3.2.2 For Mac OS

~~~bash
cd ~/.vim/bundle/YouCompleteMe
./install.py --clang-completer
~~~


## 3.3 Snippets 登场


Plugin 'SirVer/ultisnips'
Plugin 'honza/vim-snippets'

然后在.vimrc里面写

~~~bash
function! g:UltiSnips_Complete()
  call UltiSnips#ExpandSnippet()
  if g:ulti_expand_res == 0
    if pumvisible()
      return "\<C-n>"
    else
      call UltiSnips#JumpForwards()
      if g:ulti_jump_forwards_res == 0
        return "\<TAB>"
      endif
    endif
  endif
  return ""
endfunction

function! g:UltiSnips_Reverse()
  call UltiSnips#JumpBackwards()
  if g:ulti_jump_backwards_res == 0
    return "\<C-P>"
  endif

  return ""
endfunction


if !exists("g:UltiSnipsJumpForwardTrigger")
  let g:UltiSnipsJumpForwardTrigger = "<tab>"
endif
if !exists("g:UltiSnipsJumpBackwardTrigger")
  let g:UltiSnipsJumpBackwardTrigger="<s-tab>"
endif

au InsertEnter * exec "inoremap <silent> " . g:UltiSnipsExpandTrigger     . " <C-R>=g:UltiSnips_Complete()<cr>"
au InsertEnter * exec "inoremap <silent> " .     g:UltiSnipsJumpBackwardTrigger . " <C-R>=g:UltiSnips_Reverse()<cr>"

" 如果有snips，直接按tab键就可以完成添加
" tab键往下走，shfit+tab键往上走
~~~

### 3.3.1 自定义 Snippets

~~~bash
mkdir ~/.vim/UltiSnips

touch ~/.vim/UltiSnips markdown.snippets
~~~
# 意外的问题:

## 退格键失灵

那么通关密码是在~/.vimrc中加上set backspace=2。恭喜！你的问题就此解决.
