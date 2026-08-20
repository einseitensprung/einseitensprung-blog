(function(){
  var pagination = document.querySelector('.pagination');
  if(!pagination) return;
  var prev = pagination.querySelector('.page-prev');
  var next = pagination.querySelector('.page-next');
  var nums = Array.prototype.slice.call(pagination.querySelectorAll('.page-num'));

  function setActive(target){
    nums.forEach(function(btn){
      var active = btn === target;
      btn.classList.toggle('is-active', active);
      if(active){ btn.setAttribute('aria-current', 'page'); }
      else{ btn.removeAttribute('aria-current'); }
    });
    var idx = nums.indexOf(target);
    prev.disabled = idx === 0;
    next.disabled = idx === nums.length - 1;
  }

  nums.forEach(function(btn){
    btn.addEventListener('click', function(){ setActive(btn); });
  });
  prev.addEventListener('click', function(){
    var idx = nums.findIndex(function(b){ return b.classList.contains('is-active'); });
    if(idx > 0){ setActive(nums[idx - 1]); }
  });
  next.addEventListener('click', function(){
    var idx = nums.findIndex(function(b){ return b.classList.contains('is-active'); });
    if(idx < nums.length - 1){ setActive(nums[idx + 1]); }
  });
})();
