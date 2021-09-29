# BFI

"""
Language Documentation:
> - Increment Index
< - Decrement Index
+ - Increment Value
- - Decrement Value
, - Read Input to Index
. - Write Value to Output
[ - If the byte at the data pointer is zero, then instead of moving the 
instruction pointer forward to the next command, jump it forward to the 
command after the matching ] command.
] - If the byte at the data pointer is nonzero, then instead of moving the 
instruction pointer forward to the next command, jump it back to the command 
after the matching [ command.
"""

# ----- Read File -----
global instructions = ['>', '<', '+', '-', ',', '.', '[', ']']
function readfile(text::String)
	code = []
	for t in text
		if in(t, instructions)
			push!(code, t)
		end
	end
	return code
end

function init_jumptable(code)
	jumptable = Dict{UInt32, UInt32}()
	jumpstack = []
	for c = 1:length(code)
		if code[c] == '['
			push!(jumpstack, c)
		elseif code[c] == ']'
			if jumpstack == []
				println("Unbalanced brackets ...]")
			else
				start = pop!(jumpstack)
				jumptable[c] = start
				jumptable[start] = c
			end
		end
	end
	if jumpstack != []
		println("Unbalanced brackets [...")
	end
	return jumptable
end

function eval(code, jumptable)
	tape::Array{UInt8} = [0]
	tapepos::Int = 1
	pc::Int = 1 # "Program Counter" (code position)

	# Instruction Evaluation
	while pc <= length(code)
		instr = code[pc]
		if instr == '>'
			if tapepos == length(tape)
				push!(tape, 0)
			end
			tapepos += 1
		elseif instr == '<'
			if tapepos == 0
				pushfirst!(tape, 0)
			else
				tapepos -= 1
			end
		elseif instr == '+'
			tape[tapepos] += 1
		elseif instr == '-'
			if tape[tapepos] > 0
				tape[tapepos] -= 1
			else
				tape[tapepos] = 127
			end
		elseif instr == ','
			if eof(stdin)
				return 1
			else
				tape[tapepos] = read(stdin, UInt8)
			end
		elseif instr == '.'
			print(Char(tape[tapepos]))
		elseif instr == '['
			if tape[tapepos] == 0
				pc = jumptable[pc]
			end
		elseif instr == ']'
			if tape[tapepos] != 0
				pc = jumptable[pc]
			end
		end
		pc += 1
	end

end

function eval2(code, jumptable) 
	# Second version of eval, using Dict with anonymous functions

	tape::Array{UInt8} = [0] 
	# Ascii should be UInt7, so manual overflow is added in + and - cases
	tapepos::Int = 1
	pc::Int = 1 # "Program Counter" (code position)

	switch = Dict(
		'+' => () -> (tape[tapepos] += 1), 
		'-' => () -> (if tape[tapepos] > 0; tape[tapepos] -= 1; else; tape[tapepos] = 127; end), # Test alt
		'>' => () -> (if tapepos == length(tape); push!(tape, 0); end; tapepos += 1), 
		'<' => () -> (if tapepos == 0; pushfirst!(tape, 0); else; tapepos -= 1; end),
		'[' => () -> (if tape[tapepos] == 0
						pc = jumptable[pc]
					end), 
		']' => () -> (if tape[tapepos] != 0
						pc = jumptable[pc]
					end),
		',' => () -> (if eof(stdin)
						return 1
					else
						tape[tapepos] = read(stdin, UInt8)
					end), 
		'.' => () -> (print(Char(tape[tapepos]))),
		)

	while pc <= length(code)
		get(switch, code[pc],()->())()
		pc+=1
	end
end

function main() 
	code = []
	#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++.+++++++++++++++++++++++++++++.+++++++..+++.---.
	if length(ARGS) == 0
		println("Must specify a file to load.")
	else
		println("Loading " * ARGS[1] * ".")
		io = open("Programs/"*ARGS[1]*".txt", "r")
		code_plain = read(io, String)
		code = readfile(code_plain)
		jt = init_jumptable(code)
		eval(code, jt)
		println()
	end
end

main()
