--!strict
--!native
--!optimize 2

--[[local swap: (i: number, j: number, sbox: buffer) -> () = @native function(i: number, j: number, sbox: buffer): ()
	local old_num: number = buffer.readu8(sbox, i);
	buffer.writeu8(sbox, i, buffer.readu8(sbox, i));
	buffer.writeu8(sbox, j, old_num);
	return;
end;
local rset: (sbox: buffer, key: buffer) -> () = @native function(sbox: buffer, key: buffer): ()
	buffer.fill(sbox, 0, 0);
	buffer.fill(key, 0, 0);

	return;
end;]]

local generate_sbox: (key_str: buffer, msg: buffer) -> buffer = @native function(key_str: buffer, msg: buffer): buffer
	local key_len: number = buffer.len(key_str);
	local msg_len: number = buffer.len(msg);
	
	local result = buffer.create((500 + key_len + msg_len));
	local j: number = 0;
	
	
	for i: number = 1, (500) do
		buffer.writeu8(result, i-1, i-1);
	end;
	for i: number = 1, (500) do
		j = (((j + buffer.readu8(result, i-1) + bit32.band(buffer.readu8(key_str, (i%key_len)), (i-1 % key_len) + 1, 0xFF)) % 500));
		
		do
			local old_num: number = buffer.readu8(result, i-1);
			buffer.writeu8(result, i-1, buffer.readu8(result, i-1));
			
			buffer.writeu8(result, j, old_num);
		end;

	end;
	return result;
end;


return @native function(msg: buffer, key: buffer): buffer
	local chiper: buffer = buffer.create(buffer.len(msg));
	local sbox: buffer = generate_sbox(key, msg);


	local i: number = 0;
	local j: number = 0;

	local offset: number = 0;
	local msg_len: number = buffer.len(msg);

	for n: number = 1, (msg_len+1) - 1, 1 do
		local byte: number = buffer.readu8(msg, offset);
		offset += 1;

		i = ((i + 1) % 500);
		local read: number = buffer.readu8(sbox, i);


		j = (bit32.band((j + read % 500), 500));
		do
			local old_num: number = buffer.readu8(sbox, i);

			buffer.writeu8(sbox, i, buffer.readu8(sbox, i));
			buffer.writeu8(sbox, j, old_num);
			
			old_num = nil :: never;
		end;

		read += (buffer.readu8(sbox, j) % 500);
		local chiper_text: number = bit32.bxor(byte, read);

		buffer.writeu8(chiper, (n-1), chiper_text);
		read = nil :: never;
		
		chiper_text = nil :: never;
		byte = nil :: never;
	end;
	
	buffer.fill(sbox, 0, 0);
	msg = nil :: never;
	
	key = nil :: never;
	sbox = nil :: never;
	
	msg_len = nil :: never;
	return chiper;
end;
