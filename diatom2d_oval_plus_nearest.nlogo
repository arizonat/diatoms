globals [
  ;; distance of the farthest green patch from the center
  radius
  sdv_a
  sdv_b
  stv_ang
  all_angs
  ep_type ;; 0 ellipse, 1 diamond
]

to setup
  clear-all
  setup-stv
  setup-epitheca
  setup-sdv
  setup-raphe
  reset-ticks
end

to setup-diamond
  clear-all
  setup-stv
  setup-epitheca-diamond
  setup-sdv
  setup-raphe
  reset-ticks
end

to setup-triangle
  clear-all
  setup-stv
  setup-epitheca-triangle
  setup-sdv
  setup-raphe
  reset-ticks
end

to setup-sdv
  ;;set sdv_a raphe_len + sdv_raphe_offset
  ;;let d ep_a - sdv_a
  ;;set sdv_b ep_b - d

  set sdv_a sdv0_a
  set sdv_b sdv0_b

  foreach stv_ang [ang ->
    ;;let rad (sa * sb) / sqrt ((sa * cos ang) ^ 2 + (sb * sin ang) ^ 2)
    let rad ellipse-rad sdv_a sdv_b ang
    let ep_x rad * cos(ang)
    let ep_y rad * sin(ang)
    ask patch ep_x ep_y [set pcolor magenta]
  ]
end

to setup-epitheca
  ;; set via slider
  set ep_type 0

  foreach all_angs [ang ->
    ;;let rad (ea * eb) / sqrt ((ea * cos ang) ^ 2 + (eb * sin ang) ^ 2)
    let rad ellipse-rad ep_a ep_b ang
    let ep_x rad * cos(ang)
    let ep_y rad * sin(ang)
    ask patch ep_x ep_y [set pcolor yellow]
  ]
end

to setup-epitheca-diamond
  set ep_type 1
  foreach all_angs [ang ->
    let rad diamond-rad ep_a ang
    let ep_x rad * cos(ang)
    let ep_y rad * sin(ang)
    ask patch ep_x ep_y [set pcolor yellow]
  ]
end

to setup-epitheca-triangle
  set ep_type 2
  foreach all_angs [ang ->
    let rad tri-rad ep_a ang
    let ep_x rad * cos(ang)
    let ep_y rad * sin(ang)
    ask patch ep_x ep_y [set pcolor yellow]
  ]
end

to-report tri-rad [a ang]
  ;; from https://math.stackexchange.com/questions/123548/explain-triangle-perimeter-in-polar-coordinates
  set ang (ang * pi / 180)
  let tp (2 * pi)
  report a / cos((2 * pi / 3 * (3 * ang / (2 * pi) - floor(3 * ang / (2 * pi))) - pi / 3) * 180 / pi)
end

to-report diamond-rad [a ang]
  report a / (abs(sin ang) + abs(cos ang))
end

to-report ellipse-rad [a b ang]
  ;; assumes ellipse centered at origin
  report (a * b) / sqrt ((a * cos ang) ^ 2 + (b * sin ang) ^ 2)
end

to-report in-ellipse? [a b x y]
  ;; TODO make this more efficient
  let rad sqrt (x ^ 2 + y ^ 2)
  let ang atan y x
  report (ellipse-rad a b ang) > rad
end

to-report in-diamond? [a x y]
  let rad sqrt (x ^ 2 + y ^ 2)
  let ang atan y x
  report (diamond-rad a ang) > rad
end

to-report in-triangle? [a x y]
  let rad sqrt (x ^ 2 + y ^ 2)
  let ang atan y x
  report (tri-rad a ang) > rad
end

to-report ep-rad [a b ang]
  if ep_type = 0
  [report ellipse-rad a b ang]

  if ep_type = 1
  [report diamond-rad a ang]

  if ep_type = 2
  [report tri-rad a ang]
end

to-report in-ep? [a b x y]
  if ep_type = 0
  [report in-ellipse? a b x y]

  if ep_type = 1
  [report in-diamond? a x y]

  if ep_type = 2
  [report in-triangle? a x y]
end

to setup-raphe-circle
  ask patches with [pcolor = blue]
  [set pcolor black]

  ask patches with [distancexy 0 0 < raphe_len]
  [set pcolor blue]
end

to setup-raphe-tristar
  ask patches with [pcolor = blue]
  [set pcolor black]

  ask patches with [pycor = 0 and pxcor > 0 and pxcor < raphe_len]
  [set pcolor blue]

  let r 0
  repeat raphe_len
  [
    ask patch 0 0[
    ask patch-at-heading-and-distance -30 r [set pcolor blue]
    ask patch-at-heading-and-distance -150 r [set pcolor blue]
    ]
    set r r + 1
  ]
end

to setup-raphe
  let len raphe_len
  ask patches with [pxcor = 0 and pycor > -1 * len and pycor < len]
  [ set pcolor blue]
end

to setup-stv
  ;;set stv_ang [0 36 72 108 144 180 216 252 288 324 90 270]

  set stv_ang []
  let ang_inc 360 / num_stv
  let i 0
  while [i < 360]
  [
    set stv_ang lput i stv_ang
    set i i + ang_inc
  ]

  set all_angs []
  set i 0
  repeat 360 [
    set all_angs lput i all_angs
    set i i + 1
  ]
end

to bump-stvs
  let ang_inc (360 / num_stv) / 2

  set stv_ang map [ x -> (x + ang_inc) mod 360 ] stv_ang
end

to add-stvs
  ;;let ang_inc (360 / num_stv) / 2
  let ang_inc 5

  set stv_ang map [ x -> (x - ang_inc) mod 360 ] stv_ang

  foreach stv_ang[ang ->
    set stv_ang lput ((ang + 2 * ang_inc) mod 360) stv_ang
  ]
  set num_stv 2 * num_stv
end

to grow-sdv

  ;;if sdv_a = ep_a and sdv_b = ep_b
  ;;[stop]

  ;;if sdv_a < ep_a
  ;;[set sdv_a sdv_a + sdv_grow_rate]

  ;;if sdv_b < ep_b
  ;;[set sdv_b sdv_b + sdv_grow_rate]

  ;;if not in-ep? ep_a ep_b 0 sdv_a and not in-ep? ep_a ep_b sdv_b 0
  ;;[stop]

  ;;if in-ep? ep_a ep_b 0 sdv_a
  ;;[set sdv_a sdv_a + sdv_grow_rate]

  ;;if in-ep? ep_a ep_b sdv_b 0
  ;;[set sdv_b sdv_b + sdv_grow_rate]

  let containment map [ang -> (ep-rad ep_a ep_b ang) > (ellipse-rad sdv_a sdv_b ang)] stv_ang
  if member? true containment
  [set sdv_a sdv_a + sdv_grow_rate
  set sdv_b sdv_b + sdv_grow_rate]

  ask patches with [pcolor = magenta]
  [set pcolor black]

  foreach stv_ang [ang ->
    ;;let rad (sa * sb) / sqrt ((sa * cos ang) ^ 2 + (sb * sin ang) ^ 2)
    let rad ellipse-rad sdv_a sdv_b ang
    let ep_x rad * cos(ang)
    let ep_y rad * sin(ang)
    ask patch ep_x ep_y [set pcolor magenta]
  ]
end

to go
  ;; stop when we get near the edge of the world
  if radius >= max-pxcor - 3
    [ stop ]
  ;; make new turtles, up to a maximum controlled by the MAX-PARTICLES
  ;; slider; also check clock so we don't make too many turtles too
  ;; soon, otherwise we get a big green clump at the center (only happens
  ;; USE-WHOLE-WORLD? is false)

  ;;while [count turtles < max-particles and
  ;;       count turtles < ticks]
  ;;  [ make-new-turtle ]

  foreach stv_ang [ang ->
    if random-float 1 < stv-chance-to-release
    [
      make-new-turtle-at ang
    ]
  ]

  ;; now move the turtles
  ask turtles
    [ wander
      if any? neighbors with [pcolor = green or pcolor = blue]
        [ set pcolor green
          ;; increase radius if appropriate
          ;;if distancexy 0 0 > radius
          ;;  [ set radius distancexy 0 0 ]
          ;;die ]
          if not in-ellipse? (sdv_a - 1) (sdv_b - 1) xcor ycor
          [grow-sdv]
         die
      ]
      ;; kill turtles that wander too far away from the center
      ;;if not use-whole-world? and distancexy 0 0 > radius + 3
      if not use-whole-world? and not in-ep? (sdv_a + 2) (sdv_b + 2) xcor ycor
        [ die ] ]

  ;; advance clock
  tick
end

to make-new-turtle-at [ang]
    create-turtles 1
    [ set color red
      set size 3  ;; easier to see
      setxy 0 0

      set heading (ang) + 90
      ;; set heading one-of [22.5 45 67.5 90 112.5 135 157.5 180 202.5 225 247.5 270 292.5 315 337.5 360]
      let rad ellipse-rad sdv_a sdv_b ang
      let ep_rad ep-rad ep_a ep_b ang
      set rad min list ep_rad rad

      ifelse use-whole-world?
        [ jump max-pxcor ]
        [ jump rad ]

      let target-patch min-one-of (patches with [pcolor = blue and pxcor = 0]) [distance myself]
      ifelse point-at-raphe?
      [face target-patch
       set heading (heading + angle_towards_center * (towards patch 0 0 - heading))
      ]
      [rt 180]
  ]
end

to make-new-turtle
  ;; each new turtle starts its random walk from a position
  ;; a bit outside the current radius and facing the center
  create-turtles 1
    [ set color red
      set size 3  ;; easier to see
      setxy 0 0

      ;;ifelse radius > 20
      ;;[      set heading one-of [0 36 72 108 144 180 216 252 288 324]]
      ;;[      set heading one-of [20 56 92 128 164 200 236 272 308 344]]

      let ang one-of stv_ang
      set heading (ang) + 90
      ;; set heading one-of [22.5 45 67.5 90 112.5 135 157.5 180 202.5 225 247.5 270 292.5 315 337.5 360]
      let rad ellipse-rad sdv_a sdv_b ang
      let ep_rad ep-rad ep_a ep_b ang
      set rad min list ep_rad rad

      ifelse use-whole-world?
        [ jump max-pxcor ]
        [ jump rad ]

      let target-patch min-one-of (patches with [pcolor = blue and pxcor = 0]) [distance myself]
      ifelse point-at-raphe?
      [face target-patch
       set heading (heading + angle_towards_center * (towards patch 0 0 - heading))
      ]
      [rt 180]
  ]
end

to wander   ;; turtle procedure
  ;; the WIGGLE-ANGLE slider makes our path straight or wiggly
  rt random-float wiggle-angle - random-float wiggle-angle
  ;; kill off particles that reach the edge
  if not can-move? 1 [ die ]
  ;; move
  fd 1
end

to save
  ;; use file-write just for easy file-read, though it's not a very robust file format
  file-open "patches.txt"
  file-write radius
  ask patches
  [
    if pcolor = green
    [
      file-write pxcor file-write pycor
    ]
  ]
  file-close
end
; Copyright 1997 Uri Wilensky.
; See Info tab for full copyright and license.
@#$#@#$#@
GRAPHICS-WINDOW
485
46
794
356
-1
-1
1.5
1
10
1
1
1
0
1
1
1
-100
100
-100
100
1
1
1
ticks
30.0

SLIDER
920
47
1092
80
max-particles
max-particles
0
300
48.0
1
1
NIL
HORIZONTAL

SWITCH
24
320
176
353
use-whole-world?
use-whole-world?
1
1
-1000

SLIDER
28
165
200
198
wiggle-angle
wiggle-angle
0
360
8.0
1
1
NIL
HORIZONTAL

BUTTON
27
41
90
74
NIL
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
108
42
171
75
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

BUTTON
191
42
254
75
NIL
save
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
212
166
384
199
raphe_len
raphe_len
0
100
1.0
1
1
NIL
HORIZONTAL

SLIDER
213
208
385
241
ep_a
ep_a
0
150
50.0
1
1
NIL
HORIZONTAL

SLIDER
213
250
385
283
ep_b
ep_b
0
150
50.0
1
1
NIL
HORIZONTAL

SLIDER
921
86
1093
119
sdv_raphe_offset
sdv_raphe_offset
0
100
2.0
1
1
NIL
HORIZONTAL

SLIDER
214
380
386
413
num_stv
num_stv
0
360
24.0
1
1
NIL
HORIZONTAL

SLIDER
213
292
385
325
sdv0_a
sdv0_a
0
100
5.0
1
1
NIL
HORIZONTAL

SLIDER
214
335
386
368
sdv0_b
sdv0_b
0
100
5.0
1
1
NIL
HORIZONTAL

SWITCH
26
365
168
398
point-at-raphe?
point-at-raphe?
0
1
-1000

SLIDER
215
424
387
457
sdv_grow_rate
sdv_grow_rate
0
50
1.0
1
1
NIL
HORIZONTAL

BUTTON
271
43
360
76
NIL
bump-stvs
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
375
43
455
76
NIL
add-stvs
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
28
404
205
437
angle_towards_center
angle_towards_center
-1.0
1.0
0.0
.1
1
NIL
HORIZONTAL

BUTTON
27
88
140
121
NIL
setup-diamond
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
28
126
137
159
NIL
setup-triangle
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
160
86
292
119
NIL
setup-raphe-circle
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
160
125
298
158
NIL
setup-raphe-tristar
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
919
26
1069
44
These are no longer used
11
0.0
1

SLIDER
31
217
208
250
stv-chance-to-release
stv-chance-to-release
0
1
0.85
0.05
1
NIL
HORIZONTAL

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
NetLogo 6.0.2
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
