--!native
local RC4 = require(script.Parent);

local plain_text = buffer.fromstring("secret msg");
local key = buffer.fromstring("secret key");



local chiper = RC4(plain_text, key);
local decrypted = RC4(chiper, key);

warn("chiper:", buffer.tostring(chiper));
warn("decrypted:", buffer.tostring(decrypted));


warn("miaowwww");
task.wait(1);

plain_text = buffer.fromstring("new msg dont leak omg classifed");
key = buffer.fromstring("new secret key but even more secret");

chiper = RC4(plain_text, key);
decrypted = RC4(chiper, key);

warn("chiper:", buffer.tostring(chiper));
warn("decrypted:", buffer.tostring(decrypted));

