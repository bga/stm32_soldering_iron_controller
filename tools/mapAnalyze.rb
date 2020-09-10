help = "
#{ File.basename(__FILE__) } dump.map -|report.txt
  analyze gcc map file and output to stdout of file 
"
mapFile = ARGV[0] or abort(help)
outFile = ARGV[1] || "-"

def debug(*args)
	# p *args
end

lines = open(mapFile, "rt").read().lines
fwLineBeginIndex = lines.find_index { |line| line.start_with?(".isr_vector") } or abort("Can not find fw start")
fwLineEndIndex = fwLineBeginIndex + (lines[fwLineBeginIndex .. lines.size].find_index { |line| line.strip().start_with?(".data") } or abort("Cant not find fw end"))
fwLines = lines[fwLineBeginIndex .. fwLineEndIndex]
debug fwLineBeginIndex, fwLineEndIndex, fwLineEndIndex - fwLineBeginIndex

dump = (fwLines
	.map {
		|line|
		ret = nil
		
		vs = line.split()
		offsetIndex = vs.find_index { |v| v.start_with?("0x080") }
		if(offsetIndex == nil)
		else
			offset = vs[offsetIndex].to_i(16)
			ret = { offset: offset, line: line}
		end
	}
	.compact()
	.tap { |v| debug v[0] }
	.each_cons(2).to_a.map {
		|currentV, nextV|
		size = nextV[:offset] - currentV[:offset]
		{ size: size, line: currentV[:line] }
	}
	.sort_by! { |v| -v[:size] } # reverse order
	.map {
		|v| "#{ v[:size] }\t#{ v[:line].rstrip() }"
	}
	.join("\n")
)

if(outFile == "-")
	puts dump
else
	open(outFile, "wt").write(dump)
end