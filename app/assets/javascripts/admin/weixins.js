$(function(){

  wxData = {};

  if (!document.getElementById('wx-robot-manager')) {
    return;
  }

  // 微信登陆
  var login = function(data){
    $.ajax({url: '/api/v1/weixins/login', data: {uuid: data}, data_type: 'json', success:
      function(ret){
        if(ret.code !== 200){
          setTimeout(login(data), 1000);
        }else{
          wxData.ticket = ret.data.ticket;
          wxData.scan = ret.data.scan;
          wxData.lang = ret.data.lang;
          get_tickets(wxData)
        }
      },error: function(){

    }})
  };
  
  // 获取各种ticket
  var get_tickets = function (wxData) {
    $.ajax({url: '/api/v1/weixins/tickets', data: {uuid: wxData.uuid, ticket: wxData.ticket, scan: wxData.scan}, data_type: 'json', success:
      function(data){
        wxData.skey = data.data.skey;
        wxData.wxsid = data.data.wxsid;
        wxData.wxuin = data.data.wxuin;
        wxData.pass_ticket = data.data.pass_ticket;
        wxData.isgrayscale = data.data.isgrayscale;
        wxInit(wxData);
      },error: function(){
      alert('获取票据失败');
    } })
  };

  // 添加微信机器人
  $('#add-wxbot').on('click', function () {
    $('#qr').html('');
    $('#qr-msg').html('');
    var success = function (data) {
      wxData.uuid = data.data;
      $('#qr').html("<img style='width: 150px; height: 150px' src='/qrs/"+ data.data+ ".png'>")
    };
    var error = function (data) {
      $('#qr-msg').html("<p class='alert-danger' style='text-align: center'>获取二维码失败</p>")
    };
    $.ajax({
      type: 'GET',
      url: '/api/v1/weixins/qr',
      data: {},
      success: success.bind(this),
      error: error.bind(this)
    })
  })

});