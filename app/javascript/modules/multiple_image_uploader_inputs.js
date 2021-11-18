class MultipleImageUploaderInput {
  constructor(element) {
    this.$input = $(element)
    this.getSettings()
    this.initUploader()
    this.initImageWrappers()
    this.bindRemoveAction()
    this.hideDropZone()
    this.setProgress('done')
    this.bindFormSubmitPreventer()
    this.checkMaximumLimit()
  }

  getSettings() {
    this.objectName = this.$input.data('object-name')
    this.withDescription = this.$input.data('with-description')
    this.dropZoneSelector = this.$input.data('drop-zone-selector')
    if (this.dropZoneSelector) {
      this.$dropZone = $(this.dropZoneSelector)
    } else {
      this.$dropZone = this.$input
    }
    this.minimumLength = this.$input.data('minimum-length') || 0
    this.maximumLength = this.$input.data('maximum-length') || 9999
  }

  initUploader() {
    this.updateLengthData(this.getImagesCount(true))
    const $uploadInput = this.$input.find('[data-upload-input]')
    $uploadInput.fileupload({
      dataType: 'json',
      method: 'POST',
      dropZone: this.$dropZone,
      maxNumberOfFiles: this.maximumLength,
      getNumberOfFiles: this.getImagesCount.bind(this, true),
      progressall: (e, data) => {
        const progress = parseInt((data.loaded / data.total) * 100, 10)
        this.setProgress(progress)
      },
      done: (e, data) => {
        if (this.getImagesCount(true) >= this.maximumLength) {
          this.setProgress('done')
        } else {
          const { image } = data.result
          const imagesCount = this.getImagesCount()

          let imageHtml = `
                        <div class="image" data-image-wrapper="true">
                            <img src="${image.thumb_url}">
                            <input type="hidden" value="${image.id}" name="${this.objectName}[images_attributes][${imagesCount}][id]">
                            <a class="remove-btn" href="javascript:void(0)" data-remove-btn="true"></a>
                        </div>
                    `

          if (this.withDescription) {
            imageHtml = `
                            <div class="image" data-image-wrapper="true">
                                <img src="${image.thumb_url}">
                                <input type="hidden" value="${image.id}" name="${this.objectName}[images_attributes][${imagesCount}][id]">
                                <a class="remove-btn" href="javascript:void(0)" data-remove-btn="true"></a>
                                <input type="text" name="${this.objectName}[images_attributes][${imagesCount}][description]">
                            </div>
                        `
          }

          this.$input.find('[data-images]').append(imageHtml)
          this.updateLengthData(this.getImagesCount(true))
          this.bindRemoveAction()
          this.setProgress('done')

          this.checkMaximumLimit()
        }
      },
      error: () => {
        this.state = 'error'
        // TODO: Handle error
      }
    })

    document.addEventListener('dragover', this.showDropZone.bind(this))
    document.addEventListener('dragleave', this.hideDropZone.bind(this))
    document.addEventListener('drop', this.hideDropZone.bind(this))
  }

  initImageWrappers() {
    this.$input.find('[data-image-wrapper]').each((_index, item) => {
      const $item = $(item)
      if ($item.find('[data-destroy-field]').val() === 'true') {
        $item.css('display', 'none')
        $item.addClass('deleted')
      }
    })
  }

  bindRemoveAction() {
    const $removeBtns = this.$input.find('[data-remove-btn]')
    $removeBtns.off('click')
    $removeBtns.on('click', (e) => {
      const imageWrapper = $(e.target).parent()
      imageWrapper.find('[data-destroy-field]').val('true')
      imageWrapper.css('display', 'none')
      imageWrapper.addClass('deleted')
      this.checkMaximumLimit()
      this.updateLengthData(this.getImagesCount(true))
    })
  }

  bindFormSubmitPreventer() {
    this.$input.parents('form').on('submit', () => {
      if (this.state === 'uploading') {
        const notify = window.alert
        notify('Please wait for image uploading complete.')
        return false
      }

      return true
    })
  }

  showDropZone() {
    this.$input.find('[data-drop-zone-placeholder]').css('opacity', '1')
  }

  hideDropZone() {
    this.$input.find('[data-drop-zone-placeholder]').css('opacity', '0')
  }

  setProgress(progress) {
    this.$input.find('[data-progress]').css('display', 'block')
    this.$input.find('[data-progress] > *').css('width', `${progress}%`)

    if (progress === 'done') {
      this.state = 'ready'
      this.$input.find('[data-progress]').css('display', 'none')
    } else {
      this.state = 'uploading'
    }
  }

  checkMaximumLimit() {
    if (this.getImagesCount(true) >= this.maximumLength) {
      this.$input.find('.add-image').css('display', 'none')
      this.$input.find('.drop-zone').css('display', 'none')
    } else {
      this.$input.find('.add-image').css('display', 'inline-block')
      this.$input.find('.drop-zone').css('display', 'flex')
    }
  }

  getImagesCount(onlyAvailable = false) {
    if (onlyAvailable) {
      return this.$input.find('[data-images]').children(':not(.deleted)').length
    }

    return this.$input.find('[data-images]').children().length
  }

  updateLengthData(length) {
    this.$input.attr('data-length', length)
    this.$input.parent().attr('data-length', length)
  }
}

export default class MultipleImageUploaderInputs {
  constructor() {
    this.inputs = []
    this.$imageUploadInputs = $('.multiple-image-upload-input')
    this.$imageUploadInputs.each((_index, item) => {
      this.register(item)
    })
  }

  register(element) {
    const input = new MultipleImageUploaderInput(element)
    this.inputs.push(input)
  }
}
