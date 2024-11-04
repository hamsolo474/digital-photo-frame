I'm new to both low level programming languages and zig, so as useful as an exact code answer would be I am mostly looking for advice to build a mindset or intuition about these kinds of problems.

I am trying to add all the files from a list of folders
```
[ham@hamjaro-vm zig]$ tree ~/Pictures
/home/ham/Pictures
├── f1
│   ├── file10.jpg
│   ├── file1.jpg
│   ├── file2.jpg
│   ├── file5.jpg
│   ├── file6.jpg
│   ├── file7.jpg
│   ├── file8.jpg
│   └── file9.jpg
├── f2
│   ├── file3.jpg
│   ├── file4.jpg
│   └── veryLongFileNameThisIsWayTooLong.jpg
└── paths.txt
```

```
[ham@hamjaro-vm Pictures]$ cat paths.txt 
/home/ham/Pictures/f1
/home/ham/Pictures/f2
```


```
[ham@hamjaro-vm zig]$ zig run delme.zig 
Access to value during interation: file1.jpg
Access to ArrayList contents during iteration: file1.jpg
Access to value during interation: file10.jpg
Access to ArrayList contents during iteration: file10.jpg
Access to value during interation: file5.jpg
Access to ArrayList contents during iteration: file5.jpg
Access to value during interation: file8.jpg
Access to ArrayList contents during iteration: file8.jpg
Access to value during interation: file9.jpg
Access to ArrayList contents during iteration: file9.jpg
Access to value during interation: file7.jpg
Access to ArrayList contents during iteration: file7.jpg
Access to value during interation: file2.jpg
Access to ArrayList contents during iteration: file2.jpg
Access to value during interation: file6.jpg
Access to ArrayList contents during iteration: file6.jpg
Access to value during interation: veryLongFileNameThisIsWayTooLong.jpg
Access to ArrayList contents during iteration: veryLongFileNameThisIsWayTooLong.jpg
Access to value during interation: file4.jpg
Access to ArrayList contents during iteration: file4.jpg
Access to value during interation: file3.jpg
Access to ArrayList contents during iteration: file3.jpg
Access to ArrayList Elements after iteration
0) veryLongF
1) .jpg��
2) g'
3) g
4) 
5) 
6) 
7) 
8) veryLongFileNameThisIsWayTooLong.jpg
9) file4.jpg
10) file3.jpg
picList len: 11
Index 1: .jpg��
```