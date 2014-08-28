minefield = $("#game")
openRegex = /open(\d)/


getOpen = (minefield) ->
  minefield.find('[class*="open"]:not(.open0)').filter(":visible")


getNeighbors = (square) ->
  xy = square.attr("id").split(",").map (num) -> parseInt(num, 10)
  neighbors = $()
  for x in [xy[0]-1..xy[0]+1] by 1
    for y in [xy[1]-1..xy[1]+1] by 1
      neighbors = neighbors.add minefield.find("[id='#{x},#{y}']").filter(":visible") unless x == xy[0] && y == xy[1]
  return neighbors


getMyNum = (square) ->
  parseInt(square.attr('class').match(openRegex)[1], 10)


countClosed = (squares) ->
  length = 0
  squares.each ->
    if $(this).hasClass('blank') || $(this).hasClass('bombflagged')
      length += 1
  length


flagBomb = (square) ->
  unless square.hasClass('bombflagged')
    square
      .trigger({type: 'mousedown', button: 2})
      .trigger({type: 'mouseup', button: 2})


research = (square) ->
  square
    .trigger({type: 'mousedown', button: 0})
    .trigger({type: 'mousedown', button: 2})
    .trigger({type: 'mouseup', button: 0})
    .trigger({type: 'mouseup', button: 2})


doNeighborsEqualMyNum = (square) ->
  closedNeighborsLength = countClosed(getNeighbors(square))
  closedNeighborsLength != 0 && closedNeighborsLength == getMyNum(square)


flagNeighbors = (square) ->
  neighbors = getNeighbors(square)
  closedNeighborsLength = countClosed(neighbors)

  if closedNeighborsLength != 0 && closedNeighborsLength == getMyNum(square)
    neighbors.each ->
      flagBomb($(this))


isFertile = (square) ->
  if !(square.data("fertile") == false)
    if not square.data("fertile")?
      square.data("fertile", false)

    _isFertile = false
    getNeighbors(square).each ->
      if $(this).hasClass("blank")
        _isFertile = true
        square.data("fertile", _isFertile)
    return _isFertile

  else
    false


swipe = (square) ->
  if isFertile square
    # square.css {"outline":"green 2px solid"}
    flagNeighbors square
    research square


$(window).keypress (event) ->
  if event.which == 106 # j
    minefield.css {"outline":"1em solid red"}

    previousOpenMinefieldLength = 0
    previousPreviousOpenMinefieldLength = 0
    openMinefield = getOpen(minefield)

    tick = setInterval ->
      if openMinefield.length != previousPreviousOpenMinefieldLength
          openMinefield.each ->
            swipe $(this)

          previousPreviousOpenMinefieldLength = previousOpenMinefieldLength
          previousOpenMinefieldLength = openMinefield.length
          openMinefield = getOpen(minefield)
      else
        minefield.css {"outline":"1em solid green"}
        clearInterval tick
    , 16


setTimeout ->
  console.log $("#face")
  $("#face").on "click", ->
    minefield.find(".square").each ->
      $(this).data("fertile", null)
, 500
