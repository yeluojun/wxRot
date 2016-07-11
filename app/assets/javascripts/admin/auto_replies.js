$(function(){
  if (!document.getElementById('auto-reply-new') && !document.getElementById('auto-reply-edit')){
    return false;
  }

  $('#auto-reply-form').on('submit', function(){
    var formData = $(this).serialize();
    $.ajax({
      type: 'post',
      url: '/api/v1/auto_replies?wxuin='+ye.getURLParameter('wxuin'),
      data: formData,
      success: function(data){

      },
      error: function(data){

      }
    })


  })
});