# class Participant(
#   id,
#   displayIndex,
#   hasMicrophone,
#   hasCamera,
#   hasAppEnabled,
#   isBroadcaster,
#   isInBroadcast,
#   locale,
#   person,
#   person.id,
#   person.displayName,
#   person.image,
#   person.image.url )

class Lo5
  queue = []

  constructor: ->
    @setupHangoutEvents()

  setupHangoutEvents: ->

    # onApiReady
    gapi.hangout.onApiReady.add (event) =>
      ####################################
      @clearState() # THIS IS FOR DEV ONLY
      ####################################

      window.main.setUser @getUserData([gapi.hangout.getLocalParticipant()])[0]
      participants = gapi.hangout.getParticipants()
      console.log "onApiReady", participants
      window.main.addUsers @getUserData(participants)

    # onParticipantsAdded
    gapi.hangout.onParticipantsAdded.add (event) =>
      console.log "onParticipantsAdded", event.addedParticipants
      window.main.addUsers @getUserData(event.addedParticipants)

    # onParticipantsRemoved
    gapi.hangout.onParticipantsRemoved.add (event) =>
      console.log "onParticipantsRemoved", event.removedParticipants
      window.main.removeUsers @getUserData(event.removedParticipants)

    # onStateChanged
    gapi.hangout.data.onStateChanged.add (event) =>
      console.log "onStateChanged", event.state
      window.main.updateState event.state

    # onMessageReveived
    gapi.hangout.data.onMessageReceived.add (event) =>
      console.log "onMessageReceived", event
      console.log "getParticipantById", @getMessageData(event)
      window.main.addMessage(@getMessageData(event))

  # THIS IS FOR DEV ONLY
  clearState: ->
    keys = gapi.hangout.data.getKeys()
    for key in keys
      gapi.hangout.data.clearValue(key)

  getMessageData: (event) ->
    # sid = data["sid"]
    # msg = @toLink(data["data"])
    # who = @getAvatar(sid)

    # # data{sid: sid, name: dude, data: msg}
    p = gapi.hangout.getParticipantById(event.senderId).person
    return msg =
      sid: p.id
      name: p.person.displayName
      data: event.message


  getUserData: (persons) ->
    data = persons.map (p) ->
      sid: p.id
      name: p.person.displayName
      image: p.person.image.url
    return data

  sendState: (sid, state) ->
    gapi.hangout.data.setValue("#{sid}", "#{state}")

  sendMessage: (name, msg) ->
    gapi.hangout.data.sendMessage("#{name}", "#{msg}")

  addUser: (user) ->
    @queueMessage("add-user", user)

  removeUser: (user) ->
    @queueMessage("remove-user", user)

  queueMessage: (event, data) ->
    item = JSON.stringify("event": event, "data": data)
    console.log "queueMessage:On", item
    gapi.hangout.data.sendMessage item

  releaseQueue: ->
    for item in queue
      @ws.send item

    

  $ -> window.lo5 = new Lo5()