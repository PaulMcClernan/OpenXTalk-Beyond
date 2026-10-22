OXT-Beyond web IDE @VERSION@, to run on your own computer
=========================================================

This is the OXT-Beyond IDE in a web page: the real IDE, run by its own
engine built for the web. It runs on your computer and needs no
internet connection once unpacked.

Windows:   double-click "Start Web IDE.bat".
Mac/Linux: in a terminal in this folder, run  python3 serve.py

Your browser then opens http://localhost:8000/ (Chrome, Edge or
Firefox). The IDE unpacks itself the first time, which takes a little
while. Leave the window that runs the server open while you use the
IDE; close it (or press Ctrl+C) to stop. To use another port, run
python3 serve.py 8080.

Needs Python 3 (python.org, or the Microsoft Store on Windows).

To put it on a web site instead: copy every file of this folder to the
server (serve.py and the .bat are not needed there) and serve .wasm as
application/wasm. A browser does not run it from a file: address, so
opening index.html by double-clicking it does not work.

Stacks you save are kept in the browser's storage, per address (so
http://localhost:8000/ has its own). File > Download Stack gives you a
copy of a stack's file, and File > Open Stack opens one from your
computer.

Built from @SOURCE_URL@
(tools/web-ide/README.md there says what the web IDE can and cannot do).
