$(function(){
  if (!document.getElementById('auto-reply-global-new') && !document.getElementById('auto-reply-global-edit')){
    return false;
  }

  // 自动回复表单
  $('#auto-reply-global-form').on('submit', function(){
    var formData = $(this).serialize();
    $.ajax({
      type: 'post',
      url: '/api/v1/auto_reply_globals?wxuin='+ye.getURLParameter('wxuin'),
      data: formData,
      success: function(data){
        if(data.code == 200){
          ye.alert('操作成功');
          setTimeout(function(){ window.location.href = '/admin/weixins/edit?wxuin='+ye.getURLParameter('wxuin') }, 500)
        }else{
          ye.alert(data.msg);
        }
      },
      error: function(data){
        ye.alert('网络异常或服务器错误~')
      }
    });
    return false;
  });

});