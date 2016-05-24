angular.module('SampleCode.directives').directive 'memberImportUploader', ->
  restrict: 'C'
  require: 'directUploader'
  link: ($scope, element, attrs, ctrl)->

    ctrl.setOptions {
      s3Uploader:
        remove_completed_progress_bar: true
        allow_multiple_files: false
      s3UploadsComplete: (e, content) ->
        remoteAssetUrl = content['url']


    }
