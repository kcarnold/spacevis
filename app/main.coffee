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

Embedding = React.createClass
  componentDidMount: ->
    zoom_g = d3.select(@refs.zoom_g.getDOMNode())
    zoom = ->
      zoom_g.attr("transform", "translate(" + d3.event.translate + ")scale(" + d3.event.scale + ")")
    d3.select(@refs.overlay.getDOMNode())
      .call(d3.behavior.zoom().scaleExtent([1, 8]).on("zoom", zoom))

  render: ->
    {width, height, positions} = @props
    D.svg {width, height},
      D.rect {className: 'overlay', width, height, ref: 'overlay'}
      D.g {ref: 'zoom_g'},
        D.g {ref: 'inner_svg'},
          for [x, y], idx in positions
            D.circle({key: idx, r: 2.5, transform: "translate(#{x}, #{y})"})

Top = React.createClass
  render: ->
    x = 0
    y = 0
    D.div {},
      Embedding {width: 500, height: 500, positions: data.embedding}
      ClosestItems({x, y, n: 5})

$ ->
  $.getJSON 'export.json', (_data) ->
    window.data = _data
    console.log data
    React.renderComponent(Top(), document.body)