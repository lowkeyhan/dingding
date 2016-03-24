<%@ page contentType="text/html;charset=UTF-8"%>
     <%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib prefix="form"  uri="http://www.springframework.org/tags/form" %> 

<c:set var="ctx" value="${pageContext.request.contextPath}"/>
 
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>

    <meta name="viewport" content="width=device-width, initial-scale=1,maximum-scale=1,user-scalable=no">
 <link href='${ctx}/static/dingding/fullcalendar.css' rel='stylesheet' />
<link href='${ctx}/static/dingding/fullcalendar.print.css' rel='stylesheet' media='print' />
<script src='${ctx}/static/dingding/jquery.min.js'></script>


<!-- bootstrap -->
<link href="${ctx}/static/bootstrap/css/bootstrap.min.css" rel="stylesheet" type="text/css" />
<!-- validate，用于表单验证 -->
<link href="${ctx}/static/jquery-validation/1.9.0/validate.css" rel="stylesheet" type="text/css" /> 
<script type='text/javascript' src='${ctx}/static/jquery-validation/1.9.0/jquery.validate.min.js'></script>
<script type='text/javascript' src='${ctx}/static/ibutton/jquery.metadata.js'></script>
<script type='text/javascript' src='${ctx}/static/jquery-validation/1.9.0/messages_bs_cn.js'></script>
<!-- form，表单提交-->
<script src="${ctx}/static/jquery-form/jquery.form.js" type="text/javascript"></script>
<script type='text/javascript' src='${ctx}/static/bootstrap/js/bootstrap.min.js'></script>
  <!-- 公用方法 -->
<script src="${ctx}/static/dingding/public.js" type="text/javascript"></script>
<!-- 钉钉js -->
 <script src='${ctx}/static/dingding/dingtalk.js'></script> 
<title>日程</title>
<style type="text/css">
body{
		margin: 10px auto 0px auto !important;
		padding: 0 !important;
		font-family: "Lucida Grande",Helvetica,Arial,Verdana,sans-serif;
		

    background-color: #ebebeb;
}
input{
 border: 0px;
 font-size: 12px;
border: 0px solid #ccc !important;
    line-height: 30px !important;
    height: 42px !important;
    width: 100% !important;
}
.span2{
line-height: 50px !important;
    font-size: 12px !important;
padding-left:5px !important;

}
.span10{
 
}
.row-fluid{
background-color: white;
border: 1px solid #ccc !important;
margin-bottom: 5px;
}
</style>

<script type="text/javascript">
//设置弹出框居中
function setBoxCenter(_boxId,_boxWidth,_boxHeight,_currWindow)
{
	if(!_currWindow){
		_currWindow = window;
	}
  var obox=_currWindow.document.getElementById(_boxId);
  if (obox !=null && obox.style.display !="none")
  {
  	if(!_boxWidth){
			_boxWidth = $('#'+_boxId).width();
		}
		if(!_boxHeight){
			_boxHeight = $('#'+_boxId).height();
		}
		
      var oLeft,oTop;
      if (_currWindow.innerWidth)
      {
          oLeft=_currWindow.pageXOffset+(_currWindow.innerWidth-_boxWidth)/2 +"px";
          oTop=_currWindow.pageYOffset+(_currWindow.innerHeight-_boxHeight)/2 +"px";
      }
      else
      {
          var dde=_currWindow.document.documentElement;
          oLeft=dde.scrollLeft+(dde.offsetWidth-_boxWidth)/2 +"px";
          oTop=dde.scrollTop+(dde.offsetHeight-_boxHeight)/2 +"px";
      }
      
      obox.style.left=oLeft;
      obox.style.top=oTop;
      //问题1、居左、居上存在问题，有可能相对定位的父容器是负值，不在当前屏幕区域；
      //问题2、其本身定位在那个位置，比如margin为负值等样式属性会有影响
      $(obox).css('margin','0 0 0 0');
  }
}
function allsubmit(){
	$("#eventForm_${uuid}").ajaxSubmit({
		type : 'post',
		dataType : 'json',
		data : {
		},
		beforeSubmit : function(formData, jqForm, options) {
			$('#submit_${uuid}').prop("disabled", true);
		},
		success : function(responseText, statusText, xhr, $form) {
			if (responseText.success) {
				//if(state=="1"){
					//infoDialog(responseText.message, true);
					alert(responseText.message);
				window.location.href="${ctx}/calender/tab";
				//}else{
					//infoDialog(responseText.message, true, "callback()");
				//}
			} else {
				//infoDialog(responseText.message, false);
				alert(responseText.message);
				//$('#save_${uuid}').prop("disabled", false);
				$('#submit_${uuid}').prop("disabled", false);
				//$('#btnResult_${uuid}').prop("disabled", false);
			}
		},
		error : function(xhr, textStatus, errorThrown) {
			//infoDialog("系统错误", false);
			alert("系统错误");
			$('#save_${uuid}').prop("disabled", false);
			$('#submit_${uuid}').prop("disabled", false);
			$('#btnResult_${uuid}').prop("disabled", false);
		}
	});
}

var _config = <%=com.techstar.sys.dingAPI.auth.AuthHelper.getConfig(request,"3")%>;
dd.config({
	agentId : _config.agentid,
	corpId : _config.corpId,
	timeStamp : _config.timeStamp,
	nonceStr : _config.nonceStr,
	signature : _config.signature,
	jsApiList : [ 'runtime.info', 'biz.contact.choose',
			'device.notification.confirm', 'device.notification.alert',
			'device.notification.prompt', 'biz.ding.post',
			'biz.util.openLink','biz.navigation.setRight','biz.navigation.setLeft' ]
});

dd.ready(function(){
	dd.biz.navigation.setTitle({
        title: '钉钉日程',
        onSuccess: function(data) {
        },
        onFail: function(err) {
            log.e(JSON.stringify(err));
        }
    });
	dd.biz.navigation.setRight({
	    show: true,//控制按钮显示， true 显示， false 隐藏， 默认true
	    control: true,//是否控制点击事件，true 控制，false 不控制， 默认false
	    text: '添加',//控制显示文本，空字符串表示显示默认文本
	    onSuccess : function(result) {
	        //如果control为true，则onSuccess将在发生按钮点击事件被回调
	        /*
	        {}
	        */
	    	window.location.href="${ctx}/calender/event";
	    },
	    onFail : function(err) {}
	});
	dd.biz.navigation.setLeft({
	    show: true,//控制按钮显示， true 显示， false 隐藏， 默认true
	    control: true,//是否控制点击事件，true 控制，false 不控制， 默认false
	    showIcon: true,//是否显示icon，true 显示， false 不显示，默认true； 注：具体UI以客户端为准
	    text: '主页',//控制显示文本，空字符串表示显示默认文本
	    onSuccess : function(result) {
	        /*
	{}
	*/
	        //如果control为true，则onSuccess将在发生按钮点击事件被回调
	    	window.location.href="${ctx}/calender/tab";
	    },
	    onFail : function(err) {}
	});
	
	 $('#starttime').on('click', function () {
		 var date;
		 if( $('#starttime').val()){
			 date=strToDate($('#starttime').val());
		 }else{
			date = new Date();
		 }
		 var time=date.format("yyyy-MM-dd hh:mm:11");
		 dd.biz.util.datetimepicker({
			    format: 'yyyy-MM-dd HH:mm:ss',
			    value: time, //默认显示
			    onSuccess : function(result) {
			        //onSuccess将在点击完成之后回调
			        /*{
			            value: "2015-06-10 09:50"
			        }
			        */
			        $('#starttime').val(result.value);
			    },
			    onFail : function() {}
			});
		});
	 $('#endtime').on('click', function () {
		var date;
		 if( $('#endtime').val()){
			 date=strToDate($('#endtime').val());
		 }else{
			date = new Date();
		 }
		 var time=date.format("yyyy-MM-dd hh:mm:11");
		 dd.biz.util.datetimepicker({
			    format: 'yyyy-MM-dd HH:mm:ss',
			    value: time, //默认显示
			    onSuccess : function(result) {
			        //onSuccess将在点击完成之后回调
			        /*{
			            value: "2015-06-10 09:50"
			        }
			        */
			        $('#endtime').val(result.value);
			    },
			    onFail : function() {}
			});
		});
	 $('#remindertimes').on('click', function () {
		 dd.biz.ding.post({
			    users : ['${userid}'],//用户列表，工号
			    corpId: 'dingdf1938a231e0f276', //企业id
			    type: 0, //钉类型 1：image  2：link
			    alertType: 2,
			    alertDate: {"format":"yyyy-MM-dd HH:mm","value":"2015-05-09 08:00"},
			    attachment: {
			        images: [''],
			    }, //附件信息
			    text: '', //消息
			    onSuccess : function() {
			    //onSuccess将在点击发送之后调用
			    },
			    onFail : function() {   }
			});
		});
	 $('#participantname').on('click', function () {
		 var useridlist='';
		 if($('#participantid').val()){
			 useridlist=$('#participantid').val();
			 useridlist=useridlist.substring(0,useridlist.length-1);
		 }
		 useridlist="\""+useridlist.replace(",","\",\"")+"\""; 
		 dd.biz.contact.choose({
			  startWithDepartmentId: 0, //-1表示打开的通讯录从自己所在部门开始展示, 0表示从企业最上层开始，(其他数字表示从该部门开始:暂时不支持)
			  multiple: true, //是否多选： true多选 false单选； 默认true
			  users: [useridlist], //默认选中的用户列表，userid；成功回调中应包含该信息
			  corpId: 'dingdf1938a231e0f276', //企业id
			  max: 500, //人数限制，当multiple为true才生效，可选范围1-1500
			  onSuccess: function(data) {
			  //onSuccess将在选人结束，点击确定按钮的时候被回调
			  /* data结构
			    [{
			      "name": "张三", //姓名
			      "avatar": "http://g.alicdn.com/avatar/zhangsan.png" //头像图片url，可能为空
			      "emplId": '0573', //userid
			     },
			     ...
			    ]
			  */
			  var names='';
			  var nameids='';
				  for(var i=0; i<data.length; i++)  
				  {  
					  names=names+ data[i].name+",";
					  nameids=nameids+data[i].emplId+",";
				  }  
				  $('#participantname').val(names);
				  $('#participantid').val(nameids);
			  },
			  onFail : function(err) {}
			});;
		});
	 
});

dd.error(function(err) {
	alert('dd error: ' + JSON.stringify(err));
});
function formatToDate(cellvalue){
	if(cellvalue!=null){
		var date = new Date(cellvalue);// 或者直接new Date();
	    return date.format("yyyy-MM-dd hh:mm:ss");
	}
	else
		return "";
}
function strToDate(str) {
 var tempStrs = str.split(" ");
 var dateStrs = tempStrs[0].split("-");
 var year = parseInt(dateStrs[0], 10);
 var month = parseInt(dateStrs[1], 10) - 1;
 var day = parseInt(dateStrs[2], 10);
 var timeStrs = tempStrs[1].split(":");
 var hour = parseInt(timeStrs [0], 10);
 var minute = parseInt(timeStrs[1], 10) - 1;
 var second = 11;
 var date = new Date(year, month, day, hour, minute, second);
 return date;
}
</script>
</head>
<body>
  <form id="eventForm_${uuid}"     
		action="${ctx}/calender/edit"
		method="POST" class="FormGrid form-horizontal">
	<input type="hidden" id="id" name="id" value="${events.id}" />
	<input type="hidden" id="oper" name="oper" value="${oper}" />
	
	<div class="row-fluid " >
		<div class="span2" >标题</div>
		<div class="span10">
		<input id="title" name="title" type="text" class="{maxlength:127,} input nowrite" value="${events.title}">
		</div>
	</div>
	<div class="row-fluid " >
		<div class="span2" >开始时间</div>
		<div class="span10">
		<input id="starttime" readonly="readonly" name="starttime" type="text" class="input" value='<fmt:formatDate value="${events.starttime}" pattern="yyyy-MM-dd hh:mm"/>'>
		</div>
	</div>
	<div class="row-fluid " >
		<div class="span2" >结束时间</div>
		<div class="span10">
		<input id="endtime" name="endtime" readonly="readonly" type="text" class=" input" value="${events.endtime}">
		</div>
	</div>
	<div class="row-fluid " >
		<div class="span2" >ding提醒</div>
		<div class="span10" style="height: 50px;" >
		 <input type="button" id="remindertimes" style=" height: 50px  !important;margin: auto;"  class="btn" value="添加ding提醒" />		
		<input id="remindertime" name="remindertime" type="hidden" class=" input" value="2015-01-01 12:12:12">
		</div>
	</div>
	<div class="row-fluid " >
		<div class="span2" >参与人</div>
		<div class="span10">
		<input id="participantname" name="participantname" type="text" class=" input nowrite" value="${events.participantname}">
		<input id="participantid" name="participantid" type="hidden" class=" input nowrite" value="${events.participantid}">
		</div>
	</div>
	<div class="row-fluid " >
		<div class="span2" >备注</div>
		<div class="span10">
		<input id="remark" name="remark" type="text" class="input" value="${events.remark}">
		</div>
	</div>
  </form>
  <div style="margin: 0 auto;width: 90%;">
  <input type="button" id="submit_${uuid}" onclick="allsubmit();" style="width: 100%;margin: 0 auto;" class="btn btn-success" value="&nbsp;&nbsp;提&nbsp;&nbsp;交&nbsp;&nbsp;" />							
</div>
</body>
</html>