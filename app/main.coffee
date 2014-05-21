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

ClosestItems = React.createClass
  render: ->
    {x, y, n} = @props
    items = for {idx} in itemsByProximity(x, y)[...n]
      item = data.items[idx]
      D.li {key: idx}, item.text
    D.ul {},
      items

@xScale = d3.scale.linear()
@yScale = d3.scale.linear()

Embedding = React.createClass
  componentDidMount: ->
    {width, height, onMouse} = @props

    xScale.domain([-50, 50]).range([0, width])
    yScale.domain([-50, 50]).range([height, 0])

    zoom = => @forceUpdate()
    overlay = d3.select(@refs.overlay.getDOMNode())
    overlay
      .on('mousemove', =>
        [px, py] = d3.mouse(overlay.node())
        x = xScale.invert(px)
        y = yScale.invert(py)
        console.log x, y
        onMouse x, y
      )
      .call(d3.behavior.zoom().x(xScale).y(yScale).scaleExtent([1, 8]).on("zoom", zoom))
    @forceUpdate()

  render: ->
    {width, height, positions} = @props
    D.svg {width, height},
      D.g {},
        D.g {ref: 'inner_svg'},
          for [x, y], idx in positions
            D.circle({key: idx, r: 2.5, transform: "translate(#{xScale(x)}, #{yScale(y)})"})
      D.rect {className: 'overlay', width, height, ref: 'overlay'}

Top = React.createClass
  getInitialState: -> {x: 0, y: 0}

  render: ->
    {x, y} = @state
    onMouse = (x, y) =>
      @setState {x, y}

    D.div {className: 'container'},
      Embedding {width: 500, height: 500, positions: data.embedding, onMouse}
      D.div {className: 'closest'},
        ClosestItems({x, y, n: 5})

$ ->
  $.getJSON 'export.json', (_data) ->
    window.data = _data
    console.log data
    React.renderComponent(Top(), document.body)