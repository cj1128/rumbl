import Player from "./player"

const esc = str => {
  const div = document.createElement("div")
  div.appendChild(document.createTextNode(str))
  return div.innerHTML
}

const Video = {
  init(socket, element) {
    if(!element) return

    const playerID = element.getAttribute("data-player-id")
    const videoID = element.getAttribute("data-id")

    socket.connect()

    Player.init(element.id, playerID, () => {
      this.onReady(videoID, socket)
    })
  },

  onReady(videoID, socket) {
    const msgContainer = document.getElementById("msg-container")
    const msgInput = document.getElementById("msg-input")
    const postButton = document.getElementById("msg-submit")
    const vidChannel = socket.channel("videos:" + videoID)

    postButton.addEventListener("click", evt => {
      const payload = {
        body: msgInput.value,
        at: Player.getCurrentTime(),
      }

      vidChannel
        .push("new_annotation", payload)
        .receive("error", console.log)
    })

    vidChannel.on("new_annotation", resp => {
      vidChannel.params.last_seen_id = resp.id
      this.renderAnnotation(msgContainer, resp)
    })

    msgContainer.addEventListener("click", e => {
      e.preventDefault()

      const seconds = e.target.getAttribute("data-seek") ||
        e.target.parentNode.getAttribute("data-seek")

      if(!seconds) return

        Player.seekTo(seconds)
    })

    vidChannel.join()
      .receive("ok", resp => {
        console.log("joined the video channel", resp)
        const ids = resp.annotations.map(ann => ann.id)
        if(ids.length > 0) {
          vidChannel.params.last_seen_id = Math.max(...ids)
        }
        this.scheduleMessages(msgContainer, resp.annotations)
      })
      .receive("error", reason => console.log("join failed", reason))
  },

  renderAnnotation(msgContainer, {user, body, at}) {
    const template = document.createElement("div")

    template.innerHTML = `
    <a href="#" data-seek="${ esc(at) }">
      [${this.formatTime(at)}]
      <b>${ esc(user.username) }</b>: ${ esc(body) }
    </a>
    `

    msgContainer.appendChild(template)
    msgContainer.scrollTop = msgContainer.scrollHeight
  },

  scheduleMessages(msgContainer, annotations) {
    setTimeout(() => {
      const ctime = Player.getCurrentTime()
      const remaining = this.renderAtTime(annotations, ctime, msgContainer)
      this.scheduleMessages(msgContainer, remaining)
    }, 1000)
  },

  renderAtTime(annotations, seconds, msgContainer) {
    return annotations.filter(ann => {
      if(ann.at > seconds) {
        return true
      } else {
        this.renderAnnotation(msgContainer, ann)
        return false
      }
    })
  },

  formatTime(at) {
    const date = new Date(0)
    date.setSeconds(at / 1000)
    return date.toISOString().substr(14, 5)
  },
}

export default Video
