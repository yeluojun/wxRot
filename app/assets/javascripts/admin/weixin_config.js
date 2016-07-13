$(function(){
  if(!document.getElementById('wx-robot-manager-config')){
    return false;
  }

  $('.reply').on('click','.delete', function(){
    var url = this.parentNode.parentNode.parentNode.parentNode.getAttribute('data-api') + this.getAttribute('data-id');
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
      url: url,
      type: 'DELETE',
      data: {},
      success: success.bind(this),
      error: error.bind(this)
    })
  });
});