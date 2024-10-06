# Device

**查看手机的部分状态**

感谢Cute_9970提供的查看电池状态代码

感谢JARK006提供的查看冻结状态代码

# FBO Check

**查看FBO环境**

感谢The Voyager提供的检测方法

感谢Weverse提供触发条件判断

# Disable_Millet

**关闭Millet的模块，让Noactive更好的工作**

感谢Myflvor的Millet_Config_v2模块

Disable_Millet在Millet_Config_v2的基础上增加了环境判断后写入到模块描述的功能

# Power_status

**此脚本用来查看电池掉电的情况，数据来自dumpsys batterystats，数据仅供参考**

# xiaomi_neofetch

**在Device的基础上，增加了ascii art模仿Linux的neofetch写的，有厂商检测如果不是mi系无法显示内容**

# Noactive inject

**利用Noactive提供的命令注入，来查看应用的状态**

# SCM
**到达设定的电量之后停止充电，支持电流为0时停止充电保证完全充满，支持调整检测频率**

还未完成的功能

- 到达指定温度停充
- 设置充电时最大功率

日志文件：`/data/adb/modules/scm/config/log.txt`

配置文件：`/data/adb/modules/scm/config/config.env`

计数文件：`/data/adb/modules/scm/config/count.env`

感谢Top大佬的QSC定量停充模块

感谢Cong的ShortX-定量停充

# NoActive Additional

**此模块为墓碑附加模块二改，关闭Millet和Hans，为NoAtive提供必要的环境**

修改内容

- 优化模块描述
- ~~增加WebUI~~（已删除）

感谢Timeline && Myflvor的墓碑附加模块

感谢后宫学长的NoActive-附加模块-改版

# PartitionTool

注意：Backup Partition已更名为PartitionTool

使用dd命令对分区进行操作，可以提取分区和刷入分区
