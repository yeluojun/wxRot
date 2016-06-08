
window.onload =function(){
  console.log('load success');
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

          } })
      };

      $.ajax({
          url: '/ap1/v1/uuid',
          data: '',
          data_type: 'json',
          success: function(data){
              if (data.code === 200){
                  get_qr(data.data)
              }


          },
          error: function(){
              alert('login failed')
          }
      })
  }()
};

//$('.login').on('click', function(){
//    console.log('login')
//})