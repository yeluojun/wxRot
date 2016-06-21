
window.onload =function(){
  console.log('load success');
  wxData = {}; // 微信

  wxInit = function (wxData) {
      url= "https://wx.qq.com/cgi-bin/mmwebwx-bin/webwxnewloginpage?ticket="+wxData.ticket+"&uuid="+wxData.uuid+"&lang="+wxData.lang+"&scan="+wxData.scan+"&fun=new&version=v2";
      $.ajax({
          url: url,
          data: '',
          data_type: 'json',
          success: function(data){

          },
          error: function(){
              alert('login failed')
          }
      })
  };
  $('.login').on('click', function(){
      $.ajax({
            url: '/login',
            data: '',
            data_type: 'json',
            success: function(data){

            },
            error: function(){
              alert('login failed')
          }
        }
    )
  });

  var qr = function(){
      var get_qr = function(data){
          $.ajax({url: '/api/v1/qr', data: {uuid: data}, data_type: 'json', success:
              function(){

              },error: function(){
               alert('获取二维码失败')
          } })
      };

      var login = function(data){
          $.ajax({url: '/api/v1/login', data: {uuid: data}, data_type: 'json', success:
              function(ret){
                if(ret.code !== 200){
                    setTimeout(login(data), 1000);
                }else{
                    wxData.ticket = ret.data.ticket;
                    wxData.scan = ret.data.scan;
                    wxData.lang = ret.data.lang;
                }
              },error: function(){

          } })
      };

      $.ajax({
          url: '/api/v1/uuid',
          data: '',
          data_type: 'json',
          success: function(data){
              if (data.code === 200){
                  wxData.uuid = data.data;
                  get_qr(data.data);
                  login(data.data)
              }
          },
          error: function(){
              alert('get uuid failed')
          }
      })
  }()
};

//$('.login').on('click', function(){
//    console.log('login')
//})