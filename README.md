# Overview
BFI is a simple interpreter for the BF language implemented in Julia.

Evaluation is implemented in two ways, one as a loop over if statements and the other as a dictionary of anonymous functions.



# How to Run

```
$ cat Input.txt
hello world
$ julia BFI.jl Programs/rot13.txt < Input.txt
uryyb jbeyq
```
```
julia BFI.jl Programs/helloworld.txt | julia BFI.jl Programs/rot13.txt
Uryyb, jbeyq!
```


# Resources
https://en.wikipedia.org/wiki/Brainfuck

The example rot13 program is from Wikipedia.