# g

Switch between branches like a boss!

![](http://i.giphy.com/3o85xIvZUggpli4WPu.gif)

Inspired by TJ's [n](https://github.com/tj/n).

## Installation

### Linux

    $ npm install -g g-cli

or

    $ make install
    
to `$HOME`.

    $ PREFIX=$HOME make install

### Windows

Copy `g.bat` to `C:\Windows\System32` or any other directory within `PATH` variable.

### Switching branches

Type `g` to prompt selection of a local git branch. Use the `W` to go up, `S` to go down, `D` to select and `A` to cancel:

    $ g

      master
    ο develop

On Linux you can also use arrow keys, `space` or `enter` to submit, `escape` or `q` to exit.

## Usage

 Output from `g --help`:

    Usage: g [options] [COMMAND]

    Commands:
  
      g               Output local branches installed
  
    Options:
  
      -v, --version   Output current version of g
      -h, --help      Display help information
      -r, --remote    Create local branch from remote

## License

(The MIT License)

Copyright (c) 2014 Roman Paradeev &lt;sameoldmadness@gmail.com&gt;

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
