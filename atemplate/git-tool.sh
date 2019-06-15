分享工作中常用的一个Git脚本
在实际开发中，我们很频繁的需要从git远程仓库拉取master代码建立分支进行开发，开发完毕后，我们需要push到远程进行build、部署和测试，这里博主根据自己的情况，编写了一个git脚本，让我们只需要关心开发代码，至于开发代码前的git操作步骤自动化完成～

一个自动化脚本


git脚本1-26行



运行这个git脚本，需要项目名／git clone url／你的开发分支名称（比如feature/xxx）



git脚本27-46行



上面脚本的意思，就是想在特定的目录中，进行git clone，并从master新建本地开发分支。



git脚本47-62行



把本地开发分支push到远程，并建立它们之间的关联关系，之后就可以打开idea进行开发啦～

运行结果


运行脚本参数不正确





运行正常







 1 #!/bin/sh
 2
 3 #脚本执行需要3个参数
 4 if [ $# -eq 3 ]
 5 then
 6   echo "开始执行git脚本..."
 7   echo "项目名：$1 , git克隆地址：$2 ， 你的新建分支名称：$3"
 8 else
 9   echo "脚本执行需要3个参数：项目名 git克隆地址 你的新建分支名称"
10   exit -1
11 fi
12
13 #获取当前执行脚本路径
14 dir=`pwd`
15
16 #获取今天的日期,格式:yyyymmdd
17 time=`date +%Y%m%d`
18
19 #项目名
20 project=$1
21
22 #git clone 地址
23 gitcloneurl=$2
24
25 #你的本地分支名称
26 feature=$3
27
28 #删除目录,为新建目录做准备
29 rm -rf "${project}-${time}"
30
31 mkdir "$dir"/"${project}-${time}"
32 cd "$dir"/"${project}-${time}"
33
34 #git clone
35 git clone "$gitcloneurl"
36
37 if [ $? -ne 0 ]; then
38   echo "git clone url 错误"
39   exit -1
40 fi
41
42 #切换到项目根目录
43 cd "$dir"/"${project}-${time}"/"${project}"
44
45 #从master新建本地分支
46 git checkout -b "$feature"
47
48 #git push,创建远程分支
49 git push origin "$feature":"$feature"
50
51 if [ $? -ne 0 ]; then
52 echo "git push 错误"
53 exit -1
54 fi
55
56 #建立本地分支与远程分支的关联关系,为push做准备
57 git branch --set-upstream-to=origin/"$feature"
58
59 #查看分支建立情况
60 git branch -vv
61
62 echo "you can open IntelliJ IDEA to write Java code..."


