---
title: "七周七语言之IO学习笔记"
description: ""
categories: ["reading-note"]
tags: ["io-language"]
date: 2015-05-08T09:00:00+08:00
slug: "seven-days-seven-languages-io"
aliases:
  - /reading-note/seven-days-seven-languages-io
  - /reading-note/seven-days-seven-languages-io.html
---


## Io简介
大多数的Io社区都致力于将Io作为带有微型虚拟机和丰富并发特性的可嵌入语言来推广。  
Io的核心优势是拥有大量可定制的语法和函数，以及强有力的并发模型。  
在Io中，万事万物皆为消息，且每条消息都灰返回另一接受消息的对象。Io这门语言没有关键字，有的只是少量在行为上接近于关键字的字符。  

## 对象、原型和继承
Io是一门原型语言，所有的对象都有原型，对象还带有槽（slot，相当于类的域和方法？？）。  
槽的相关操作  
 1.  `:=`当槽不存在，Io会创建一个槽，然后赋值   
 2.  `=`给槽赋值，如果槽不存在，抛出异常  
 3.  `::=`新建槽
 4.  type 任何对象都有type这个槽，返回对象的原型  
 5.  slotNames返回对象的槽名列表  
 6.  getSlot(name)获取槽的内容，如果槽不存在会获取父对象的槽  

Io的类型是一个非常好的机制。从惯用的角度说，以大写开开头的对象时类型，因此Io会对它设置type槽。而类型的复制品若以小写开头则会调用它父对象的type槽。  
<!-- more -->
## 方法
方法是槽的一种？    
方法也是对象，和其它类型的对象一样，你可以获取它的类型。

	Io>method() type  
	==>Block  

Lobby是主命名空间（相当于浏览器中javascript的window？），包含所有已命名的对象。

	Io> Lobby
	  Protos           = Object_0x1dac868
	  _                = Object_0x1dac8c8
	  exit             = method(...)
	  forward          = method(...)
	  set_             = method(...)

 1. 所有事物都是对象； 
 2. 所有与对象的交互都是消息
 3. 你要做的不是实例化类，而是复制那些叫做原型的对象  
 4. 对象会记住它的原型  
 5. 对象有槽  
 6. 槽包含对象（包括方法对象）  
 7. 消息返回槽中的值，或调用槽中的方法  
 8. 如果对象无法响应某消息，它则会把消息发送给自己的原型  

### 单例
true、false和nil都是单例（singleton），对它们进行复制，返回的只是单例对象的值。构建单例只需重定义clone方法，让它返回单例对象自身即可。  


## 第一天自习

1. 对1+1求值，然后对1+"one"求值。Io是强类型还是弱类型？用代码证实你的答案。

		Io> 1+1
		==> 2
		Io> 1+"one"
		
		Exception: argument 0 to method '+' must be a Number, not a 'Sequence'
		---------
		message '+' in 'Command Line' on line 1
		
		Io> "1"+"one"
		
		Exception: Io Assertion 'operation not valid on non-number encodings'
		---------
		message '+' in 'Command Line' on line 1
		
		Io> "1" .. "one"
		==> 1one
		Io> 1 .. "one"
		==> 1one

2.  0是true还是false？空字符串是true还是false？nil是true还是false？用代码证实你的答案。  

		Io> if( 0 , true println,false println)
		true
		==> true
		Io> if( "" , true println,false println)
		true
		==> true
		Io> if( nil , true println,false println)
		false
		==> false

3. 如何知道某个原型具有哪些槽？

		Io> Sequence slotNames foreach(println)
		log
		linePrint
		beforeSeq
		pathComponent
		urlDecoded
		removeSeq
		bitwiseAnd
		removeOddIndexes
		uppercase
		findSeq
		replaceSeq
		cPrint
		logicalOr
		...

4. `=、:=、::=`之间有什么区别？你会在什么时候使用它们？

		Io> OperatorTable
		==> OperatorTable_0x951180:
		Operators
		  0   ? @ @@
		  ...
		
		Assign Operators
		  ::= newSlot
		  :=  setSlot
		  =   updateSlot

	实际测试没有发现::=与:=的区别。

5. 从文件中运行Io程序。
		
		D:\IoCodes>cat sum.io
		sum := 0
		for(i,1,100,
		        sum = sum + i
		)
		sum println
		
		D:\IoCodes>io sum.io
		5050

## 运算符
	
	Io> OperatorTable addOperator("xor",11)
	==> OperatorTable_0x1d61180:
	Operators
	  ...
	  10  && and
	  11  or xor ||
	  12  ..
	  13  %= &= *= += -= /= <<= >>= ^= |=
	  14  return
	
	Assign Operators
	  ::= newSlot
	  :=  setSlot
	  =   updateSlot
	
	To add a new operator: OperatorTable addOperator("+", 4) and implement the + message.
	To add a new assign operator: OperatorTable addAssignOperator("=", "updateSlot") and implement the updateSlot 	message.
	
	Io> true xor := method(bool,if(bool,false,true))
	==> method(bool,
	    if(bool, false, true)
	)
	Io> false xor := method(bool,if(bool,true,false))
	==> method(bool,
	    if(bool, true, false)
	)
	Io> true xor false
	==> true

## 消息
在Io中，几乎一切都是消息。一个消息由三部分组成：发送者（sender)、目标（target）、参数（arguments）。你可以用call方法访问任何消息的元信息。

	//msg.io
	MsgReceiver := Object clone
	MsgReceiver receive := method(
		"message name is : " print
		call message name println
	
		"sender is :" println
		call sender  println
	
		"target is :" println
		call target  println
	
		"arguments is :" println
		call message arguments  println
	
		"arguments[0] is : " print
		call message argAt(0)  println
		"arguments[0] is : " print
		call argAt(0)  type println
		"arguments[0] is : " print
		call evalArgAt(0)  type println
	)
	
	MsgSender := Object clone
	MsgSender send := method(
		"message name is : " print
		call message name println
	
		"sender is :" println
		call sender  println
	
		"target is :" println
		call target  println
		receiver := MsgReceiver clone
		receiver receive("hollo world!")
	)
	
	sender := MsgSender clone
	sender send

	//result:
	message name is : send
	sender is :
	 Object_0x44c890:
	  Lobby            = Object_0x44c890
	  MsgReceiver      = MsgReceiver_0x2171178
	  MsgSender        = MsgSender_0x2171238
	  Protos           = Object_0x44c830
	  _                = nil
	  exit             = method(...)
	  forward          = method(...)
	  sender           = MsgSender_0x21712c8
	  set_             = method(...)
	
	target is :
	 MsgSender_0x21712c8:
	
	message name is : receive
	sender is :
	 MsgSender_0x21712c8:
	
	target is :
	 MsgReceiver_0x217c368:
	
	arguments is :
	list("hollo world!")
	arguments[0] is : "hollo world!"
	arguments[0] is : Message
	arguments[0] is : Sequence
	[Finished in 0.2s]

可以看到，send方法的发送者是全局对象Lobby。
evalArgAt和argAt是两者间的区别：  

> evalArgAt(argNumber)  
>  Evaluates the specified argument of the Call’s message in the context of it’s sender.  
>
> argAt(argNumber)  
>   Returns the message’s argNumber arg. Shorthand for same as call message argAt(argNumber).

大多数语言都将参数作为栈上的值传递，但是Io不是这样。Io传递的是消息本身和上下文，在由接受者对消息求值。实际上你可以用消息实现控制结构。

## 反射
在Io中，处理反射分为两个部分。在邮局那个例子中，是消息反射。对象反射是处理对象和对象的槽。

	Object ancestors := method(
		prototype := self proto
		if(prototype !=Object,
		writeln("Slots of ",prototype type,"\n---------------------")
		prototype slotNames foreach(slotName, writeln(slotName))
		writeln
		prototype ancestors))
	
	Animal := Object clone
	Animal speak := method(
		"ambigulous animal noise" println
	)
	
	Duck := Animal clone
	Duck speak := method(
		"quack" println
	)
	
	Duck walk := method(
		"waddle" println
	)
	
	disco := Duck clone
	disco ancestors
	
	disco walk
	
	disco speak

	***************output:*******************
	Slots of Duck
	---------------------
	walk
	speak
	type
	
	Slots of Animal
	---------------------
	speak
	type
	
	waddle
	quack


## 第二天自习

 1. 计算斐波那契数列的递归和循环两种方法： 
	
		fib := method(n,
			if(n ==1 or n == 2) then(
				return 1
			) else (
				return (fib(n-1) + fib(n-2))
			)
		)
		
		fib2 := method(n,
			if(n == 1) then (
				return 1
			) else (
				prv1 := 1
				prv2 := 0
				cur := 0
				for(i,2,n,
					cur = prv1 + prv2
					prv2 = prv1
					prv1 = cur
				)
				return cur
			)
		)

 2. 在分母为0的情况下如何让运算符/返回0？

		Number setSlot("coreDivision", Number getSlot("/"))

		Number / = method(n,
			if(n==0) then(
				return 0
			)else(
				return (self coreDivision(n))
			)
		)

		(4/0) println
		
		(8/4) println
		
		(16/8) println
		
		(16 / -8) println

 3. 写一个程序，把二维数组的所有数相加  
	Io中没有Array这个原型，所以用List代替数组

		sum := method(arr,
			if(arr type != "List") then(
				return 0
			)
			sum := 0
			arr foreach(e,
				if(e type != "List") then(
					continue
				)
				if(e size < 2) then(
					continue
				)
				sum = sum + e at(0)
				sum = sum + e at(1)
			)
			return sum
		)
		
		sum(list(list(3,4),list(5))) println
		sum(list(7,8)) println

		************output*************
		7
		0

 4. 对列表增加一个名为myAverage的槽，以计算所有数字的平均值。

		List myAverage := method(
			if(self isEmpty) then( return 0 )
			sum := 0
			self foreach(e,
				if(e type != "Number") then(
					Exception raise("List member is not a number") 
				)
				sum = sum + e
			)
			avg := sum / self size
		)
		
		list() myAverage println
		list(3,4,5,1.2) myAverage println

 5. 对二维矩阵写一个原型。该原型dim的方法可为一个包含y个列表的列表分配内存，其中每个列表有x个元素，set(x,y) 方法可以设置类别中的值，get(x,y)方法可返回列表中的值。  

		TwoDArray := Object clone
		TwoDArray dim := method(x,y,
			self data := list()
			for(i,0,x-1,
				innerList := list()
				for(j,0,y-1,
					innerList append(nil)
				)
				data append(innerList)
			)
		)
		
		TwoDArray set := method(x,y,e,
			outterList := self data
			if(x > outterList size, return)
			innerList := outterList at(x)
			if(y > innerList size, return)
			innerList atPut(y,e)
		)
		
		TwoDArray get := method(x,y,
			outterList := self data
			if(x > outterList size, return nil)
			innerList := outterList at(x)
			if(y > innerList size, return nil)
			innerList at(y)
		)
		
		
		arr2 := TwoDArray clone
		arr2 dim(3,4)
		arr2 set(1,2,3)
		arr2 set(1,10,3)
		arr2 get(1,2) println
		arr2 get(1,10) println

	dim(x,y)分配了包含x个列表的列表，每个子列表有y个元素，与题目有点不同，但觉得这样更好理解。	代码没有对数组下标越界抛出异常，抛出异常应该更好。

 6. 写一个转置方法，是原列表上的matrix get(x,y)与转置后的列表(new_matrix get(y,x))相等。
		
		TwoDArray transpose := method(
			outterList := self data
			y := outterList size
			innerList := outterList at(0)
			x := innerList size
			ret := TwoDArray clone
			ret dim(x, y)
			for(i,0,x-1,
				for(j,0,y-1,
					ret set(i, j, self get(j, i))
				)
			)
			return ret
		)
		
		
		arr2 := TwoDArray clone
		arr2 dim(3,4)
		arr2 set(1,2,3)
		arr2 set(1,10,3)
		arr2 get(1,2) println
		arr2 get(1,10) println
		"-----------" println
		arr3 := arr2 transpose
		arr3 get(2,1) println
		arr3 get(10,1) println

 7. 将文件写入矩阵，并从文件读取矩阵

		TwoDArray writeMatrix := method(filePath,
			f := File with(filePath)
			f remove
			f openForUpdating
			outterList := self data
			x := outterList size
			y := outterList at(0) size
			f write((x .. "," .. y .. "\n"))
			outterList foreach(e,
				line := ""
				e foreach(e2,
					line = line .. e2 .. ","
				)
				f write(line exSlice(0,-1),"\n")
			)
			f close
		)
		
		
		TwoDArray readMatrix := method(filePath,
			f := File with(filePath)
			f openForReading
			line := f readLine
			d := line split(",")
			x := d at(0) asNumber
			y := d at(1) asNumber
			ret := TwoDArray clone
			ret dim(x,y)
			writeln("x=",x,", y=",y)
			i := 0
			j := 0
			f readLines foreach(line,
				list := line split(",")
				j = 0
				list foreach(e,
					writeln(i,"x",j,"=",e)
					if(e != "nil",ret set(i,j,e))
					j = j + 1
				)
				i = i +1
			)
			f close
			return ret
		)
		
		
		TwoDArray writeMatrix2 := method(filePath,
			f := File with(filePath)
			f remove
			f openForUpdating
			f write(self serialized())
			f close
		)
		
		TwoDArray readMatrix2 := method(filePath,
			ret := doFile(filePath)
			return ret
		)
		
		
		arr2 := TwoDArray clone
		arr2 dim(3,4)
		arr2 set(1,2,3)
		arr2 set(1,10,3)
		arr2 get(1,2) println
		arr2 get(1,10) println
		"-----------" println
		arr3 := arr2 transpose
		arr3 get(2,1) println
		arr3 get(10,1) println
		
		arr3 writeMatrix("./test.dt")
		
		arr4 := TwoDArray readMatrix("./test.dt")
		
		arr4 println
		arr4 get(2,1) println
		arr4 get(10,1) println
		
		arr3 writeMatrix2("./test2.dt")
		
		arr5 := TwoDArray readMatrix2("./test2.dt")
		
		arr5 println
		arr5 get(2,1) println
		arr5 get(10,1) println

 8. 写一个程序，提供10次尝试机会，猜一个1~100之间的随机数。如果

		GuessNumGame := Object clone
		GuessNumGame init := method(
			self secretNum := Random value(1,101) floor
			self guessTimes := 0
			self lowBoundry := 0
			self highBoundry := 100
			secretNum println
		)
		
		GuessNumGame guess := method(x,
			guessTimes println
			if(guessTimes > 10) then(
				"You had guess over 10 times! Game over!" println
				return
			)
			if(x < secretNum) then(
				if(x > lowBoundry,lowBoundry = x)
				writeln("You guess lowwer. You can guess between ",lowBoundry," to ",highBoundry)
			) elseif(x == self secretNum) then(
				writeln("Congratulations! You got the right number!")
			) else(
				if(x < highBoundry, highBoundry = x)
				writeln("You guess higher. You can guess between ",lowBoundry," to ",highBoundry)
			)
			guessTimes = guessTimes + 1
		)
		
		game := GuessNumGame clone
		game guess(10)
		game guess(50)


## 领域特定语言
几乎每一个研究过Io语言的人，都会对它在DSL方面的强大赞不绝口。下面实现一种有趣的电话号码语法的API。  
比如：  

	{
		"Bob smith":"5195551212",
		"Mary Walsh":"4162223434"
	}
解决这一个问题的办法：

	OperatorTable addAssignOperator(":","atPutNumber")
	curlyBrackets := method(
		r := Map clone
		call message arguments foreach(arg,
			r doMessage(arg)
		)
		r
	)
	
	Map atPutNumber := method(
		self atPut(
			call evalArgAt(0) asMutable removePrefix("\"") removeSuffix("\""),
			call evalArgAt(1)
		)
	)
	
	s := File with("phonebook.txt") openForReading contents
	phoneNumbers := doString(s)  //doString把电话号码簿求值为Io代码
	phoneNumbers keys println
	phoneNumbers values println

## Io的method_messing
就像Ruby的method_missing那样，你也可以用Io的forward消息做到同样的事，但是这样做的风险会高一些。Io没有类，所以改变forward也将改变从Object获得的基本行为方式。  
XML是对数据进行结构化的绝妙方式，但是却有着令人作呕的语法。为了摆脱这语法，你可以写一个程序，用Io代码来表示XML数据。
假如你想把下面的数据：

	<body>
	<p>
	This is a simple paragraph.
	</p>
	</body>

表示成：  

	body(
		p("This is a simple paragraph.")
	)


我们把这种新语言称作LispML。我们将用Io的forward处理这门语言，就像处理不存在的方法一样（missing_method）。

	Builder := Object clone
	Builder forward := method(
		writeln("<",call message name,">")
			call message arguments foreach(arg,
				content := self doMessage(arg)
				if(content type == "Sequence", writeln(content))
			)
		writeln("</",call message name,">")
	)
	
	Builder ul(
		li("IO"),
		li("Lua"),
		li("Javascript")
	)

## 并发
Io有非常出色的并发库，其主要组成部分包括协程、actor和future。
### 1.协程
协程是并发的基础。它提供了进程自动挂起和恢复执行的机制。你可以把协程想象成有多个入口和出口的函数。每次yield都会自动挂起当前进程，并把控制转到另一个进程中。
通过在消息前加上@或@@，你可以异步触发消息，前者将返回future，后者会返回nil，并在其自身线程中触发消息。

	vizzini := Object clone
	vizzini talk := method(
		"Fezzik, are there rooks ahead?" println
		yield
		"No more rhymes now, I mean it." println
		yield
	)
	
	fezzik := Object clone
	fezzik rhyme := method(
		yield
		"If there are, we'll all be dead." println
		yield
		"Anybody want a peanut?" println
	)
	
	vizzini @@talk
	fezzik @@rhyme
	
	Coroutine currentCoroutine pause


协程是组成更高级抽象概念（如actor）的基本元素。你可以把actor想象成通用的并发原语，它可以发送消息、处理消息以及创建其它actor。actor接收到的消息是并发的。在Io中，actor把新到达的消息放到队列上，并用协程处理队列中的各个消息。

### 2.Actor
和线程相比，actor有巨大的理论优势。一个actor可以改变其自身状态，并且通过严格控制的队列接触其它actor。而多个线程可以不受限制地改变状态。线程容易接受到被称为竞争条件的并发影响。在这种问题中，如果两个线程同时存取资源，可能导致不可预测的后果。  
Io的动人之处就在于此，发送异步消息给任何对象就是actor，就这么简单。举一个例子：

	slower := Object clone
	faster := Object clone
	
	slower start := method(
		wait(2)
		writeln("slowly")
	)
	
	faster start := method(
		wait(1)
		writeln("quickly")
	)
	
	slower start
	faster start
	"======================" println
	slower @@start
	faster @@start
	Coroutine currentCoroutine pause


### 3.future
在Io中，future并不是代理实现。future会阻塞到可获得结果为止。future的值一开始是个future对象，但等到结果产生之后，所有future值的实例都会指向结果对象。

	futureResult := URL with("http://google.com/") @fetch
	writeln("doing other thing ...")
	wait(2)
	writeln("fetched," futureResult size," bytes")

在windows下运行上面代码出现Exception: Object does not respond to 'URL'异常，google了一下，未能解决，望高手指点。

## 第三天自习

 1. 改进本节生成的XML程序，增加空格以显示缩进结构。

		Builder := Object clone
		Builder indentSize := 4
		Builder i := 0
		Builder forward := method(
			(i * indentSize) repeat(write(" "))
			writeln("<",call message name,">")
		
			i = i + 1
			call message arguments foreach(arg,
				content := self doMessage(arg)
				if(content type == "Sequence", 
					(i * indentSize) repeat(write(" "))
					writeln(content)
				)
			)
			i = i -1
		
			(i * indentSize) repeat(write(" "))
			writeln("</",call message name,">")
		)
		
		Builder ul(
			li(p("IO")),
			li("Lua"),
			li("Javascript")
		)

 2. 创建一种使用括号的列表语法

		squareBrackets := method(		
		  if(call message arguments asString containsSeq("squareBrackets") not,return call message arguments) 		//如果不含子数组就直接返回参数列表,参数列表本来就是一个list
		  list := List clone
		  call message arguments foreach(arg,
		   aArg := if(arg asString beginsWithSeq("squareBrackets"),doMessage(arg),arg)
		   list append(aArg)// 最后一行为返回值
		  )
		  list
		)
		
		[] println
		[1,"kk"] println
		[1,["kk",10.5]] println

 3. 改进本节生成xml程序，使其可以处理属性：如果第一个参数时映射（用大括号语法），则为xml添加属性。例如：  
`book({"author":"Tate"}...)` 将打印出` <book author="Tate">`  

		OperatorTable addAssignOperator(":","addAttribute")
		
		Builder := Object clone
		
		Builder addAttribute := method(
			call message arguments println
			write(call evalArgAt(0))
			write("=\"",call evalArgAt(1),"\"")
		)
		
		Builder curlyBrackets := method(
			call message arguments foreach(arg,
				self doMessage(arg)
			)
		)
		
		
		
		Builder indentSize := 4
		Builder i := 0
		Builder forward := method(
			(i * indentSize) repeat(write(" "))
			write("<",call message name)
		
			i = i + 1
			
			args :=call message arguments 
			arg1 := args at(0)
			if( arg1 asString beginsWithSeq("curlyBrackets"),
				//arg1 println
				self doMessage(arg1)
				args remove(arg1)
			)
			writeln(">")
			args foreach(arg,
				content := self doMessage(arg)
				if(content type == "Sequence", 
					(i * indentSize) repeat(write(" "))
					writeln(content)
				)
			)
			i = i -1
		
			(i * indentSize) repeat(write(" "))
			writeln("</",call message name,">")
		)
				
		
		Builder ul(
			{"class" : "foo","id" : "language"},
			li("Io")
		)

上面代码会出现异常，不知道如何解决。

		<ul
		  Exception: Sequence does not respond to ':'
		  ---------
		  Sequence :                           builder.io 50
		  Builder curlyBrackets                builder.io 50
		  Builder ul                           builder.io 49
		  CLI doFile                           Z_CLI.io 140
		  CLI run     

