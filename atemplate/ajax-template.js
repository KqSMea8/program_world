
//AJAX = Asynchronous JavaScript and XML（异步的 JavaScript 和 XML）。

variable=new XMLHttpRequest();

// 老版本的 Internet Explorer （IE5 和 IE6）使用 ActiveX 对象：
variable=new ActiveXObject("Microsoft.XMLHTTP");

/*
 * 为了应对所有的现代浏览器，包括 IE5 和 IE6，请检查浏览器是否支持 XMLHttpRequest 对象。如果支持，则创建
 * XMLHttpRequest 对象。如果不支持，则创建 ActiveXObject
 */
var xmlhttp;
if (window.XMLHttpRequest)
  {// code for IE7+, Firefox, Chrome, Opera, Safari
  xmlhttp=new XMLHttpRequest();
  }
else
  {// code for IE6, IE5
  xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
  }


xmlhttp.open("GET","test1.txt",true);
xmlhttp.send();


xmlhttp.open("GET","demo_get.asp",true);
xmlhttp.send();

/* 为了避免这种情况，请向 URL 添加一个唯一的 ID： */
xmlhttp.open("GET","demo_get.asp?t=" + Math.random(),true);
xmlhttp.send();

// 如果您希望通过 GET 方法发送信息，请向 URL 添加信息：
xmlhttp.open("GET","demo_get2.asp?fname=Bill&lname=Gates",true);
xmlhttp.send();

// POST 请求
// 一个简单 POST 请求：
xmlhttp.open("POST","demo_post.asp",true);
xmlhttp.send();

// 如果需要像 HTML 表单那样 POST 数据，请使用 setRequestHeader() 来添加 HTTP 头。然后在 send()
// 方法中规定您希望发送的数据：
xmlhttp.open("POST","ajax_test.asp",true);
xmlhttp.setRequestHeader("Content-type","application/x-www-form-urlencoded");
xmlhttp.send("fname=Bill&lname=Gates");




// open() 方法的 url 参数是服务器上文件的地址：
// xmlhttp.open("GET","ajax_test.asp",true);

xmlhttp.open("GET","ajax_test.asp",true);


xmlhttp.onreadystatechange=function()
{
if (xmlhttp.readyState==4 && xmlhttp.status==200)
  {
  document.getElementById("myDiv").innerHTML=xmlhttp.responseText;
  }
}
xmlhttp.open("GET","test1.txt",true);
xmlhttp.send();

xmlhttp.open("GET","test1.txt",false);
xmlhttp.send();
document.getElementById("myDiv").innerHTML=xmlhttp.responseText;


document.getElementById("myDiv").innerHTML=xmlhttp.responseText;

xmlDoc=xmlhttp.responseXML;
txt="";
x=xmlDoc.getElementsByTagName("ARTIST");
for (i=0;i<x.length;i++)
  {
  txt=txt + x[i].childNodes[0].nodeValue + "<br />";
  }
document.getElementById("myDiv").innerHTML=txt;


xmlhttp.onreadystatechange=function()
{
if (xmlhttp.readyState==4 && xmlhttp.status==200)
  {
  document.getElementById("myDiv").innerHTML=xmlhttp.responseText;
  }
}


/* 使用 Callback 函数 */
function myFunction()
{
loadXMLDoc("ajax_info.txt",function()
  {
  if (xmlhttp.readyState==4 && xmlhttp.status==200)
    {
    document.getElementById("myDiv").innerHTML=xmlhttp.responseText;
    }
  });
}




// 通过上述代码我们已经成功的创建了ajax核心对象,我们保存在变量xhr中,接下来提到的ajax核心对象都将以xhr代替.
// 第二步就是与服务器建立连接,通过ajax核心对象调用open(method,url,async)方法.
// open方法的形参解释:
// method表示请求方式(get或post)
// url表示请求的php的地址(注意当请求类型为get的时候,请求的数据将以问号跟随url地址后面,下面的send方法中将传入null值)
// async是个布尔值,表示是否异步,默认为true.在最新规范中这一项已经不在需要填写,因为官方认为使用ajax就是为了实现异步.
// xhr.open("get","01.php?user=xianfeng");//这是get方式请求数据
// xhr.open("post","01.php");//这是以post方式请求数据
// 第三步我们将向服务器发送请求,利用ajax核心对象调用send方法
// 如果是post方式,请求的数据将以name=value形式放在send方法里发送给服务器,get方式直接传入null值
// xhr.send("user=xianfeng");//这是以post方式发送请求数据
// xhr.send(null);//这是以get方式
//  第四步接收服务器响应回来的数据,使用onreadystatechange事件监听服务器的通信状态.通过readyState属性获取服务器端当前通信状态.status获得状态码,利用responseText属性接收服务器响应回来的数据(这里指text类型的字符串格式数据).后面再写XML格式的数据和大名鼎鼎的json格式数据.

xhr.onreadystatechange = function(){   
	// 保证服务器端响应的数据发送完毕,保证这次请求必须是成功的
	if(xhr.readyState == 4&&xhr.status == 200){                    
		// 接收服务器端的数据
		var data = xhr.responseText;                  
		// 测试
		console.log(data);                     
     };
}


/*
 * 如果输入框为空 (str.length==0)，则该函数清空 txtHint 占位符的内容，并退出函数。 如果输入框不为空，showHint()
 * 函数执行以下任务： 创建 XMLHttpRequest 对象 当服务器响应就绪时执行函数 把请求发送到服务器上的文件 请注意我们向 URL 添加了一个参数
 * q （带有输入框的内容）
 */

function showHint(str)
{
var xmlhttp;
if (str.length==0)
{
  document.getElementById("txtHint").innerHTML="";
  return;
  }
if (window.XMLHttpRequest)
  {// code for IE7+, Firefox, Chrome, Opera, Safari
  xmlhttp=new XMLHttpRequest();
  }
else
  {// code for IE6, IE5
  xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
  }
xmlhttp.onreadystatechange=function()
  {
  if (xmlhttp.readyState==4 && xmlhttp.status==200)
    {
    document.getElementById("txtHint").innerHTML=xmlhttp.responseText;
    }
  }
xmlhttp.open("GET","gethint.asp?q="+str,true);
xmlhttp.send();
}

/* asp */
// <%
// response.expires=-1
// dim a(30)
// '用名字来填充数组
// a(1)="Anna"
// a(2)="Brittany"
// a(3)="Cinderella"
// a(4)="Diana"
// a(5)="Eva"
// a(6)="Fiona"
// a(7)="Gunda"
// a(8)="Hege"
// a(9)="Inga"
// a(10)="Johanna"
// a(11)="Kitty"
// a(12)="Linda"
// a(13)="Nina"
// a(14)="Ophelia"
// a(15)="Petunia"
// a(16)="Amanda"
// a(17)="Raquel"
// a(18)="Cindy"
// a(19)="Doris"
// a(20)="Eve"
// a(21)="Evita"
// a(22)="Sunniva"
// a(23)="Tove"
// a(24)="Unni"
// a(25)="Violet"
// a(26)="Liza"
// a(27)="Elizabeth"
// a(28)="Ellen"
// a(29)="Wenche"
// a(30)="Vicky"
//
// '获得来自 URL 的 q 参数
// q=ucase(request.querystring("q"))
//
// '如果 q 大于 0，则查找数组中的所有提示
// if len(q)>0 then
// hint=""
// for i=1 to 30
// if q=ucase(mid(a(i),1,len(q))) then
// if hint="" then
// hint=a(i)
// else
// hint=hint & " , " & a(i)
// end if
// end if
// next
// end if
//
// '如果未找到提示，则输出 "no suggestion"
// '否则输出正确的值
// if hint="" then
// response.write("no suggestion")
// else
// response.write(hint)
// end if
// %>

/* php */
// <?php
// // 用名字来填充数组
// $a[]="Anna";
// $a[]="Brittany";
// $a[]="Cinderella";
// $a[]="Diana";
// $a[]="Eva";
// $a[]="Fiona";
// $a[]="Gunda";
// $a[]="Hege";
// $a[]="Inga";
// $a[]="Johanna";
// $a[]="Kitty";
// $a[]="Linda";
// $a[]="Nina";
// $a[]="Ophelia";
// $a[]="Petunia";
// $a[]="Amanda";
// $a[]="Raquel";
// $a[]="Cindy";
// $a[]="Doris";
// $a[]="Eve";
// $a[]="Evita";
// $a[]="Sunniva";
// $a[]="Tove";
// $a[]="Unni";
// $a[]="Violet";
// $a[]="Liza";
// $a[]="Elizabeth";
// $a[]="Ellen";
// $a[]="Wenche";
// $a[]="Vicky";
//
// //获得来自 URL 的 q 参数
// $q=$_GET["q"];
//
// //如果 q 大于 0，则查找数组中的所有提示
// if (strlen($q) > 0)
// {
// $hint="";
// for($i=0; $i<count($a); $i++)
// {
// if (strtolower($q)==strtolower(substr($a[$i],0,strlen($q))))
// {
// if ($hint=="")
// {
// $hint=$a[$i];
// }
// else
// {
// $hint=$hint." , ".$a[$i];
// }
// }
// }
// }
//
// // 如果未找到提示，则把输出设置为 "no suggestion"
// // 否则设置为正确的值
// if ($hint == "")
// {
// $response="no suggestion";
// }
// else
// {
// $response=$hint;
// }
//
// //输出响应
// echo $response;
// ?>



/* AJAX 数据库实例 */

function showCustomer(str)
{
var xmlhttp;
if (str=="")
  {
  document.getElementById("txtHint").innerHTML="";
  return;
  }
if (window.XMLHttpRequest)
  {// code for IE7+, Firefox, Chrome, Opera, Safari
  xmlhttp=new XMLHttpRequest();
  }
else
  {// code for IE6, IE5
  xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
  }
xmlhttp.onreadystatechange=function()
  {
  if (xmlhttp.readyState==4 && xmlhttp.status==200)
    {
    document.getElementById("txtHint").innerHTML=xmlhttp.responseText;
    }
  }
xmlhttp.open("GET","getcustomer.asp?q="+str,true);
xmlhttp.send();
}





// <%
// response.expires=-1
// sql="SELECT * FROM CUSTOMERS WHERE CUSTOMERID="
// sql=sql & "'" & request.querystring("q") & "'"
//
// set conn=Server.CreateObject("ADODB.Connection")
// conn.Provider="Microsoft.Jet.OLEDB.4.0"
// conn.Open(Server.Mappath("/db/northwind.mdb"))
// set rs=Server.CreateObject("ADODB.recordset")
// rs.Open sql,conn
//
// response.write("<table>")
// do until rs.EOF
// for each x in rs.Fields
// response.write("<tr><td><b>" & x.name & "</b></td>")
// response.write("<td>" & x.value & "</td></tr>")
// next
// rs.MoveNext
// loop
// response.write("</table>")
// %>
//

/* loadXMLDoc() 函数 */
function loadXMLDoc(url)
{
var xmlhttp;
var txt,xx,x,i;
if (window.XMLHttpRequest)
  {// code for IE7+, Firefox, Chrome, Opera, Safari
  xmlhttp=new XMLHttpRequest();
  }
else
  {// code for IE6, IE5
  xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
  }
xmlhttp.onreadystatechange=function()
  {
  if (xmlhttp.readyState==4 && xmlhttp.status==200)
    {
    txt="<table border='1'><tr><th>Title</th><th>Artist</th></tr>";
    x=xmlhttp.responseXML.documentElement.getElementsByTagName("CD");
    for (i=0;i<x.length;i++)
      {
      txt=txt + "<tr>";
      xx=x[i].getElementsByTagName("TITLE");
        {
        try
          {
          txt=txt + "<td>" + xx[0].firstChild.nodeValue + "</td>";
          }
        catch (er)
          {
          txt=txt + "<td> </td>";
          }
        }
    xx=x[i].getElementsByTagName("ARTIST");
      {
        try
          {
          txt=txt + "<td>" + xx[0].firstChild.nodeValue + "</td>";
          }
        catch (er)
          {
          txt=txt + "<td> </td>";
          }
        }
      txt=txt + "</tr>";
      }
    txt=txt + "</table>";
    document.getElementById('txtCDInfo').innerHTML=txt;
    }
  }
xmlhttp.open("GET",url,true);
xmlhttp.send();
}










/*
 * 首先我们创建ajax的核心对象, 由于浏览器的兼容问题我们在创建ajax核心对象的时候不得考虑其兼容问题,
 * 因为要想实现异步交互的后面步骤都基于第一步是否成功的创建了ajax核心对象.
 */

function getXhr() { // 声明XMLHttpRequest对象
	var xhr = null;
	// 根据浏览器的不同情况进行创建
	if (window.XMLHttpRequest) {
		// 表示除IE外的其他浏览器
		xhr = new XMLHttpRequest();
	} else { // 表示IE浏览器
		xhr = new ActiveXObject('Microsoft.XMLHttp');
	}
	return
	

	xhr;
} // 创建核心对象 v
ar
xhr = getXhr();
