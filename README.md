时间日志同步到GoogleCalendar (timelog_to_google_cal)
=======

# 背景
> 既然“管理时间”是不可能的，那么解决方法就只能是，想尽一切办法真正了解自己，真正了解时间、精确地感知时间；而后再想尽一切办法是自己以及自己的行为与时间“合拍”，就是我的说法--“与时间做朋友”

> **----李笑来，把时间当做朋友**



这个项目的灵感来自于一本叫做[《奇特的一生》](http://book.douban.com/subject/1115353/)的一本书，这本书描述的主人公擅长把自己的时间记录起来，之后做一些分析统计，从而提高自己对时间的利用。

在主人公的时代，纸和笔是记录的方式，在我们的时代，就喜欢电子化了。

我最开始是通过APP 操作，将数据写入 **谷歌日历** 上的，但是我发现了一些问题：

- 打开日历太麻烦了
- 日历的时间选择很麻烦，要点很多次手机屏幕，还得精确操作
- 选完日期还得选标题 又要切换

我觉得更快速的方式应该是使用 Evernote 直接以文本形式来记录时间开销，直接打字就好了，不用转换，而且同步起来个人觉得还是挺方便的

但是文字记录可视化程度不高，很难直观的看出时间利用率，那么我们就简单点，写个程序，将文字转化为Google Calendar 的事件。

我在做拆字的时候，有一个原则，就是    文字输入，一定要简单
这是一条典型的记录

```
1000 1130 做RubyOnRails的练习

```

代表从10点到11点30 做了ruby on rails 的练习。



---
# 初次使用配置
## 1. 确认能访问Google的服务器 

没什么好说的，不行就挂VPN
## 2. 开启Google Calendar API,授权为Service account

**为何是Service Account ** ?

因为我觉得证书登陆比输入密码简单，还不受Cookie的影响什么的，也许以后会改成Desktop Account

** 怎样开启 **

1.  拥有Google 账户
2.  使用这个账户去开启一个新的Project 项目 [https://console.developers.google.com/project](https://console.developers.google.com/project)
3.  点击进入你新开的Project 账户，进入API，打开 Google+ (用来做用户验证) 和 Google calendar 的API 
4.  进入credential 凭证，在OAuth 建立新的Client ID ，之后选择**service account**,保存，之后系统会提示你下载一个 p12结尾的签名文件，存好了别掉了，这是登录的凭证

## 3. 添加Google Project 里 Service Account 的Email 到 Google Calendar 的你记录时间的日历的共享账户，并将其权限选择为“拥有这个日历”
 `**非常重要，我被坑了好久**`  你会在你申请的Project 看到在Oauth下的Service account 有一个Email Address  请把这个地址添加到你Google Calendar 里记录时间的日历的账户共享中
 
 如果你不这么做，**程序就读不到这个日历**




## 4. 确认拥有Ruby 环境
安装ruby请移步[ruby china 的教程](https://github.com/ruby-china/ruby-china/wiki/Mac-OS-X-%E4%B8%8A%E5%AE%89%E8%A3%85-Ruby)


## 5. 安装对应Gem && 修改配置文件

脚本运行

```
git clone https://github.com/jicheng1014/timelog_to_google_cal
cd timelog_to_google_cal
bundle install
touch raw.txt
```

之后把刚下载的.p12 的签名文件保存到项目同级目录下。

修改配置文件 config.yml ，修改 service_account_email  和key_file 的具体值


-------------------

# 日志格式格式
我在做日志格式的时候，有一个原则，就是 文字输入，一定要简单,无论是在电脑上写，还是在手机、平板上输入，都应该力图简洁。

默认是在raw.txt 中写日志，当然我自己是这么干的，写在Evernote 里，之后需要将数据展现的时候，再拷贝到这个文件当中

格式为

```
开始时间 结束时间 做的事情
```

- 使用24小时进制
- 时间为双位，中间没有空格  如下午1点30分   则是1330
- 24点为0点，系统会自动增加一天（对夜猫子友好） 如`2330 0010 跑步` 代表 晚上11点30到凌晨24:10 跑步

这是一条典型的记录

```
1000 1130 做RubyOnRails的练习
1130 1215 吃饭

2300 0010 跑步

```



----
# 使用方法

项目目录下输入 `ruby my_date_log [日期差] [日志文件名]`



**日期差**

考虑到有可能在晚上0点之后更新，故可减少天数，比如现在是凌晨0147 我的日志记录的实际上是昨天的内容，则我的日期差就是 1   

即可执行`ruby my_date_log 1`  可不填写，默认是0 

**日志文件**

日志的文件名，默认是raw.txt

## 特别说明
- 当你多次同步某天的日志到日历的时候也是可以的，程序会自动删除日志当天的老数据（根据内容标签为日志当天日期，你可以在Google Calendar 里点一个日志看他的详细内容，就是以那个为标注删除的）
- 联系方式 atpking#gmail com



----
# TODO
- 直接通过Evernote 的API获取日志，之后自动的同步到Google Calendar
- 做成指令，之后不在项目当前路径上输入


