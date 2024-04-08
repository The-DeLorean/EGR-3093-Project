main will contain all files the will be used in our PacMan project henceforth.

<h2>Some notes: </h2>

- `/impl` contains the constraints.
- `/rtl` contains all .vhd design sources.
- `/rtl/joystick` contains drivers for button debouncing, score counting, and username selection.
- `/rtl/seven-segment` contains the display driver and decoder, as well as a 1khz internal clock divider.
- `/rtl/graphics` contains VGA level graphics signals for game objects.
- `/rtl/graphics/hdmi` contains the VGA-to-HDMI converter files created by fcayci
-  `/rtl/game-logic/` contains movement logic for game objects.

I hope this helps us organize our contributions and enables our team to work on different facets of the project.




<h2> FPGA-based Videogame </h2>
Objective

    Present the proposal of a videogame implementation using the FPGA selected for this course

Instructions 

    Select an existing videogame (preferably classic) the team wishes to implement.
    Consider the interfacing options offered by the peripherals of your development board.
    Implementing additional circuitry is also accepted.
    The videogame implementation must be connected with each topic presented in this course: combinational logic, sequential logic circuits (flip-flops, counters, and data storage), binary arithmetic, and state machines. 
    The project will be developed in four stages, one per topic mentioned above.
    The game must have at least the following qualities:
        Real-time scorekeeping
        Username storage
        Human-machine interface (e.g., screen, LEDs, buttons, controller, etc.)
        Change of difficulty over time.

Recommendations

    Ensure that your project is feasible. Investigate the capabilities of your board or what others have achieved with similar FPGAs.
    Highlight how your proposal fulfills each requirement.
    Consider the possible users of your game as non-technical people.
    Do not limit yourself by the peripherals offered on your board or the topics covered in the course.

Presentation Outline

    Introduction
    Game Structure and Objective
    Development Plan
    Possible Challenges
