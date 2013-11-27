Meteor Photo Uploader  (BETA !!!)
=====================

#### BETA !!! 
	Only on Atmosphere to allow me to use in multiple projects easily.

### Intro
This is a drop in widget to add the ability to upload, or capture, *(if allowed by the device)*, images/photos.  It will rescale the image, fix iOS sampling and orientation *(using [JavaScript-Load-Image](https://github.com/blueimp/JavaScript-Load-Image) which is included)*, allows cropping via [Jcrop](https://github.com/tapmodo/Jcrop), which is also included with a few [modifications](https://github.com/tapmodo/Jcrop/pull/107).

	Note: this is built using coffeescript.  If you don't want that then clone and compile it down to javascript.

## TODO

Tests other than the test [website](http://photos.pfafman.com)
Add more options

## Installation

* Pre-Install [Meteorite](https://github.com/oortcloud/meteorite) to use [Atmosphere](https://atmosphere.meteor.com)

	
```sh
	[sudo] npm install -g meteorite
```

* Install via [Atmosphere](https://atmosphere.meteor.com)

```
	mrt add photo-uploader
```

In your handlebar templates you can just include the template photoUploader:

```
    {{> photoUpload}}
```

Then in create a photoUpload object:

```coffee
	myObject = new PhotoUploader( [options] )
```

##Options

	serverUploadMethod:  	Name of your server side Meteor method for loading 
							the images to.  Default 'submitPhoto'.  The method 
							takes two arguments one for the image record and the
							second is an optional one to pass to the server method.
							
	serverUploadOptions:    Object to pass to the server method.  Default {}

	callback:				Callback for the server method callback(error, result)
							
	uploadButtonLabel:		Label for the upload button.  Default 'Upload'
	
	takePhotoButtonLabel:	Label for the take photo button.  Default 'Take Photo'
	
	resizeMaxHeight:		Max Height of the image before loading to server. 
							Default: 300
			
	resizeMaxWidth:			Max Width of the image before loading to server. 
							Default: 300
							
	editTitle:              Add a title on upload.  Default: false
	
	editCaption:            Add a caption on upload.  Default: false
							

## Outside Packages

* [Bootstrap](http://http://getbootstrap.com)
* [JavaScript-Load-Image](https://github.com/blueimp/JavaScript-Load-Image)
* [Jcrop](https://github.com/tapmodo/Jcrop) with [modifications](https://github.com/tapmodo/Jcrop/pull/107)
