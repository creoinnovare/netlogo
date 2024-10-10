;; Battle of Scarif Simulation Model
;; Compatible with NetLogo 6.4
;; At the top, declare turtles-own variables
;; correlation between introducing cyber resiliency as one might think about bayesian requirements
turtles-own [
  shield-gate?   ;; True for the shield gate turtle
  role
  health
  ship-type
]

agents-own [
  risk-aversion       ; R, fixed for the agent's lifetime, ranging from 0-1 (inclusive)
  perceived-hardship  ; H, also ranging from 0-1 (inclusive)
  active?             ; if true, then the agent is actively rebelling
  jail-term           ; how many turns in jail remain? (if 0, the agent is not in jail)
]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Global Variables and Setup
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

globals [
  k                           ;; zz - factor for determining arrest probablilty
  threshold                   ;; zz - by how much must G > N to make someone rebel

  time                        ;; Simulation time
  battle-over?                ;; Flag to end simulation
  shield-gate-status          ;; Status of the Shield Gate

  weather                     ;; Current weather condition
  target-agent
  equipment-failure-alpha     ;; Alpha parameter for Beta prior
  equipment-failure-beta      ;; Beta parameter for Beta prior
]

;; Breeds represent different agent types
breed [agents is-agent]     ;; zz -
breed [cops cop]            ;; zz -

breed [rebels rebel]
breed [imperials imperial]
breed [ships ship]
breed [troopers trooper]  ;; Not used in this version but can be expanded
breed [projectiles projectile]

rebels-own [
  role          ;; Role of the rebel (e.g., infantry, specialist)
  health        ;; Health status
  ship-type     ;; Type of ship (for ships)
]

imperials-own [
  role          ;; Role of the imperial (e.g., trooper)
  health        ;; Health status
  ship-type     ;; Type of ship (for ships)
]

ships-own [
  ship-type     ;; Type of ship (e.g., fighter, bomber)
]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Control Factors (Adjustable via Interface)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; The following variables should be set up as sliders and choosers in the NetLogo Interface:

;; Sliders:
;; rebel-ground-troop-numbers (Range: 50 to 200)
;; rebel-spacecraft-numbers (Range: 10 to 50)
;; imperial-troop-deployment (Range: 100 to 300)
;; imperial-spacecraft-deployment (Range: 20 to 60)
;; timing-of-ground-and-space-assaults (Range: 0 to 60)
;; reinforcements-arrival-time (Range: 10 to 45)

;; Choosers:
;; rebel-ground-force-composition (Options: "Infantry Only", "Infantry + Specialists", "Mixed Units")
;; rebel-spacecraft-types (Options: "Fighters Only", "Bombers Only", "Mixed Fleet", "Includes Capital Ships")
;; rebel-tactical-strategies (Options: "Stealth Infiltration", "Full Frontal Assault", "Diversionary Tactics")
;; shield-gate-operational-status (Options: "Fully Operational", "Reduced Efficiency", "Vulnerable")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Setup Procedures
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to setup
  clear-all

  set equipment-failure-alpha 3      ;; Prior successes (failures + 1)
  set equipment-failure-beta 19      ;; Prior failures (non-failures + 1)  equipment-failure-alpha     ;; Alpha parameter for Beta prior

  set-default-shape rebels "person"
  set-default-shape imperials "person"
  set-default-shape ships "airplane"
  set-default-shape projectiles "circle"

  setup-environment
  set time 0
  set battle-over? false
  set weather one-of ["Clear" "Overcast" "Rainy" "Foggy" "Stormy"]
  setup-shield-gate
  setup-imperials
  setup-rebels

  reset-ticks
end

to setup-environment
  ;; Set up terrain (land and water patches)
  ask patches [
    ifelse pycor < 0
    [ set pcolor blue ] ;; Water
    [ set pcolor green ] ;; Land
  ]
end

;; Define the setup-shield-gate procedure
to setup-shield-gate
  ;; Initialize the shield gate status
  set shield-gate-status shield-gate-operational-status

  ;; Create the shield gate turtle
  create-turtles 1 [
    set shield-gate? true
    set color cyan
    set shape "circle"
    set size 5
    setxy 0 (max-pycor - 2)
    set heading 180
    set label "Shield Gate"
    set label-color black
    hide-turtle  ;; Hide if you don't want it visible
  ]
end

to setup-imperials
  ;; Create Imperial ground troops
  create-imperials imperial-troop-deployment [
    set color gray + 2
    set shape "person"
    setxy random-xcor (max-pycor - 5)
    set role "trooper"
    set health 100
  ]

  ;; Create Imperial ships
  create-ships imperial-spacecraft-deployment [
    set breed imperials
    set color gray
    set shape "airplane"
    setxy random-xcor (max-pycor + 5)
    set heading 180
    set ship-type "tie-fighter"
    set health 100
  ]
end

to setup-rebels
  ;; Create Rebel ground troops based on control factors
  create-rebels rebel-ground-troop-numbers [
    set color red
    set shape "person"
    setxy random-xcor (min-pycor + 5)
    assign-rebel-role
    set health 100
  ]

  ;; Schedule space assault based on timing
  if timing-of-ground-and-space-assaults = 0 [
    setup-rebel-ships
  ]
  if timing-of-ground-and-space-assaults > 0 [
    ;;schedule [ setup-rebel-ships ] timing-of-ground-and-space-assaults
  ]
end


to assign-rebel-role
  ;; Assign roles based on Rebel Ground Force Composition
  if rebel-ground-force-composition = "Infantry Only" [
    set role "infantry"
  ]
  if rebel-ground-force-composition = "Infantry + Specialists" [
    set role one-of ["infantry" "specialist"]
  ]
  if rebel-ground-force-composition = "Mixed Units" [
    set role one-of ["infantry" "specialist" "heavy"]
  ]
end

to setup-rebel-ships
  ;; Create Rebel ships based on spacecraft numbers and types
  create-ships rebel-spacecraft-numbers [
    set breed rebels
    set color red
    set shape "airplane"
    setxy random-xcor (min-pycor - 5)
    set heading 0
    assign-rebel-ship-type
    set health 100
  ]
end

to assign-rebel-ship-type
  ;; Assign ship types
  if rebel-spacecraft-types = "Fighters Only" [
    set ship-type "fighter"
  ]
  if rebel-spacecraft-types = "Bombers Only" [
    set ship-type "bomber"
  ]
  if rebel-spacecraft-types = "Mixed Fleet" [
    set ship-type one-of ["fighter" "bomber" "transport"]
  ]
  if rebel-spacecraft-types = "Includes Capital Ships" [
    set ship-type one-of ["fighter" "bomber" "transport" "capital"]
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Main Simulation Loop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to go
  if battle-over? [ stop ]

  set time time + 1

  ;; Handle reinforcements
  if time = reinforcements-arrival-time [
    call-reinforcements
  ]

  ;; Agents perform actions
  rebels-act
  imperials-act
  move-projectiles

  ;; Check for battle end conditions
  check-battle-over

  tick
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Agent Actions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Modify rebels-act to include attempt to disable shield gate
to rebels-act
  ask rebels [
    ifelse member? self ships [
      rebel-ship-actions
    ]
    [ rebel-ground-actions ]  ;;
    ]
  ;;]
  ;; Rebels attempt to disable the shield gate
  if shield-gate-status != "Destroyed" [
    attempt-disable-shield-gate
  ]
end

to attempt-disable-shield-gate
  ask rebels with [ breed != ships ] [
    if distancexy 0 (max-pycor - 2) < 5 [
      if shield-gate-status = "Vulnerable" [
        ;; Successful attempt
        set shield-gate-status "Destroyed"
        user-message "Rebels have disabled the Shield Gate!"
      ]
      ;;else [
        ;; Unsuccessful attempt; perhaps decrement shield gate's health
      ;;]
    ]
  ]
end

to rebel-ground-actions
  ;; Implement movement and combat based on tactical strategies
  if rebel-tactical-strategies = "Stealth Infiltration" [
    stealth-move
  ]
  if rebel-tactical-strategies = "Full Frontal Assault" [
    attack-move
  ]
  if rebel-tactical-strategies = "Diversionary Tactics" [
    diversion-move
  ]

  ;; Engage in combat if in range
  engage-combat imperials
end

to rebel-ship-actions
  ;; Ships move and engage in space combat
  fly-forward
  engage-combat imperials
end

to imperials-act
  ask imperials [
    ifelse member? self ships [
      imperial-ship-actions
    ]
    [ imperial-ground-actions ]
    ;;else [
    ;;  imperial-ground-actions
    ;;]
  ]
end

to imperial-ground-actions
  ;; Imperial troops patrol or defend
  imperial-patrol
  ;; Engage rebels if in range
  engage-combat rebels
end

to imperial-ship-actions
  ;; Imperial ships patrol and engage
  fly-forward
  engage-combat rebels
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Movement and Combat Procedures
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to stealth-move
  ;; Rebels move cautiously to avoid detection
  rt random-float 20 - 10
  fd 0.5
end

to attack-move
  ;; Rebels advance aggressively
  rt random-float 40 - 20
  fd 1.5
end

to diversion-move
  ;; Rebels create diversions
  if random 100 < 50 [
    set heading random 360
  ]
  fd 1
end

to imperial-patrol
  ;; Imperials patrol the area
  rt random-float 30 - 15
  fd 1
end

to fly-forward
  ;; Ships move forward
  fd 2
end

to engage-combat [enemy-breed]
  ;; Generic combat procedure
  let target one-of enemy-breed in-cone 5 60
  if target != nobody [
    fire-at target
  ]
end

to fire-at [target]
  ;; Create a projectile towards the target
  hatch-projectiles 1 [
    set color yellow
    set size 0.5
    set shape "circle"
    set heading towards target
    set target-agent target
  ]
end

to move-projectiles
  ask projectiles [
    fd 3
    if distance target-agent < 1 [
      ;; Inflict damage
      ask target-agent [
        set health health - 20
        if health <= 0 [ die ]
      ]
      die  ;; Projectile disappears
    ]
    ;; Remove projectile if it goes off-screen
    if not can-move? 1 [
      die
    ]
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Reinforcements and Shield Gate
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to call-reinforcements
  ;; Bring in Imperial reinforcements
  create-imperials imperial-troop-deployment [
    set color gray + 2
    set shape "person"
    setxy random-xcor (max-pycor - 5)
    set role "trooper"
    set health 100
  ]

  ;; Optionally, bring in Rebel reinforcements
  ;; create-rebels rebel-ground-troop-numbers [...]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Battle End Conditions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Update check-battle-over to include shield gate status
to check-battle-over
  if shield-gate-status = "Destroyed" and not battle-over? [
    set battle-over? true
    user-message "Rebels have won by disabling the Shield Gate!"
  ]

  ;; Existing conditions...
  if not any? rebels and any? imperials [
    set battle-over? true
    user-message "Imperial forces have won the battle."
  ]
  if any? rebels and not any? imperials [
    set battle-over? true
    user-message "Rebel forces have won the battle."
  ]
  if not any? rebels and not any? imperials [
    set battle-over? true
    user-message "The battle ended in a draw."
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Utility Procedures
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; extensions [time]

to schedule [task time-offset]
  ;; Schedule a task to run after a time offset
  let scheduled-time time + time-offset
  run task
  ;; Note: In NetLogo, we need to implement our own scheduling mechanism or use the "timer" extension
end
@#$#@#$#@
GRAPHICS-WINDOW
613
52
1199
639
-1
-1
17.52
1
10
1
1
1
0
1
1
1
-16
16
-16
16
1
1
1
ticks
30.0

SLIDER
173
144
414
177
rebel-ground-troop-numbers
rebel-ground-troop-numbers
10
200
10.0
1
1
NIL
HORIZONTAL

CHOOSER
169
636
386
681
shield-gate-operational-status
shield-gate-operational-status
"Fully Operational" "Reduced Efficiency" "Vulnerable"
0

CHOOSER
169
581
343
626
rebel-tactical-strategies
rebel-tactical-strategies
"Stealth Infiltration" "Full Frontal Assault" "Diversionary Tactics"
2

CHOOSER
168
526
352
571
rebel-spacecraft-types
rebel-spacecraft-types
"Fighters Only" "Bombers Only" "Mixed Fleet" "Includes Capital Ships"
3

CHOOSER
164
475
396
520
rebel-ground-force-composition
rebel-ground-force-composition
"Infantry Only" "Infantry + Specialists" "Mixed Units"
2

SLIDER
172
186
390
219
rebel-spacecraft-numbers
rebel-spacecraft-numbers
10
300
10.0
1
1
NIL
HORIZONTAL

SLIDER
173
232
397
265
imperial-troop-deployment
imperial-troop-deployment
10
300
10.0
1
1
NIL
HORIZONTAL

SLIDER
170
280
424
313
imperial-spacecraft-deployment
imperial-spacecraft-deployment
20
60
20.0
1
1
NIL
HORIZONTAL

SLIDER
168
331
463
364
timing-of-ground-and-space-assaults
timing-of-ground-and-space-assaults
0
60
0.0
1
1
NIL
HORIZONTAL

SLIDER
168
380
395
413
reinforcements-arrival-time
reinforcements-arrival-time
10
45
30.0
1
1
NIL
HORIZONTAL

BUTTON
166
69
232
102
Setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
260
70
323
103
Go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.4.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
