# In the comments $ means jQuery object that represents a set of DOM elements


minefield = $("#game")
openRegex = /open(\d)/


# Takes $ with several squares
# Returns $ with only open squares
#
getOpen = (minefield) ->
  minefield.find('[class*="open"]:not(.open0)').filter(":visible")


# Takes $ with a single square
# Returns $ with all surrounding squares (neighbors)
#
getNeighbors = (square) ->
  xy = square.attr("id").split(",").map (num) -> parseInt(num, 10)
  neighbors = $()
  for x in [xy[0]-1..xy[0]+1] by 1
    for y in [xy[1]-1..xy[1]+1] by 1
      neighbors = neighbors.add minefield.find("[id='#{x},#{y}']").filter(":visible") unless x == xy[0] && y == xy[1]
  return neighbors


# Takes $ with a single square
# Returns integer representing the number of mines in neighbors
#
getMyNum = (square) ->
  parseInt(square.attr('class').match(openRegex)[1], 10)


# Takes $ with several squares
# Returns integer representing amount of those squares that are closed (not yet
# discovered what they hide)
#
countClosed = (squares) ->
  length = 0
  squares.each ->
    if $(this).hasClass('blank') || $(this).hasClass('bombflagged')
      length += 1
  length


# Takes $ with a single square
# Emulates a secondary click therefore flagging the square (has a bomb)
#
flagBomb = (square) ->
  unless square.hasClass('bombflagged')
    square
      .trigger({type: 'mousedown', button: 2})
      .trigger({type: 'mouseup', button: 2})


# Takes $ with a single square
# Emulates a two button click therefore automatically clicking all neighbors
# if amount of flagged bombs is equal to self number
#
research = (square) ->
  square
    .trigger({type: 'mousedown', button: 0})
    .trigger({type: 'mousedown', button: 2})
    .trigger({type: 'mouseup', button: 0})
    .trigger({type: 'mouseup', button: 2})


# Takes $ with a single square
# Counts neighbors and square number and if they equal, neighbors get flagged
#
flagNeighbors = (square) ->
  neighbors = getNeighbors(square)
  closedNeighborsLength = countClosed(neighbors)

  if closedNeighborsLength != 0 && closedNeighborsLength == getMyNum(square)
    neighbors.each ->
      flagBomb($(this))


# Takes $ with a single square
# If there are no more possible moves for this square and its neighbors, the
# square is marked as "infertile" to avoid unnecessary calculations. If the
# square still has open neighbors its marked as "fertile" and further
# calculations are done on the square. Whether it's fertile or not gets
# memoized on the square to avoid even doing this check on squares already
# marked as infertile
#
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


# Takes $ with a single square
# If the square is "fertile" executes flagNeighbors and research on it
#
swipe = (square) ->
  if isFertile square
    # square.css {"outline":"green 2px solid"}
    flagNeighbors square
    research square


# Pressing j starts the research loop and stops when there are no more changes
# after two ticks
#
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


# Binds pressing the smiley to setting fertility to null on all squares
# (it's a new game)
#
setTimeout ->
  console.log $("#face")
  $("#face").on "click", ->
    minefield.find(".square").each ->
      $(this).data("fertile", null)
, 500
