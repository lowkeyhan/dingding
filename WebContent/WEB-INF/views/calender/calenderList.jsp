<%@ page language="java" contentType="text/html; charset=utf-8"
    pageEncoding="utf-8"%>
 <%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib prefix="form"  uri="http://www.springframework.org/tags/form" %> 

<c:set var="ctx" value="${pageContext.request.contextPath}"/>
 
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta charset='utf-8' />
    <meta name="viewport" content="width=device-width, initial-scale=1,maximum-scale=1,user-scalable=no">
 <link href='${ctx}/static/dingding/fullcalendar.css' rel='stylesheet' />
<link href='${ctx}/static/dingding/fullcalendar.print.css' rel='stylesheet' media='print' />
<script src='${ctx}/static/dingding/moment.min.js'></script>
<script src='${ctx}/static/dingding/jquery.min.js'></script>
<script src='${ctx}/static/dingding/fullcalendar.js'></script>

    <script src='${ctx}/static/dingding/lang-all.js'></script>
    <!-- 公用方法 -->
<script src="${ctx}/static/dingding/public.js" type="text/javascript"></script>
<!-- 钉钉js -->
 <script src='${ctx}/static/dingding/dingtalk.js'></script>
 <style>
 .fc-left{
 width: 50%;
 }
 .fc-right{
 width: 50%;
 }
 .fc-right .fc-button-group{
     float: right !important;
 }
 </style>
<script>
var _config = <%=com.techstar.sys.dingAPI.auth.AuthHelper.getConfig(request,"1")%>;
dd.config({
	agentId : _config.agentid,
	corpId : _config.corpId,
	timeStamp : _config.timeStamp,
	nonceStr : _config.nonceStr,
	signature : _config.signature,
	jsApiList : [ 'runtime.info', 'biz.contact.choose',
			'device.notification.confirm', 'device.notification.alert',
			'device.notification.prompt', 'biz.ding.post',
			'biz.util.openLink','biz.navigation.setRight','biz.navigation.setLeft',
			'device.notification.showPreloader','device.notification.hidePreloader','biz.navigation.close' ]
});

dd.ready(function(){
	dd.device.notification.showPreloader({
	    text: "加载中..", //loading显示的字符，空表示不显示文字
	    showIcon: true, //是否显示icon，默认true
	    onSuccess : function(result) {
	        /*{}*/
	    },
	    onFail : function(err) {}
	});
	dd.biz.navigation.setTitle({
        title: '日程管理',
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
	    text: '钉钉',//控制显示文本，空字符串表示显示默认文本
	    onSuccess : function(result) {
	        /*
	{}
	*/
	        //如果control为true，则onSuccess将在发生按钮点击事件被回调
	    	dd.biz.navigation.close({
			    onSuccess : function(result) {
			        /*result结构
			{}
			*/
			    },
			    onFail : function(err) {}
			});
	    },
	    onFail : function(err) {}
	});
	
	dd.runtime.permission.requestAuthCode({
	    corpId: _config.corpId,
	    onSuccess: function(result) {
	    	//$('#keyword').val(result.code);
	    	//alert('authcode: ' + result.code);
	    	$('#calendar').fullCalendar({
				header: {left: 'prev,next today',center: 'title',right: 'month,agendaWeek,agendaDay'},
				lang: 'zh-cn',
				contentHeight: $(window).height()-100,
			    handleWindowResiz:true,
				selectable: true,
				selectHelper: false,
				windowResize: function(view) {
				    $('#calendar').fullCalendar({
				    	contentHeight: $(window).height()-100
				    });
				},
				select: function(start, end) {
					window.location.href="${ctx}/calender/daylist?time="+start.unix();
				},
				eventClick:function(calEvent, jsEvent, view){
				    window.location.href="${ctx}/calender/daylist?time="+calEvent.start.unix();
				},
				editable: false,
				eventLimit: true, // allow "more" link when too many events
				events:function(start, end, timezone, callback) {
					getlist(start, end, timezone, callback,result.code);
					dd.device.notification.hidePreloader({
					    onSuccess : function(result) {
					        /*{}*/
					    },
					    onFail : function(err) {}
					});
				}
			});
	  
	    },
	    onFail : function(err) {}

	});
});


dd.error(function(err) {
	alert('dd error: ' + JSON.stringify(err));
});
	
	
	function getlist(start, end, timezone, callback,code) {
	 	$.ajax({
			url:'${ctx}/calender/list',
			data:{
				viewStart:start.unix(),
				viewEnd:end.unix(),
				code:code
				},
			type:'POST',
			dataType:'json',
			success:function(responseText){
				var events = [];
				$.each(responseText.userdata,function(i,n){	
					events.push({
                        title:  $(this).attr('title'),
                        id: $(this).attr('id'),
                        start: formatToDate($(this).attr('starttime')),
                        end:formatToDate($(this).attr('endtime'))
                    });
				});
				
                callback(events);
			},
			error:function(XMLHttpRequest, textStatus, errorThrown){
				alert(XMLHttpRequest.status+XMLHttpRequest.readyState+textStatus);
			}
		});
	 	
    };
	
	
	
	function formatToDate(cellvalue){
		if(cellvalue!=null){
			var date = new Date(cellvalue);// 或者直接new Date();
		    return date.format("yyyy-MM-dd hh:mm:ss");
		}
		else
			return "";
	};
function strToDate(str) {
 var tempStrs = str.split(" ");
 var dateStrs = tempStrs[0].split("-");
 var year = parseInt(dateStrs[0], 10);
 var month = parseInt(dateStrs[1], 10) - 1;
 var day = parseInt(dateStrs[2], 10);
 var timeStrs = tempStrs[1].split(":");
 var hour = parseInt(timeStrs [0], 10);
 var minute = parseInt(timeStrs[1], 10) - 1;
 var second = 0;
 var date = new Date(year, month, day, hour, minute, second);
 return date;
}
</script>
<style>

	body {
		margin: 10px auto 0px auto;
		padding: 0;
		font-family: "Lucida Grande",Helvetica,Arial,Verdana,sans-serif;
		font-size: 14px;
	}

	#calendar {
		
		margin: 0 auto;
	}

</style>
</head>
<body>

	<div id='calendar'></div>

</body>
</html>