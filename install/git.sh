#!/bin/bash

groupadd git
adduser git -g git
passwd git

cd /home/git/
mkdir .ssh
chmod 700 .ssh
touch .ssh/authorized_keys
chmod 600 .ssh/authorized_keys

cd /home
mkdir gitrepo

chown git:git gitrepo/

cd gitrepo

####################
git init --bare w3cschoolcc.git
###################

chown -R git:git w3cschoolcc.git

# /etc/passwd
# git:x:503:503::/home/git:/bin/bash
# ¸Ŏª£º
# git:x:503:503::/home/git:/sbin/nologin

# 查看当前的远程库
# 查看当前配置有哪些远程仓库,可以用 Git remote 命令,它会列出每个远程库的简短名字.
# 在克隆完某个项目后,至少可以看到一个名为 origin 的远程库,
# Git 默认使用这个名字来标识你所克隆的原始仓库:

git clone git://github.com/schacon/ticgit.git

# 　　Initialized empty Git repository in /private/tmp/ticgit/.git/

# 　　remote: Counting objects: 595, done.

# 　　remote: Compressing objects: 100% (269/269), done.

# 　　remote: Total 595 (delta 255), reused 589 (delta 253)

# 　　Receiving objects: 100% (595/595), 73.31 KiB | 1 KiB/s, done.

# 　　Resolving deltas: 100% (255/255), done.

# 　　$ cd ticgit

#列出已经存在的远程分支

git remote

# origin

# 此时， -v 选项(译注:此为 –verbose 的简写,取首字母),
# 显示对应的克隆地址:

git remote -v
　　
# 　　origin 这样一来,我就可以非常轻松地从这些用户的仓库中,拉取他们的提交到本地.请注意,上面列出的地址只有 origin 用的是 SSH URL 链接,所以也只有这个仓库我能推送数据上去



# 　　要添加一个新的远程仓库,可以指定一个简单的名字,以便将来引用,运行
git remote
# 　　origin

git remote add pb git://github.com/paulboone/ticgit.git

git remote -v

#     origin git://github.com/schacon/ticgit.git

# 　　pb git://github.com/paulboone/ticgit.git

#     现在可以用字串 pb 指代对应的仓库地址了.


# 比如说,要抓取所有 Paul 有的,但本地仓库没有的信息,可以运行 git fetch pb:

git fetch pb

# 　　remote: Counting objects: 58, done.

# 　　remote: Compressing objects: 100% (41/41), done.

# 　　remote: Total 44 (delta 24), reused 1 (delta 0)

# 　　Unpacking objects: 100% (44/44), done.

# 　　From git://github.com/paulboone/ticgit

# 　　* [new branch] master -> pb/master

# 　　* [new branch] ticgit -> pb/ticgit

# 现在,Paul 的主干分支(master)已经完全可以在本地访问了,对应的名字是 pb/master,你可以将它合并到自己的某个分支,或者切换到这个分支



# 二。通过git remote 建立远程仓库

# 1.初始化一个空的git仓库
# 1 software@debian:~$ mkdir yafeng
# 2 software@debian:~$ cd yafeng/
# 3  ls
# 4  git init
# 5 Initialized empty Git repository in /home/software/yafeng/.git/
# 6

# 当然，还有很多同学会看见加了参数--bare的命令，
# 这个命令会在我们以后慢慢给大家解释，对于不是作为共享仓库，而是作为一个自己操作的仓库，上面这样就足够了。

# 好了，现在yafeng目录就是我们的据点---git仓库了哦。

# 2.向仓库提交我们写的文件
# 1  echo "our first git repository" >> file
# 2  ls
# 3 file
# 4  git add file
# 5  git commit -m "the first file to commit" file
# 6 [master (root-commit) 0c72641] the first file to commit
# 7  1 files changed, 1 insertions(+), 0 deletions(-)
# 8  create mode 100644 file
# 9

# 命令解释：
# 我们在仓库中新建了一个文件file，作为我们的示例文件。

# 第4行：将file文件的信息添加到git仓库的索引库中，并没有真正添加到库。当然上例中的file文件只是我们的示例，它是一个路径，因此，可以是文件，更可以是目录。

# 第5行：将索引库中的内容向git仓库进行提交。这步之后文件file才算真正提交到拉git仓库中。双引号中的内容是根据每次修改的不同内容，由我们自己去填写的，

# 很多人会看见

git commit -a -m “ ”

# 这条的命令是在你已经add了一个或多个文件过之后，然后修改了这些文件，就可以使用该命令进行提交。

#好了，不管怎么样，终于是将文件提交到库了。可是现在的仓库只是一个本地的仓库，我们的目标是变成远程仓库哦，继续吧。

# 在本地仓库添加一个远程仓库,并将本地的master分支跟踪到远程分支
# 第1行:在本地仓库添加一个远程仓库,当然ssh后面的地址是我们本地仓库的地址.
git remote add origin ssh://software@172.16.0.30/~/yafeng/.git


#第2行:将本地master分支跟踪到远程分支,在git仓库建立之初就会有一个默认的master分支,当然你如果建立了其他分支,也可以用同样的方法去跟踪.
git push origin master
#  software@172.16.0.30's password:
#  Everything up-to-date


# 做到拉这一步了吗?我告诉你,你已经完成目的了哦,现在的git仓库已经是一个远程仓库了,
# 现在本机上看看:
git remote show origin
 #  software@172.16.0.30's password:
 #  * remote origin
 #    Fetch URL: ssh://software@172.16.0.30/~/yafeng/.git
 #    Push  URL: ssh://software@172.16.0.30/~/yafeng/.git
 #    HEAD branch: master
 #    Remote branch:
 #      master tracked
 #    Local ref configured for 'git push':
#      master pushes to master (up to date)




# 在另一个机子上,远程clone
  # root@yafeng-VirtualBox:~# ls
  # bin  gittest  read_temp
  # root@yafeng-VirtualBox:~# git clone ssh://software@172.16.0.30/~/yafeng/.git
  # Cloning into yafeng...
  # software@172.16.0.30's password:
  # remote: Counting objects: 9, done.
  # remote: Compressing objects: 100% (3/3), done.
  # remote: Total 9 (delta 0), reused 0 (delta 0)
  # Receiving objects: 100% (9/9), done.
  # root@yafeng-VirtualBox:~# ls
  # bin  gittest  read_temp  yafeng
  # root@yafeng-VirtualBox:~# cd yafeng/
  # oot@yafeng-VirtualBox:~/yafeng# ls
  # file
  # root@yafeng-VirtualBox:~/yafeng#
  #第3行:就是远程clone仓库.很明显的对比可以知道多了yafeng目录,而这个yafeng目录里的内容和我们另外一台机子上的内容一样

##############
ssh

#!/bin/bash
#####################################################################################
# # 创建和使用git ssh key
#首先设置git的user name和email
 git config --global user.name "ub01"
 git config --global user.email "ub01@aiso.com"

# 查看git配置
 git config --list

 # 然后生成SHH密匙查看是否已经有了ssh密钥：
 cd ~/.ssh
# 如果没有密钥则不会有此文件夹，有则备份删除

# 生成密钥
 ssh-keygen -t rsa -C "ub01@aiso.com"

 # 按3个回车，密码为空这里一般不使用密钥。
# 最后得到了两个文件：id_rsa和id_rsa.pub

# 注意：密匙生成就不要改了，如果已经生成到~/.ssh文件夹下去找。


#拷贝公钥到remote
ssh -T git@xyz01.aiso.com
git@git.avcdata.com:vboxdata/tracker-job.git

##################


# 使用git在本地创建一个项目的过程
mkdir ~/hello-world

# //创建一个项目hello-world
cd  ~/hello-world

# //打开这个项目
git init

# //初始化
touch README

git add README

# //更新README文件
git commit -m 'first commit'

# //提交更新，并注释信息“first commit”
git remote add origin git@github.test/hellotest.git

# //连接远程github项目
git push -u origin master
# //将本地项目更新到github项目上去


# git设置关闭自动换行
# 为了保证文件的换行符是以安全的方法，避免windows与unix的换行符混用的情况，最好也加上这么一句
git config --global core.autocrlf false
git config --global core.safecrlf true

# 列出当前仓库的所有标签

git tag  # 查看当前分支下的标签
git tag -l 'v0.1.*'  # 搜索符合当前模式的标签
git tag v0.2.1-light  # 创建轻量标签
git tag -a v0.2.1 -m '0.2.1版本'  # 创建附注标签
git checkout [tagname]  # 切换到标签
git show v0.2.1  # 查看标签版本信息
git tag -d v0.2.1  # 删除标签
git tag -a v0.2.1 9fbc3d0  # 补打标签
git push origin v0.1.2  # 将v0.1.2标签提交到git服务器
git push origin --tags  # 将本地所有标签一次性提交到git服务器




# You asked me to pull without telling me which branch you
# want to merge with, and 'branch.content_api_zhangxu.merge' in
# your configuration file does not tell me, either. Please
# specify which branch you want to use on the command line and
# try again (e.g. 'git pull <repository> <refspec>').
# See git-pull(1) for details.
# If you often merge with the same branch, you may want to
# use something like the following in your configuration file:
    # [branch "content_api_zhangxu"]
    # remote = <nickname>
    # merge = <remote-ref>
    # [remote "<nickname>"]
    # url = <url>
    # fetch = <refspec>See git-config(1) for details.

git pull origin new_branch


# 怎样遍历移除项目中的所有 .pyc 文件
# sudo find /tmp -name "*.pyc" | xargs rm -rf
# 替换/tmp目录为工作目录
 git rm *.pyc

 # 这个用着也可以
# 避免再次误提交，在项目新建.gitignore文件，输入*.pyc过滤文件
# git变更项目地址
git remote set-url origin git@192.168.6.70:res_dev_group/test.git
git remote -v

# 查看某个文件的修改历史
git log --pretty=oneline 文件名 # 显示修改历史
git show 356f6def9d3fb7f3b9032ff5aa4b9110d4cca87e # 查看更改
# git push 时报错 warning: push.default is unset

# ‘matching’ 参数是 Git 1.x 的默认行为，其意是如果你执行 git push 但没有指定分支，它将 push 所有你本地的分支到远程仓库中对应匹配的分支。而 Git 2.x 默认的是 simple，意味着执行 git push 没有指定分支时，只有当前分支会被 push 到你使用 git pull 获取的代码。
# 根据提示，修改git push的行为:

 git config –global push.default matching
# 再次执行git push 得到解决
# it submodule的使用拉子项目代码开发过程中，经常会有一些通用的部分希望抽取出来做成一个公共库来提供给别的工程来使用，而公共代码库的版本管理是个麻烦的事情。今天无意中发现了git的git submodule命令，之前的问题迎刃而解了。


# 添加
# 为当前工程添加submodule，命令如下：
# git submodule add 仓库地址 路径
# 其中，仓库地址是指子模块仓库地址，路径指将子模块放置在当前工程下的路径。
# 注意：路径不能以 / 结尾（会造成修改不生效）、不能是现有工程已有的目录（不能順利 Clone）
# 命令执行完成，会在当前工程根路径下生成一个名为“.gitmodules”的文件，其中记录了子模块的信息。添加完成以后，再将子模块所在的文件夹添加到工程中即可。


# 删除
# submodule的删除稍微麻烦点：首先，要在“.gitmodules”文件中删除相应配置信息。然后，执行git rm –cached命令将子模块所在的文件从git中删除。


# 下载的工程带有submodule

# 当使用git clone下来的工程中带有submodule时，初始的时候，submodule的内容并不会自动下载下来的，此时，只需执行如下命令：

 git submodule update --init --recursive
# 1
# 即可将子模块内容下载下来后工程才不会缺少相应的文件。
# 一些错误“pathspec ‘branch’ did not match any file(s) known to git.”错误
 git checkout master
 git pull
 git checkout new_branch

# 使用git提交比较大的文件的时候可能会出现这个错误
# error: RPC failed; result=22, HTTP code = 411
# fatal: The remote end hung up unexpectedly
# fatal: The remote end hung up unexpectedly
# Everything up-to-date
# 这样的话首先改一下git的传输字节限制
 git config http.postBuffer 524288000

# error: RPC failed; result=22, HTTP code = 413
# fatal: The remote end hung up unexpectedly
# fatal: The remote end hung up unexpectedly
# Everything up-to-date

# 这两个错误看上去相似，一个是411，一个是413

# 下面这个错误添加一下密钥就可以了

# 首先key-keygen 生成密钥
# 然后把生成的密钥复制到git中自己的账号下的相应位置
 git push ssh://192.168.64.250/eccp.git branch
# git add文件取消在git的一般使用中，如果发现错误的将不想提交的文件add进入index之后，想回退取消，则可以使用命令：

 git reset HEAD <file>...
# 同时git add完毕之后，git也会做相应的提示。
# git删除文件删除文件跟踪并且删除文件系统中的文件file1

 git rm file1
# 提交刚才的删除动作，之后git不再管理该文件

 git commit

 # 删除文件跟踪但不删除文件系统中的文件
# file1git rm --cached file1

# 提交刚才的删除动作，之后git不再管理该文件，但是文件系统中还是有file1
 git commit
# 1
# 版本回退版本回退用于线上系统出现问题后恢复旧版本的操作，回退到的版本。
 git reset --hard 248cba8e77231601d1189e3576dc096c8986ae51
# 1
# 回退的是所有文件，如果后悔回退可以git pull就可以了。
# 历史版本对比查看日志
git log
# 查看某一历史版本的提交内容，这里能看到版本的详细修改代码。
git show 4ebd4bbc3ed321d01484a4ed206f18ce2ebde5ca
# 1
# 对比不同版本
git diff c0f28a2ec490236caa13dec0e8ea826583b49b7a 2e476412c34a63b213b735e5a6d90cd05b014c33

# 分支的意义与管理创建分支可以避免提交代码后对主分支的影响，同时也使你有了相对独立的开发环境。

# # 创建并切换分支，提交代码后才能在其它机器拉分支代码
git checkout -b new_branch

# # 查看当前分支
git branch

# # 切换到master分支
 git checkout master

 # # 合并分支到当前分支，合并分支的操作是从new_branch合并到master分支，当前环境在master分支。
 git merge new_branch

 # # 删除分支
 git branch -d new_branch


#####################################################git冲突##################################
# # git冲突文件编辑冲突文件冲突的地方如下面这样
# a123
# <<<<<<< HEAD
# b789
# =======
# b45678910>>>>>>> 6853e5ff961e684d3a6c02d4d06183b5ff330dccc
# 冲突标记<<<<<<< （7个<）与=======之间的内容是我的修改，
#=======与>>>>>>>之间的内容是别人的修改。
# 此时，还没有任何其它垃圾文件产生。

# 你需要把代码合并好后重新走一遍代码提交流程就好了。

# 不顺利的代码提交流程在git push后出现错误可能是因为其他人提交了代码，而使你的本地代码库版本不是最新。

# 这时你需要先git pull代码后，检查是否有文件冲突。

# 没有文件冲突的话需要重新走一遍代码提交流程add —> commit —> push。


# git顺利的提交代码流程查看修改的文件
git status

 # # 为了谨慎检查一下代码
git diff
# # 添加修改的文件，新加的文件也是直接add就好了
git add dirname1/filename1.py dirname2/filenam2.py
# # 添加修改的日志
git commit -m "fixed:修改了上传文件的逻辑"
# # 提交代码
git push
#，如果提交失败的可能原因是本地代码库版本不是最新。
# # 理解github的pull request有一个仓库，叫RepoA。你如果要往里贡献代码，
# 首先要Fork这个Repo，于是在你的Github账号下有了一个Repo A2,。
# 然后你在这个A2下工作，commit，push等。
# 然后你希望原始仓库Repo A合并你的工作，你可以在Github上发起一个Pull Request，
# 意思是请求Repo A的所有者从你的A2合并分支。如果被审核通过并正式合并，这样你就为项目A做贡献了。







# git init

git clone git@github.com:schacon/simplegit.git yourname
git status -s

#将文件添加到缓存
git add README hello.php
#git status 以查看在你上次提交之后是否有修改。
git status -s
#命令来添加当前项目的所有文件。
git add .
vim README
#<pre>
#<p>在 README 添加以下内容：<b># Runoob Git 测试</b>，然后保存退出。</p>
#<p>再执行一下 git status：</p>
git status -s
#AM README
#A  hello.php
#"AM" 状态的意思是，这个文件在我们将它添加到缓存之后又有改动。
git add .
git status -s
#A  README
#A  hello.php
#  (use "git rm --cached <file>..." to unstage)
# 查看执行 git status 的结果的详细信息。
git diff
#git diff 命令显示已写入缓存与已修改但尚未写入缓存的改动的区别。
# 尚未缓存的改动：git diff

# 查看已缓存的改动： git diff --cached

# 查看已缓存的与未缓存的所有改动：git diff HEAD

# 显示摘要而非整个 diff：git diff --stat
# 在 hello.php 文件中输入以下内容：
# <?php
# echo '菜鸟教程：www.runoob.com';
# ?>
#  git status -s
# A  README
# AM hello.php
#  git diff
# diff --git a/hello.php b/hello.php
# index e69de29..69b5711 100644
# --- a/hello.php
# +++ b/hello.php
# @@ -0,0 +1,3 @@
# +<?php
# +echo '菜鸟教程：www.runoob.com';
# +?>
# git status 显示你上次提交更新后的更改或者写入缓存的改动，
# git diff 一行一行地显示这些改动具体是啥。
git add hello.php
git status -s
# A  README
# A  hello.php
git diff --cached
# diff --git a/README b/README
# new file mode 100644
# index 0000000..8f87495
# --- /dev/null
# +++ b/README
# @@ -0,0 +1 @@
# +# Runoob Git 测试
# diff --git a/hello.php b/hello.php
# new file mode 100644
# index 0000000..69b5711
# --- /dev/null
# +++ b/hello.php
# @@ -0,0 +1,3 @@
# +<?php
# +echo '菜鸟教程：www.runoob.com';
# +?>
# git commit 将缓存区内容添加到仓库中。
# Git 为你的每一个提交都记录你的名字与电子邮箱地址，所以第一步需要配置用户名和邮箱地址。
git config --global user.name 'xiaoyuzhou'
git config --global user.email ub01@aiso.com

# -m 选项以在命令行中提供提交注释。
git commit -m '第一次版本提交'
# [master (root-commit) d32cf1f] 第一次版本提交
 # 2 files changed, 4 insertions(+)
 # create mode 100644 README
 # create mode 100644 hello.php

git status
# On branch master
# nothing to commit (working directory clean)
# 以上输出说明我们在最近一次提交之后，没有做任何改动，是一个"working directory clean：干净的工作目录"。
# 如果你没有设置 -m 选项，Git 会尝试为你打开一个编辑器以填写提交信息。
# 如果 Git 在你对它的配置中找不到相关信息，默认会打开 vim。屏幕会像这样：
# Please enter the commit message for your changes. Lines starting
# with '#' will be ignored, and an empty message aborts the commit.
# On branch master
# Changes to be committed:
#   (use "git reset HEAD <file>..." to unstage)
#
# modified:   hello.php
#

# ".git/COMMIT_EDITMSG" 9L, 257C
# 如果你觉得 git add 提交缓存的流程太过繁琐，Git 也允许你用 -a 选项跳过这一步。

# 我们先修改 hello.php 文件为以下内容：
# <?php
# echo '菜鸟教程：www.runoob.com';
# echo '菜鸟教程：www.runoob.com';
# ?>

# 再执行以下命令：
git commit -am '修改 hello.php 文件'
# [master 71ee2cb] 修改 hello.php 文件
 # 1 file changed, 1 insertion(+)
# git reset HEAD
# git reset HEAD 命令用于取消已缓存的内容。


# 我们先改动文件 README 文件，内容如下：
# Runoob Git 测试
# 菜鸟教程
# hello.php 文件修改为：
# <?php
# echo '菜鸟教程：www.runoob.com';
# echo '菜鸟教程：www.runoob.com';
# echo '菜鸟教程：www.runoob.com';
# ?>


# 现在两个文件修改后，都提交到了缓存区，我们现在要取消其中一个的缓存，操作如下：
#现在你执行 git commit，只会将 README 文件的改动提交，
#而 hello.php 是没有的。

#将缓存区恢复为我们做出修改之前的样子。
git reset HEAD -- hello.php
# Unstaged changes after reset:
# M	hello.php

git commit -m '修改'
# [master f50cfda] 修改
 # 1 file changed, 1 insertion(+)
 # git status -s
 # M hello.php
# 可以看到 hello.php 文件的修改并未提交。

# 这时我们可以使用以下命令将 hello.php 的修改提交：
git commit -am '修改 hello.php 文件'
# [master 760f74d] 修改 hello.php 文件
 # 1 file changed, 1 insertion(+)

git status
# On branch master
# nothing to commit, working directory clean

# 简而言之，执行 git reset HEAD 以取消之前 git add 添加，但不希望包含在下一提交快照中的缓存。

#################################################################################
# 如我们从缓存区和工作区删除 hello.php文件
git rm hello.php
 # rm 'hello.php'
 # ls
 # README


# 不从工作区中删除文件：
# 如果你要在工作目录中留着该文件，可以使用 git rm --cached：

git rm --cached README
# rm 'README'
# ls
# README

# 重命名磁盘上的文件，
# 然后再执行 git add 把新文件添加到缓存区。
# 我们先把刚移除的 README 添加回来：

git add README
git mv README  README.md
README.md



##############################
应用场景：
我们需要从Client机器上远程登陆Server机器。登陆方式采用RSA密钥免密码登陆方式。其中Client端与Server端都为Ubuntu系统。

Client与Server端用户名都选用phenix（可以不相同）

Server端需要安装并开启SSH服务
Client端需要支持ssh-keygen命令
确认两台机器能够连接到Internet

apt-get install ssh

在命令行模式下执行命令：ssh -V

结果显示ssh版本证明成功
查看Server端phenix用户家目录下是否存在隐藏目录".ssh"
在安装ssh完成后，进入phenix用户家目录，使用命令：ls -al    查看目录结构中是否存在隐藏目录“.ssh”
若存在，则操作正确，若不存在，解决方法如下：
1，按照步骤一，重新安装一遍ssh服务
2，若安装成功后还不存在".ssh"目录，则使用mkdir  .ssh   在家目录下新建一个.ssh目录
一般来说，多数系统在安装完ssh服务后，默认都会自动建立“ssh”隐藏目录，只有少数需要手动创建。
ubuntu系统使用SSH免密码登陆


Client端生成公钥和密钥
我们使用RSA密钥认证的目的是：从Client端登陆Server端时，不需要密码认证。
所以，我们在进行认证时首先需要在Client端建立属于Client端自己的一对密钥（公钥和私钥），建立方法如下：
在命令行下执行：ssh-keygen


执行过程中，它先要求你确认保存公钥的位置（默认为：.ssh/id_rsa），

然后它会让你重复输入一个密码两次，如果不想在使用公钥的时候输入密码，可以留空

执行完毕后，就会生成数据Client端的一对密钥。

执行过程如下图：
SSH 密钥默认储存在账户的家目录下的 ~/.ssh 目录中

关键是看有没有用 xxx_rsa 和 xxx_rsa.pub 来命名的一对文件，有 .pub

后缀的文件就是公钥，另一个文件则是密钥。

生成的一对公私钥，顾名思义：

公钥是公开的，不需要保密，而私钥是由个人自己持有，并且必须妥善保管和注意保密。

生成的密钥截图如下：
将Client端的公钥添加到用于认证的Server端的公钥文件中
首先检查Server端需要认证的phenix用户的家目录下，隐藏目录“ssh”目录下是否存在一个名为“authorized_keys”的文件，

若不存在，使用命令：touch authorized_keys 创建一个空文件

1，将Clinet端公钥的内容复制
2，将复制到的Client端公钥内容，粘贴至Server端刚才创建的 authorized_keys 文件中，保存文件。
3，更改 authorized_keys 文件的权限
执行命令：chmod 600  authorized_keys
Client公钥内容格式大概如下：
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCzKGjCrHNCPCT96TTl8j1UtJ10V9a3fLIdx6R0upKP2N7FJP82Nni/vmAx7UVDhUNCgyfyG5Y6wK8AK2hOGjKLfLdfyYPojwmx3MF8KTspZBmmYKbHWh6Aem4TskRmsHOSpWeqns7o3tle0Ln1GMmPpdFph/owa7vj5/JYSOCBX8c+gGFyJeAMHGTs1fnHhGZRl5mzu8mWIv+qJnDxRmE/jBtuNXzSrPeZ2Cz86U+DfWtXVRyEl9XoIotX+GZ/zPxvPoMoItWD3UL6aA8McCX/PE7BLFA4B1Nl+mefTVpHH39AqcyqkcAJxntoqeNU3IwaM7sx/J7ONrFxp9Z3fjVR phenix@Client

验证无密码登陆
在Client端命令行执行如下命令：
ssh -p12  phenix@10.2.31.33     （本例ssh服务开在了12端口，默认为22）

ssh-keygen执行完毕后一定要检查下phenix用户家目录下.ssh目录中是否有一对密钥
在将公钥粘贴至Server端后，一定要修改authorized_keys文件的权限为600，
否则认证会失败
Server端需要开启SSH服务，不然客户端使用ssh连接不上