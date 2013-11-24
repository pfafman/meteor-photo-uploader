

class PhotoUploadHandler
    constructor: (@options) ->
    
        defaults =
            serverUploadMethod:     "submitPhoto"
            uploadButtonLabel:      "Upload"
            takePhotoButtonLabel:   "Take Photo"
            #resizeMaxHeight:        300
            #resizeMaxWidth:         300
            serverUploadOptions:    {}

        @options = _.defaults(@options, defaults)
        
        @previewImage = null
        @previewImageListeners = new Deps.Dependency()
        
        @cropCords = null
        @previewImageCropListeners = new Deps.Dependency()

        @setup()

    _iOS: ->
        window.navigator?.platform? and (/iP(hone|od|ad)/).test(window.navigator.platform)

    _maxPreviewImageWidth: ->
        console.log('_maxPreviewImageWidth', $('.photo-uploader-control').width())
        if @_iOS()
            @options.resizeMaxWidth || (0.9 * $('.photo-uploader-control').width())
        else
            @options.resizeMaxWidth || (0.9 * $('.photo-uploader-control').width())

    _maxPreviewImageHeight: ->
        @options.resizeMaxHeight

    setOptions: (newOptions) ->
        @options = _.extend(@options, newOptions)
    
    reset: ->
        # nothing

    _reset: ->
        @previewImage = null
        @cropCords = null
        @previewImageListeners.changed()

    setup: ->
    
        Template.photoUpload.created = =>
            @previewImage = null
    
        Template.photoUpload.helpers
            havePreviewImage: =>
                @previewImageListeners.depend()
                @previewImage?

            previewImage: =>
                @previewImageListeners.depend()
                @previewImage

            takePhotoLabel: =>
                @options.takePhotoButtonLabel

        Template.photoUpload.events
            "click #take-photo-button": (e) ->
                e.preventDefault()
                $("#photoUploadForm").get(0).reset()
                $("#photoUploadFileSelector").trigger('click')

            "change #photoUploadFileSelector": (e) =>
                if file = e.target.files[0]

                    loadImage.parseMetaData file, (data) =>
                        loadImage file, (img) =>
                            @previewImage =
                                name: file.name.split('.')[0]
                                src: img.toDataURL() #img.src #reSizeImageMP(img, metadata.Orientation)
                                filesize: file.size
                                newImage: true
                                orientation: data?.exif?.get?('Orientation') or 1
                            @previewImageListeners.changed()
                        ,
                            maxHeight: @_maxPreviewImageHeight()
                            maxWidth: @_maxPreviewImageWidth()
                            orientation: data?.exif?.get?('Orientation') or 1
                            canvas: true
                

            #
            #"drop #photo-button": (e) ->
            #    e.stopPropagation()
            #    e.preventDefault()
            #    file = e.dataTransfer.files[0]
            #    console.log("drop event", file)
            #    handleFile(file)

            #"dragenter #photo-button": (e) ->
            #    e.stopPropagation()
            #    e.preventDefault()
            #    console.log("dragenter event")

            #"dragover #photo-button": (e) ->
            #    e.stopPropagation()
            #    e.preventDefault()



        Template.photoUploadPreview.created = =>
            @cropCords = null

        Template.photoUploadPreview.rendered = =>
            Meteor.defer =>
                $('#photoUploadPreview').Jcrop(
                    onSelect: (cords) =>
                        @cropCords = cords
                        console.log("onSelect", @cropCords)
                        @previewImageCropListeners.changed()
                    onRelease: =>
                        @cropCords = null
                        @previewImageCropListeners.changed()
                ).parent().on "click", (event) ->
                    event.preventDefault()

        Template.photoUploadPreview.helpers
            size: ->
                Math.round(@filesize/1000) + " kb"

            imagePartSelected: =>
                @previewImageCropListeners.depend()
                @cropCords?

            uploadLabel: =>
                @options.uploadButtonLabel

        Template.photoUploadPreview.events

            "click #crop-photo-button": (e) =>
                e.preventDefault()
                img = $('#photoUploadPreview')
                if not @cropCords or not img
                    alert("You have to select a part of the image to crop")
                else
                    #if @_iOS()
                        #console.log("iOS", img[0].width, img[0].height)
                        #if img[0].width > img[0].height
                            #console.log("landscape")
                            #@cropCords.x *= 2
                            #@cropCords.y *= 2
                            #@cropCords.w *= 2
                            #@cropCords.h *= 2

                    newImg = loadImage.scale img[0],
                        left: @cropCords.x
                        top: @cropCords.y
                        sourceWidth: @cropCords.w
                        sourceHeight: @cropCords.h
                        #minWidth: img.parent().width()
                        canvas: true
                    @previewImage.src = newImg.src || newImg.toDataURL()
                    @previewImageListeners.changed()
                    @cropCords = null
                    @previewImageCropListeners.changed()

            "click #upload-photo-button": (e) =>
                e.preventDefault()
                newPhoto = $('#photoUploadPreview')
                rec =
                    name: newPhoto.attr('name')
                    filesize: newPhoto.attr('src').length
                    orientation: newPhoto.attr('orientation')
                    src: newPhoto.attr('src')

                Meteor.call @options.serverUploadMethod, rec, @options.serverUploadOptions, (error, result) =>
                    if error
                        CoffeeAlerts.error(error.reason)
                    else
                        @previewImage = null
                    @previewImageListeners.changed()
                    if @options.callback?
                        @options.callback(error, result)




