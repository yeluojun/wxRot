$(function(){
  if(!document.getElementById('wx-robot-manager-config')){
    return false;
  }

  $('#auto-replies').on('click','.delete', function(){
    var success = function(data){
      if (data.code === 200){
        this.parentNode.parentNode.parentNode.removeChild(this.parentNode.parentNode)
      }else{
        ye.alert(data.msg)
      }
    };
    var error = function(){
      ye.alert('网络异常或服务器错误,请稍后重试');
    };
    $.ajax({
      url: '/api/v1/auto_replies/' + this.getAttribute('data-id'),
      type: 'DELETE',
      data: {},
      success: success.bind(this),
      error: error.bind(this)
    })
  });
});