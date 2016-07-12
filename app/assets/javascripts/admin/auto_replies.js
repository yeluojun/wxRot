$(function(){
  if (!document.getElementById('auto-reply-new') && !document.getElementById('auto-reply-edit')){
    return false;
  }

  // 自动回复表单
  $('#auto-reply-form').on('submit', function(){
    var formData = $(this).serialize();
    $.ajax({
      type: 'post',
      url: '/api/v1/auto_replies?wxuin='+ye.getURLParameter('wxuin'),
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

  $('#friend-autocomplete').autocomplete(
    {
      serviceUrl: '/api/v1/friends/friends?wxuin='+ye.getURLParameter('wxuin'),
      dataType: 'json',
      maxHeight: 400,
      minChars: 0,
      transformResult: function(response){
        return {
          suggestions: $.map(response.data, function(dataItem){
            if (response.code === 200) {
              return dataItem.id + ' ' + dataItem.NickName;
            } else {
              return '';
            }
          })
        };
      }
    }
  )

});