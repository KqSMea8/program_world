
//jQuery.ajax()	执行异步 HTTP (Ajax) 请求。
$(document).ready(function(){
  $("#b01").click(function(){
  htmlobj=$.ajax({url:"/jquery/test1.txt",async:false});
  $("#myDiv").html(htmlobj.responseText);
  });
});

/*
 * <div id="myDiv"><h2>Let AJAX change this text</h2></div> <button id="b01"
 * type="button">Change Content</button>
 */

$(document).ready(function() {
	$("#b01").click(function() {
		htmlobj = $.ajax({
			url : "/jquery/test1.txt",
			async : false
		});
		$("#myDiv").html(htmlobj.responseText);
	});
});

/*
 * 所有的选项都可以通过 $.ajaxSetup() 函数来全局设置。 jQuery.ajax([settings])
 */

$.ajax({
	url : "test.html",
	context : document.body,
	success : function() {
		$(this).addClass("done");
	}
});

// options,async,beforeSend(XHR)







$.ajax({
	async : false,// 同步
	beforeSend(XHR):function(){},
	complete(XHR, TS):function(){},
	contentType: "application/x-www-form-urlencoded",// 默认值
	cache: true,// 默认值
	context:" Object类型 比如document.body，",
	data:{storeCode:"<%=storeCode%>"},
	dataFilter:function(){},
	dataType:智能判断,// 默认值 xml/html/script/json/jsonp/text
	global:true,/*
				 * 设置为 false 将不会触发全局 AJAX 事件，如 ajaxStart 或 ajaxStop 可用于控制不同的
				 * Ajax 事件
				 */
	ifModified:false,// 仅在服务器数据改变时获取新数据
	jsonp:'onJsonPLoad',
	jsonpCallback:"",
	options:"Object",
	xhr:"",
	username:"",
	password:"",// 用于响应 HTTP 访问认证请求的密码
	processData:true,// application/x-www-form-urlencoded
	scriptCharset:"",// 只有当请求时 dataType 为 "jsonp" 或 "script"，并且 type 是 "GET"
						// 才会用于强制修改 charset。通常只在本地和远程的内容编码不同时使用。

	traditional:false,
	timeout:123,// 设置请求超时时间（毫秒）。此设置将覆盖全局设置。
	type : "get",// 默认值: "GET")。请求方式 ("POST" 或 "GET")， 默认为 "GET"。注意：其它 HTTP
					// 请求方法，如 PUT 和 DELETE 也可以使用，但仅部分浏览器支持。
	url : "action",
	success : function(data) {
		$.each(data.rows, function(i) {
			counts[data.rows[i].status] = data.rows[i].count;
		});
	},
// error : function("XMLHttpRequest 对象","错误信息","（可选）捕获的异常对象") {
// $.ligerDialog.error("ajax请求失败！" + action);
//		 
// //第二个参数值：null timeout error notmodified parsererror
//		
// }
});



// .ajaxComplete() 当 Ajax 请求完成时注册要调用的处理程序。这是一个 Ajax 事件。
// ajaxComplete() 方法在 AJAX 请求完成时执行函数。它是一个 Ajax 事件。
// 与 ajaxSuccess() 不同，通过 ajaxComplete() 方法规定的函数会在请求完成时运行，即使请求并未成功。
// /.jQueryajaxComplete(function(event,xhr,options))

// function(event,xhr,options)
// 必需。规定当请求完成时运行的函数。
// 额外的参数：
// event - 包含 event 对象
// xhr - 包含 XMLHttpRequest 对象
// options - 包含 AJAX 请求中使用的选项


$("#txt").ajaxStart(function(){
	  $("#wait").css("display","block");
	});
$("#txt").ajaxComplete(function(){
  $("#wait").css("display","none");
});



// .ajaxError() 当 Ajax 请求完成且出现错误时注册要调用的处理程序。这是一个 Ajax 事件。

$("div").ajaxError(function(){
	  alert("An error occurred!");
	});

// .ajaxError(function(event,xhr,options,exc))
// 参数 描述
// function(event,xhr,options,exc)
// 必需。规定当请求失败时运行的函数。
// 额外的参数：
// event - 包含 event 对象
// xhr - 包含 XMLHttpRequest 对象
// options - 包含 AJAX 请求中使用的选项
// exc - 包含 JavaScript exception



// .ajaxSend() 在 Ajax 请求发送之前显示一条消息。
// 当 AJAX 请求即将发送时，改变 div 元素的内容：
$("div").ajaxSend(function(e,xhr,opt){
  $(this).html("Requesting " + opt.url);
});

// .ajaxSend([function(event,xhr,options)])
// 参数 描述
// function(event,xhr,options)
// 必需。规定当请求开始时执行函数。
// 额外的参数：
// event - 包含 event 对象
// xhr - 包含 XMLHttpRequest 对象
// options - 包含 AJAX 请求中使用的选项


// jQuery.ajaxSetup() 设置将来的 Ajax 请求的默认值。

// 为所有 AJAX 请求设置默认 URL 和 success 函数：
$("button").click(function(){
  $.ajaxSetup({url:"demo_ajax_load.txt",success:function(result){
    $("div").html(result);}});
  $.ajax();
});
// Query.ajaxSetup() 方法设置全局 AJAX 默认选项。
// jQuery.ajaxSetup(name:value, name:value, ...)
// 设置 AJAX 请求默认地址为 "/xmlhttp/"，禁止触发全局 AJAX 事件，用 POST 代替默认 GET 方法。其后的 AJAX
// 请求不再设置任何选项参数：
$.ajaxSetup({
  url: "/xmlhttp/",
  global: false,
  type: "POST"
});
$.ajax({ data: myData });
// 参数 描述
// name:value 可选。使用名称/值对来规定 AJAX 请求的设置。



// .ajaxStart() 当首个 Ajax 请求完成开始时注册要调用的处理程序。这是一个 Ajax 事件。
// ajaxStart() 方法在 AJAX 请求发送前执行函数。它是一个 Ajax 事件。
$("div").ajaxStart(function(){
	  $(this).html("<img src='demo_wait.gif' />");
	});

// 无论在何时发送 Ajax 请求，jQuery 都会检查是否存在其他 Ajax 请求。如果不存在，则 jQuery 会触发该 ajaxStart
// 事件。在此时，由 .ajaxStart() 方法注册的任何函数都会被执行。

$("#loading").ajaxStart(function(){
	  $(this).show();
	});













// .ajaxStop() 当所有 Ajax 请求完成时注册要调用的处理程序。这是一个 Ajax 事件。
// 当所有 AJAX 请求完成时，触发一个提示框：
$("div").ajaxStop(function(){
  alert("所有 AJAX 请求已完成");
});
/*
 * 无论 Ajax 请求在何时完成 ，jQuery 都会检查是否存在其他 Ajax 请求。如果不存在，则 jQuery 会触发该 ajaxStop
 * 事件。在此时，由 .ajaxStop() 方法注册的任何函数都会被执行。
 */

$("#loading").ajaxStop(function(){
	  $(this).hide();
	});









// .ajaxSuccess() 当 Ajax 请求成功完成时显示一条消息。
// 当 AJAX 请求成功完成时，触发提示框：
$("div").ajaxSuccess(function(){
  alert("AJAX 请求已成功完成");
});
// AJAX 请求成功后显示消息：
$("#msg").ajaxSuccess(function(evt, request, settings){
  $(this).append("<p>请求成功!</p>");
});
// axSuccess() 方法在 AJAX 请求成功时执行函数。它是一个 Ajax 事件。
// 详细说明
// XMLHttpRequest 对象和设置作为参数传递给回调函数。
// 无论 Ajax 请求在何时成功完成 ，jQuery 都会触发该 ajaxSuccess 事件。在此时，由 .ajaxSuccess()
// 方法注册的任何函数都会被执行。
// 语法
// .ajaxSuccess(function(event,xhr,options))
// 参数 描述
// function(event,xhr,options)
// 必需。规定当请求成功时运行的函数。
// 额外的参数：
// event - 包含 event 对象
// xhr - 包含 XMLHttpRequest 对象
// options - 包含 AJAX 请求中使用的选项










// jQuery.get() 使用 HTTP GET 请求从服务器加载数据。

$.get(URL,callback);

$("button").click(function(){
	  $.get("demo_test.asp",function(data,status){
	    alert("Data: " + data + "\nStatus: " + status);
	  });
	});

/* demo_test.asp */
/*
 * <% response.write("This is some text from an external ASP file.") %>
 */

$("button").click(function(){
	  $.get("demo_ajax_load.txt", function(result){
	    $("div").html(result);
	  });
	});



// get() 方法通过远程 HTTP GET 请求载入信息。
// 这是一个简单的 GET 请求功能以取代复杂 $.ajax 。请求成功时可调用回调函数。如果需要在出错时执行函数，请使用 $.ajax。
// 语法
// $(selector).get(url,data,success(response,status,xhr),dataType)
// 参数 描述
// url 必需。规定将请求发送的哪个 URL。
// data 可选。规定连同请求发送到服务器的数据。
// success(response,status,xhr)
// 可选。规定当请求成功时运行的函数。
// 额外的参数：
// response - 包含来自请求的结果数据
// status - 包含请求的状态
// xhr - 包含 XMLHttpRequest 对象
// dataType
// 可选。规定预计的服务器响应的数据类型。
// 默认地，jQuery 将智能判断。
// 可能的类型：
// "xml"
// "html"
// "text"
// "script"
// "json"
// "jsonp"

$.get("test.php");

$.get("test.php", { name: "John", time: "2pm" } );



$.get("test.php", function(data){
	  alert("Data Loaded: " + data);
	});



$.get("test.cgi", { name: "John", time: "2pm" },
		  function(data){
		    alert("Data Loaded: " + data);
		  });

// jQuery.getJSON() 使用 HTTP GET 请求从服务器加载 JSON 编码数据。

$("button").click(function(){
	  $.getJSON("demo_ajax_json.js",function(result){
	    $.each(result, function(i, field){
	      $("div").append(field + " ");
	    });
	  });
	});

// 通过 HTTP GET 请求载入 JSON 数据。
// 在 jQuery 1.2 中，您可以通过使用 JSONP 形式的回调函数来加载其他网域的 JSON 数据，如
// "myurl?callback=?"。jQuery 将自动替换 ? 为正确的函数名，以执行回调函数。 注意：此行以后的代码将在这个回调函数执行前执行。
// 语法
// jQuery.getJSON(url,data,success(data,status,xhr))
// 参数 描述
// url 必需。规定将请求发送的哪个 URL。
// data 可选。规定连同请求发送到服务器的数据。
// success(data,status,xhr)
// 可选。规定当请求成功时运行的函数。
// 额外的参数：
// response - 包含来自请求的结果数据
// status - 包含请求的状态
// xhr - 包含 XMLHttpRequest 对象

// 发送到服务器的数据可作为查询字符串附加到 URL 之后。如果 data 参数的值是对象（映射），那么在附加到 URL 之前将转换为字符串，并进行 URL
// 编码。
// 传递给 callback 的返回数据，可以是 JavaScript 对象，或以 JSON 结构定义的数组，并使用 $.parseJSON()
// 方法进行解析。
// 示例
// 从 test.js 载入 JSON 数据并显示 JSON 数据中一个 name 字段数据：
$.getJSON("test.js", function(json){
  alert("JSON Data: " + json.users[3].name);
});




$.getJSON("http://api.flickr.com/services/feeds/photos_public.gne?tags=cat&tagmode=any&format=json&jsoncallback=?", function(data){
		  $.each(data.items, function(i,item){
		    $("<img/>").attr("src", item.media.m).appendTo("#images");
		    if ( i == 3 ) return false;
		  });
		});


$.getJSON("test.js", { name: "John", time: "2pm" }, function(json){
	  alert("JSON Data: " + json.users[3].name);
	});


// jQuery.getScript() 使用 HTTP GET 请求从服务器加载 JavaScript 文件，然后执行该文件。


$("button").click(function(){
	  $.getScript("demo_ajax_script.js");
	});

// getScript() 方法通过 HTTP GET 请求载入并执行 JavaScript 文件。
// 语法
// jQuery.getScript(url,success(response,status))
// 参数 描述
// url 将要请求的 URL 字符串。
// success(response,status)
// 可选。规定请求成功后执行的回调函数。
// 额外的参数：
// response - 包含来自请求的结果数据
// status - 包含请求的状态（"success", "notmodified", "error", "timeout" 或
// "parsererror"）
//

// 这里的回调函数会传入返回的 JavaScript 文件。这通常不怎么有用，因为那时脚本已经运行了。
// 载入的脚本在全局环境中执行，因此能够引用其他变量，并使用 jQuery 函数。
//

// 通过引用该文件名，就可以载入并运行这段脚本：
$.getScript("ajax/test.js", function() {
  alert("Load was performed.");
});


// 比如加载一个 test.js 文件，里边包含下面这段代码：
$(".result").html("<p>Lorem ipsum dolor sit amet.</p>");
// 注释：jQuery 1.2 版本之前，getScript 只能调用同域 JS 文件。 1.2中，您可以跨域调用 JavaScript
// 文件。注意：Safari 2 或更早的版本不能在全局作用域中同步执行脚本。如果通过 getScript 加入脚本，请加入延时函数。




// 加载并执行 test.js：
$.getScript("test.js");
// 加载并执行 test.js ，成功后显示信息：
$.getScript("test.js", function(){
  alert("Script loaded and executed.");
});
// 例子 3
// 载入 jQuery 官方颜色动画插件 成功后绑定颜色变化动画：
// <button id="go">Run</button>
// <div class="block"></div>
jQuery.getScript("http://dev.jquery.com/view/trunk/plugins/color/jquery.color.js",
 function(){
  $("#go").click(function(){
    $(".block").animate( { backgroundColor: 'pink' }, 1000)
      .animate( { backgroundColor: 'blue' }, 1000);
  });
});


// .load() 从服务器加载数据，然后把返回到 HTML 放入匹配元素。
$(selector).load(URL,data,callback);
$("#div1").load("demo_test.txt");// load() 方法从服务器加载数据，并把返回的数据放入被选元素中。

$("#div1").load("demo_test.txt #p1");


// 下面的例子把 "demo_test.txt" 文件中 id="p1"
// 的元素的内容，加载到指定的 <div> 元素中：

// responseTxt - 包含调用成功时的结果内容
/*
 * statusTXT - 包含调用的状态 xhr - 包含 XMLHttpRequest 对象
 */
$("button").click(function(){
	  $("#div1").load("demo_test.txt",function(responseTxt,statusTxt,xhr){
	    if(statusTxt=="success")
	      alert("外部内容加载成功！");
	    if(statusTxt=="error")
	      alert("Error: "+xhr.status+": "+xhr.statusText);
// xhr xhr - 包含 XMLHttpRequest 对象
	  });
	});


// load(url,data,function(response,status,xhr))
// 参数 描述
// url 规定要将请求发送到哪个 URL。
// data 可选。规定连同请求发送到服务器的数据。
// function(response,status,xhr)
// 可选。规定当请求完成时运行的函数。
// 额外的参数：
// response - 包含来自请求的结果数据
// status - 包含请求的状态（"success", "notmodified", "error", "timeout" 或
// "parsererror"）
// xhr - 包含 XMLHttpRequest 对象


// 该方法是最简单的从服务器获取数据的方法。它几乎与 $.get(url, data, success)
// 等价，不同的是它不是全局函数，并且它拥有隐式的回调函数。当侦测到成功的响应时（比如，当 textStatus 为 "success" 或
// "notmodified" 时），.load() 将匹配元素的 HTML 内容设置为返回的数据

// .load() 方法，与 $.get() 不同，允许我们规定要插入的远程文档的某个部分。这一点是通过 url
// 参数的特殊语法实现的。如果该字符串中包含一个或多个空格，紧接第一个空格的字符串则是决定所加载内容的 jQuery 选择器。
// 我们可以修改上面的例子，这样就可以使用所获得文档的某部分：
// $("#result").load("ajax/test.html #container");


// 如果执行该方法，则会取回 ajax/test.html 的内容，不过然后，jQuery 会解析被返回的文档，来查找带有容器 ID
// 的元素。该元素，连同其内容，会被插入带有结果 ID 的元素中，所取回文档的其余部分会被丢弃。
// jQuery 使用浏览器的 .innerHTML 属性来解析被取回的文档，并把它插入当前文档。在此过程中，浏览器常会从文档中过滤掉元素，比如
// <html>, <title> 或 <head> 元素。结果是，由 .load() 取回的元素可能与由浏览器直接取回的文档不完全相同。

// 加载 feeds.html 文件内容：
$("#feeds").load("feeds.html");
// 与上面的实例类似，但是以 POST 形式发送附加参数并在成功时显示信息：
$("#feeds").load("feeds.php", {limit: 25}, function(){
  alert("The last 25 entries in the feed have been loaded");
});
// 加载文章侧边栏导航部分至一个无序列表：
// <b>jQuery Links:</b>
// <ul id="links"></ul>
$("#links").load("/Main_Page #p-Getting-Started li");


$("#result").load("ajax/test.html");
$("#result").load("ajax/test.html", function() {
	  alert("Load was performed.");
	});



// jQuery.param() 创建数组或对象的序列化表示，适合在 URL 查询字符串或 Ajax 请求中使用。
// 序列化一个 key/value 对象：
var params = { width:1900, height:1200 };
var str = jQuery.param(params);
$("#results").text(str);

// 结果:
// width=1680&height=1050
// TIY 实例
// 输出序列化对象的结果：
$("button").click(function(){
  $("div").text($.param(personObj));
});

// param() 方法创建数组或对象的序列化表示。
// 该序列化值可在进行 AJAX 请求时在 URL 查询字符串中使用。
// 语法
jQuery.param(object,traditional)
// 参数 描述
// object 要进行序列化的数组或对象。
// traditional 规定是否使用传统的方式浅层进行序列化（参数序列化）。
// 详细说明
// param() 方法用于在内部将元素值转换为序列化的字符串表示。请参阅 .serialize() 了解更多信息。
// 对于 jQuery 1.3，如果传递的参数是一个函数，那么用 .param() 会得到这个函数的返回值，而不是把这个函数作为一个字符串来返回。
// 对于 jQuery 1.4，.param() 方法将会通过深度递归的方式序列化对象，以便符合现代化脚本语言的需求，比如 PHP、Ruby on Rails
// 等。你可以通过设置 jQuery.ajaxSettings.traditional = true; 来全局地禁用这个功能。
// 如果被传递的对象在数组中，则必须是以 .serializeArray() 的返回值为格式的对象数组：
[{name:"first",value:"Rick"},
{name:"last",value:"Astley"},
{name:"job",value:"Rock Star"}]


// 可以将 traditional 参数设置为 true，来模拟 jQuery 1.4 之前版本中 $.param() 的行为：
var myObject = {
  a: {
    one: 1, 
    two: 2, 
    three: 3
  }, 
  b: [1,2,3]
};
var shallowEncoded = $.param(myObject, true);
var shallowDecoded = decodeURIComponent(shallowEncoded);

alert(shallowEncoded);
alert(shallowDecoded);
// a=%5Bobject+Object%5D&b=1&b=2&b=3a=[object+Object]&b=1&b=2&b=3
// 对象的查询字符串表示以及 URI 编码版本
var myObject = {
	  a: {
	    one: 1, 
	    two: 2, 
	    three: 3
	  }, 
	  b: [1,2,3]
	};
	var recursiveEncoded = $.param(myObject);
	var recursiveDecoded = decodeURIComponent($.param(myObject));

	alert(recursiveEncoded);
	alert(recursiveDecoded);

// a=%5Bobject+Object%5D&b=1&b=2&b=3a=[object+Object]&b=1&b=2&b=3














// jQuery.post() 使用 HTTP POST 请求从服务器加载数据。
$.post(URL,data,callback);
$("button").click(function(){
	  $.post("demo_test_post.asp",
	  {
	    name:"Donald Duck",
	    city:"Duckburg"
	  },
	  function(data,status){
	    alert("Data: " + data + "\nStatus: " + status);
	  });
	});
// demo_test_post.asp:
// <%
// dim fname,city
// fname=Request.Form("name")
// city=Request.Form("city")
// Response.Write("Dear " & fname & ". ")
// Response.Write("Hope you live well in " & city & ".")
// %>



$.post("test.php");
// $("input").keyup(function(){
// txt=$("input").val();
// $.post("demo_ajax_gethint.asp",{suggest:txt},function(result){
// $("span").html(result);
// });
// });

// jQuery.post(url,data,success(data, textStatus, jqXHR),dataType)
// 参数 描述
// url 必需。规定把请求发送到哪个 URL。
// data 可选。映射或字符串值。规定连同请求发送到服务器的数据。
// success(data, textStatus, jqXHR) 可选。请求成功时执行的回调函数。
// dataType
// 可选。规定预期的服务器响应的数据类型。
// 默认执行智能判断（xml、json、script 或 html）。


// 根据响应的不同的 MIME 类型，传递给 success 回调函数的返回数据也有所不同，这些数据可以是 XML 根元素、文本字符串、JavaScript
// 文件或者 JSON 对象。也可向 success 回调函数传递响应的文本状态。
$.post("ajax/test.html", function(data) {
	  $(".result").html(data);
	});


// 通过 POST 读取的页面不被缓存，因此 jQuery.ajaxSetup() 中的 cache 和 ifModified 选项不会影响这些请求。
// jQuery 1.5，jQuery.post() 返回的 jqXHR 对象的 .error() 方法也可以用于错误处理。
// 对于 jQuery 1.5，也可以向 success 回调函数传递 jqXHR 对象（jQuery 1.4 中传递的是 XMLHttpRequest
// 对象）



// jqXHR 对象

// 对于 jQuery 1.5，所有 jQuery 的 AJAX 方法返回的是 XMLHTTPRequest 对象的超集。由 $.post() 返回的
// jQuery XHR 对象或 "jqXHR,"实现了约定的接口，赋予其所有的属性、方法，以及约定的行为。出于对由 $.ajax()
// 使用的回调函数名称便利性和一致性的考虑，它提供了 .error(), .success() 以及 .complete()
// 方法。这些方法使用请求终止时调用的函数参数，该函数接受与对应命名的 $.ajax() 回调函数相同的参数。
// jQuery 1.5 中的约定接口同样允许 jQuery 的 Ajax 方法，包括 $.post()，来链接同一请求的多个
// .success()、.complete() 以及 .error() 回调函数，甚至会在请求也许已经完成后分配这些回调函数。
// // 请求生成后立即分配处理程序，请记住该请求针对 jqxhr 对象
    var jqxhr = $.post("example.php", function() {
      alert("success");
    }) .success(function() { alert("second success"); })
    .error(function() { alert("error"); })
    .complete(function() { alert("complete"); });

    // 在这里执行其他任务
    
    
    // 为上面的请求设置另一个完成函数
    jqxhr.complete(function(){ alert("second complete"); });


   // 例子 1
   // 请求 test.php 页面，并一起发送一些额外的数据（同时仍然忽略返回值）：
    $.post("test.php", { name: "John", time: "2pm" } );
   // 例子 2
   // 向服务器传递数据数组（同时仍然忽略返回值）：
    $.post("test.php", { 'choices[]': ["Jon", "Susan"] });
   // 例子 3
   // 使用 ajax 请求发送表单数据：
    $.post("test.php", $("#testform").serialize());
  // 例子 4
  // 输出来自请求页面 test.php 的结果（HTML 或 XML，取决于所返回的内容）：
    $.post("test.php", function(data){
       alert("Data Loaded: " + data);
     });
// 例子 5
// 向页面 test.php 发送数据，并输出结果（HTML 或 XML，取决于所返回的内容）：
    $.post("test.php", { name: "John", time: "2pm" },
       function(data){
         alert("Data Loaded: " + data);
       });
// 例子 6
// 获得 test.php 页面的内容，并存储为 XMLHttpResponse 对象，并通过 process() 这个 JavaScript 函数进行处理：
    $.post("test.php", { name: "John", time: "2pm" },
       function(data){
         process(data);
       }, "xml");
// 例子 7
// 获得 test.php 页面返回的 json 格式的内容：
    $.post("test.php", { "func": "getNameAndTime" },
       function(data){
         alert(data.name); // John
         console.log(data.time); // 2pm
       }, "json");



// .serialize() 将表单内容序列化为字符串。
    //输出序列化表单值的结果：
    $("button").click(function(){
      $("div").text($("form").serialize());
    });
//    serialize() 方法通过序列化表单值，创建 URL 编码文本字符串。
//    您可以选择一个或多个表单元素（比如 input 及/或 文本框），或者 form 元素本身。
//    序列化的值可在生成 AJAX 请求时用于 URL 查询字符串中。
    $(selector).serialize();
    //.serialize() 方法创建以标准 URL 编码表示的文本字符串。它的操作对象是代表表单元素集合的 jQuery 对象。
    
   // .serialize() 方法可以操作已选取个别表单元素的 jQuery 对象，比如 <input>, <textarea> 以及 <select>。不过，选择 <form> 标签本身进行序列化一般更容易些：
    $('form').submit(function() {
      alert($(this).serialize());
      return false;
    });
    
//    <form>
//    <div><input type="text" name="a" value="1" id="a" /></div>
//    <div><input type="text" name="b" value="2" id="b" /></div>
//    <div><input type="hidden" name="c" value="3" id="c" /></div>
//    <div>
//      <textarea name="d" rows="8" cols="40">4</textarea>
//    </div>
//    <div><select name="e">
//      <option value="5" selected="selected">5</option>
//      <option value="6">6</option>
//      <option value="7">7</option>
//    </select></div>
//    <div>
//      <input type="checkbox" name="f" value="8" id="f" />
//    </div>
//    <div>
//      <input type="submit" name="g" value="Submit" id="g" />
//    </div>
//  </form>
    
  //  输出标准的查询字符串：
 //   a=1&b=2&c=3&d=4&e=5
    
//   只会将”成功的控件“序列化为字符串。如果不使用按钮来提交表单，则不对提交按钮的值序列化。如果要表单元素的值包含到序列字符串中，元素必须使用 name 属性。
    
// .serializeArray() 序列化表单元素，返回 JSON 数据结构数据。
   // 输出以数组形式序列化表单值的结果：
    $("button").click(function(){
      x=$("form").serializeArray();
      $.each(x, function(i, field){
        $("#results").append(field.name + ":" + field.value + " ");
      });
    });

//    serializeArray() 方法通过序列化表单值来创建对象数组（名称和值）。
//    您可以选择一个或多个表单元素（比如 input 及/或 textarea），或者 form 元素本身。


//    $(selector).serializeArray()
//    详细说明
//    serializeArray() 方法序列化表单元素（类似 .serialize() 方法），返回 JSON 数据结构数据。
//    注意：此方法返回的是 JSON 对象而非 JSON 字符串。需要使用插件或者第三方库进行字符串化操作。
//    返回的 JSON 对象是由一个对象数组组成的，其中每个对象包含一个或两个名值对 —— name 参数和 value 参数（如果 value 不为空的话）。举例来说：
//    [ 
//      {name: 'firstname', value: 'Hello'}, 
//      {name: 'lastname', value: 'World'},
//      {name: 'alias'}, // 值为空
//    ]
//    .serializeArray() 方法使用了 W3C 关于 successful controls（有效控件） 的标准来检测哪些元素应当包括在内。特别说明，元素不能被禁用（禁用的元素不会被包括在内），并且元素应当有含有 name 属性。提交按钮的值也不会被序列化。文件选择元素的数据也不会被序列化。
//    该方法可以对已选择单独表单元素的对象进行操作，比如 <input>, <textarea>, 和 <select>。不过，更方便的方法是，直接选择 <form> 标签自身来进行序列化操作。
    $("form").submit(function() {
      console.log($(this).serializeArray());
      return false;
    });

    //上面的代码产生下面的数据结构（假设浏览器支持 console.log）：
    [ { name: a
        value: 1
      },
      {
        name: b
        value: 2
      },
      {
        name: c
        value: 3
      },
      {
        name: d
        value: 4
      },
      {
        name: e
        value: 5
      }
    ]



//    <p id="results"><b>Results:</b> </p>
//    <form>
//      <select name="single">
//        <option>Single</option>
//        <option>Single2</option>
//      </select>
//      <select name="multiple" multiple="multiple">
//        <option selected="selected">Multiple</option>
//        <option>Multiple2</option>
//        <option selected="selected">Multiple3</option>
//      </select><br/>
//      <input type="checkbox" name="check" value="check1"/> check1
//      <input type="checkbox" name="check" value="check2" checked="checked"/> check2
//      <input type="radio" name="radio" value="radio1" checked="checked"/> radio1
//      <input type="radio" name="radio" value="radio2"/> radio2
//    </form>

  var fields = $("select, :radio").serializeArray();
  jQuery.each( fields, function(i, field){
    $("#results").append(field.value + " ");//取得表单选中的值
  });















// input name="headcooker"
// input name="title"
// id="title"
// id="storeName"
// id="datetime"


// 一直调用error方法，请求失败时调用此函数。有以下三个参数：XMLHttpRequest 对象、错误信息、（可选）捕获的异常对象。
// 如果发生了错误，错误信息（第二个参数）除了得到null之外，还可能是"timeout", "error", "notmodified" 和
// "parsererror"。
// 参考如下：
$.ajax({
url : "/education2/json/getSearchQuestionknowledgeview",
type: "post",
data : params,
dataType : "json",
cache : false,
error : function(textStatus, errorThrown) {
	alert("系统ajax交互错误: " + textStatus);
}
});
// 调试停在alert("系统ajax交互错误: " +
// textStatus);处,然后在firebug右边的监控窗口看"textStatus",展开看有详细错误细节.errorThrown中有错误类型。


// timeout Number 设置请求超时时间（毫秒）。此设置将覆盖全局设置。 async Boolean (默认: true)
// 默认设置下，所有请求均为异步请求。如果需要发送同步请求，请将此选项设置为 false。注意，同步请求将锁住浏览器，用户其它操作必须等待请求完成才可以执行。
// beforeSend Function 发送请求前可修改 XMLHttpRequest 对象的函数，如添加自定义 HTTP
// 头。XMLHttpRequest 对象是唯一的参数。
// function (XMLHttpRequest) { this; // the options for this ajax request }
// cache Boolean (默认: true) jQuery 1.2 新功能，设置为 false 将不会从浏览器缓存中加载请求信息。 complete
// Function 请求完成后回调函数 (请求成功或失败时均调用)。参数： XMLHttpRequest 对象，成功信息字符串。
// function (XMLHttpRequest, textStatus) { this; // the options for this ajax
// request }
// contentType String (默认: "application/x-www-form-urlencoded")
// 发送信息至服务器时内容编码类型。默认值适合大多数应用场合。 data Object, String 发
// 送到服务器的数据。将自动转换为请求字符串格式。GET 请求中将附加在 URL 后。查看 processData 选项说明以禁止此自动转换。必须为
// Key/Value 格式。如果为数组，jQuery 将自动为不同值对应同一个名称。如 {foo:["bar1", "bar2"]} 转换为
// '&foo=bar1&foo=bar2'。 dataType String
// 预期服务器返回的数据类型。如果不指定，jQuery 将自动根据 HTTP 包 MIME 信息返回 responseXML 或
// responseText，并作为回调函数参数传递，可用值:
// "xml": 返回 XML 文档，可用 jQuery 处理。
// "html": 返回纯文本 HTML 信息；包含 script 元素。
// "script": 返回纯文本 JavaScript 代码。不会自动缓存结果。
// "json": 返回 JSON 数据 。
// "jsonp": JSONP 格式。使用 JSONP 形式调用函数时，如 "myurl?callback=?" jQuery 将自动替换 ?
// 为正确的函数名，以执行回调函数。
// error Function (默认: 自动判断 (xml 或 html)) 请求失败时将调用此方法。这个方法有三个参数：XMLHttpRequest
// 对象，错误信息，（可能）捕获的错误对象。
// function (XMLHttpRequest, textStatus, errorThrown) { //
// 通常情况下textStatus和errorThown只有其中一个有值 this; // the options for this ajax request
// }
// global Boolean (默认: true) 是否触发全局 AJAX 事件。设置为 false 将不会触发全局 AJAX 事件，如
// ajaxStart 或 ajaxStop 。可用于控制不同的Ajax事件 ifModified Boolean (默认: false)
// 仅在服务器数据改变时获取新数据。使用 HTTP 包 Last-Modified 头信息判断。 processData Boolean (默认: true)
// 默认情况下，发送的数据将被转换为对象(技术上讲并非字符串) 以配合默认内容类型
// "application/x-www-form-urlencoded"。如果要发送 DOM 树信息或其它不希望转换的信息，请设置为 false。
// success Function 请求成功后回调函数。这个方法有两个参数：服务器返回数据，返回状态
// function (data, textStatus) { // data could be xmlDoc, jsonObj, html, text,
// etc... this; // the options for this ajax request }
//
$(document).ready(function() {
        jQuery("#clearCac").click(function() {
            jQuery.ajax({
                url: "/Handle/Do.aspx",
                type: "post",
                data: { id: '0' },
                dataType: "json",
                success: function(msg) {
                    alert(msg);
                },
                error: function(XMLHttpRequest, textStatus, errorThrown) {
                    alert(XMLHttpRequest.status);
                    alert(XMLHttpRequest.readyState);
                    alert(textStatus);
                },
                complete: function(XMLHttpRequest, textStatus) {
                    this; // 调用本次AJAX请求时传递的options参数
                }
            });
        });
    });



// 一、error：function (XMLHttpRequest, textStatus, errorThrown)
// {
// }
// (默 认: 自动判断 (xml 或 html)) 请求失败时调用时间。参数有以下三个：XMLHttpRequest
// 对象、错误信息、（可选）捕获的错误对象。如果发生了错误，错误信息（第二个参数）除了得到null之外，还可能是"timeout", "error",
// "notmodified" 和 "parsererror"。
//
// textStatus:
//
// "timeout", "error", "notmodified" 和 "parsererror"。
//
// 二、error事件返回的第一个参数XMLHttpRequest有一些有用的信息：
//
// XMLHttpRequest.readyState:
// 状态码
// － （未初始化）还没有调用send()方法
// － （载入）已调用send()方法，正在发送请求
// － （载入完成）send()方法执行完成，已经接收到全部响应内容
// － （交互）正在解析响应内容
// － （完成）响应内容解析完成，可以在客户端调用了
//
// 三、data:"{}", data为空也一定要传"{}"；不然返回的是xml格式的。并提示parsererror.
//
// 四、parsererror的异常和Header 类型也有关系。及编码header('Content-type: text/html;
// charset=utf8');
// 五、XMLHttpRequest.status:
// xx-信息提示
// 这些状态代码表示临时的响应。客户端在收到常规响应之前，应准备接收一个或多个1xx响应。
// -继续。
// -切换协议。
//
// xx-成功
// 这类状态代码表明服务器成功地接受了客户端请求。
// -确定。客户端请求已成功。
// -已创建。
// -已接受。
// -非权威性信息。
// -无内容。
// -重置内容。
// -部分内容。
//
// xx-重定向
// 客户端浏览器必须采取更多操作来实现请求。例如，浏览器可能不得不请求服务器上的不同的页面，或通过代理服务器重复该请求。
// -对象已永久移走，即永久重定向。
// -对象已临时移动。
// -未修改。
// -临时重定向。
//
// xx-客户端错误
// 发生错误，客户端似乎有问题。例如，客户端请求不存在的页面，客户端未提供有效的身份验证信息。400-错误的请求。
// -访问被拒绝。IIS定义了许多不同的401错误，它们指明更为具体的错误原因。这些具体的错误代码在浏览器中显示，但不在IIS日志中显示：
// .1-登录失败。
// .2-服务器配置导致登录失败。
// .3-由于ACL对资源的限制而未获得授权。
// .4-筛选器授权失败。
// .5-ISAPI/CGI应用程序授权失败。
// .7–访问被Web服务器上的URL授权策略拒绝。这个错误代码为IIS6.0所专用。
// -禁止访问：IIS定义了许多不同的403错误，它们指明更为具体的错误原因：
// .1-执行访问被禁止。
// .2-读访问被禁止。
// .3-写访问被禁止。
// .4-要求SSL。
// .5-要求SSL128。
// .6-IP地址被拒绝。
// .7-要求客户端证书。
// .8-站点访问被拒绝。
// .9-用户数过多。
// .10-配置无效。
// .11-密码更改。
// .12-拒绝访问映射表。
// .13-客户端证书被吊销。
// .14-拒绝目录列表。
// .15-超出客户端访问许可。
// .16-客户端证书不受信任或无效。
// .17-客户端证书已过期或尚未生效。
// .18-在当前的应用程序池中不能执行所请求的URL。这个错误代码为IIS6.0所专用。
// .19-不能为这个应用程序池中的客户端执行CGI。这个错误代码为IIS6.0所专用。
// .20-Passport登录失败。这个错误代码为IIS6.0所专用。
// -未找到。
// .0-（无）–没有找到文件或目录。
// .1-无法在所请求的端口上访问Web站点。
// .2-Web服务扩展锁定策略阻止本请求。
// .3-MIME映射策略阻止本请求。
// -用来访问本页面的HTTP谓词不被允许（方法不被允许）
// -客户端浏览器不接受所请求页面的MIME类型。
// -要求进行代理身份验证。
// -前提条件失败。
// –请求实体太大。
// -请求URI太长。
// –不支持的媒体类型。
// –所请求的范围无法满足。
// –执行失败。
// –锁定的错误。
//
// xx-服务器错误
// 服务器由于遇到错误而不能完成该请求。
// -内部服务器错误。
// .12-应用程序正忙于在Web服务器上重新启动。
// .13-Web服务器太忙。
// .15-不允许直接请求Global.asa。
// .16–UNC授权凭据不正确。这个错误代码为IIS6.0所专用。
// .18–URL授权存储不能打开。这个错误代码为IIS6.0所专用。
// .100-内部ASP错误。
// -页眉值指定了未实现的配置。
// -Web服务器用作网关或代理服务器时收到了无效响应。
// .1-CGI应用程序超时。
// .2-CGI应用程序出错。application.
// -服务不可用。这个错误代码为IIS6.0所专用。
// -网关超时。
// -HTTP版本不受支持。
// FTP
//
// xx-肯定的初步答复
// 这些状态代码指示一项操作已经成功开始，但客户端希望在继续操作新命令前得到另一个答复。
// 重新启动标记答复。
// 服务已就绪，在nnn分钟后开始。
// 数据连接已打开，正在开始传输。
// 文件状态正常，准备打开数据连接。
//
// xx-肯定的完成答复
// 一项操作已经成功完成。客户端可以执行新命令。200命令确定。
// 未执行命令，站点上的命令过多。
// 系统状态，或系统帮助答复。
// 目录状态。
// 文件状态。
// 帮助消息。
// NAME系统类型，其中，NAME是AssignedNumbers文档中所列的正式系统名称。
// 服务就绪，可以执行新用户的请求。
// 服务关闭控制连接。如果适当，请注销。
// 数据连接打开，没有进行中的传输。
// 关闭数据连接。请求的文件操作已成功（例如，传输文件或放弃文件）。
// 进入被动模式(h1,h2,h3,h4,p1,p2)。
// 用户已登录，继续进行。
// 请求的文件操作正确，已完成。
// 已创建“PATHNAME”。
//
// xx-肯定的中间答复
// 该命令已成功，但服务器需要更多来自客户端的信息以完成对请求的处理。331用户名正确，需要密码。
// 需要登录帐户。
// 请求的文件操作正在等待进一步的信息。
//
// xx-瞬态否定的完成答复
// 该命令不成功，但错误是暂时的。如果客户端重试命令，可能会执行成功。421服务不可用，正在关闭控制连接。如果服务确定它必须关闭，将向任何命令发送这一应答。
// 无法打开数据连接。
// Connectionclosed;transferaborted.
// 未执行请求的文件操作。文件不可用（例如，文件繁忙）。
// 请求的操作异常终止：正在处理本地错误。
// 未执行请求的操作。系统存储空间不够。
//
// xx-永久性否定的完成答复
// 该命令不成功，错误是永久性的。如果客户端重试命令，将再次出现同样的错误。500语法错误，命令无法识别。这可能包括诸如命令行太长之类的错误。
// 在参数中有语法错误。
// 未执行命令。
// 错误的命令序列。
// 未执行该参数的命令。
// 未登录。
// 存储文件需要帐户。
// 未执行请求的操作。文件不可用（例如，未找到文件，没有访问权限）。
// 请求的操作异常终止：未知的页面类型。
// 请求的文件操作异常终止：超出存储分配（对于当前目录或数据集）。
// 未执行请求的操作。不允许的文件名。
// 常见的FTP状态代码及其原因
// -FTP使用两个端口：21用于发送命令，20用于发送数据。状态代码150表示服务器准备在端口20上打开新连接，发送一些数据。
// -命令在端口20上打开数据连接以执行操作，如传输文件。该操作成功完成，数据连接已关闭。
// -客户端发送正确的密码后，显示该状态代码。它表示用户已成功登录。
// -客户端发送用户名后，显示该状态代码。无论所提供的用户名是否为系统中的有效帐户，都将显示该状态代码。
// -命令打开数据连接以执行操作，但该操作已被取消，数据连接已关闭。
// -该状态代码表示用户无法登录，因为用户名和密码组合无效。如果使用某个用户帐户登录，可能键入错误的用户名或密码，也可能选择只允许匿名访问。如果使用匿名帐户登录，IIS的配置可能拒绝匿名访问。
// -命令未被执行，因为指定的文件不可用。例如，要GET的文件并不存在，或试图将文件PUT到您没有写入权限的目录。



// ajax() 方法通过 HTTP 请求加载远程数据。
// 该方法是 jQuery 底层 AJAX 实现。简单易用的高层实现见 $.get, $.post 等。$.ajax() 返回其创建的
// XMLHttpRequest 对象。大多数情况下你无需直接操作该函数，除非你需要操作不常用的选项，以获得更多的灵活性。
// 最简单的情况下，$.ajax() 可以不带任何参数直接使用。
// 注意：所有的选项都可以通过 $.ajaxSetup() 函数来全局设置。
// 语法
// jQuery.ajax([settings])
// 参数 描述
// settings
// 可选。用于配置 Ajax 请求的键值对集合。
// 可以通过 $.ajaxSetup() 设置任何选项的默认值。
// 参数
// options
// 类型：Object
// 可选。AJAX 请求设置。所有选项都是可选的。
// async
// 类型：Boolean
// 默认值: true。默认设置下，所有请求均为异步请求。如果需要发送同步请求，请将此选项设置为 false。
// 注意，同步请求将锁住浏览器，用户其它操作必须等待请求完成才可以执行。
// beforeSend(XHR)
// 类型：Function
// 发送请求前可修改 XMLHttpRequest 对象的函数，如添加自定义 HTTP 头。
// XMLHttpRequest 对象是唯一的参数。
// 这是一个 Ajax 事件。如果返回 false 可以取消本次 ajax 请求。
// cache
// 类型：Boolean
// 默认值: true，dataType 为 script 和 jsonp 时默认为 false。设置为 false 将不缓存此页面。
// jQuery 1.2 新功能。
// complete(XHR, TS)
// 类型：Function
// 请求完成后回调函数 (请求成功或失败之后均调用)。
// 参数： XMLHttpRequest 对象和一个描述请求类型的字符串。
// 这是一个 Ajax 事件。
// contentType
// 类型：String
// 默认值: "application/x-www-form-urlencoded"。发送信息至服务器时内容编码类型。
// 默认值适合大多数情况。如果你明确地传递了一个 content-type 给 $.ajax() 那么它必定会发送给服务器（即使没有数据要发送）。
// context
// 类型：Object
// 这个对象用于设置 Ajax 相关回调函数的上下文。也就是说，让回调函数内 this 指向这个对象（如果不设定这个参数，那么 this 就指向调用本次
// AJAX 请求时传递的 options 参数）。比如指定一个 DOM 元素作为 context 参数，这样就设置了 success 回调函数的上下文为这个
// DOM 元素。
// 就像这样：
// $.ajax({ url: "test.html", context: document.body, success: function(){
// $(this).addClass("done");
// }});
// data
// 类型：String
// 发送到服务器的数据。将自动转换为请求字符串格式。GET 请求中将附加在 URL 后。查看 processData 选项说明以禁止此自动转换。必须为
// Key/Value 格式。如果为数组，jQuery 将自动为不同值对应同一个名称。如 {foo:["bar1", "bar2"]} 转换为
// '&foo=bar1&foo=bar2'。
// dataFilter
// 类型：Function
// 给 Ajax 返回的原始数据的进行预处理的函数。提供 data 和 type 两个参数：data 是 Ajax 返回的原始数据，type 是调用
// jQuery.ajax 时提供的 dataType 参数。函数返回的值将由 jQuery 进一步处理。
// dataType
// 类型：String
// 预期服务器返回的数据类型。如果不指定，jQuery 将自动根据 HTTP 包 MIME 信息来智能判断，比如 XML MIME 类型就被识别为 XML。在
// 1.4 中，JSON 就会生成一个 JavaScript 对象，而 script
// 则会执行这个脚本。随后服务器端返回的数据会根据这个值解析后，传递给回调函数。可用值:
// "xml": 返回 XML 文档，可用 jQuery 处理。
// "html": 返回纯文本 HTML 信息；包含的 script 标签会在插入 dom 时执行。
// "script": 返回纯文本 JavaScript 代码。不会自动缓存结果。除非设置了 "cache" 参数。注意：在远程请求时(不在同一个域下)，所有
// POST 请求都将转为 GET 请求。（因为将使用 DOM 的 script标签来加载）
// "json": 返回 JSON 数据 。
// "jsonp": JSONP 格式。使用 JSONP 形式调用函数时，如 "myurl?callback=?" jQuery 将自动替换 ?
// 为正确的函数名，以执行回调函数。
// "text": 返回纯文本字符串
// error
// 类型：Function
// 默认值: 自动判断 (xml 或 html)。请求失败时调用此函数。
// 有以下三个参数：XMLHttpRequest 对象、错误信息、（可选）捕获的异常对象。
// 如果发生了错误，错误信息（第二个参数）除了得到 null 之外，还可能是 "timeout", "error", "notmodified" 和
// "parsererror"。
// 这是一个 Ajax 事件。
// global
// 类型：Boolean
// 是否触发全局 AJAX 事件。默认值: true。设置为 false 将不会触发全局 AJAX 事件，如 ajaxStart 或 ajaxStop
// 可用于控制不同的 Ajax 事件。
// ifModified
// 类型：Boolean
// 仅在服务器数据改变时获取新数据。默认值: false。使用 HTTP 包 Last-Modified 头信息判断。在 jQuery 1.4
// 中，它也会检查服务器指定的 'etag' 来确定数据没有被修改过。
// jsonp
// 类型：String
// 在一个 jsonp 请求中重写回调函数的名字。这个值用来替代在 "callback=?" 这种 GET 或 POST 请求中 URL 参数里的
// "callback" 部分，比如 {jsonp:'onJsonPLoad'} 会导致将 "onJsonPLoad=?" 传给服务器。
// jsonpCallback
// 类型：String
// 为 jsonp 请求指定一个回调函数名。这个值将用来取代 jQuery 自动生成的随机函数名。这主要用来让 jQuery
// 生成度独特的函数名，这样管理请求更容易，也能方便地提供回调函数和错误处理。你也可以在想让浏览器缓存 GET 请求的时候，指定这个回调函数名。
// password
// 类型：String
// 用于响应 HTTP 访问认证请求的密码
// processData
// 类型：Boolean
// 默认值: true。默认情况下，通过data选项传递进来的数据，如果是一个对象(技术上讲只要不是字符串)，都会处理转化成一个查询字符串，以配合默认内容类型
// "application/x-www-form-urlencoded"。如果要发送 DOM 树信息或其它不希望转换的信息，请设置为 false。
// scriptCharset
// 类型：String
// 只有当请求时 dataType 为 "jsonp" 或 "script"，并且 type 是 "GET" 才会用于强制修改
// charset。通常只在本地和远程的内容编码不同时使用。
// success
// 类型：Function
// 请求成功后的回调函数。
// 参数：由服务器返回，并根据 dataType 参数进行处理后的数据；描述状态的字符串。
// 这是一个 Ajax 事件。
// traditional
// 类型：Boolean
// 如果你想要用传统的方式来序列化数据，那么就设置为 true。请参考工具分类下面的 jQuery.param 方法。
// timeout
// 类型：Number
// 设置请求超时时间（毫秒）。此设置将覆盖全局设置。
// type
// 类型：String
// 默认值: "GET")。请求方式 ("POST" 或 "GET")， 默认为 "GET"。注意：其它 HTTP 请求方法，如 PUT 和 DELETE
// 也可以使用，但仅部分浏览器支持。
// url
// 类型：String
// 默认值: 当前页地址。发送请求的地址。
// username
// 类型：String
// 用于响应 HTTP 访问认证请求的用户名。
// xhr
// 类型：Function
// 需要返回一个 XMLHttpRequest 对象。默认在 IE 下是 ActiveXObject 而其他情况下是 XMLHttpRequest
// 。用于重写或者提供一个增强的 XMLHttpRequest 对象。这个参数在 jQuery 1.3 以前不可用。
// 回调函数
// 如果要处理 $.ajax() 得到的数据，则需要使用回调函数：beforeSend、error、dataFilter、success、complete。
// beforeSend
// 在发送请求之前调用，并且传入一个 XMLHttpRequest 作为参数。
// error
// 在请求出错时调用。传入 XMLHttpRequest 对象，描述错误类型的字符串以及一个异常对象（如果有的话）
// dataFilter
// 在请求成功之后调用。传入返回的数据以及 "dataType" 参数的值。并且必须返回新的数据（可能是处理过的）传递给 success 回调函数。
// success
// 当请求之后调用。传入返回后的数据，以及包含成功代码的字符串。
// complete
// 当请求完成之后调用这个函数，无论成功或失败。传入 XMLHttpRequest 对象，以及一个包含成功或错误代码的字符串。
// 数据类型
// $.ajax() 函数依赖服务器提供的信息来处理返回的数据。如果服务器报告说返回的数据是 XML，那么返回的结果就可以用普通的 XML 方法或者
// jQuery 的选择器来遍历。如果见得到其他类型，比如 HTML，则数据就以文本形式来对待。
// 通过 dataType 选项还可以指定其他不同数据处理方式。除了单纯的 XML，还可以指定 html、json、jsonp、script 或者 text。
// 其中，text 和 xml 类型返回的数据不会经过处理。数据仅仅简单的将 XMLHttpRequest 的 responseText 或
// responseHTML 属性传递给 success 回调函数。
// 注意：我们必须确保网页服务器报告的 MIME 类型与我们选择的 dataType 所匹配。比如说，XML的话，服务器端就必须声明 text/xml 或者
// application/xml 来获得一致的结果。
// 如果指定为 html 类型，任何内嵌的 JavaScript 都会在 HTML 作为一个字符串返回之前执行。类似地，指定 script
// 类型的话，也会先执行服务器端生成 JavaScript，然后再把脚本作为一个文本数据返回。
// 如果指定为 json 类型，则会把获取到的数据作为一个 JavaScript 对象来解析，并且把构建好的对象作为结果返回。为了实现这个目的，它首先尝试使用
// JSON.parse()。如果浏览器不支持，则使用一个函数来构建。
// JSON 数据是一种能很方便通过 JavaScript 解析的结构化数据。如果获取的数据文件存放在远程服务器上（域名不同，也就是跨域获取数据），则需要使用
// jsonp 类型。使用这种类型的话，会创建一个查询字符串参数 callback=? ，这个参数会加在请求的 URL 后面。服务器端应当在 JSON
// 数据前加上回调函数名，以便完成一个有效的 JSONP 请求。如果要指定回调函数的参数名来取代默认的 callback，可以通过设置 $.ajax() 的
// jsonp 参数。
// 注意：JSONP 是 JSON 格式的扩展。它要求一些服务器端的代码来检测并处理查询字符串参数。
// 如果指定了 script 或者 jsonp 类型，那么当从服务器接收到数据时，实际上是用了 <script> 标签而不是 XMLHttpRequest
// 对象。这种情况下，$.ajax() 不再返回一个 XMLHttpRequest 对象，并且也不会传递事件处理函数，比如 beforeSend。
// 发送数据到服务器
// 默认情况下，Ajax 请求使用 GET 方法。如果要使用 POST 方法，可以设定 type 参数值。这个选项也会影响 data
// 选项中的内容如何发送到服务器。
// data 选项既可以包含一个查询字符串，比如 key1=value1&key2=value2 ，也可以是一个映射，比如 {key1: 'value1',
// key2: 'value2'} 。如果使用了后者的形式，则数据再发送器会被转换成查询字符串。这个处理过程也可以通过设置 processData 选项为
// false 来回避。如果我们希望发送一个 XML 对象给服务器时，这种处理可能并不合适。并且在这种情况下，我们也应当改变 contentType
// 选项的值，用其他合适的 MIME 类型来取代默认的 application/x-www-form-urlencoded 。
// 高级选项
// global 选项用于阻止响应注册的回调函数，比如 .ajaxSend，或者
// ajaxError，以及类似的方法。这在有些时候很有用，比如发送的请求非常频繁且简短的时候，就可以在 ajaxSend 里禁用这个。
// 如果服务器需要 HTTP 认证，可以使用用户名和密码可以通过 username 和 password 选项来设置。
// Ajax 请求是限时的，所以错误警告被捕获并处理后，可以用来提升用户体验。请求超时这个参数通常就保留其默认值，要不就通过 jQuery.ajaxSetup
// 来全局设定，很少为特定的请求重新设置 timeout 选项。
// 默认情况下，请求总会被发出去，但浏览器有可能从它的缓存中调取数据。要禁止使用缓存的结果，可以设置 cache 参数为
// false。如果希望判断数据自从上次请求后没有更改过就报告出错的话，可以设置 ifModified 为 true。
// scriptCharset 允许给 <script> 标签的请求设定一个特定的字符集，用于 script 或者 jsonp
// 类似的数据。当脚本和页面字符集不同时，这特别好用。
// Ajax 的第一个字母是 asynchronous 的开头字母，这意味着所有的操作都是并行的，完成的顺序没有前后关系。$.ajax() 的 async
// 参数总是设置成true，这标志着在请求开始后，其他代码依然能够执行。强烈不建议把这个选项设置成
// false，这意味着所有的请求都不再是异步的了，这也会导致浏览器被锁死。
// $.ajax 函数返回它创建的 XMLHttpRequest 对象。通常 jQuery 只在内部处理并创建这个对象，但用户也可以通过 xhr
// 选项来传递一个自己创建的 xhr 对象。返回的对象通常已经被丢弃了，但依然提供一个底层接口来观察和操控请求。比如说，调用对象上的 .abort()
// 可以在请求完成前挂起请求。











