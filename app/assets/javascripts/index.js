
window.onload =function(){
  $("#user-login").on('click', function () {

    if($('.login_div').find("input[name='name']").val()  == null || $('.login_div').find("input[name='name']").val()  == '' ){
      ye.alert('请输入用户名');
      return
    }
    if($('.login_div').find("input[name='name']").val()  == null || $('.login_div').find("input[name='password']").val()  == '' ){
      ye.alert('请输入密码');
      return
    }
    $(this).addClass('disabled');
    var success = function (data) {
      if (data.code === 200){

      }else{
        ye.alert(data.msg)
      }
      $(this).removeClass('disabled');
    };
    var error = function (err) {
      $(this).removeClass('disabled');
      ye.alert('网络或服务器异常，请稍后重试');
    };

    $.ajax({
      type: 'POST',
      url: '/sessions',
      data: {name: $('.login_div').find("input[name='name']").val(), password: $('.login_div').find("input[name='password']").val()},
      data_type: 'json',
      success: success.bind(this),
      error: error.bind(this)
    })
  })
};
// window.onload =function(){
//   console.log('load success');
//   wxData = {}; // 微信
//   $('.login').on('click', function(){
//       $.ajax({
//             url: '/login',
//             data: '',
//             data_type: 'json',
//             success: function(data){
//
//             },
//             error: function(){
//               alert('login failed')
//           }
//         }
//     );
//   });
//
//   var qr = function(){
//       var get_qr = function(data){
//           $.ajax({url: '/api/v1/qr', data: {uuid: data}, data_type: 'json', success:
//               function(){
//
//               },error: function(){
//                alert('获取二维码失败')
//           } })
//       };
//       var get_tickets = function (wxData) {
//           $.ajax({url: '/api/v1/tickets', data: {uuid: wxData.uuid, ticket: wxData.ticket, scan: wxData.scan}, data_type: 'json', success:
//               function(data){
//                   wxData.skey = data.data.skey;
//                   wxData.wxsid = data.data.wxsid;
//                   wxData.wxuin = data.data.wxuin;
//                   wxData.pass_ticket = data.data.pass_ticket;
//                   wxData.isgrayscale = data.data.isgrayscale;
//                   wxInit(wxData);
//               },error: function(){
//                  alert('获取票据失败');
//           } })
//       };
//
//       wxInit = function (wxData) {
//           var params = { BaseRequest: { Uin: wxData.wxuin, Sid: wxData.wxsid, Skey: wxData.skey, DeviceID: 'e846610781548096' } };
//           var url = "https://wx.qq.com/cgi-bin/mmwebwx-bin/webwxinit?r=-"+Date.now()+"&lang="+wxData.lang+"&pass_ticket="+wxData.pass_ticket+"";
//           $.ajax({
//               type: 'POST',
//               url: url,
//               contentType: "application/json;charset=utf-8",
//               data: JSON.stringify(params),
//               success: function(data){
//               },
//
//               error: function(){
//                   alert('Wxinit failed')
//               }
//           })
//       };
//
//       var login = function(data){
//           $.ajax({url: '/api/v1/login', data: {uuid: data}, data_type: 'json', success:
//               function(ret){
//                 if(ret.code !== 200){
//                     setTimeout(login(data), 1000);
//                 }else{
//                     wxData.ticket = ret.data.ticket;
//                     wxData.scan = ret.data.scan;
//                     wxData.lang = ret.data.lang;
//                     get_tickets(wxData)
//                 }
//               },error: function(){
//
//           } })
//       };
//
//       $.ajax({
//           url: '/api/v1/uuid',
//           data: '',
//           data_type: 'json',
//           success: function(data){
//               if (data.code === 200){
//                   wxData.uuid = data.data;
//                   get_qr(data.data);
//                   login(data.data)
//               }
//           },
//           error: function(){
//               alert('get uuid failed')
//           }
//       })
//   }()
// };

//$('.login').on('click', function(){
//    console.log('login')
//})