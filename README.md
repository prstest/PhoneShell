# 这是什么？
一个下午学了一点shell，搓出来的一个查看设备信息Shell脚本，在编写这段脚本中学到了很多关于Lunix和Shell以及ADB的知识。
# 两个版本分别代表什么？
version.sh是最新的版本

version_cnTime.sh是version之前几个版本的产物，区别在于编译时间变成了正常的中文显示，但是写法依旧很粗暴。
# 实现的方式
非常没用的写法，无论是检测Root环境还是检测墓碑都是通过包名进行检测，这是一个临时的写法。

获取Noactive版本号的方法也是十分粗暴，直接提取Noactive的Log中的版本号。
# 结论
这是看起来并不是一个通用的脚本，这是一个很没用的脚本，写着玩的。

感谢传播者："Rock&Z"提供的查看电池状态代码

感谢作者："JARK006"提供的查看冻结状态代码
