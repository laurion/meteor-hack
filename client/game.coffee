# Front-end file
# Read more here : http://docs.meteor.com/#structuringyourapp
# 
# 
# 
# 
# 
# 
# 
#  
#
#




#////
#//// Utility functions
#////
player = ->
  Players.findOne Session.get("player_id")

game = ->
  
  # console.log("game():");
  me = player()
  
  # console.log(me);
  # if(me) console.log(me.game_id);
  # if(me) console.log(Games.findOne(me.game_id));
  # console.log("--game()");
  me and me.game_id and Games.findOne(me.game_id)


#////
#//// lobby template: shows random code to share, and
#//// offers a button to start a fresh game.
#////
Template.lobby.show = ->
  
  # only show lobby if we're not in a game
  # console.log("start_game: " + game());
  not game()

Template.lobby.waiting = ->
  players = Players.find(
    _id:
      $ne: Session.get("player_id")

    name:
      $ne: ""

    game_id:
      $exists: false
  )
  players

Template.lobby.count = ->
  players = Players.find(
    _id:
      $ne: Session.get("player_id")

    name:
      $ne: ""

    game_id:
      $exists: false
  )
  players.count()
Template.lobby.disabled = ->
  me = player()
  return ""  if me and me.name
  "disabled=\"disabled\""

Template.lobby.events
  "keyup input#myname": (evt) ->
    name = $("#lobby input#myname").val().trim()
    Session.set "player_name", name
    console.log Session.get("player_id")
    Players.update Session.get("player_id"),
      $set:
        name: name


  "click button.startgame": ->
    
    # console.log("Should start new game");
    Meteor.call "start_new_game"


# console.log("did it start new game?")

#////
#//// board template: renders the board and the clock given the
#//// current game.
#////
Template.board.element = ->
  Games.findOne player().game_id  if player() and player().game_id

Template.board.show = ->
  !!game()

Template.cssFront.screen = ->
  scren = new Object()
  scren.w = $(document.body).width() / 20
  scren.h = ($(document).height() - 200) / 25
  scren

Template.board.score = ->
  Session.get "player_score"

Template.board.player_name = ->
  Session.get "player_name"

clicked = (event) ->
  
  #console.log(this);
  # console.log(Session.get('player_id'));
  item = Games.findOne(player().game_id)
  
  # console.log(player().game_id);
  if item.board[@i][@j].color is "grey"
    console.log item
    score = Session.get("player_score") + 1
    if item and item.board
      item.board[@i][@j].color = Session.get("color") #player().color;
      console.log item.board[@i][@j]
      Games.update player().game_id,
        board: item.board

    Session.set "player_score", score

Template.board.events
  "mousedown td": clicked
  "touchstart td": clicked

Meteor.startup ->
  
  # Allocate a new player id.
  #
  # XXX this does not handle hot reload. In the reload case,
  # Session.get('player_id') will return a real id. We should check for
  # a pre-existing player, and if it exists, make sure the server still
  # knows about us.
  player_id = Players.insert(
    name: ""
    idle: false
  )
  console.log "player_id: " + player_id
  Session.set "player_score", 0
  Session.set "player_id", player_id
  Session.set "color", get_random_color()
  Session.set "player_name", "None"
  Deps.autorun ->
    Meteor.subscribe "players"
    if Session.get("player_id")
      me = player()
      console.log "me: " + me
      Meteor.subscribe "colors" , "white"
      if me and me.game_id
        console.log "me.game_id: " + me.game_id
        Meteor.subscribe "games", me.game_id

  
  # Meteor.subscribe('items', me.game_id, Session.get('player_id'));
  
  # send keepalives so the server can tell when we go away.
  #
  # XXX this is not a great idiom. meteor server does not yet have a
  # way to expose connection status to user code. Once it does, this
  # code can go away.
  Meteor.setInterval (->
    Meteor.call "keepalive", Session.get("player_id")  if Meteor.status().connected
  ), 20 * 1000

  Meteor.setInterval (->
    Meteor.call "keepalive", Session.get("color")  if Meteor.status().connected
  ), 20 * 1000

#Meteor.subscribe("items");
