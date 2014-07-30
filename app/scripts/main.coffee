minefield = $("#game")


getOpen = (minefield) ->
  minefield.find('[class*="open"]').filter(":visible")


getNeighbors = (square) ->
  xy = square.attr("id").split(",").map (num) -> parseInt(num, 10)
  neighbors = $()
  for x in [xy[0]-1..xy[0]+1] by 1
    for y in [xy[1]-1..xy[1]+1] by 1
      neighbors = neighbors.add minefield.find("[id='#{x},#{y}']").filter(":visible") unless x == xy[0] && y == xy[1]
  return neighbors


getMyNum = (square) ->
  parseInt(square.attr('class').match(/open(\d)/)[1], 10)

countClosed = (squares) ->
  length = 0
  squares.each () ->
    if $(this).hasClass('blank') || $(this).hasClass('bombflagged')
      length += 1
  length


flagBomb = (square) ->
  unless square.hasClass('bombflagged')
    # console.log "flagBomb", square.attr "id"
    square
      .trigger({type: 'mousedown', button: 2})
      .trigger({type: 'mouseup', button: 2})

research = (square) ->

  # console.log "research", square.attr "id"
  square
    .trigger({type: 'mousedown', button: 0})
    .trigger({type: 'mousedown', button: 2})
    .trigger({type: 'mouseup', button: 0})
    .trigger({type: 'mouseup', button: 2})

doNeighborsEqualMyNum = (square) ->
  closedNeighborsLength = countClosed(getNeighbors(square))

  if closedNeighborsLength != 0 && closedNeighborsLength == getMyNum(square)
    true

flagNeighbors = (square) ->
  neighbors = getNeighbors(square)
  closedNeighborsLength = countClosed(neighbors)

  if closedNeighborsLength != 0 && closedNeighborsLength == getMyNum(square)
    neighbors.each () ->
      flagBomb($(this))

$(window).keypress (event) ->
  if event.which == 106
    minefield.css {"outline":"4px solid red"}

    previousOpenMinefieldLength = 0
    previousPreviousOpenMinefieldLength = 0
    openMinefield = getOpen(minefield)

    tick = setInterval () ->
      console.log openMinefield.length
      console.log previousOpenMinefieldLength
      console.log previousPreviousOpenMinefieldLength
      console.log "------"

      if openMinefield.length != previousPreviousOpenMinefieldLength
          openMinefield.each () ->
            flagNeighbors $(this)
            research $(this)
          previousPreviousOpenMinefieldLength = previousOpenMinefieldLength
          previousOpenMinefieldLength = openMinefield.length
          openMinefield = getOpen(minefield)
      else
        minefield.css {"outline":"4px solid yellow"}
        console.log "stopped"
        clearInterval tick
    , 16










