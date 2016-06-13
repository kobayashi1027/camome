class window.HtmlFormatter
  constructor: (clam_type) ->
    type = clam_type.match(/^Resource::(.*)$/)

    unless type?
      alert("Error!! Invalid content_type: #{clam_type}")
      ## TODO: Return some object to show content_type error
    else
      try
        return new (eval(type[1] + "ClamConverter"))()
      catch e
        if e instanceof ReferenceError
          alert("Error!! Undefined class: #{type[1]}ClamConverter")
          ## TODO: Return some object to show className is invalid

class ClamConverter
  convert: (clam) =>
    """
    <tr class='clam-body' clam-id='#{clam.id}'>
      <td colspan='2'>
        #{@content(clam)}
      </td>
    </tr>
    """
  content: (clam) ->

class MailClamConverter extends ClamConverter
  content: (clam) ->
    source_clam = clam.reuse_source
    events = clam.events

    reuse_source =
      if source_clam?
        "再利用元のメール：<a href='#' class='show-reuse-source' source-id='#{source_clam.id}'>#{source_clam.summary}</a>"
      else ""

    related_tasks =
      if events.length
        buf = "関連するタスク："
        for event in events
          buf += "<a href='#' class='show-related-task' task-id='#{event.id}'>#{event.summary}</a>"
          buf += ", "
        buf.slice(0, -2)
      else ""

    reuse_link =
      "<a href='/mail/new?clam_id=#{clam.id}' class='btn btn-primary fa fa-repeat'></a>"

    content =
      """
      <div>
        <pre>
          <table>
            <tr><th>差出人</th><td>#{clam.options.originator}</td><td>#{reuse_link}</td></tr>
            <tr><th>件名</th><td>#{clam.summary}</td></tr>
            <tr><th>宛先</th><td>#{clam.options.recipients}</td></tr>
            <tr><td colspan='2'>#{clam.options.description}</td></tr>
          </table>
        </pre>
      </div>
      <div>
        #{reuse_source}
      </div>
      <div>
        #{related_tasks}
      </div>
      """
    return content

class SlackClamConverter extends ClamConverter
  content: (clam) ->
    """
    <pre>
      <h1 class='clam-body'>Hello Slack</h1>
    </pre>
    """

class EvernoteClamConverter extends ClamConverter
  content: (clam) ->
    """
    <pre>
      <h1 class='clam-body'>Hello Evernote</h1>
    </pre>
    """

class TogglClamConverter extends ClamConverter
  content: (clam) ->
    """
    <pre>
      <h1 class='clam-body'>Hello Toggl</h1>
    </pre>
    """

class EventClamConverter extends ClamConverter
  content: (clam) ->
    """
    <pre>
      <h1 class='clam-body'>Hello Event</h1>
    </pre>
    """

class DocumentClamConverter extends ClamConverter
  content: (clam) ->
    """
    <pre>
      <h1 class='clam-body'>Hello Document</h1>
    </pre>
    """
