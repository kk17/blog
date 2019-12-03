---
title: "七周七语言之Prolog学习笔记"
description: ""
categories: ["reading-note"]
tags: ["prelog"]
date: 2015-05-08T10:00:00+08:00
slug: "seven-days-seven-languages-prelog"
aliases:
  - /reading-note/seven-days-seven-languages-prelog
  - /reading-note/seven-days-seven-languages-prelog.html
---


## 有关于Prolog
Prolog是一门逻辑编程语言，它于1972年由Alain Colmerauer和Phillipe Roussel开发完成，在
自然语言处理领域颇受欢迎。在Prolog中，数据以逻辑规则的形式存在，下面是基本
构建单元。  

 1.  事实。事实是关于真实世界的基本断言。（Babe是一头猪，猪喜欢泥巴。） 
 2. 规则。规则是关于真实世界中一些事实的推论。（如果一个动物是猪，那么它喜欢泥巴。）
 3. 查询。查询是关于真实世界的一个问题。（Babe喜欢泥巴吗？）

事实和规则被放入一个知识库（knowledge base）。Prolog编译器将这个知识库编译成一种适
于高效查询的形式。  
在Prolog中，第一个字母的大小写是有着重要意义的，如果一个词以小写字母开头，它就是一个原子（atom）——一个类似Ruby符号（symbol）的固定值，如果一个词以大写字母或下划线开头，那么它就是一个变量。变量的值可以改变，原子则不能。

    likes(wallace,cheese). //事实
    likes(grommit,cheese).
    likes(wendolene,sheep).
    
    friend(X,Y) :- \+(X = Y), likes(X, Z), likes(Y, Z). //规则，\+执行逻辑取反操作，\+(X=Y)表示X不等于Y

    | ？- friend(grommit， wallace). //查询


Prolog让你通过事实和推论来表达逻辑，然后直接提问即可。
<!-- more -->
### 合一
合一的意思是“找出那些使规则两侧匹配的值”

## 第一天自习

 1. 建立一个知识库，描述你最喜欢的书籍和其作者。

		%--列出书籍
		book('Zen and the Art of Motorcycle Maintenance').
		book('Seven Languages in Seven Weeks').
		book('Introduction to Algorithms').
		book('Design Patterns').
		book('Effective Java').
		
		%--列出作者
		author('Bruce A.Tate').
		author('Erich Gamma').
		author('Richard Helm').
		author('Ralph Johnson').
		author('John Vlissides').
		author('Thomas H.Cormen').
		author('Charles E.Leiserson').
		author('Ronald L.Rivest').
		author(' Clifford Stein').
		author('Joshua Bloch').
		author('Robert M. Pirsig').
		
		book_author('Zen and the Art of Motorcycle Maintenance','Robert M. Pirsig').
		book_author('Seven Languages in Seven Weeks','Bruce A.Tate').
		book_author('Introduction to Algorithms','Thomas H.Cormen').
		book_author('Introduction to Algorithms','Charles E.Leiserson').
		book_author('Introduction to Algorithms','Ronald L.Rivest').
		book_author('Introduction to Algorithms',' Clifford Stein').
		book_author('Effective Java','Joshua Bloch').
		book_author('Design Patterns','Erich Gamma').
		book_author('Design Patterns','Richard Helm').
		book_author('Design Patterns','Ralph Johnson').
		book_author('Design Patterns','John Vlissides').
		
		%--定义共同作者
		coauthor( FirstAuthor, SecondAuthor ) :-
		(FirstAuthor \= SecondAuthor),
		author( FirstAuthor ),
		author( SecondAuthor ),
		book_author( SomeBook ,FirstAuthor),
		book_author( SomeBook, SecondAuthor).
		
		%--定义非共同作者
		notCoauthor( FirstAuthor, SecondAuthor ) :-
		(FirstAuthor \= SecondAuthor),
		\+coauthor( FirstAuthor, SecondAuthor ).
查询

		GNU Prolog 1.4.4 (64 bits)
		Compiled Apr 23 2013, 16:05:07 with cl
		By Daniel Diaz
		Copyright (C) 1999-2013 Daniel Diaz
		| ?- consult('D:/PrologCodes/books.pl').
		compiling D:/PrologCodes/books.pl for byte code...
		D:/PrologCodes/books.pl compiled, 45 lines read - 4452 bytes written, 8 ms
		
		yes
		| ?- book(Whatbook).
		
		Whatbook = 'Zen and the Art of Motorcycle Maintenance' ? ;
		
		Whatbook = 'Seven Languages in Seven Weeks' ? ;
		
		Whatbook = 'Introduction to Algorithms' ? ;
		
		Whatbook = 'Design Patterns' ? ;
		
		Whatbook = 'Effective Java'
		
		(16 ms) yes
		| ?- author(Author).
		
		Author = 'Bruce A.Tate' ? ;
		
		Author = 'Erich Gamma' ? ;
		
		Author = 'Richard Helm' ? ;
		
		Author = 'Ralph Johnson' ? ;
		
		Author = 'John Vlissides' ? ;
		
		Author = 'Thomas H.Cormen' ? ;
		
		Author = 'Charles E.Leiserson' ? ;
		
		Author = 'Ronald L.Rivest' ? ;
		
		Author = ' Clifford Stein' ? ;
		
		Author = 'Joshua Bloch' ? ;
		
		Author = 'Robert M. Pirsig'
		
		| ?- book_author('Design Patterns',Author).
		
		Author = 'Erich Gamma' ? ;
		
		Author = 'Richard Helm' ? ;
		
		Author = 'Ralph Johnson' ? ;
		
		Author = 'John Vlissides'
		
		yes
		
		| ?- coauthor('Erich Gamma','Richard Helm').
		
		true ? ;
		
		no
		
		| ?- notCoauthor('Erich Gamma','Richard Helm').
		
		no
		| ?- coauthor('Bruce A.Tate','Erich Gamma').
		
		no
		| ?- coauthor('Bruce A.Ta1te','Erich Gamma').
		
		no
		| ?- notCoauthor('Erich Gamma','Richard Helm').
		
		no
		| ?- book_author(SomeBook,'Erich Gamma').
		
		SomeBook = 'Design Patterns' ? ;
		
		no


## 第二天自习

 1. 斐波那契数列和阶乘的实现。  

		fib(1,1).
		fib(2,1).
		fib(N,Ret) :- N > 2, N1 is N -1, N2 is N -2, fib(N1,Prv1), fib(N2,Prv2), Ret is Prv2 + Prv1.

		factorial(0,1).
		factorial(1,1).
		factorial(N,Ret) :-  N > 1, N1 is N - 1, factorial(N1, Ret1), Ret is N * Ret1.

 2. 汉诺塔问题  

		%--参考了网上的实现
		hanoi(N) :- move(N,left,middle,right).
		
		move(1,A,_,C) :- inform(A,C), !. %-- 此处的!作用不太明白
		move(N,A,B,C) :- N1 is N - 1,
			move(N1,A,C,B),
			inform(A,C),
			move(N1,B,A,C).
		
		inform(Loc1,Loc2) :- nl,write('Move a disk from '-Loc1-' to '-Loc2).

 3. 翻转列表元素

    	reverse_list([],[]).
		reverse_list(List,ReverseList) :- List = [Head|Tail],
				 reverse_list(Tail, ReverseTail),
				 append(ReverseTail,[Head],ReverseList).

 4. 找出列表最小元素  

		find_min([E],E).
		find_min(List,Min) :- List = [Head|Tail], find_min(Tail,Min2), Min is min(Head,Min2).

 5. 对列表元素进行排序  

		sort_list([],[]).
		sort_list(List,SortedList) :- List = [Head|Tail],
			sort_list(Tail,SortedTail),
			merge_list(Head,SortedTail,SortedList).
		
		merge_list(E,[],[E]).
		merge_list(E1,SortedTail,MergedList) :- SortedTail = [E2|Tail],
			(E1 < E2 ->
				append([E1],SortedTail,MergedList);
				merge_list(E1,Tail,MergedTail),
				append([E2],MergedTail,MergedList)
			).

## 第三天自习

 1. 9x9数独问题。

		valid([]).
		valid([Head|Tail]) :-
			fd_all_different(Head),
			valid(Tail).
		
		sudoku(Puzzle, Solution) :- Solution = Puzzle ,
			Puzzle = [S11,S12,S13,S14,S15,S16,S17,S18,S19,
			S21,S22,S23,S24,S25,S26,S27,S28,S29,
			S31,S32,S33,S34,S35,S36,S37,S38,S39,
			S41,S42,S43,S44,S45,S46,S47,S48,S49,
			S51,S52,S53,S54,S55,S56,S57,S58,S59,
			S61,S62,S63,S64,S65,S66,S67,S68,S69,
			S71,S72,S73,S74,S75,S76,S77,S78,S79,
			S81,S82,S83,S84,S85,S86,S87,S88,S89,
			S91,S92,S93,S94,S95,S96,S97,S98,S99],
			fd_domain(Puzzle,1,9),
		
			Row1=[S11,S12,S13,S14,S15,S16,S17,S18,S19],
			Row2=[S21,S22,S23,S24,S25,S26,S27,S28,S29],
			Row3=[S31,S32,S33,S34,S35,S36,S37,S38,S39],
			Row4=[S41,S42,S43,S44,S45,S46,S47,S48,S49],
			Row5=[S51,S52,S53,S54,S55,S56,S57,S58,S59],
			Row6=[S61,S62,S63,S64,S65,S66,S67,S68,S69],
			Row7=[S71,S72,S73,S74,S75,S76,S77,S78,S79],
			Row8=[S81,S82,S83,S84,S85,S86,S87,S88,S89],
			Row9=[S91,S92,S93,S94,S95,S96,S97,S98,S99],
			Col1=[S11, S21, S31, S41, S51, S61, S71, S81, S91],
			Col2=[S12, S22, S32, S42, S52, S62, S72, S82, S92],
			Col3=[S13, S23, S33, S43, S53, S63, S73, S83, S93],
			Col4=[S14, S24, S34, S44, S54, S64, S74, S84, S94],
			Col5=[S15, S25, S35, S45, S55, S65, S75, S85, S95],
			Col6=[S16, S26, S36, S46, S56, S66, S76, S86, S96],
			Col7=[S17, S27, S37, S47, S57, S67, S77, S87, S97],
			Col8=[S18, S28, S38, S48, S58, S68, S78, S88, S98],
			Col9=[S19, S29, S39, S49, S59, S69, S79, S89, S99],
		
			Square1=[S11,S12,S13, S21,S22,S23, S31,S32,S33],
			Square2=[S14,S15,S16, S24,S25,S26, S34,S35,S36],
			Square3=[S17,S18,S19, S27,S28,S29, S37,S38,S39],
			Square4=[S41,S42,S43, S51,S52,S53, S61,S62,S63],
			Square5=[S44,S45,S46, S54,S55,S56, S64,S65,S66],
			Square6=[S47,S48,S49, S57,S58,S59, S67,S68,S69],
			Square7=[S71,S72,S73, S81,S82,S83, S91,S92,S93],
			Square8=[S74,S75,S76, S84,S85,S86, S94,S95,S96],
			Square9=[S77,S78,S79, S87,S88,S89, S97,S98,S99],
		
			valid([Row1, Row2, Row3, Row4, Row5, Row6, Row7, Row8, 
				Row9, Col1, Col2, Col3, Col4, Col5, Col6, Col7, Col8, Col9,
				Square1, Square2, Square3, Square4, Square5, Square6,
				Square7, Square8, Square9]),
		
			write( '\n' ), write( Row1 ),
			write( '\n' ), write( Row2 ),
			write( '\n' ), write( Row3 ),
			write( '\n' ), write( Row4 ),
			write( '\n' ), write( Row5 ),
			write( '\n' ), write( Row6 ),
			write( '\n' ), write( Row7 ),
			write( '\n' ), write( Row8 ),
			write( '\n' ), write( Row9 ).
