$ = require("jquery")
Bacon = require("baconjs")
storage = require("./storage.coffee")

module.exports = (authorP, fileOpenE) ->
  $dialog = $("#file-open-dialog")
  fileLoadedE = fileOpenE.map(authorP).flatMapLatest (author) ->
    $dialog.addClass("active")
    Bacon.fromPromise($.ajax("/apps/" + author))
      .onValue (files) ->
        if files.length
          $files = files.map((f) -> f.name).map (name) ->
            $("<li>").addClass("file").text(name).data("file", name)
          $dialog.find(".files").html($files)
          $dialog.addClass("loaded")
        else
          $dialog.addClass("empty")

    fileSelectE = $dialog.asEventStream("click", ".file")
      .doAction(".stopPropagation")
      .map((e)-> $(e.target).data("file"))

    fileContentE = fileSelectE.flatMap (name) ->
      storage.openE author, name

    fileContentE

  cancelE = $dialog.asEventStream("click").doAction(".stopPropagation")
  dismissE = cancelE.merge(fileLoadedE)
  dismissE.onValue -> $dialog.removeClass("active").removeClass("loaded").removeClass("empty")

  { fileLoadedE }
  
