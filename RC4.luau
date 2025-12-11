--!strict
--!native
--!optimize 2

local sbox_length: number = 500; --TODO: guh
local swap: (i: number, j: number, sbox: buffer) -> () = @native function(i: number, j: number, sbox: buffer): ()
	local old_num: number = buffer.readu8(sbox, i);
	buffer.writeu8(sbox, i, buffer.readu8(sbox, i));
	
	--[[if (j > buffer.len(sbox)) then
		print("no")
		return;
	end;]]
	
	buffer.writeu8(sbox, j, old_num);
	return;
end;

local rset: (sbox: buffer, key: buffer) -> () = @native function(sbox: buffer, key: buffer): ()
	buffer.fill(sbox, 0, 0);
	buffer.fill(sbox, 0, 0);

	return;
end;
local generate_sbox: (key_str: string, msg: string) -> buffer = @native function(key_str: string, msg: string): buffer
	local result = buffer.create((sbox_length + string.len(key_str) + string.len(msg)));
	local j: number = 0;
	
	for i: number = 1, (sbox_length) do
		i -= 1;
		buffer.writeu8(result, i, i);
	end;
	for i: number = 1, (sbox_length) do
		i -= 1;
		
		j = (((j + buffer.readu8(result, i) + bit32.band(string.byte(key_str, (i % string.len(key_str)) + 1), 0xFF)) % sbox_length));
		swap(i, j, result);
	end;
	
	return result;
end;


local crypt: (msg: string, key: buffer) -> (buffer, buffer) = @native function(msg: string, key: buffer): (buffer, buffer)
	local chiper: buffer = buffer.create(string.len(msg));
	local sbox: buffer = generate_sbox(buffer.tostring(key), msg);
	
	
	local i: number = 0;
	local j: number = 0;

	for n: number = 1, (string.len(msg)+1) - 1, 1 do
		i = ((i + 1) % sbox_length)
		j = bit32.band((j + buffer.readu8(sbox, i) % sbox_length), sbox_length);
		
		swap(i, j, sbox);
		
		local read: number = buffer.readu8(sbox, i);
		--warn(j, buffer.len(sbox))
		read += (buffer.readu8(sbox, j) % sbox_length);
		
		local chiper_text: number = bit32.bxor(string.byte(msg, n), read);
		--warn(n, string.len(msg))
		
		buffer.writeu8(chiper, (n-1), chiper_text);
		
	end;

	return chiper, sbox;
end;

local decrypt: (chiper: buffer, key: buffer) -> buffer = @native function(chiper: buffer, key: buffer): buffer
	local decrypted: buffer, sbox: buffer = crypt(buffer.tostring(chiper), key);
	rset(sbox, key);
	
	return decrypted;
end;
return table.freeze({
	crypt = @native function(msg: buffer, key: buffer): buffer	
		local chiper: buffer, sbox: buffer = crypt(buffer.tostring(msg), key);
		rset(sbox, key);
		
		return chiper;
	end,
	decrypt = decrypt;
});
