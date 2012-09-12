for i=1,32 do
	for j=1,32 do
		if(j <= i) then
			io.write("128,80,0,")
		else
			io.write("20,128,20,")
		end
	end
	io.write("\n")
end
--print("128,20,0")
