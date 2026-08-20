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

(function(){
  var fab = document.getElementById('fab');
  if(!fab) return;
  var toggle = fab.querySelector('.fab-toggle');

  function close(){
    fab.classList.remove('is-open');
    toggle.setAttribute('aria-expanded', 'false');
  }
  function open(){
    fab.classList.add('is-open');
    toggle.setAttribute('aria-expanded', 'true');
  }

  toggle.addEventListener('click', function(){
    if(fab.classList.contains('is-open')){ close(); } else { open(); }
  });
  document.addEventListener('click', function(e){
    if(!fab.contains(e.target)){ close(); }
  });
  document.addEventListener('keydown', function(e){
    if(e.key === 'Escape'){ close(); }
  });
  fab.querySelectorAll('.fab-menu a').forEach(function(a){
    a.addEventListener('click', close);
  });
})();

(function(){
  var search = document.getElementById('search');
  if(!search) return;
  var toggle = search.querySelector('.search-toggle');
  var input = search.querySelector('.search-input');

  function close(){
    search.classList.remove('is-open');
    toggle.setAttribute('aria-expanded', 'false');
  }
  function open(){
    search.classList.add('is-open');
    toggle.setAttribute('aria-expanded', 'true');
    input.focus();
  }

  toggle.addEventListener('click', function(){
    if(search.classList.contains('is-open')){ close(); } else { open(); }
  });
  document.addEventListener('click', function(e){
    if(!search.contains(e.target)){ close(); }
  });
  document.addEventListener('keydown', function(e){
    if(e.key === 'Escape'){ close(); toggle.focus(); }
  });
})();
