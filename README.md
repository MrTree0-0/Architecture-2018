# 一个跑到300MHz的CPU 
RISC-V CPU

金乐盛

此次体系结构大作业要求实现一个基于RISC-V指令集的CPU。

## 报告
* My [**Project Report**](doc)

## 难点
1. CPU与Memory的带宽为8位，所以对32位数据的操作需要花起码4个周期
2. 如何在上板之后提高运行速度

## 设计
实现了标准的五级流水，附带了一些微小的优化：

1.Data forwarding: 在EX/MEM后把将要写入内存的数据forwarding至ID；在MEM/WB后把将要Write Back的数据forwarding至ID

2.Static Prediction: 采用Not taken机制，如果后来EX阶段发现错误，将前面流水线寄存器倒空。

3.Over Clock: 提高CPU时钟频率，最高可达300MHz。（2.8s跑完pi，100MHz情况下约9s）

## 模拟
用Verilog进行模拟，使用助教所提供的testbench+testcase进行模拟。

## 上板
将电脑与FPGA连接，将代码的bitstream烧入FPGA，开始运行测试。

## 关于调频
提高频率，从100MHz，到150MHz，到200MHz，到250MHz，到300MHz，还能跑，到350MHz，终于跑不动了。
到300MHz的时候，qsort运行正常。但是WNS已经变成-3ns多了，可见还是运气比较好。
在旧的版本里面，在100MHz的时候，WNS已经接近于0ns，150ns勉强能跑。

短板效应，整个CPU中限制频率的是耗时最长的模块。
诸如像ID、EX、WB这些模块都是组合逻辑，always@* 的操作在布线的时候或多或少会被简化，想当于一堆assign连线，个人认为优化空间不大。
有时序逻辑的地方应该是被简化的重点，所以就开始重构。

在流水线寄存器方面没什么优化，因为本来就写成了DQ锁存器的形式。
然后重点攻克Memory方面，重点是完全采用时序逻辑，完全采用非阻塞赋值，在数据读取或者写入完成后hold一个周期（这个可能可以淡化一部分电路延迟的弊端）。

一句话总结，用最简单的想法写最简单的代码做最简单的事！

## 参考文献
* 雷思磊. 自己动手写 CPU. 电子工业出版社, 2014.
* John L. Hennessy, David A. Patterson, et al. Computer Architecture: A Quantitative
Approach, Fifth Edition, 2012.
* David A. Patterson. PPT of CS252 Graduate Computer Architecture, 2001.
* 夏宇闻. Verilog经典教程

## 特别感谢
特别感谢苏起冬同学展示时提出小而快的想法，陈林淇同学在调试上的指导
