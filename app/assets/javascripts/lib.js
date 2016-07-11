(function(){
  ye = {};
  ye.alert  = function (msg) {
    alert(msg)
  };

  // 获取url参数
  ye.getURLParameter = function(name) {
    return decodeURIComponent((new RegExp('[?|&]' + name + '=' + '([^&;]+?)(&|#|;|$)').exec(location.search) || [null, ''])[1].replace(/\+/g, '%20')) || null;
  }

})();