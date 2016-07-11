$(function(){
  if(!document.getElementById('wx-robot-manager-config')){
    return false;
  }

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