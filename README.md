Meteor Photo Uploader
=====================

This is a drop in widget to add the ability to upload, or capture if allowed by the device, images.  It will rescale the image, fix iOS sampling and orientation.  Allows cropping via [jquery-jcrop] (https://github.com/waltyuyu/meteor-jquery-jcrop), which is required.

	Note: this is built using coffeescript.  If you don't want that then clone and compile it down to javascript


### Installation

* Pre-Install [Meteorite](https://github.com/oortcloud/meteorite) to use [Atmosphere](https://atmosphere.meteor.com)

	
```sh
	[sudo] npm install -g meteorite
```

* Install via [Atmosphere](https://atmosphere.meteor.com)

	mrt add photo-uploader


In your handlebar templates you can just include the template photoUploader:

```
    {{> photoUpload}}
```

Then in create a photoUpload object:

```coffee
	myObject = new PhotoUploader( [options] )
```

###Options

	serverUploadMethod:  	Name of your server side Meteor method for loading 
							the images to.  Default 'submitPhoto'.  The method 
							takes one argument for the image record.
							
	uploadButtonLabel:		Label for the upload button.  Default 'Upload'
	
	takePhotoButtonLabel:	Label for the take photo button.  Default 'Take Photo'
	
	resizeMaxHeight:		Max Height of the image before loading to server. 
							Default: 300
			
	resizeMaxWidth:			Max Width of the image before loading to server. 
							Default: 300
							



### Outside Packages

* [Bootstrap] (http://http://getbootstrap.com)
* [JavaScript-Load-Image] (https://github.com/blueimp/JavaScript-Load-Image)
