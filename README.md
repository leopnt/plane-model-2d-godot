# Godot 2D Plane Model

This is the core project for my game

The model isn't intended to be 💯% accurate. I just made it coherent and playable 🤗


![main view](presentation_imgs/main_view.png)


## The diagrams that explain it all
They are inverted but you get the idea

![Aerodynamic forces diagram](https://upload.wikimedia.org/wikipedia/commons/d/d7/Lift-force-en.svg)

Note that aerodynamic forces apply on the center of lift where other ones apply on the center of mass. This is necessary for the plane stability: he will constantly try to align itself with his own velocity

In Godot, you can offset the point where you apply the force with ```apply_impulse(offset, force)```

Don't forget to rotate the offset! (That was my biggest mistake that took me a lot headaches 😌) ```apply_impulse(offset.rotated(rotation), force)``` Or the force will not apply at the right point. Of course, it has to follow the plane rotation...

![Center of pressure and center of mass](https://www.skybrary.aero/images/3/36/LiftDrag.png)


## CREDITS

### Font
 - CodeMan38 / Press Start 2P


## Link to the finished game
https://kahagino.itch.io/dunkirk-land-the-plane

## Godot License
This game uses Godot Engine, available under the following license:

Copyright (c) 2007-2020 Juan Linietsky, Ariel Manzur. Copyright (c) 2014-2020 Godot Engine contributors.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

Portions of this software are copyright © <year> The FreeType Project (www.freetype.org). All rights reserved.