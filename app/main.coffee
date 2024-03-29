sqeuclidean = (a, b) ->
  d = 0
  for i in [0...a.length]
    c = (a[i] - b[i])
    d += c * c
  d

@itemsByProximity = (x, y) ->
  p = [x, y]
  distances = ({idx, pos, dist: sqeuclidean(p, pos)} for pos, idx in data.embedding)
  distances.sort (a, b) -> (a.dist - b.dist)
  distances


D = React.DOM

ItemList = React.createClass
  render: ->
    {nearbyItems} = @props
    items = for {idx, dist} in nearbyItems
      item = data.items[idx]
      D.li {key: idx, style: {color: colorScale(1/dist)}}, item.text
    D.ul {},
      items

@xScale = d3.scale.linear()
@yScale = d3.scale.linear()
colorScale = d3.scale.linear().domain([0, 1]).range(['grey', 'red']).clamp(true)


Embedding = React.createClass
  displayName: 'Embedding'

  componentDidMount: ->
    {width, height, onMouse} = @props

    xScale.domain([-20, 20]).range([0, width])
    yScale.domain([-20, 20]).range([height, 0])

    zoom = => @forceUpdate()
    overlay = d3.select(@refs.overlay.getDOMNode())
    overlay
      .on('mousemove', =>
        [px, py] = d3.mouse(overlay.node())
        x = xScale.invert(px)
        y = yScale.invert(py)
        onMouse x, y
      )
      .call(d3.behavior.zoom().x(xScale).y(yScale).scaleExtent([1, 8]).on("zoom", zoom))
    @forceUpdate()

  render: ->
    {width, height, items, onClick} = @props
    D.svg {width, height},
      for item, idx in items
        [x, y] = item.pos
        D.circle({key: item.idx, r: 2.5, fill: colorScale(1/item.dist), transform: "translate(#{xScale(x)}, #{yScale(y)})"})
      for {idx, pos} in items
        item = data.items[idx]
        continue unless item.labeled
        [x, y] = pos
        text = item.text
        D.text {key: idx, transform: "translate(#{xScale(x)}, #{yScale(y)})"}, text
      D.rect {className: 'overlay', width, height, ref: 'overlay', onClick}

Top = React.createClass
  displayName: 'Top'
  getInitialState: -> {x: 0, y: 0}

  render: ->
    {x, y} = @state
    onMouse = (x, y) =>
      @setState {x, y}

    nearbyItems = itemsByProximity(x, y)

    onClick = =>
      closest = data.items[nearbyItems[0].idx]
      closest.labeled = !closest.labeled
      console.log closest
      @forceUpdate()

    D.div {className: 'container'},
      Embedding {width: 500, height: 500, items: nearbyItems, onMouse, onClick}
      D.div {className: 'closest'},
        "Closest items to the mouse:"
        ItemList({nearbyItems: nearbyItems[...10]})

$ ->
  $.getJSON 'export.json', (_data) ->
    window.data = _data
    for item in data.items
      words = item.text.split(' ')
      #words = (word for word in words when not word.lower() in ['of'])
      start = _.random(words.length-3)
      item.shortText = words[start...start+3].join(' ')
      item.labeled = Math.random() < 1/6
    console.log data
    React.renderComponent(Top(), document.body)