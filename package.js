
Package.describe({
  summary: "Photo capture or upload, resize, crop and push to server widget on the client"
});

Package.on_use(function(api, where) {
  
  api.use(['minimongo', 'mongo-livedata', 'templating', 'coffeescript', 'jquery', 'jquery-jcrop'], 'client');
  
  api.add_files([
    'lib/load-image.min.js',
    'lib/photoUpload.css', 
    'lib/photoUpload.html', 
    'lib/photoUpload.coffee'
    ], 'client');

  if (api.export) {
    //api.export('PhotoUploadHandler');
    api.export('PhotoUploadHandler');
  }
});

/*
Package.on_test(function(api) {
    api.use('coffee-alerts', 'client'); 
    api.use(['tinytest', 'test-helpers', 'coffeescript'], 'client');
    api.add_files('alerts_tests.coffee', 'client'); 
});
*/