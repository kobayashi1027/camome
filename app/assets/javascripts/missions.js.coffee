# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

fullCalendar = ->
  $('#calendar').fullCalendar
    editable: false
    selectable: true
    droppable: true
    timezone: 'Tokyo'
    timeFormat:
      month: ''
      week: 'HH:mm'
      day: 'HH:mm'
    events: '/events.json'

    eventClick:
      (calEvent) ->
        document.location = "../events/#{calEvent.id}"

    drop:
      (date) ->
        clam  = getClam($(this).data('clam').id)
        $('#create-event-modal #event-dtstart').val(moment(date).format("YYYY/MM/DD H:mm"))
        $('#create-event-modal #event-dtend').val(moment(date).format("YYYY/MM/DD H:mm"))
        $('#create-event-modal #event-summary').val(clam.summary)
        $('#create-event-modal #event-description').val(clam.options.description)
        $('.mail').empty().append("<a href='#' id='mail' data-id='#{clam.id}'>#{clam.summary}</a>")
        $('#create-event-modal').modal('show')

getClam = (id) ->
  res = $ . ajax
    type: 'GET'
    url: "/clams/#{id}.json"
    dataType: "json"
    async: false
    error: ->
      alert("error")
  res.responseJSON

initDraggableClam = ->
  $('.draggable-clam').each ->
    clam = {
      id: $(this).attr("data-id")
      summary: $(this).attr("data-summary")
    }
    $(this).data('clam', clam)

    $(this).draggable
      appendTo: "body"
      zIndex: 999
      helper: (event) ->
        length =  $(".selected").length
        length = 1 if length is 0
        $("<span style='white-space:nowrap;'>").text length + "mails"
      revert: "invalid"

displayCalendar = ->
  if ($('.mini-calendar').is(':visible') != true)
    $('.mini-calendar').show(100, ->
      fullCalendar()
      )
    $('.missions-table').hide(100)
    $('.clams-table').css('width','55%')
    $('.clams-table').css('float','right')

displayMissions = ->
  if ($('.missions-table').is(':visible') != true)
    $('.missions-table').show(100)
    $('.mini-calendar').hide(100)
    $('.clams-table').css('width','80%')

submitEvent = ->
  $("#create-event-modal").modal('hide')

  data = {
    clam_id: $('#create-event-modal #mail').attr("data-id")
    event:
      summary: $('#create-event-modal #event-summary').val()
      dtstart: $('#create-event-modal #event-dtstart').val()
      dtend: $('#create-event-modal #event-dtend').val()
      description: $('#create-event-modal #event-description').val()
  }

  $ . ajax
    type: 'POST'
    url: '/events'
    data: data
    dataType: 'json'
    timeout: 9000
    success: ->
      $("#calendar").fullCalendar('refetchEvents')
    error: ->
      alert("error")

showBodyColumns = (clickedClam) ->
  if ($('.clam-body').is(':visible') == true)
    clamBodyId = $('.clam-body').attr('clam-id')
    $(".clam-body").remove()
    return if clamBodyId == clickedClam.attr("data-id")

  clam  = getClam(clickedClam.attr("data-id"))
  parent_clam = getParentClam(clam.id)
  events = getEventOfRelatedClam(clam.id)

  reuse_parent =
    if parent_clam?
      "再利用元のメール：<a href='#' class='show-reuse-parent' parent-id='#{parent_clam.id}'>#{parent_clam.summary}</a>"
    else ""

  related_tasks =
    if events.length
      buf = "関連するタスク："
      for event in events
        buf += "<a href='#' class='show-related-task' task-id='#{event.id}'>#{event.summary}</a>"
        buf += ", "
      buf.slice(0, -2)
    else ""

  clamBody =
    """
    <tr class='clam-body' clam-id='#{clam.id}' >
      <td colspan='5'>
        <div>
          <pre>
            <table>
              <tr><th>差出人</th><td>#{clam.options.originator}</td></tr>
              <tr><th>件名</th><td>#{clam.summary}</td></tr>
              <tr><th>宛先</th><td>#{clam.options.recipients}</td></tr>
              <tr><td colspan='2'>#{clam.options.description}</td></tr>
            </table>
          </pre>
        </div>
        <div>
          #{reuse_parent}
        </div>
        <div>
          #{related_tasks}
        </div>
      </td>
    </tr>
    """

  $(".draggable-clam[data-id=#{clam.id}]").after(clamBody)
  $(".clam-body > td > div").hide().slideDown(200)

getParentClam = (id) ->
  res = $ . ajax
    type: 'GET'
    url: "/clams/#{id}/reuse_parent.json"
    dataType: "json"
    async: false
    error: ->
      alert("error")
  res.responseJSON

getEventOfRelatedClam = (id) ->
  res = $ . ajax
    type: 'GET'
    url: "/clams/#{id}/events.json"
    dataType: "json"
    async: false
    error: ->
      alert("error")
  res.responseJSON

changeFixed = (clickedClam) ->
  clickedClam.removeClass("fixed")
  clickedClam.css("font-weight","normal")

  data = {
    clam:
      fixed: true
    }

  $ . ajax
    type: 'PUT'
    url: "/clams/#{clickedClam.attr("data-id")}"
    data: data
    dataType: 'json'
    async: false
    timeout: 9000
    error: ->
      alert("error")

showPopover = (clickedClam) ->
  createPopover(clickedClam)
  clickedClam.find(".suggest-icon").focus()

createPopover = (clickedClam) ->
  id = clickedClam.attr("data-id")
  parent_id = getParentClam(id).id
  event_name = getEventOfRelatedClam(parent_id)[0].summary

  content = """
    「#{event_name}」というタスクを<br>
    登録してはどうでしょうか？<br>
    <div align="right"><a href="#">今後表示しない</a></div>
  """

  $(".suggest-icon").popover({
    html: 'true'
    trigger: 'focus'
    placement: 'bottom'
    content: content
  })

changeRelatedEventColor = (eventId) ->
  event = $('#calendar').fullCalendar('clientEvents', eventId)[0]
  event.color = "#ffaaaa"
  $('#calendar').fullCalendar('refetchEvents')
  $('#calendar').fullCalendar('gotoDate', event.start)
  setTimeout ->
    $('#calendar').fullCalendar('updateEvent', event)
  , 200

ready = ->
  initDraggableClam()
  $('.mini-calendar').hide()
  $('.calendar-icon').click ->
    displayCalendar()
  $('.missions-icon').click ->
    displayMissions()
  $('#submit-button').click ->
    submitEvent()
  $('.show-clam').click ->
    clam = $(this).parent()
    showBodyColumns(clam)
    if clam.hasClass("fixed")
      changeFixed(clam)
    showPopover(clam) if clam.find('.suggest-icon').size()
  $(this).on 'click','.show-related-task', ->
    $('.calendar-icon').trigger('click')
    changeRelatedEventColor($(this).attr('task-id'))

$(document).ready(ready)
$(document).on('page:load', ready)
