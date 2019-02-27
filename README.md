##关键词
GlobalAlloc CreateFileMapping Shared Memory 共享内存
## 用于跨程序的通信
主要有两种方案 GlobalAlloc CreateFileMapping
主要实现了一个Record和一个流 的内存共享
## 解决方案1
+ GlobalAlloc 生成内存 搞出的 Handle 放在剪切板上
	+ 1.代码和理解较简单
	+ 2.但是每一个程序都要生成一个 全局内存块, 只是粘贴板上放的不一样而已
## 解决方案2	
+ 通过 -> CreateFileMapping 生成唯一内存
    + 1.释放的时候有一点点难理解
	+ 2.所有程序仅仅生成一个内存块, A生成的好像是必须A释放, 即B无法释放A创建的内存块, 而是重新获取到, 但是否会修改Size?????  可能会有问题(目前测试没有问题)
	+ 3.调试不抱错, 非调试部分情况跟下CreateFileMapping报错(以管理员运行-> OK)
	+ (权限问题-> CreateFileMapping调试中创建第一遍之后就没有问题了)
## 解决方案总结:	
+ 目前测试 采用了一个Record(记录Stream大小,和其他的信息) 加 一个Stream的 方式, 两种方式都是OK的
+ GlobalAlloc-> 自带锁 CreateFileMapping需自己写锁
+ 是否需要程序关闭后仍然可以粘贴? GlobalAlloc 不可以: CreateFileMapping 可以(但是不好释放)
