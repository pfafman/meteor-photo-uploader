

class PhotoUploadHandler
    
    constructor: (options) ->
        @setOptions(options)
        @previewImage = null
        @previewImageListeners = new Deps.Dependency()
        @cropCords = null
        @previewImageCropListeners = new Deps.Dependency()
    

    setOptions: (options = {}) ->
        defaults =
            serverUploadMethod:     "submitPhoto"
            uploadButtonLabel:      "Upload"
            takePhotoButtonLabel:   "Take Photo"
            #resizeMaxHeight:        300
            #resizeMaxWidth:         300
            allowCropping:          true
            serverUploadOptions:    {}
            editTitle:              false
            editCaption:            false

        @options = _.defaults(options, defaults)
        

    _iOS: ->
        window.navigator?.platform? and (/iP(hone|od|ad)/).test(window.navigator.platform)

    _maxPreviewImageWidth: ->
        if @_iOS()
            @options.resizeMaxWidth || (0.9 * $('.photo-uploader-control').width())
        else
            @options.resizeMaxWidth || (0.9 * $('.photo-uploader-control').width())

    _maxPreviewImageHeight: ->
        @options.resizeMaxHeight

    
    reset: ->
        # nothing
        @_reset()

    _reset: ->
        console.log("reset")
        @previewImage = null
        @cropCords = null
        @previewImageListeners.changed()
        @jcrop?.destroy()

    doJcrop: ->
        $('#photoUploadPreview').Jcrop
            onSelect: (cords) =>
                @cropCords = cords
                @previewImageCropListeners.changed()
            onRelease: =>
                @cropCords = null
                @previewImageCropListeners.changed()
        , ->
            PhotoUploader.jcrop = @
        .parent().on "click", (event) ->
            event.preventDefault()


PhotoUploader = new PhotoUploadHandler()

Template.photoUpload.created = ->
    PhotoUploader.previewImage = null

Template.photoUpload.helpers
    havePreviewImage: ->
        PhotoUploader.previewImageListeners.depend()
        PhotoUploader.previewImage?

    previewImage: ->
        PhotoUploader.previewImageListeners.depend()
        PhotoUploader.previewImage

    takePhotoLabel: ->
        PhotoUploader.options.takePhotoButtonLabel

Template.photoUpload.events
    "click #take-photo-button": (e) ->
        e.preventDefault()
        $("#photoUploadForm").get(0).reset()
        $("#photoUploadFileSelector").trigger('click')

    "change #photoUploadFileSelector": (e) ->
        if file = e.target.files[0]

            loadImage.parseMetaData file, (data) ->
                loadImage file, (img) ->
                    PhotoUploader.previewImage =
                        name: file.name.split('.')[0]
                        src: img.toDataURL() #img.src #reSizeImageMP(img, metadata.Orientation)
                        filesize: file.size
                        newImage: true
                        orientation: data?.exif?.get?('Orientation') or 1
                    $('#photoUploadPreview').attr("src", img.toDataURL())
                    if PhotoUploader.options.allowCropping
                        PhotoUploader.doJcrop()

                    PhotoUploader.previewImageListeners.changed()
                    $('#photo-preview-dialog').modal
                        show: true
                ,
                    maxHeight: PhotoUploader._maxPreviewImageHeight()
                    maxWidth: PhotoUploader._maxPreviewImageWidth()
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



Template.photoUploadPreview.created = ->
    PhotoUploader.cropCords = null

Template.photoUploadPreview.rendered = ->
    $('#photo-preview-dialog').on 'hidden.bs.modal', (e) ->
         PhotoUploader.reset()

Template.photoUploadPreview.helpers

    previewImage: ->
        PhotoUploader.previewImageListeners.depend()
        PhotoUploader.previewImage

    name: -> 
        PhotoUploader.previewImageListeners.depend()
        PhotoUploader.previewImage?.name

    caption: -> 
        PhotoUploader.previewImageListeners.depend()
        PhotoUploader.previewImage?.caption

    orientation: -> 
        PhotoUploader.previewImageListeners.depend()
        PhotoUploader.previewImage?.orientation

    uploadLabel: -> 
        PhotoUploader.previewImageListeners.depend()
        PhotoUploader.previewImage?.uploadLabel

    size: ->
        PhotoUploader.previewImageCropListeners.depend()
        if PhotoUploader.previewImage?.filesize?
            Math.round(PhotoUploader.previewImage?.filesize/1000) + " kb"

    imagePartSelected: ->
        PhotoUploader.previewImageCropListeners.depend()
        PhotoUploader.cropCords?

    uploadLabel: ->
        PhotoUploader.options.uploadButtonLabel

    editTitle: ->
        PhotoUploader.options.editTitle

    editCaption: ->
        PhotoUploader.options.editCaption

    src: -> 
        PhotoUploader.previewImageListeners.depend()
        PhotoUploader.previewImage?.src


Template.photoUploadPreview.events

    "click #cancel-photo-upload": (e) ->
        PhotoUploader.previewImage = null
        PhotoUploader.previewImageListeners.changed()
        $('#photo-preview-dialog').modal('hide')
       

    "click #crop-photo-button": (e) ->
        e.preventDefault()
        img = $('#photoUploadPreview')
        if not PhotoUploader.cropCords or not img
            alert("You have to select a part of the image to crop")
        else
            #if PhotoUploader._iOS()
                #console.log("iOS", img[0].width, img[0].height)
                #if img[0].width > img[0].height
                    #console.log("landscape")
                    #PhotoUploader.cropCords.x *= 2
                    #PhotoUploader.cropCords.y *= 2
                    #PhotoUploader.cropCords.w *= 2
                    #PhotoUploader.cropCords.h *= 2

            newImg = loadImage.scale img[0],
                left: PhotoUploader.cropCords.x
                top: PhotoUploader.cropCords.y
                sourceWidth: PhotoUploader.cropCords.w
                sourceHeight: PhotoUploader.cropCords.h
                #minWidth: img.parent().width()
                canvas: true
            PhotoUploader.previewImage.src = newImg.src || newImg.toDataURL()
            PhotoUploader.jcrop?.destroy()
            $('#photoUploadPreview').attr("src", PhotoUploader.previewImage.src) 
            PhotoUploader.previewImageListeners.changed()
            PhotoUploader.cropCords = null
            PhotoUploader.previewImageCropListeners.changed()
            Meteor.defer =>
                PhotoUploader.doJcrop()

    "click #upload-photo-button": (e) ->
        e.preventDefault()
        newPhoto = $('#photoUploadPreview')
        $('#photo-preview-dialog').modal('hide')

        rec =
            name: newPhoto.attr('name')
            filesize: newPhoto.attr('src').length
            orientation: newPhoto.attr('orientation')
            src: newPhoto.attr('src')

        if PhotoUploader.options.editTitle
            rec.title = $('#title').val()
        else
            rec.title = rec.name

        if PhotoUploader.options.editCaption
            rec.caption = $('#caption').val()

        tempPreviewImage = PhotoUploader.previewImage
        PhotoUploader.previewImage = null
        PhotoUploader.previewImageListeners.changed()

        Meteor.call PhotoUploader.options.serverUploadMethod, rec, PhotoUploader.options.serverUploadOptions, (error, result) =>
            if error
                CoffeeAlerts.error(error.reason)
                PhotoUploader.previewImage = tempPreviewImage
                PhotoUploader.previewImageListeners.changed()
            if PhotoUploader.options.callback?
                PhotoUploader.options.callback(error, result)






